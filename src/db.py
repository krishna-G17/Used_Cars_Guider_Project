"""
SQL Server connection utility for UCPP.

Required .env variables:
    DB_SERVER   — e.g. localhost\\SQLEXPRESS  or  your-server.database.windows.net
    DB_NAME     — e.g. test_UCPP
    DB_USER     — SQL login username  (leave blank to use Windows Auth)
    DB_PASSWORD — SQL login password  (leave blank to use Windows Auth)
    DB_DRIVER   — optional, defaults to 'ODBC Driver 17 for SQL Server'
"""

import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

_SERVER   = os.getenv("DB_SERVER", "")
_DATABASE = os.getenv("DB_NAME", "test_UCPP")
_USER     = os.getenv("DB_USER", "")
_PASSWORD = os.getenv("DB_PASSWORD", "")
_DRIVER   = os.getenv("DB_DRIVER", "ODBC Driver 17 for SQL Server")


def get_connection() -> pyodbc.Connection:
    """Return a live pyodbc connection to the SQL Server database."""
    if not _SERVER:
        raise EnvironmentError(
            "DB_SERVER is not set in .env. "
            "Add DB_SERVER, DB_NAME, DB_USER, DB_PASSWORD to your .env file."
        )

    if _USER and _PASSWORD:
        conn_str = (
            f"DRIVER={{{_DRIVER}}};"
            f"SERVER={_SERVER};"
            f"DATABASE={_DATABASE};"
            f"UID={_USER};"
            f"PWD={_PASSWORD};"
        )
    else:
        # Windows Authentication (Trusted Connection)
        conn_str = (
            f"DRIVER={{{_DRIVER}}};"
            f"SERVER={_SERVER};"
            f"DATABASE={_DATABASE};"
            "Trusted_Connection=yes;"
        )

    return pyodbc.connect(conn_str)
