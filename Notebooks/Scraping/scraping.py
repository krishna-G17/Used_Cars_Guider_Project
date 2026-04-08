"""
UCPP — Craigslist Used Car Scraper
===================================
Production script that:
  1. Collects listing URLs from Craigslist search pages (Selenium / Edge headless)
  2. Scrapes individual post details (requests + BeautifulSoup — much faster)
  3. Deduplicates against the SQL Server DB, saves a CSV backup, and loads new rows

Usage
-----
  # Scrape ALL ~413 US cities (default — runs nightly via Task Scheduler)
  python scraping.py

  # Scrape only specific cities
  python scraping.py --cities "dallas,houston,chicago,los angeles,seattle"

  # Dry run: collect URLs and save CSV but do NOT load to DB
  python scraping.py --dry-run

  # Skip Phase 1 if a checkpoint URL file already exists for today
  python scraping.py --skip-phase1

Environment / .env variables required
--------------------------------------
  DB_SERVER   — SQL Server host (e.g.  .  or  localhost\SQLEXPRESS)
  DB_NAME     — Database name (test_UCPP)
  DB_USER     — SQL login (blank = Windows Auth)
  DB_PASSWORD — SQL password (blank = Windows Auth)
  DB_DRIVER   — optional, default "ODBC Driver 17 for SQL Server"
"""

import argparse
import logging
import os
import re
import sys
import time
import warnings
from datetime import datetime
from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException, WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.options import Options as EdgeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from sqlalchemy import create_engine, text

warnings.filterwarnings("ignore")
load_dotenv(dotenv_path=Path(__file__).resolve().parents[2] / ".env")

# ── Paths ──────────────────────────────────────────────────────────────────
SCRIPT_DIR    = Path(__file__).resolve().parent
PROJECT_ROOT  = SCRIPT_DIR.parents[1]
DATA_DIR      = PROJECT_ROOT / "Notebooks" / "Data" / "scraped_data"
CHECKPOINT_DIR = SCRIPT_DIR / "checkpoints"
DATA_DIR.mkdir(parents=True, exist_ok=True)
CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)

TODAY       = datetime.now().strftime("%d_%m_%Y")
LOG_PATH    = SCRIPT_DIR / f"scrape_{TODAY}.log"

