import os
from flask import Flask, request, render_template, jsonify
from flask_cors import CORS
from src.db import get_connection
from src.nhtsa import get_nhtsa_radar, get_nhtsa_wordcloud
from src.pipeline.predict_pipeline import CarData, PredictPipeline

application = Flask(__name__)
app = application
CORS(app)


# ---------------------------------------------------------------------------
# Pages
# ---------------------------------------------------------------------------

@app.route('/')
def index():
    return render_template('index.html')


# ---------------------------------------------------------------------------
# Search — return matching listings from SQL Server
# ---------------------------------------------------------------------------

@app.route('/api/search', methods=['GET'])
def search():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()
    state = request.args.get('state', '').strip()
    city = request.args.get('city', '').strip()

    filters = []
    params = []

    if manufacturer:
        filters.append("LOWER(Manufacturer) = LOWER(?)")
        params.append(manufacturer)
    if model:
        filters.append("LOWER(Model) LIKE LOWER(?)")
        params.append(f"%{model}%")
    if year:
        filters.append("Year = ?")
        params.append(int(year))
    if state:
        filters.append("LOWER(State) = LOWER(?)")
        params.append(state)
    if city:
        filters.append("LOWER(City) LIKE LOWER(?)")
        params.append(f"%{city}%")

    where = ("WHERE " + " AND ".join(filters)) if filters else ""
    query = f"""
        SELECT TOP 50
            Manufacturer, Model, Year, Price, Odometer,
            City, State, [title status], transmission,
            cylinders, drive, URL
        FROM [dbo].[Used_Cars_DF]
        {where}
        ORDER BY Date DESC
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        columns = [col[0] for col in cursor.description]
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
        conn.close()
        return jsonify({"status": "ok", "data": rows})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Price range stats
# ---------------------------------------------------------------------------

@app.route('/api/price-range', methods=['GET'])
def price_range():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()

    filters, params = _build_filters(manufacturer, model, year)
    where = ("WHERE " + " AND ".join(filters)) if filters else ""

    query = f"""
        SELECT
            AVG(CAST(Price AS FLOAT))  AS avg_price,
            MIN(Price)                  AS min_price,
            MAX(Price)                  AS max_price,
            AVG(CAST(Odometer AS FLOAT)) AS avg_odometer,
            COUNT(*)                    AS listing_count
        FROM [dbo].[Used_Cars_DF]
        {where}
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        row = cursor.fetchone()
        conn.close()
        if row and row[0] is not None:
            return jsonify({
                "status": "ok",
                "avg_price": round(row[0], 2),
                "min_price": row[1],
                "max_price": row[2],
                "avg_odometer": round(row[3], 0) if row[3] else None,
                "listing_count": row[4],
            })
        return jsonify({"status": "ok", "listing_count": 0})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Listing frequency by state (for bar chart / map)
# ---------------------------------------------------------------------------

