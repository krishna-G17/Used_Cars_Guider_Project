# CLAUDE.md — Used Car Purchase Planner (UCPP)

> This file is written for Claude Code. Reading it at the start of any session
> gives full project context without needing to re-read source files.
> Last updated: 2026-04-07

---

## 1. What This Project Does

UCPP is a Flask web application that helps used-car buyers make informed purchasing
decisions. It combines three data sources:

1. **Craigslist listings** — scraped daily from ~413 US cities (Apr–Jul 2024 historic
   data + ongoing daily scraping). Stored in SQL Server.
2. **NHTSA complaints** — 1.3M+ consumer safety complaints from 1995–2023, stored as
   Excel files and loaded into memory at runtime.
3. **ML price prediction** — a regression model (not yet trained) that will estimate
   fair market price for a given car configuration.

The dashboard lets a buyer search by Make/Model/Year/State/City and immediately see:
- Average price, min/max, listing count (KPI cards)
- Which US states have the most listings (bar chart)
- Average price by title/condition (bar chart)
- Price depreciation by model year (line chart)
- NHTSA complaint breakdown by component (radar/spider chart)
- Top complaint keywords (word cloud)
- ML-estimated fair price (form, requires trained model)
- Raw listings table (top 50)
- Similar car recommendations

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.x, Flask, flask-cors |
| Database | Microsoft SQL Server (local), pyodbc + SQLAlchemy |
| Scraping Phase 1 | Selenium (Edge headless; Firefox fallback) |
| Scraping Phase 2 | requests + BeautifulSoup4 |
| ML | scikit-learn, XGBoost, CatBoost, dill (serialisation) |
| Frontend | Vanilla HTML/CSS/JS (no framework) |
| Charts | Chart.js 4.4.2 (CDN), wordcloud2.js 1.2.2 (CDN) |
| Config | python-dotenv (.env file) |
| NLP / embeddings | HuggingFace transformers (BERT), embeddings.npy pre-generated |
| Deployment target | AWS Elastic Beanstalk (application.py entry-point pattern) |
| VCS | Git → GitHub |

---

## 3. Folder Structure

```
UCPP/
├── app.py                          # Main Flask app — all API routes
├── application.py                  # AWS EB stub: `from app import application`
├── requirements.txt                # Python dependencies
├── .env                            # Secrets (gitignored) — see Section 5
├── run_scraping_script.bat         # Windows Task Scheduler batch file
├── mybatchfile.bat                 # Old batch file (legacy, keep for reference)
│
├── src/
│   ├── db.py                       # pyodbc connection factory (reads .env)
│   ├── nhtsa.py                    # NHTSA in-memory loader + radar/wordcloud helpers
│   ├── utils.py                    # load_object() helper (dill/pickle)
│   ├── exception.py                # CustomException wrapper
│   ├── logger.py                   # Python logging setup
│   ├── pipeline/
│   │   ├── predict_pipeline.py     # CarData + PredictPipeline (inference)
│   │   └── train_pipeline.py       # Training orchestrator (NOT YET REWRITTEN)
│   └── components/
│       ├── data_ingestion.py       # Reads from SQL → train/test split (NOT YET REWRITTEN)
│       ├── data_transformation.py  # ColumnTransformer for car features (NOT YET REWRITTEN)
│       └── model_trainer.py        # Fits regressor, saves artifacts (NOT YET REWRITTEN)
│
├── templates/
│   └── index.html                  # Single-page dashboard UI
│
├── static/
│   ├── css/style.css               # Dark-theme responsive CSS
│   └── js/dashboard.js             # All Chart.js wiring + API calls
│
├── artifacts/                      # GENERATED — model.pkl + preprocessor.pkl
│                                   # (gitignored; does not exist until model is trained)
│
├── Notebooks/
│   ├── Basic_DA.sql                # SQL exploration queries for Used_Cars_DF
│   ├── Data/
│   │   └── scraped_data/           # ~66+ daily CSVs (gitignored)
│   │       └── scraped_data_DD_MM_YYYY.csv
│   ├── Complaints_NLP/
│   │   ├── Complaints_Data/        # NHTSA Excel files (gitignored — large)
│   │   │   ├── Complaints_1995_1999.xlsx
│   │   │   ├── Complaints_2000_2004.xlsx
│   │   │   ├── Complaints_2005_2009.xlsx
│   │   │   ├── Complaints_2010_2014.xlsx
│   │   │   ├── Complaints_2015_2019.xlsx
│   │   │   └── Complaints_2020_2023.xlsx
│   │   └── embeddings.npy          # Pre-generated BERT embeddings (gitignored)
│   └── Scraping/
│       ├── scraping.py             # PRODUCTION scraper (Phase 1: Selenium, Phase 2: requests)
│       ├── load_nhtsa.py           # Helper to ingest new NHTSA Excel files
│       ├── checkpoints/            # Per-run URL checkpoint CSVs (auto-created)
│       └── *.ipynb                 # Development notebooks (historical reference)
│
└── ucppvenv/                       # Virtual environment (gitignored)
```

