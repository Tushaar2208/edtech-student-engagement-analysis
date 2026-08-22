import sqlite3
import pandas as pd
from pathlib import Path

# ==========================================================
# CONFIGURATION
# ==========================================================

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"
DB_PATH = PROJECT_DIR / "oulad.db"

# ==========================================================
# CSV FILES
# ==========================================================

FILES = {
    "assessments": "assessments.csv",
    "courses": "courses.csv",
    "studentAssessments": "studentAssessment.csv",
    "studentInfo": "studentinfo.csv",
    "studentRegistration": "studentRegistration.csv",
    "studentVle": "studentVle.csv",
    "vle": "vle.csv"
}

# ==========================================================
# CREATE DATABASE
# ==========================================================

print("Creating OULAD database...")

conn = sqlite3.connect(DB_PATH)

# ==========================================================
# IMPORT CSVs
# ==========================================================

for table_name, filename in FILES.items():

    file_path = DATA_DIR / filename

    print(f"Loading {filename}...")

    df = pd.read_csv(file_path)

    df.to_sql(
        table_name,
        conn,
        if_exists="replace",
        index=False
    )

    print(f"  ✓ {table_name}: {len(df):,} rows")

# ==========================================================
# VERIFY
# ==========================================================

print("\nDatabase created successfully.")
print(f"Location: {DB_PATH}")

cursor = conn.cursor()

cursor.execute("""
    SELECT name
    FROM sqlite_master
    WHERE type='table'
    ORDER BY name;
""")

tables = cursor.fetchall()

print("\nTables:")
for table in tables:
    print(f"  ✓ {table[0]}")

conn.close()

print("\nSetup complete.")