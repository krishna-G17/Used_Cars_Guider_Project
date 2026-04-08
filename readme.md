# Used Car Purchase Planner (UCPP)

Buying a used car is one of those decisions where having the right information can save you thousands of dollars — or spare you from inheriting someone else's problem. This project exists to make that process a lot less stressful.

UCPP is a web app that pulls together real Craigslist listings and NHTSA safety complaint data so you can search for a car and immediately see how much it should cost, where it's most commonly listed, how it holds its value over time, and what kinds of issues other owners have reported. Think of it as a research dashboard that does the grunt work for you.

---

## What It Does

Search for any used car by make, model, year, state, or city and the dashboard shows you:

- **Price snapshot** — average, minimum, and maximum listed prices across the US, plus average odometer reading
- **Regional availability** — a bar chart of which states have the most listings so you know where supply is strong
- **Condition vs. price** — how title status (clean, rebuilt, salvage) affects what people are actually paying
- **Depreciation curve** — a line chart showing how average asking price has moved across model years, so you can spot the sweet spot where value drops off
- **NHTSA complaint radar** — a spider chart scoring the car across eight complaint categories (brakes, electrical, engine, airbags, etc.) based on 1.3 million NHTSA safety reports from 1995 to 2023
- **Complaint word cloud** — the most common keywords from real consumer complaints, at a glance
- **Price prediction** — an ML-estimated fair market price based on the car's specs (requires the model to be trained — see setup notes below)
- **Live listings table** — the 50 most recent matching posts pulled from the database
- **Similar cars** — a handful of alternatives in a similar price range in case the one you're looking at doesn't feel right

---

## Data Sources

**Craigslist listings** — scraped daily from ~413 US city markets using a three-phase automated scraper. The current dataset covers April through July 2024 (66+ daily snapshots). A Windows Task Scheduler job runs the scraper every night to keep data fresh.

**NHTSA complaints** — six Excel files covering every consumer safety complaint filed with the National Highway Traffic Safety Administration from 1995 through 2023. These are loaded into memory when the app starts and cached for fast queries. When NHTSA releases new data, a helper script (`Notebooks/Scraping/load_nhtsa.py`) handles ingestion.

---

## Tech Stack

| What | How |
|------|-----|
| Backend | Python, Flask |
| Database | Microsoft SQL Server (`test_UCPP` database) |
| DB connection | pyodbc + SQLAlchemy |
| Scraping | Selenium (Edge headless) + requests + BeautifulSoup |
| Machine learning | scikit-learn, XGBoost, CatBoost |
| Frontend | Vanilla HTML, CSS, JavaScript |
| Charts | Chart.js, wordcloud2.js |
| NLP / embeddings | HuggingFace Transformers (BERT), pre-generated embeddings |
| Deployment target | AWS Elastic Beanstalk |

---

## Project Structure

```
UCPP/
├── app.py                    # Flask app — all API endpoints
├── application.py            # AWS Elastic Beanstalk entry point
├── requirements.txt
├── run_scraping_script.bat   # Daily scraper automation (Task Scheduler)
│
├── src/
│   ├── db.py                 # SQL Server connection (reads from .env)
│   ├── nhtsa.py              # NHTSA data loader and query helpers
│   ├── pipeline/
│   │   └── predict_pipeline.py   # Car price inference
│   └── components/
│       ├── data_ingestion.py     # Pulls data from SQL Server for training
│       ├── data_transformation.py # Feature engineering pipeline
│       └── model_trainer.py      # Trains and saves the price model
│
├── templates/
│   └── index.html            # Single-page dashboard
│
├── static/
│   ├── css/style.css         # Dark-theme styles
│   └── js/dashboard.js       # Chart wiring and API calls
│
├── Notebooks/
│   ├── Data/scraped_data/    # Daily CSV backups (not committed — large)
│   ├── Complaints_NLP/       # NHTSA Excel files + NLP dev work
│   └── Scraping/             # Scraper scripts and dev notebooks
│
└── artifacts/                # Trained model files (generated, not committed)
```

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/krishna-G17/Used_Cars_Guider_Project.git
cd Used_Cars_Guider_Project
```

### 2. Create a virtual environment and install dependencies

```bash
python -m venv ucppvenv
ucppvenv\Scripts\activate      # Windows
pip install -r requirements.txt
```

### 3. Set up your `.env` file

Create a `.env` file in the project root. It is gitignored so it will never be committed.

```
# SQL Server connection (required — the app won't run without these)
DB_SERVER=.\SQLEXPRESS
DB_NAME=test_UCPP
DB_USER=
DB_PASSWORD=
DB_DRIVER=ODBC Driver 17 for SQL Server