# ── Logging ────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    handlers=[
        logging.FileHandler(LOG_PATH, encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger("ucpp_scraper")

# ── DB credentials ─────────────────────────────────────────────────────────
DB_SERVER   = os.getenv("DB_SERVER", "")
DB_NAME     = os.getenv("DB_NAME", "test_UCPP")
DB_USER     = os.getenv("DB_USER", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_DRIVER   = os.getenv("DB_DRIVER", "ODBC Driver 17 for SQL Server")

# ── SQL table columns (must match Used_Cars_DF) ────────────────────────────
DB_COLUMNS = [
    "Date", "URL", "Manufacturer", "Model", "Year", "Price", "Odometer",
    "City", "State", "transmission", "title status", "VIN",
    "cylinders", "drive", "description", "condition", "fuel",
    "paint color", "type",
]

# ── Request headers (mimic browser) ────────────────────────────────────────
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}

# ── City → "City Name, STATE" mapping (413 US CG cities) ──────────────────
CITY_TO_FULL = {
    'SF bay area': 'San Francisco - Bay Area, CA',
    'abilene': 'Abilene, TX', 'akron-canton': 'Akron-Canton, OH',
    'albany, GA': 'Albany, GA', 'albany, NY': 'Albany, NY',
    'albuquerque': 'Albuquerque, NM', 'allentown': 'Allentown, PA',
    'altoona': 'Altoona, PA', 'amarillo': 'Amarillo, TX',
    'ames, IA': 'Ames, IA', 'anchorage': 'Anchorage, AK',
    'ann arbor': 'Ann Arbor, MI', 'annapolis': 'Annapolis, MD',
    'appleton': 'Appleton, WI', 'asheville': 'Asheville, NC',
    'ashtabula': 'Ashtabula, OH', 'athens, GA': 'Athens, GA',
    'athens, OH': 'Athens, OH', 'atlanta': 'Atlanta, GA',
    'auburn': 'Auburn, AL', 'augusta': 'Augusta, GA',
    'austin': 'Austin, TX', 'bakersfield': 'Bakersfield, CA',
    'baltimore': 'Baltimore, MD', 'baton rouge': 'Baton Rouge, LA',
    'battle creek': 'Battle Creek, MI', 'beaumont': 'Beaumont, TX',
    'bellingham': 'Bellingham, WA', 'bemidji': 'Bemidji, MN',
    'bend': 'Bend, OR', 'billings': 'Billings, MT',
    'binghamton': 'Binghamton, NY', 'birmingham, AL': 'Birmingham, AL',
    'bismarck': 'Bismarck, ND', 'blacksburg': 'Blacksburg, VA',
    'bloomington, IL': 'Bloomington, IL', 'bloomington, IN': 'Bloomington, IN',
    'boise': 'Boise, ID', 'boone': 'Boone, NC',
    'boston': 'Boston, MA', 'boulder': 'Boulder, CO',
    'bowling green': 'Bowling Green, KY', 'bozeman': 'Bozeman, MT',
    'brainerd': 'Brainerd, MN', 'brownsville': 'Brownsville, TX',
    'brunswick, GA': 'Brunswick, GA', 'buffalo': 'Buffalo, NY',
    'butte': 'Butte, MT', 'cape cod': 'Cape Cod, MA',
    'catskills': 'Catskill, NY', 'cedar rapids': 'Cedar Rapids, IA',
    'central LA': 'Central Louisiana Region, LA',
    'central MI': 'Central Michigan Region, MI',
    'central NJ': 'Central New Jersey Region, NJ',
    'central SD': 'Central South Dakota: Missouri River Region, SD',
    'chambana': 'Urbana, IL', 'charleston': 'Charleston, SC',
    'charleston, WV': 'Charleston, WV', 'charlotte': 'Charlotte, NC',
    'charlottesville': 'Charlottesville, VA', 'chattanooga': 'Chattanooga, TN',
    'chautauqua': 'Chautauqua, NY', 'chicago': 'Chicago, IL',
    'chico': 'Chico, CA', 'chillicothe': 'Chillicothe, OH',
    'cincinnati': 'Cincinnati, OH', 'clarksville, TN': 'Clarksville, TN',
    'cleveland': 'Cleveland, OH', 'clovis-portales': 'Clovis-Portales Area, NM',
    'college station': 'College Station, TX',
    'colo springs': 'Colorado Springs, CO',
    'columbia': 'Columbia, SC', 'columbia, MO': 'Columbia, MO',
    'columbus, GA': 'Columbus, GA', 'columbus, OH': 'Columbus, OH',
    'cookeville': 'Cookeville, TN', 'corpus christi': 'Corpus Christi, TX',
    'corvallis': 'Corvallis, OR',
    'cumberland val': 'Cumberland Valley Township, PA',
    'dallas': 'Dallas-Fort Worth Metropolitan Area, TX',
    'danville': 'Danville, VA', 'dayton': 'Dayton, OH',
    'daytona beach': 'Daytona Beach, FL', 'decatur, IL': 'Decatur, IL',
    'deep east TX': 'Deep East Texas Area, TX', 'del rio': 'Del Rio, TX',
    'delaware': 'Delaware, DE', 'denver': 'Denver, CO',
    'des moines': 'Des Moines, IA', 'detroit metro': 'Detroit, MI',
    'dothan, AL': 'Dothan, AL', 'dubuque': 'Dubuque, IA',
    'duluth': 'Duluth, MN', 'east TX': 'Tyler, TX',
    'east idaho': 'Eastern Idaho Region, ID',
    'east oregon': 'Eastern Oregon Region, OR',
    'eastern CO': 'East Colorado Region, CO',
    'eastern CT': 'East Connecticut Region, CT',
    'eastern KY': 'East Kentucky Region, KY',
    'eastern NC': 'Eastern Region of North Carolina, NC',
    'eastern WV': 'Eastern Panhandle Region of West Virginia, WV',
    'eastern montana': 'East Montana Region, MT',
    'eastern shore': 'Eastern Shore of Maryland, MD',
    'eau claire': 'Eau Claire, WI', 'el paso': 'El Paso, TX',
    'elko': 'Elko, NV', 'elmira': 'Elmira, NY',
    'erie, PA': 'Erie, PA', 'eugene': 'Eugene, OR',
    'evansville': 'Evansville, IN', 'fairbanks': 'Fairbanks, AK',
    'fargo': 'Fargo, ND', 'farmington, NM': 'Farmington, NM',
    'fayetteville, AR': 'Fayetteville, AR',
    'fayetteville, NC': 'Fayetteville, NC',
    'finger lakes': 'Finger Lakes, NY', 'flagstaff': 'Flagstaff, AZ',
    'flint': 'Flint, MI', 'florence, SC': 'Florence, SC',
    'florida keys': 'Florida Keys, FL', 'fort collins': 'Fort Collins, CO',
    'fort dodge': 'Fort Dodge, IA', 'fort myers': 'Fort Myers, FL',
    'fort smith': 'Fort Smith, AR', 'fort wayne': 'Fort Wayne, IN',
    'frederick': 'Frederick, MD', 'fredericksburg': 'Fredericksburg, VA',
    'fresno': 'Fresno, CA', 'gadsden': 'Gadsden, AL',
    'gainesville': 'Gainesville, FL', 'galveston': 'Galveston, TX',
    'glens falls': 'Glens Falls, NY',
    'gold country': 'Gold Country Region, CA',
    'grand forks': 'Grand Forks, ND', 'grand island': 'Grand Island, NE',
    'grand rapids': 'Grand Rapids, MI', 'great falls': 'Great Falls, MT',
    'green bay': 'Green Bay, WI', 'greensboro': 'Greensboro, NC',
    'greenville': 'Greenville, SC', 'gulfport': 'Gulfport, MS',
    'hanford': 'Hanford, CA', 'harrisburg': 'Harrisburg, PA',
    'harrisonburg': 'Harrisonburg, VA', 'hartford': 'Hartford, CT',
    'hattiesburg': 'Hattiesburg, MS', 'hawaii': 'Honolulu, HI',
    'heartland FL': 'Florida Heartland Region, FL', 'helena': 'Helena, MT',
    'hickory': 'Hickory, NC', 'high rockies': 'High Rockies Region, CO',
    'hilton head': 'Hilton Head, SC', 'holland': 'Holland, MI',
    'houma': 'Houma, LA', 'houston': 'Houston, TX',
    'hudson valley': 'Hudson Valley Region, NY',
    'humboldt': 'Humboldt County, CA', 'huntington': 'Huntington, WV',
    'huntsville': 'Huntsville, AL', 'imperial co': 'Imperial County, CA',
    'indianapolis': 'Indianapolis, IN', 'inland empire': 'Inland Empire, CA',
    'iowa city': 'Iowa City, IA', 'ithaca': 'Ithaca, NY',
    'jackson, MI': 'Jackson, MI', 'jackson, MS': 'Jackson, MS',
    'jackson, TN': 'Jackson, TN', 'jacksonville, FL': 'Jacksonville, FL',
    'jacksonville, NC': 'Jacksonville, NC', 'janesville': 'Janesville, WI',
    'jersey shore': 'Jersey Shore, NJ', 'jonesboro': 'Jonesboro, AR',
    'joplin': 'Joplin, MO', 'kalamazoo': 'Kalamazoo, MI',
    'kalispell': 'Kalispell, MT', 'kansas city': 'Kansas City, MO',
    'kenai': 'Kenai, AK', 'kenosha-racine': 'Kenosha-Racine, WI',
    'killeen-temple': 'Killeen-Temple, TX', 'kirksville': 'Kirksville, MO',
    'klamath falls': 'Klamath Falls, OR', 'knoxville': 'Knoxville, TN',
    'kokomo': 'Kokomo, IN', 'la crosse': 'La Crosse, WI',
    'la salle co': 'LaSalle County, IL', 'lafayette': 'Lafayette, LA',
    'lake charles': 'Lake Charles, LA', 'lake city': 'Lake City, FL',
    'lake of ozarks': 'Lake of the Ozarks, MO', 'lakeland': 'Lakeland, FL',
    'lancaster, PA': 'Lancaster, PA', 'lansing': 'Lansing, MI',
    'laredo': 'Laredo, TX', 'las cruces': 'Las Cruces, NM',
    'las vegas': 'Las Vegas, NV', 'lawrence': 'Lawrence, KS',
    'lawton': 'Lawton, OK', 'lewiston': 'Lewiston, ID',
    'lexington': 'Lexington, KY', 'lima-findlay': 'Lima-Findlay, OH',
    'lincoln': 'Lincoln, NE', 'little rock': 'Little Rock, AR',
    'logan': 'Logan, UT', 'long island': 'Long Island, NY',
    'los angeles': 'Los Angeles, CA', 'louisville': 'Louisville, KY',
    'lubbock': 'Lubbock, TX', 'lynchburg': 'Lynchburg, VA',
    'macon': 'Macon, GA', 'madison': 'Madison, WI',
    'maine': 'Maine, ME', 'manhattan': 'Manhattan, KS',
    'mankato': 'Mankato, MN', 'mansfield': 'Mansfield, OH',
    'mason city': 'Mason City, IA', 'mattoon': 'Mattoon, IL',
    'mcallen': 'McAllen, TX', 'meadville': 'Meadville, PA',
    'medford': 'Medford, OR', 'memphis': 'Memphis, TN',
    'mendocino co': 'Mendocino County, CA', 'merced': 'Merced, CA',
    'meridian': 'Meridian, MS', 'milwaukee': 'Milwaukee, WI',
    'minneapolis': 'Minneapolis-St Paul Area, MN', 'missoula': 'Missoula, MT',
    'mobile, AL': 'Mobile, AL', 'modesto': 'Modesto, CA',
    'mohave co': 'Mohave County, AZ', 'monroe, LA': 'Monroe, LA',
    'monroe, MI': 'Monroe, MI', 'monterey': 'Monterey, CA',
    'montgomery': 'Montgomery, AL', 'morgantown': 'Morgantown, WV',
    'moses lake': 'Moses Lake, WA', 'muncie': 'Muncie, IN',
    'muskegon': 'Muskegon, MI', 'myrtle beach': 'Myrtle Beach, SC',
    'nashville': 'Nashville, TN', 'new hampshire': 'New Hampshire, NH',
    'new haven': 'New Haven, CT', 'new orleans': 'New Orleans, LA',
    'new york': 'New York City, NY', 'norfolk': 'Norfolk, VA',
    'north MS': 'North Mississippi Region, MS',
    'north dakota': 'North Dakota Region, ND',
    'north jersey': 'North Jersey Region, NJ',
    'north platte': 'North Platte, NE',
    'northeast SD': 'Northeast region of South Dakota, SD',
    'northern MI': 'North region of Michigan, MI',
    'northern WI': 'North region of Wisconsin, WI',
    'northern WV': 'North region of West Virginia, WV',
    'northwest CT': 'North west region of Connecticut, CT',
    'northwest GA': 'North west region of Georgia, GA',
    'northwest KS': 'North west region of Kansas, KS',
    'northwest OK': 'North west region of oklahoma, OK',
    'ocala': 'Ocala, FL', 'odessa': 'Odessa, TX',
    'ogden': 'Ogden, UT', 'okaloosa': 'Okaloosa, FL',
    'oklahoma city': 'Oklahoma City, OK',
    'olympic pen': 'Olympic Peninsula, WA',
    'omaha': 'Omaha, NE', 'oneonta': 'Oneonta, NY',
    'orange co': 'Orange County, CA',
    'oregon coast': 'Oregon Coast, OR', 'orlando': 'Orlando, FL',
    'outer banks': 'Outer Banks, NC', 'owensboro': 'Owensboro, KY',
    'palm springs': 'Palm Springs, CA',
    'panama city, FL': 'Panama City, FL', 'parkersburg': 'Parkersburg, WV',
    'pensacola': 'Pensacola, FL', 'peoria': 'Peoria, IL',
    'philadelphia': 'Philadelphia, PA', 'phoenix': 'Phoenix, AZ',
    'pittsburgh': 'Pittsburgh, PA', 'plattsburgh': 'Plattsburgh, NY',
    'poconos': 'Poconos, PA', 'port huron': 'Port Huron, MI',
    'portland': 'Portland, OR',
    'potsdam-massena': 'Potsdam-Canton-Massena, NY',
    'prescott': 'Prescott, AZ', 'provo': 'Provo, UT',
    'pueblo': 'Pueblo, CO', 'pullman-moscow': 'Pullman-Moscow, WA',
    'quad cities': 'Davenport, IA', 'raleigh': 'Raleigh, NC',
    'rapid city': 'Rapid City, SD', 'reading': 'Reading, PA',
    'redding': 'Redding, CA', 'reno': 'Reno, NV',
    'rhode island': 'Rhode Island, RI', 'richmond, IN': 'Richmond, IN',
    'richmond, VA': 'Richmond, VA', 'roanoke': 'Roanoke, VA',
    'rochester, MN': 'Rochester, MN', 'rochester, NY': 'Rochester, NY',
    'rockford': 'Rockford, IL', 'roseburg': 'Roseburg, OR',
    'roswell': 'Roswell, NM', 'sacramento': 'Sacramento, CA',
    'saginaw': 'Saginaw, MI', 'salem': 'Salem, OR',
    'salina': 'Salina, KS', 'salt lake': 'Salt Lake City, UT',
    'san angelo': 'San Angelo, TX', 'san antonio': 'San Antonio, TX',
    'san diego': 'San Diego, CA',
    'san luis obispo': 'San Luis Obispo, CA',
    'san marcos': 'San Marcos, TX', 'sandusky': 'Sandusky, OH',
    'santa barbara': 'Santa Barbara, CA', 'santa fe': 'Santa Fe, NM',
    'santa maria': 'Santa Maria, CA', 'sarasota': 'Sarasota, FL',
    'savannah': 'Savannah, GA', 'scottsbluff': 'Scottsbluff, NE',
    'scranton': 'Scranton, PA', 'seattle': 'Seattle, WA',
    'sheboygan, WI': 'Sheboygan, WI', 'show low': 'Show Low, AZ',
    'shreveport': 'Shreveport, LA', 'sierra vista': 'Sierra Vista, AZ',
    'sioux city': 'Sioux City, IA', 'sioux falls': 'Sioux Falls, SD',
    'siskiyou co': 'Siskiyou County, CA', 'skagit': 'Skagit, WA',
    'south bend': 'South Bend, IN',
    'south coast': 'Southern Bristol and Plymouth counties, MA',
    'south dakota': 'South Dakota, SD',
    'south florida': 'Miami, FL',
    'south jersey': 'South Region of New Jersey, NJ',
    'southeast AK': 'South Eastern Region of Alaska, AK',
    'southeast IA': 'South Eastern Region of Iowa, IA',
    'southeast KS': 'South Eastern Region of Kansas, KS',
    'southeast MO': 'South Eastern Region of Missouri, MO',
    'southern IL': 'South Region of Illinois, IL',
    'southern MD': 'South Region of Maryland, MD',
    'southern WV': 'South Region of West Virginia, WV',
    'southwest KS': 'South West Region of Kansas, KS',
    'southwest MI': 'South West Region of Michigan, MI',
    'southwest MN': 'South Western Region of Minnesota, MN',
    'southwest MS': 'South Western Region of Mississippi, MS',
    'southwest TX': 'South Western Region of Texas, TX',
    'southwest VA': 'South Western Region of Virginia, VA',
    'space coast': 'Space Coast, FL', 'spokane': 'Spokane, WA',
    'springfield': 'Springfield, MO', 'springfield, IL': 'Springfield, IL',
    'st augustine': 'St Augustine, FL', 'st cloud': 'St Cloud, MN',
    'st george': 'St George, UT', 'st joseph': 'St Joseph, MO',
    'st louis': 'St Louis, MO', 'state college': 'State College, PA',
    'statesboro': 'Statesboro, GA', 'stillwater': 'Stillwater, OK',
    'stockton': 'Stockton, CA', 'susanville': 'Susanville, CA',
    'syracuse': 'Syracuse, NY', 'tallahassee': 'Tallahassee, FL',
    'tampa bay': 'Tampa, FL', 'terre haute': 'Terre Haute, IN',
    'texarkana': 'Texarkana, TX', 'texoma': 'Texoma, TX',
    'the shoals': 'Florence-Muscle Shoals Area, AL',
    'the thumb': 'The Thumb, MI', 'tippecanoe': 'Tippecanoe, IN',
    'toledo': 'Toledo, OH', 'topeka': 'Topeka, KS',
    'treasure coast': 'Treasure Coast, FL',
    'tri-cities, TN': 'Tri-Cities Region, TN',
    'tri-cities, WA': 'Tri-Cities, WA', 'tucson': 'Tucson, AZ',
    'tulsa': 'Tulsa, OK', 'tuscaloosa': 'Tuscaloosa, AL',
    'tuscarawas co': 'Tuscarawas County, OH', 'twin falls': 'Twin Falls, ID',
    'twin tiers': 'Twin Tiers, NY', 'utica': 'Utica, NY',
    'valdosta': 'Valdosta, GA', 'ventura': 'Ventura County, CA',
    'vermont': 'Vermont, VT', 'victoria, TX': 'Victoria, TX',
    'visalia-tulare': 'Visalia-Tulare, CA', 'waco': 'Waco, TX',
    'washington, DC': 'Washington, DC', 'waterloo': 'Waterloo, IA',
    'watertown': 'Watertown, NY', 'wausau': 'Wausau, WI',
    'wenatchee': 'Wenatchee, WA', 'west virginia': 'West Virginia, WV',
    'western IL': 'Western Illinois Region, IL',
    'western KY': 'Western Kentucky Region, KY',
    'western MD': 'Western Maryland Region, MD',
    'western mass': 'Western Massachusetts Region, MA',
    'western slope': 'Western Slope, CO', 'wichita': 'Wichita, KS',
    'wichita falls': 'Wichita Falls, TX', 'williamsport': 'Williamsport, PA',
    'wilmington, NC': 'Wilmington, NC', 'winchester': 'Winchester, VA',
    'winston-salem': 'Winston-Salem, NC', 'worcester': 'Worcester, MA',
    'wyoming': 'Wyoming, WY', 'yakima': 'Yakima, WA',
    'yoopers': 'Upper Peninsula, MI', 'york, PA': 'York, PA',
    'youngstown': 'Youngstown, OH', 'yuba-sutter': 'Yuba-Sutter, CA',
    'yuma': 'Yuma, AZ', 'zanesville': 'Zanesville, OH',
}


def _state_from_full(full_name: str) -> str:
    """Extract two-letter state abbreviation from 'City Name, ST' string."""
    if not full_name:
        return ""
    parts = full_name.rsplit(",", 1)
    if len(parts) == 2:
        return parts[1].strip().split()[0].upper()
    return ""


def _city_label_from_full(full_name: str) -> str:
    """Return human-readable city portion from 'City Name, ST'."""
    if not full_name:
        return ""
    return full_name.rsplit(",", 1)[0].strip()


# ── Selenium driver factory ────────────────────────────────────────────────

def _make_driver():
    """Try Edge first, fall back to Firefox (headless)."""
    try:
        opts = EdgeOptions()
        opts.add_argument("--headless=new")
        opts.add_argument("--window-size=1920,1080")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--log-level=3")
        driver = webdriver.Edge(options=opts)
        driver.set_page_load_timeout(30)
        log.info("Using Microsoft Edge (headless)")
        return driver
    except Exception as e:
        log.warning(f"Edge unavailable ({e}), trying Firefox…")

    opts = FirefoxOptions()
    opts.add_argument("--headless")
    opts.add_argument("--width=1920")
    opts.add_argument("--height=1080")
    driver = webdriver.Firefox(options=opts)
    driver.set_page_load_timeout(30)
    log.info("Using Firefox (headless)")
    return driver


# ══════════════════════════════════════════════════════════════════════════
# PHASE 1 — Collect listing URLs via Selenium
# ══════════════════════════════════════════════════════════════════════════

def collect_listing_urls(city_slugs: list[str]) -> list[dict]:
    """
    For each city slug, scrape Craigslist search results (cars & trucks, today's posts).
    Returns list of dicts: {city_slug, city_full, state, url, title, price, tags}
    """
    checkpoint_file = CHECKPOINT_DIR / f"urls_{TODAY}.csv"
    if checkpoint_file.exists():
        log.info(f"Resuming from checkpoint: {checkpoint_file}")
        existing = pd.read_csv(checkpoint_file)
        done_cities = set(existing["city_slug"].unique())
        records = existing.to_dict("records")
    else:
        done_cities = set()
        records = []

    remaining = [c for c in city_slugs if c not in done_cities]
    if not remaining:
        log.info("All cities already checkpointed — skipping Phase 1.")
        return records

    log.info(f"Phase 1: collecting URLs for {len(remaining)} cities "
             f"({len(done_cities)} already done)")

    driver = _make_driver()
    try:
        for i, slug in enumerate(remaining, 1):
            full_name = CITY_TO_FULL.get(slug, "")
            state = _state_from_full(full_name)
            city_label = _city_label_from_full(full_name) or slug

            # Derive the subdomain from slug (CG uses slug as subdomain)
            subdomain = slug.replace(" ", "").replace(",", "").lower()
            base_url = f"https://{subdomain}.craigslist.org"
            search_url = f"{base_url}/search/cta?bundleDuplicates=1&postedToday=1"

            log.info(f"[{i}/{len(remaining)}] {slug} → {search_url}")
            city_records = _scrape_city_urls(driver, slug, city_label, state, search_url)
            records.extend(city_records)

            # Save checkpoint after every city
            pd.DataFrame(records).to_csv(checkpoint_file, index=False)

            time.sleep(2)  # polite rate limiting between cities
    finally:
        driver.quit()

    log.info(f"Phase 1 complete: {len(records)} listings collected across all cities.")
    return records


def _scrape_city_urls(driver, city_slug, city_label, state, search_url) -> list[dict]:
    records = []
    try:
        driver.get(search_url)
        time.sleep(4)

        # Get total count and page count
        try:
            total_el = driver.find_element(By.CLASS_NAME, "cl-page-number")
            total_text = total_el.text
            total = int(re.search(r"of\s*([\d,]+)", total_text).group(1).replace(",", ""))
            total_pages = (total // 120) + 1
        except (NoSuchElementException, AttributeError):
            # No listings or page counter not found
            return records

        log.info(f"  {city_label}: {total} listings, {total_pages} pages")

        for page in range(total_pages):
            page_url = f"{search_url}#search=1~gallery~{page}~0"
            driver.get(page_url)
            time.sleep(6)

            items = driver.find_elements(
                By.CSS_SELECTOR, "li.cl-search-result.cl-search-view-mode-gallery"
            )
            for item in items:
                try:
                    title_el = item.find_elements(By.CSS_SELECTOR, "span.label")
                    price_el = item.find_elements(By.CLASS_NAME, "priceinfo")
                    tag_el   = item.find_elements(By.CLASS_NAME, "meta")
                    link_el  = item.find_elements(By.TAG_NAME, "a")

                    records.append({
                        "city_slug":  city_slug,
                        "city_label": city_label,
                        "state":      state,
                        "url":        link_el[0].get_attribute("href") if link_el else None,
                        "title":      title_el[0].text if title_el else None,
                        "price":      price_el[0].text if price_el else None,
                        "tags":       tag_el[0].text if tag_el else None,
                    })
                except Exception:
                    pass

    except (TimeoutException, WebDriverException) as e:
        log.warning(f"  Skipped {city_label}: {e}")

    return records


# ══════════════════════════════════════════════════════════════════════════
# PHASE 2 — Scrape post details with requests + BeautifulSoup
# ══════════════════════════════════════════════════════════════════════════

def scrape_post_details(url_records: list[dict]) -> pd.DataFrame:
    """
    Visit each listing URL and extract vehicle attributes.
    Uses requests+BS4 (no Selenium — 10–20× faster).
    """
    log.info(f"Phase 2: scraping details for {len(url_records)} posts…")
    session = requests.Session()
    session.headers.update(HEADERS)

    results = []
    for i, rec in enumerate(url_records, 1):
        url = rec.get("url")
        if not url:
            continue

        if i % 100 == 0:
            log.info(f"  Progress: {i}/{len(url_records)}")

        attrs = _fetch_post(session, url, max_retries=3)
        row = {
            "Date":          datetime.now().strftime("%Y-%m-%d"),
            "URL":           url,
            "City":          rec.get("city_label", rec.get("city_slug", "")),
            "State":         rec.get("state", ""),
            "Price":         _parse_price(rec.get("price", "")),
            "description":   attrs.get("description", ""),
            "Manufacturer":  attrs.get("manufacturer", ""),
            "Model":         attrs.get("model", ""),
            "Year":          attrs.get("year"),
            "Odometer":      attrs.get("odometer"),
            "fuel":          attrs.get("fuel", ""),
            "title status":  attrs.get("title_status", ""),
            "transmission":  attrs.get("transmission", ""),
            "VIN":           attrs.get("vin", ""),
            "condition":     attrs.get("condition", ""),
            "cylinders":     attrs.get("cylinders", ""),
            "drive":         attrs.get("drive", ""),
            "paint color":   attrs.get("paint_color", ""),
            "type":          attrs.get("type", ""),
        }
        results.append(row)
        time.sleep(0.4)  # ~0.4s per post → ~400 posts/min

    df = pd.DataFrame(results)
    log.info(f"Phase 2 complete: {len(df)} rows scraped.")
    return df


def _fetch_post(session: requests.Session, url: str, max_retries: int = 3) -> dict:
    """Fetch one CG post page and parse all vehicle attributes."""
    attrs = {}
    for attempt in range(max_retries):
        try:
            resp = session.get(url, timeout=15)
            if resp.status_code == 404:
                return {"error": "404"}
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "html.parser")

            # ── Description ──
            body = soup.find(id="postingbody")
            attrs["description"] = body.get_text(" ", strip=True) if body else ""

            # ── Structured attributes from the attribute grid ──
            for span in soup.select("span.attrgroup span"):
                txt = span.get_text(strip=True).lower()
                label_el = span.find("b") or span.find("span", class_="labl")
                label = label_el.get_text(strip=True).lower().rstrip(":") if label_el else ""
                value_el = span.find("span", class_="valu") or span
                value = value_el.get_text(strip=True)

                if "year" in label or span.get("class", []) == ["valu", "year"]:
                    attrs.setdefault("year", _safe_int(value))
                elif "make" in label or "makemodel" in span.get("class", []):
                    _parse_makemodel(value, attrs)
                elif "odometer" in label:
                    attrs.setdefault("odometer", _safe_int(re.sub(r"[^\d]", "", value)))
                elif "fuel" in label:
                    attrs.setdefault("fuel", value)
                elif "title" in label:
                    attrs.setdefault("title_status", value)
                elif "transmission" in label:
                    attrs.setdefault("transmission", value)
                elif "vin" in label:
                    attrs.setdefault("vin", value)
                elif "condition" in label:
                    attrs.setdefault("condition", value)
                elif "cylinders" in label:
                    attrs.setdefault("cylinders", value)
                elif "drive" in label:
                    attrs.setdefault("drive", value)
                elif "paint" in label or "color" in label:
                    attrs.setdefault("paint_color", value)
                elif "type" in label:
                    attrs.setdefault("type", value)

            # ── Fallback: parse from the mapAndAttrs div (older CG layout) ──
            for div in soup.select("div.mapAndAttrs"):
                yr_el = div.select_one("span.valu.year")
                if yr_el:
                    attrs.setdefault("year", _safe_int(yr_el.get_text(strip=True)))
                mm_el = div.select_one("a.valu.makemodel")
                if mm_el:
                    _parse_makemodel(mm_el.get_text(strip=True), attrs)
                for span in div.select("span.valu"):
                    classes = span.get("class", [])
                    txt = span.get_text(strip=True).lower()
                    if "auto" in txt or "manual" in txt:
                        attrs.setdefault("transmission", txt)
                    elif "cylinders" in txt:
                        attrs.setdefault("cylinders", txt)
                    elif txt in ("fwd", "rwd", "4wd", "awd"):
                        attrs.setdefault("drive", txt)
                    elif txt in ("gas", "diesel", "hybrid", "electric", "other"):
                        attrs.setdefault("fuel", txt)

            return attrs

        except requests.RequestException as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
            else:
                log.debug(f"Failed to fetch {url}: {e}")
    return attrs


def _parse_makemodel(text: str, attrs: dict):
    """Split 'Toyota Camry' or '2019 Toyota Camry' into manufacturer + model."""
    parts = [p for p in text.split() if not p.isdigit()]
    if len(parts) >= 2:
        attrs.setdefault("manufacturer", parts[0].upper())
        attrs.setdefault("model", " ".join(parts[1:]).upper())
    elif len(parts) == 1:
        attrs.setdefault("manufacturer", parts[0].upper())


def _parse_price(price_str: str):
    if not price_str:
        return None
    cleaned = re.sub(r"[^\d]", "", price_str)
    return int(cleaned) if cleaned else None


def _safe_int(val):
    try:
        return int(str(val).replace(",", "").strip())
    except (ValueError, TypeError):
        return None


# ══════════════════════════════════════════════════════════════════════════
# PHASE 3 — Save CSV + deduplicate + load to SQL Server
# ══════════════════════════════════════════════════════════════════════════

def _get_engine():
    if not DB_SERVER:
        raise EnvironmentError(
            "DB_SERVER not set in .env — cannot connect to SQL Server. "
            "Set DB_SERVER, DB_NAME, DB_USER, DB_PASSWORD in .env"
        )
    driver_escaped = DB_DRIVER.replace(" ", "+")
    if DB_USER and DB_PASSWORD:
        conn_str = (
            f"mssql+pyodbc://{DB_USER}:{DB_PASSWORD}@{DB_SERVER}/{DB_NAME}"
            f"?driver={driver_escaped}"
        )
    else:
        conn_str = (
            f"mssql+pyodbc://@{DB_SERVER}/{DB_NAME}"
            f"?driver={driver_escaped}&trusted_connection=yes"
        )
    return create_engine(conn_str, fast_executemany=True)


def save_and_load(df: pd.DataFrame, dry_run: bool = False):
    """Save CSV backup, deduplicate against DB, insert new rows."""
    if df.empty:
        log.warning("No data to save.")
        return

    # ── Save full CSV ──
    csv_path = DATA_DIR / f"scraped_data_{TODAY}.csv"
    df.to_csv(csv_path, index=False)
    log.info(f"CSV saved: {csv_path} ({len(df)} rows)")

    if dry_run:
        log.info("Dry-run mode — skipping DB load.")
        return

    # ── Connect to SQL Server ──
    try:
        engine = _get_engine()
    except EnvironmentError as e:
        log.error(str(e))
        return

    # ── Fetch existing URLs to deduplicate ──
    try:
        with engine.connect() as conn:
            existing_urls = pd.read_sql(
                text("SELECT URL FROM [dbo].[Used_Cars_DF]"), conn
            )["URL"].tolist()
        existing_set = set(existing_urls)
        log.info(f"DB has {len(existing_set)} existing URLs.")
    except Exception as e:
        log.error(f"Could not read existing URLs from DB: {e}")
        existing_set = set()

    # ── Filter to new rows only ──
    new_df = df[~df["URL"].isin(existing_set)].copy()
    log.info(f"New rows to insert: {len(new_df)} (skipping {len(df) - len(new_df)} duplicates)")

    if new_df.empty:
        log.info("Nothing new to insert.")
        return

    # ── Keep only columns that exist in the DB table ──
    insert_cols = [c for c in DB_COLUMNS if c in new_df.columns]
    insert_df = new_df[insert_cols].copy()

    # ── Type cleanup ──
    for col in ["Year", "Odometer", "Price"]:
        if col in insert_df.columns:
            insert_df[col] = pd.to_numeric(insert_df[col], errors="coerce")

    insert_df.fillna("", inplace=True)

    # ── Insert ──
    try:
        with engine.connect() as conn:
            insert_df.to_sql(
                "Used_Cars_DF", conn,
                schema="dbo",
                if_exists="append",
                index=False,
                chunksize=500,
            )
            conn.commit()
        log.info(f"Inserted {len(insert_df)} rows into [dbo].[Used_Cars_DF].")
    except Exception as e:
        log.error(f"DB insert failed: {e}")

    # ── Clean up checkpoint file after successful load ──
    checkpoint_file = CHECKPOINT_DIR / f"urls_{TODAY}.csv"
    if checkpoint_file.exists():
        checkpoint_file.unlink()
        log.info("Checkpoint file removed.")


# ══════════════════════════════════════════════════════════════════════════
# CLI entry point
# ══════════════════════════════════════════════════════════════════════════

def parse_args():
    parser = argparse.ArgumentParser(description="UCPP Craigslist scraper")
    parser.add_argument(
        "--cities",
        type=str,
        default="",
        help="Comma-separated list of city slugs to scrape (default: all 413 cities)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Save CSV but do not load into SQL Server",
    )
    parser.add_argument(
        "--skip-phase1",
        action="store_true",
        help="Skip URL collection (use today's existing checkpoint file)",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    # Resolve city list
    if args.cities:
        city_slugs = [c.strip() for c in args.cities.split(",") if c.strip()]
        invalid = [c for c in city_slugs if c not in CITY_TO_FULL]
        if invalid:
            log.warning(f"Unknown city slugs (will be skipped): {invalid}")
        city_slugs = [c for c in city_slugs if c in CITY_TO_FULL]
    else:
        city_slugs = list(CITY_TO_FULL.keys())

    log.info(f"═══ UCPP Scraper started — {TODAY} ═══")
    log.info(f"Cities: {len(city_slugs)}  |  Dry run: {args.dry_run}")

    # ── Phase 1 ──
    if args.skip_phase1:
        checkpoint_file = CHECKPOINT_DIR / f"urls_{TODAY}.csv"
        if checkpoint_file.exists():
            url_records = pd.read_csv(checkpoint_file).to_dict("records")
            log.info(f"Loaded {len(url_records)} URLs from checkpoint.")
        else:
            log.error("--skip-phase1 specified but no checkpoint file found for today.")
            sys.exit(1)
    else:
        url_records = collect_listing_urls(city_slugs)

    if not url_records:
        log.warning("No listing URLs collected — nothing to scrape.")
        return

    # ── Phase 2 ──
    details_df = scrape_post_details(url_records)

    # ── Phase 3 ──
    save_and_load(details_df, dry_run=args.dry_run)

    log.info(f"═══ Scrape complete ═══")


if __name__ == "__main__":
    main()