---

## 4. Current State

### Works
- Flask app runs: `python app.py` starts on port 5000
- All 9 API routes defined and wired up (search, price-range, listing-frequency,
  condition-price, price-trend, similar-cars, nhtsa-radar, nhtsa-wordcloud,
  predict-price, nhtsa-reload)
- Dashboard UI fully built (index.html + style.css + dashboard.js)
- NHTSA in-memory loader works (src/nhtsa.py) — loads all 6 Excel files, serves
  radar chart data and word cloud on first request, caches with @lru_cache
- src/db.py connection factory built — supports both SQL auth and Windows Auth
- Daily scraper built (Notebooks/Scraping/scraping.py) — 3-phase, resume-capable,
  deduplicates before inserting, saves CSV backup
- load_nhtsa.py helper validates and ingests new NHTSA Excel files
- run_scraping_script.bat wired to ucppvenv, includes schtasks setup command
- .gitignore excludes .env, all CSVs, Excel data, embeddings, venv, artifacts

### Blocked / Not Working Yet
- **All SQL-backed routes return errors** — `.env` is missing SQL Server credentials.
  Only OPENAI_API_KEY and HUGGINGFACEHUB_API_TOKEN are currently in .env.
  The DB routes will not function until DB_SERVER etc. are added.
- **`/api/predict-price` returns 503** — `artifacts/model.pkl` and
  `artifacts/preprocessor.pkl` do not exist. The training pipeline has not been
  written yet (the components in src/components/ still reference the old student
  score predictor dataset).

### Known Issues
- `src/components/data_ingestion.py` still reads `notebook\data\stud.csv` — needs
  rewrite to pull from SQL Server `Used_Cars_DF`.
- `src/components/data_transformation.py` still has student-project column names —
  needs ColumnTransformer for car features (year, odometer, manufacturer, model,
  state, transmission, cylinders, drive, fuel, title_status).
- `src/components/model_trainer.py` not updated for regression on car prices.
- `State` column in Used_Cars_DF may be sparsely populated — the scraper derives
  state from city-slug lookup; some city slugs may not be in the mapping dict.
- NHTSA data ends at 2023. For 2024+ model years, complaints data is empty.

---

## 5. Database

### Connection (.env — add these, they are currently missing)
```
DB_SERVER=.\SQLEXPRESS          # or your SQL Server instance name
DB_NAME=test_UCPP
DB_USER=                        # leave blank for Windows Auth
DB_PASSWORD=                    # leave blank for Windows Auth
DB_DRIVER=ODBC Driver 17 for SQL Server

# Already present in .env (do not remove):
OPENAI_API_KEY=<your key>
HUGGINGFACEHUB_API_TOKEN=<your token>
```

### Database: `test_UCPP`

#### Table: `[dbo].[Used_Cars_DF]` (main table)
| Column | Type | Notes |
|--------|------|-------|
| Date | date | Scrape date |
| URL | nvarchar | Craigslist post URL (used for dedup) |
| Manufacturer | nvarchar | e.g. TOYOTA, FORD |
| Model | nvarchar | e.g. CAMRY, F-150 |
| Year | int | Manufacturing year |
| Price | int | Listed price in USD |
| Odometer | float | Miles |
| City | nvarchar | Full city name (e.g. "Dallas-Fort Worth Metropolitan Area") |
| State | nvarchar | Two-letter abbreviation (e.g. TX) |
| transmission | nvarchar | automatic / manual / other |
| title status | nvarchar | clean / rebuilt / salvage / lien / parts only |
| VIN | nvarchar | Vehicle Identification Number |
| cylinders | nvarchar | e.g. "6 cylinders" |
| drive | nvarchar | fwd / rwd / 4wd |
| description | nvarchar(max) | Full posting text |
| condition | nvarchar | excellent / good / fair / etc. |
| fuel | nvarchar | gas / diesel / hybrid / electric |
| paint color | nvarchar | |
| type | nvarchar | sedan / truck / SUV / etc. |
| lat | float | Latitude (from CG geotagging) |
| long | float | Longitude |

