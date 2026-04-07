"""
NHTSA complaints data loader and query helpers.

Loads all 6 Excel files into a single in-memory DataFrame on first use,
then answers radar-chart and word-cloud queries from that cache.

NHTSA key columns used:
    MAKETXT    — manufacturer name  (e.g. HONDA)
    MODELTXT   — model name         (e.g. ACCORD)
    YEAR       — model year
    COMPDESC   — component category (e.g. SERVICE BRAKES, ELECTRICAL SYSTEM)
    CDESCR     — free-text complaint description
    CRASH, FIRE, INJURED, DEATHS — safety flags
"""

import os
import re
import glob
from collections import Counter
from functools import lru_cache

import pandas as pd

_DATA_DIR = os.path.join(
    os.path.dirname(__file__), "..", "Notebooks", "Complaints_NLP", "Complaints_Data"
)

# Component buckets for the radar/spider chart
_RADAR_CATEGORIES = {
    "Engine":           ["ENGINE", "POWERTRAIN", "FUEL SYSTEM"],
    "Brakes":           ["BRAKE", "SERVICE BRAKE"],
    "Electrical":       ["ELECTRICAL", "WIRING"],
    "Airbags":          ["AIR BAG", "AIRBAG", "SEAT BELT"],
    "Suspension":       ["SUSPENSION", "STEERING", "WHEEL"],
    "Transmission":     ["TRANSMISSION", "DRIVELINE", "DRIVE"],
    "Structure":        ["STRUCTURE", "BODY", "VISIBILITY"],
    "Fuel":             ["FUEL SYSTEM", "FUEL SUPPLY", "GAS"],
}

# Stopwords to strip from word cloud
_STOPWORDS = {
    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
    "of", "is", "it", "was", "are", "be", "has", "had", "have", "with",
    "this", "that", "my", "me", "i", "they", "their", "our", "from",
    "not", "no", "can", "did", "do", "when", "after", "while", "if",
    "been", "were", "so", "as", "by", "its", "we", "he", "she", "his",
    "her", "than", "then", "also", "would", "could", "should", "said",
    "there", "which", "who", "more", "than", "about", "up", "out", "all",
    "car", "vehicle", "dealer", "driving", "miles", "contact",
}


@lru_cache(maxsize=1)
def _load_all() -> pd.DataFrame:
    """Load all NHTSA Excel files into one DataFrame (cached after first call)."""
    pattern = os.path.join(_DATA_DIR, "Complaints_*.xlsx")
    files = glob.glob(pattern)
    if not files:
        raise FileNotFoundError(f"No NHTSA Excel files found in {_DATA_DIR}")

    frames = []
    for f in sorted(files):
        try:
            df = pd.read_excel(f, usecols=["MAKETXT", "MODELTXT", "YEAR", "COMPDESC", "CDESCR"])
            frames.append(df)
        except Exception:
            pass

    if not frames:
        raise RuntimeError("Could not read any NHTSA Excel files.")

    combined = pd.concat(frames, ignore_index=True)
    combined["MAKETXT"]  = combined["MAKETXT"].astype(str).str.upper().str.strip()
    combined["MODELTXT"] = combined["MODELTXT"].astype(str).str.upper().str.strip()
    combined["COMPDESC"] = combined["COMPDESC"].astype(str).str.upper().str.strip()
    combined["CDESCR"]   = combined["CDESCR"].astype(str).str.upper().str.strip()
    return combined


def _filter(manufacturer: str, model: str, year=None) -> pd.DataFrame:
    df = _load_all()
    mask = pd.Series([True] * len(df), index=df.index)
    if manufacturer:
        mask &= df["MAKETXT"].str.contains(manufacturer.upper(), na=False)
    if model:
        mask &= df["MODELTXT"].str.contains(model.upper(), na=False)
    if year:
        try:
            mask &= df["YEAR"] == int(year)
        except (ValueError, TypeError):
            pass
    return df[mask]


def get_nhtsa_radar(manufacturer: str, model: str, year=None) -> dict:
    """
    Return complaint counts per radar category for a given make/model/year.
    Each key is a category name, value is the complaint count.
    Scores are normalised 0–100 relative to the max category.
    """
    subset = _filter(manufacturer, model, year)
    if subset.empty:
        return {cat: 0 for cat in _RADAR_CATEGORIES}

    raw_counts = {}
    for cat, keywords in _RADAR_CATEGORIES.items():
        pat = "|".join(keywords)
        count = subset["COMPDESC"].str.contains(pat, na=False).sum()
        raw_counts[cat] = int(count)

    max_val = max(raw_counts.values()) or 1
    normalised = {cat: round(count / max_val * 100, 1)
                  for cat, count in raw_counts.items()}
    # Also return raw counts for tooltip
    return {"scores": normalised, "raw": raw_counts, "total": int(len(subset))}


def get_nhtsa_wordcloud(manufacturer: str, model: str, year=None, top_n: int = 80) -> list:
    """
    Return a list of {text, value} dicts suitable for wordcloud2.js.
    """
    subset = _filter(manufacturer, model, year)
    if subset.empty:
        return []

    text = " ".join(subset["CDESCR"].dropna().tolist())
    words = re.findall(r"[A-Z]{3,}", text)   # only uppercase words ≥ 3 chars
    counts = Counter(w for w in words if w.lower() not in _STOPWORDS)
    top = counts.most_common(top_n)

    if not top:
        return []

    max_freq = top[0][1]
    return [{"text": word, "value": round(freq / max_freq * 100, 1)}
            for word, freq in top]