@app.route('/api/listing-frequency', methods=['GET'])
def listing_frequency():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()

    filters, params = _build_filters(manufacturer, model, year)
    where = ("WHERE " + " AND ".join(filters)) if filters else ""

    query = f"""
        SELECT State, COUNT(*) AS listing_count
        FROM [dbo].[Used_Cars_DF]
        {where}
        GROUP BY State
        ORDER BY listing_count DESC
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        data = [{"state": row[0], "count": row[1]} for row in cursor.fetchall()]
        conn.close()
        return jsonify({"status": "ok", "data": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Condition vs price
# ---------------------------------------------------------------------------

@app.route('/api/condition-price', methods=['GET'])
def condition_price():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()

    filters, params = _build_filters(manufacturer, model, year)
    where = ("WHERE " + " AND ".join(filters)) if filters else ""

    query = f"""
        SELECT [title status], AVG(CAST(Price AS FLOAT)) AS avg_price, COUNT(*) AS cnt
        FROM [dbo].[Used_Cars_DF]
        {where}
        GROUP BY [title status]
        ORDER BY avg_price DESC
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        data = [{"condition": row[0], "avg_price": round(row[1], 2), "count": row[2]}
                for row in cursor.fetchall() if row[0]]
        conn.close()
        return jsonify({"status": "ok", "data": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Price trend / depreciation by year
# ---------------------------------------------------------------------------

@app.route('/api/price-trend', methods=['GET'])
def price_trend():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()

    filters = []
    params = []
    if manufacturer:
        filters.append("LOWER(Manufacturer) = LOWER(?)")
        params.append(manufacturer)
    if model:
        filters.append("LOWER(Model) LIKE LOWER(?)")
        params.append(f"%{model}%")
    filters.append("Year IS NOT NULL")
    filters.append("Price IS NOT NULL AND Price > 0")
    where = "WHERE " + " AND ".join(filters)

    query = f"""
        SELECT Year, AVG(CAST(Price AS FLOAT)) AS avg_price, COUNT(*) AS cnt
        FROM [dbo].[Used_Cars_DF]
        {where}
        GROUP BY Year
        ORDER BY Year ASC
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        data = [{"year": row[0], "avg_price": round(row[1], 2), "count": row[2]}
                for row in cursor.fetchall()]
        conn.close()
        return jsonify({"status": "ok", "data": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Similar car recommendations
# ---------------------------------------------------------------------------

@app.route('/api/similar-cars', methods=['GET'])
def similar_cars():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()
    target_price = request.args.get('price', '0').strip()

    try:
        target_price = float(target_price)
    except ValueError:
        target_price = 0

    params = []
    exclude_filters = []
    if manufacturer:
        exclude_filters.append("LOWER(Manufacturer) = LOWER(?)")
        params.append(manufacturer)
    if model:
        exclude_filters.append("LOWER(Model) LIKE LOWER(?)")
        params.append(f"%{model}%")

    price_clause = ""
    if target_price > 0:
        params.append(target_price * 0.7)
        params.append(target_price * 1.3)
        price_clause = "AND Price BETWEEN ? AND ?"

    where_parts = " AND ".join(exclude_filters) if exclude_filters else "1=1"
    query = f"""
        SELECT TOP 6
            Manufacturer, Model, Year, Price, Odometer,
            City, State, [title status], URL
        FROM [dbo].[Used_Cars_DF]
        WHERE ({where_parts}) {price_clause}
        ORDER BY NEWID()
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        columns = [col[0] for col in cursor.description]
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
        conn.close()
        return jsonify({"status": "ok", "data": rows})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# NHTSA radar chart (complaint categories)
# ---------------------------------------------------------------------------

@app.route('/api/nhtsa-radar', methods=['GET'])
def nhtsa_radar():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()
    try:
        data = get_nhtsa_radar(manufacturer, model, year if year else None)
        return jsonify({"status": "ok", "data": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# NHTSA word cloud
# ---------------------------------------------------------------------------

@app.route('/api/nhtsa-wordcloud', methods=['GET'])
def nhtsa_wordcloud():
    manufacturer = request.args.get('manufacturer', '').strip()
    model = request.args.get('model', '').strip()
    year = request.args.get('year', '').strip()
    try:
        data = get_nhtsa_wordcloud(manufacturer, model, year if year else None)
        return jsonify({"status": "ok", "data": data})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Price prediction (ML)
# ---------------------------------------------------------------------------

@app.route('/api/predict-price', methods=['POST'])
def predict_price():
    body = request.get_json(force=True)
    try:
        car = CarData(
            manufacturer=body.get('manufacturer', ''),
            model=body.get('model', ''),
            year=int(body.get('year', 0)),
            odometer=float(body.get('odometer', 0)),
            state=body.get('state', ''),
            transmission=body.get('transmission', ''),
            cylinders=body.get('cylinders', ''),
            drive=body.get('drive', ''),
            fuel=body.get('fuel', ''),
            title_status=body.get('title_status', 'clean'),
        )
        pipeline = PredictPipeline()
        price = pipeline.predict(car.to_dataframe())
        return jsonify({"status": "ok", "predicted_price": round(float(price[0]), 2)})
    except FileNotFoundError:
        return jsonify({"status": "error", "message": "Model not trained yet. Run the training pipeline first."}), 503
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _build_filters(manufacturer, model, year):
    filters, params = [], []
    if manufacturer:
        filters.append("LOWER(Manufacturer) = LOWER(?)")
        params.append(manufacturer)
    if model:
        filters.append("LOWER(Model) LIKE LOWER(?)")
        params.append(f"%{model}%")
    if year:
        filters.append("Year = ?")
        params.append(int(year))
    filters.append("Price IS NOT NULL AND Price > 0")
    return filters, params


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