#### Note on column names
SQL queries must quote columns with spaces: `[title status]`, `[paint color]`.
pyodbc uses `?` as the placeholder (not `%s`).

---

## 6. What Still Needs to Be Built

### Priority 1 — Unblock the app (nothing works without these)
1. **Add SQL Server credentials to .env** — without DB_SERVER, every API route
   returns a 500 error. This is the single highest-priority action.

### Priority 2 — ML training pipeline (rewrite src/components/)
Rewrite these three files for car price regression:

- `src/components/data_ingestion.py`
  - Read from SQL Server `Used_Cars_DF` (not a CSV)
  - Filter out rows where Price is null/0 or Year < 1990
  - Train/test split (80/20), save to `artifacts/train.csv` and `artifacts/test.csv`

- `src/components/data_transformation.py`
  - Numeric features: `year`, `odometer`
  - Categorical features: `Manufacturer`, `Model`, `State`, `transmission`,
    `cylinders`, `drive`, `fuel`, `title status`
  - Target: `Price`
  - Use `sklearn.pipeline.Pipeline` with `ColumnTransformer` + `OrdinalEncoder`
    or `OneHotEncoder` for categoricals
  - Save fitted preprocessor to `artifacts/preprocessor.pkl`

- `src/components/model_trainer.py`
  - Try XGBoostRegressor and CatBoostRegressor
  - Evaluate with RMSE and R²
  - Save best model to `artifacts/model.pkl`

Then run `python src/components/data_ingestion.py` to trigger the full training chain.

### Priority 3 — Data freshness
- The existing scraped data covers only Apr–Jul 2024. The daily scraper is built
  but needs to be scheduled (see run_scraping_script.bat for the schtasks command).
- Add new NHTSA files when available using `python Notebooks/Scraping/load_nhtsa.py`

### Priority 4 — Dashboard enhancements
- Add a dropdown auto-complete for Manufacturer and Model fields (query DB for
  distinct values via a `/api/manufacturers` and `/api/models?manufacturer=X` endpoint)
- The "Similar Cars" section logic is rough (currently uses NEWID() random sampling
  within a 70%-130% price band). Could improve to sort by proximity in price+odometer.
- Word cloud canvas sizing is fixed — make it responsive on resize.

### Priority 5 — Deployment
- application.py is already set up for AWS Elastic Beanstalk
- Will need a Procfile or .ebextensions if deploying to EB
- SQL Server would need to be reachable from the cloud instance (consider Azure SQL
  or RDS SQL Server if moving off local)

---

## 7. GitHub Repository

URL: https://github.com/krishna-G17/Used_Cars_Guider_Project.git
Branch: `main` (all work goes directly to main; feature branches optional)

### Commit conventions used so far
```
fix: <description>   — bug fix or incorrect logic
feat: <description>  — new feature
```

### What NOT to commit (already in .gitignore)
- `.env`
- `Notebooks/Data/` (CSV files)
- `Notebooks/Complaints_NLP/Complaints_Data/` (Excel + embeddings)
- `ucppvenv/`, `venv/`
- `artifacts/` (model pkl files)
- `__pycache__/`
- `*.pbix`, `*.docx`, `*.pdf`

---

## 8. Step-by-Step Plan for Next Session

