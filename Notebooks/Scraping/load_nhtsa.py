"""
UCPP — NHTSA Data Loader
=========================
Run this script whenever you've manually downloaded a new NHTSA complaints
Excel file from the NHTSA website to add it to the project.

Steps:
  1. Download the file from: https://www.nhtsa.gov/complaints
     (or from: https://static.nhtsa.gov/odi/ffdd/cmpl/FLAT_CMPL.zip)
  2. Save the file as  Complaints_YYYY_YYYY.xlsx  in:
       Notebooks/Complaints_NLP/Complaints_Data/
  3. Run this script:
       python load_nhtsa.py --file "Complaints_2024_2025.xlsx"

The script:
  - Validates the file has the expected columns
  - Removes any duplicate Complaint IDs already present in other files
  - Saves the validated file to the Complaints_Data folder
  - Prints a summary
  - After adding, restart the Flask app (or hit /api/nhtsa-reload) so the
    in-memory cache picks up the new data

Usage
-----
  python load_nhtsa.py --file path/to/your/new_nhtsa_file.xlsx
  python load_nhtsa.py --file path/to/your/new_nhtsa_file.xlsx --dest-name "Complaints_2024_2025.xlsx"
  python load_nhtsa.py --validate-all   # just validate existing files
"""

import argparse
import glob
import shutil
import sys
from pathlib import Path

import pandas as pd

COMPLAINTS_DIR = (
    Path(__file__).resolve().parents[2]
    / "Notebooks" / "Complaints_NLP" / "Complaints_Data"
)

REQUIRED_COLS = [
    "MAKETXT", "MODELTXT", "YEAR", "COMPDESC", "CDESCR",
]
RECOMMENDED_COLS = [
    "Complaint ID", "NHTSA Refno", "Manufacturer_name",
    "CRASH", "FIRE", "INJURED", "DEATHS", "FAILDATE",
    "CITY", "STATE", "VIN", "DATEA", "MILES",
]


def _load_file(path: Path) -> pd.DataFrame:
    ext = path.suffix.lower()
    if ext in (".xlsx", ".xls"):
        return pd.read_excel(path)
    elif ext == ".csv":
        return pd.read_csv(path)
    else:
        raise ValueError(f"Unsupported file type: {ext}. Use .xlsx or .csv")


def validate_file(path: Path) -> pd.DataFrame:
    """Load and validate that the file has the required columns."""
    print(f"Loading: {path.name} …")
    df = _load_file(path)
    print(f"  Rows: {len(df):,}  |  Columns: {len(df.columns)}")

    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        print(f"  ERROR — Missing required columns: {missing}")
        print(f"  Available columns: {df.columns.tolist()}")
        sys.exit(1)

    missing_rec = [c for c in RECOMMENDED_COLS if c not in df.columns]
    if missing_rec:
        print(f"  WARNING — Missing recommended columns (non-fatal): {missing_rec}")

    makes  = df["MAKETXT"].nunique()
    models = df["MODELTXT"].nunique()
    years  = f"{int(df['YEAR'].min())}–{int(df['YEAR'].max())}"
    top_makes = df["MAKETXT"].value_counts().head(5).to_dict()

    print(f"  Makes: {makes}  |  Models: {models}  |  Year range: {years}")
    print(f"  Top makes: {top_makes}")
    return df


def get_existing_ids() -> set:
    """Collect all Complaint IDs already present in Complaints_Data/."""
    ids = set()
    for f in glob.glob(str(COMPLAINTS_DIR / "Complaints_*.xlsx")):
        try:
            df = pd.read_excel(f, usecols=["Complaint ID"])
            ids.update(df["Complaint ID"].dropna().tolist())
        except Exception:
            pass
    return ids


def load_new_file(source_path: Path, dest_name: str | None = None):
    """Validate, deduplicate, and copy a new NHTSA file into Complaints_Data/."""
    source_path = Path(source_path).resolve()
    if not source_path.exists():
        print(f"ERROR: File not found: {source_path}")
        sys.exit(1)

    # ── Validate ──
    df = validate_file(source_path)

    # ── Deduplicate by Complaint ID (if column exists) ──
    if "Complaint ID" in df.columns:
        existing_ids = get_existing_ids()
        before = len(df)
        df = df[~df["Complaint ID"].isin(existing_ids)]
        removed = before - len(df)
        if removed:
            print(f"  Removed {removed:,} duplicate Complaint IDs already in DB.")
        print(f"  Net new records: {len(df):,}")
    else:
        print("  No 'Complaint ID' column — skipping duplicate check.")

    if df.empty:
        print("  No new records to add — file already fully present.")
        return

    # ── Determine destination filename ──
    if dest_name:
        dest_filename = dest_name
    else:
        # Use the source filename or prompt for a name
        dest_filename = source_path.name
        if not dest_filename.startswith("Complaints_"):
            # Try to infer year range
            if "YEAR" in df.columns:
                min_yr = int(df["YEAR"].min())
                max_yr = int(df["YEAR"].max())
                dest_filename = f"Complaints_{min_yr}_{max_yr}.xlsx"
            else:
                dest_filename = f"Complaints_new_{source_path.stem}.xlsx"

    dest_path = COMPLAINTS_DIR / dest_filename

    if dest_path.exists():
        print(f"  WARNING: {dest_filename} already exists in Complaints_Data/.")
        ans = input("  Overwrite? [y/N] ").strip().lower()
        if ans != "y":
            print("  Aborted.")
            return

    # ── Save deduplicated file ──
    if dest_path.suffix.lower() == ".xlsx":
        df.to_excel(dest_path, index=False)
    else:
        df.to_csv(dest_path, index=False)

    print(f"\n  Saved {len(df):,} records → {dest_path}")
    print("\nNext steps:")
    print("  1. Restart Flask app  (or hit GET /api/nhtsa-reload)")
    print("  2. Search for a make/model on the dashboard to verify the radar / word cloud updated.")


def validate_all():
    """Validate all existing files in Complaints_Data/."""
    files = sorted(glob.glob(str(COMPLAINTS_DIR / "Complaints_*.xlsx")))
    if not files:
        print("No Complaints_*.xlsx files found in Complaints_Data/")
        return
    total = 0
    for f in files:
        df = validate_file(Path(f))
        total += len(df)
        print()
    print(f"Total records across {len(files)} files: {total:,}")


def main():
    parser = argparse.ArgumentParser(description="UCPP NHTSA data loader")
    parser.add_argument("--file", type=str, help="Path to new NHTSA Excel/CSV file to add")
    parser.add_argument(
        "--dest-name", type=str,
        help="Target filename in Complaints_Data/ (e.g. Complaints_2024_2025.xlsx)"
    )
    parser.add_argument(
        "--validate-all", action="store_true",
        help="Validate all existing files in Complaints_Data/ and print summary"
    )
    args = parser.parse_args()

    if args.validate_all:
        validate_all()
    elif args.file:
        load_new_file(Path(args.file), args.dest_name)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
