"""
Database connection utility for UCPP.

Supports two backends — the active one is chosen by .env:

  SQLite (default / local development)
  ─────────────────────────────────────
  DB_PATH = Notebooks/Scraping/UCPP_test.db   ← relative to project root
             (or an absolute path)

  SQL Server (production / cloud)
  ────────────────────────────────
  DB_SERVER   = .\SQLEXPRESS  (or your server name)
  DB_NAME     = test_UCPP
  DB_USER     = (blank = Windows Auth)
  DB_PASSWORD = (blank = Windows Auth)
  DB_DRIVER   = ODBC Driver 17 for SQL Server

If DB_PATH is set, SQLite is used and SQL Server settings are ignored.
"""

import os
import sqlite3
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

_DB_PATH   = os.getenv("DB_PATH", "")
_SERVER    = os.getenv("DB_SERVER", "")
_DATABASE  = os.getenv("DB_NAME", "test_UCPP")
_USER      = os.getenv("DB_USER", "")
_PASSWORD  = os.getenv("DB_PASSWORD", "")
_DRIVER    = os.getenv("DB_DRIVER", "ODBC Driver 17 for SQL Server")

# Resolve DB_PATH relative to the project root (two levels up from src/)
_PROJECT_ROOT = Path(__file__).resolve().parents[1]


def get_connection():
    """Return a live database connection (sqlite3 or pyodbc)."""
    if _DB_PATH:
        return _sqlite_connection()
    if _SERVER:
        return _sqlserver_connection()
    # Default fallback: look for the SQLite file in the standard location
    default = _PROJECT_ROOT / "Notebooks" / "Scraping" / "UCPP_test.db"
    if default.exists():
        return sqlite3.connect(str(default))
    raise EnvironmentError(
        "No database configured. Add DB_PATH (SQLite) or DB_SERVER (SQL Server) to .env"
    )


def _sqlite_connection():
    path = Path(_DB_PATH)
    if not path.is_absolute():
        path = _PROJECT_ROOT / path
    if not path.exists():
        raise FileNotFoundError(f"SQLite database not found: {path}")
    conn = sqlite3.connect(str(path))
    conn.row_factory = sqlite3.Row   # allows dict-like access to rows
    return conn


def _sqlserver_connection():
    import pyodbc
    if _USER and _PASSWORD:
        conn_str = (
            f"DRIVER={{{_DRIVER}}};"
            f"SERVER={_SERVER};"
            f"DATABASE={_DATABASE};"
            f"UID={_USER};"
            f"PWD={_PASSWORD};"
        )
    else:
        conn_str = (
            f"DRIVER={{{_DRIVER}}};"
            f"SERVER={_SERVER};"
            f"DATABASE={_DATABASE};"
            "Trusted_Connection=yes;"
        )
    return pyodbc.connect(conn_str)