```
Step 1  Add SQL creds to .env and test the Flask app end-to-end
        → python app.py → open http://localhost:5000 → search "toyota camry"
        → all 8 chart areas should populate

Step 2  Rewrite src/components/data_ingestion.py
        → Connect to SQL Server, read Used_Cars_DF
        → Filter, split, save artifacts/train.csv + artifacts/test.csv

Step 3  Rewrite src/components/data_transformation.py
        → ColumnTransformer for numeric + categoricals
        → Save artifacts/preprocessor.pkl

Step 4  Rewrite src/components/model_trainer.py
        → XGBoost regression
        → Evaluate RMSE / R²
        → Save artifacts/model.pkl

Step 5  Run the training chain:
        python src/components/data_ingestion.py

Step 6  Test /api/predict-price via the dashboard form

Step 7  Schedule the daily scraper:
        schtasks /create /tn "UCPP Daily Scrape" ^
          /tr "\"W:\Personal Projects\UCPP\run_scraping_script.bat\"" ^
          /sc DAILY /st 02:00 /ru "%USERNAME%" /f

Step 8  Add /api/manufacturers and /api/models endpoints +
        auto-complete dropdowns in the dashboard search bar

Step 9  Deployment prep (Procfile, environment variables, DB accessibility)
```

---

## 9. Code Patterns and Conventions

### API response envelope
All routes return JSON with a consistent shape:
```python
{"status": "ok", "data": [...]}          # success
{"status": "error", "message": "..."}   # failure
```

### SQL queries
- Use `pyodbc` directly (via `src/db.py:get_connection()`)
- Placeholder is `?` (not `%s`)
- Quote columns with spaces: `[title status]`, `[paint color]`
- Always `conn.close()` after use (not a context manager)
- Helper `_build_filters(manufacturer, model, year)` returns `(filters_list, params_list)`
  and always appends `"Price IS NOT NULL AND Price > 0"` — use this for all price queries

### NHTSA
- `src/nhtsa.py:_load_all()` is decorated with `@lru_cache(maxsize=1)` — it loads
  all 6 Excel files once and caches the combined DataFrame in memory
- To reload after adding new files: `GET /api/nhtsa-reload` (calls `_load_all.cache_clear()`)
- Radar chart normalises scores 0-100 relative to the category with the most complaints
- Word cloud filters words to uppercase tokens >= 3 chars, strips a custom stopword set

### Scraper
- Phase 1 (Selenium): collects URLs, saves checkpoint to `Notebooks/Scraping/checkpoints/urls_DD_MM_YYYY.csv`
- Phase 2 (requests+BS4): visits each URL, parses `div.mapAndAttrs` and `span.attrgroup`
- Phase 3 (SQLAlchemy): deduplicates by URL before inserting
- Logs to `Notebooks/Scraping/scrape_DD_MM_YYYY.log`
- CLI: `--cities "dallas,houston"`, `--dry-run`, `--skip-phase1`

### Frontend
- No build step — vanilla HTML/CSS/JS loaded by Flask's `render_template`
- Chart instances stored in a `charts = {}` object; always `destroyChart(key)` before
  re-drawing to prevent canvas memory leaks
- All API calls happen in parallel via `Promise.all([...])` on search submit
- CSS variables defined on `:root` in style.css — change accent colour there only

### Error handling
- `src/exception.py` provides `CustomException(e, sys)` which captures file/line
- `src/logger.py` sets up a timestamped log file; import as `from src.logger import logging`
- The scraper uses Python's `logging` module independently (not src/logger.py)

---

## 10. Session History

### 2026-04-07 — Initial build session
**What was done:**
- Audited the project (was a copy of a student score predictor)
- Rewrote `app.py` with 9 correct UCPP REST endpoints
- Created `src/db.py` — SQL Server connection utility
- Created `src/nhtsa.py` — NHTSA in-memory loader with radar + word cloud
- Rewrote `src/pipeline/predict_pipeline.py` — CarData + PredictPipeline for cars
- Created `templates/index.html` — full dashboard UI
- Created `static/css/style.css` — dark theme
- Created `static/js/dashboard.js` — all chart wiring
- Updated `requirements.txt` (added flask-cors, python-dotenv, openpyxl)
- Updated `.gitignore` (added data files, venv, embeddings, .pbix, .docx)
- Wrote `Notebooks/Scraping/scraping.py` — production 3-phase scraper
- Wrote `Notebooks/Scraping/load_nhtsa.py` — NHTSA file ingest helper
- Updated `run_scraping_script.bat` — wired to ucppvenv + new scraper
- Wrote `CLAUDE.md` (this file)

**What was NOT done (still needed):**
- SQL credentials were never added to `.env` — all DB routes are blocked
- ML training pipeline (`src/components/`) was not rewritten
- No `artifacts/model.pkl` exists — predict-price returns 503
- Task Scheduler job not yet registered (command is in run_scraping_script.bat)