# Optional API keys (used in NLP / QA model work)
OPENAI_API_KEY=your_key_here
HUGGINGFACEHUB_API_TOKEN=your_token_here
```

Leave `DB_USER` and `DB_PASSWORD` blank if you're using Windows Authentication.

### 4. Run the app

```bash
python app.py
```

Open `http://localhost:5000` in your browser.

---

## Running the Scraper

The scraper collects today's Craigslist car listings from every US market and loads them into SQL Server. It runs in three phases: collecting listing URLs with Selenium, scraping post details with requests + BeautifulSoup, then deduplicating and inserting into the database.

```bash
# Scrape all ~413 US cities (default)
python Notebooks/Scraping/scraping.py

# Scrape a specific subset
python Notebooks/Scraping/scraping.py --cities "dallas,houston,chicago"

# Dry run — save CSV only, skip DB insert
python Notebooks/Scraping/scraping.py --dry-run
```

To schedule it as a daily job on Windows:

```bat
schtasks /create /tn "UCPP Daily Scrape" ^
  /tr "\"W:\Personal Projects\UCPP\run_scraping_script.bat\"" ^
  /sc DAILY /st 02:00 /ru "%USERNAME%" /f
```

---

## Adding New NHTSA Data

When NHTSA releases updated complaint data, download the file and run:

```bash
python Notebooks/Scraping/load_nhtsa.py --file path/to/new_file.xlsx --dest-name "Complaints_2024_2025.xlsx"
```

Then reload the in-memory cache without restarting Flask:

```
GET http://localhost:5000/api/nhtsa-reload
```

---

## Current State

The backend, dashboard UI, and scraper are fully built. Here is an honest status of what is and isn't working yet:

| Component | Status |
|-----------|--------|
| Flask app and all API routes | Built |
| Dashboard UI (charts, search, word cloud) | Built |
| Craigslist daily scraper | Built |
| NHTSA in-memory data loader | Built |
| SQL Server connection utility | Built |
| ML inference pipeline (CarData, PredictPipeline) | Built |
| SQL Server credentials in .env | **Not set up yet — required** |
| ML training pipeline (data_ingestion, data_transformation, model_trainer) | Not rewritten yet |
| Trained model artifacts (model.pkl, preprocessor.pkl) | Not generated yet |
| Task Scheduler job registered | Not registered yet |

The single step that unblocks everything is adding your SQL Server connection details to `.env`. Once that's done, all eight chart areas on the dashboard will populate. The price prediction form will remain inactive until the training pipeline is run.

---

## API Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Dashboard page |
| `/api/search` | GET | Search listings (manufacturer, model, year, state, city) |
| `/api/price-range` | GET | Avg / min / max price and listing count |
| `/api/listing-frequency` | GET | Listing counts by state |
| `/api/condition-price` | GET | Average price grouped by title status |
| `/api/price-trend` | GET | Average price by model year (depreciation) |
| `/api/similar-cars` | GET | Similar listings within ±30% of target price |
| `/api/nhtsa-radar` | GET | Complaint scores by component category |
| `/api/nhtsa-wordcloud` | GET | Top complaint keywords for word cloud |
| `/api/predict-price` | POST | ML price estimate (requires trained model) |
| `/api/nhtsa-reload` | GET | Clears NHTSA in-memory cache |

---

## What's Next

- Rewrite `src/components/` to train a price prediction model on the Craigslist data
- Add manufacturer and model auto-complete dropdowns to the search bar
- Schedule the daily scraper via Windows Task Scheduler
- Deployment to AWS Elastic Beanstalk

---

## Repository

[https://github.com/krishna-G17/Used_Cars_Guider_Project.git](https://github.com/krishna-G17/Used_Cars_Guider_Project.git)
