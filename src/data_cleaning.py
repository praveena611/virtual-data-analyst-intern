"""
Data cleaning, validation, and preprocessing pipeline functions.
"""

from typing import List, Optional
import pandas as pd
import numpy as np


def standardize_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convert column names to lower_snake_case and strip whitespace.
    """
    df = df.copy()
    df.columns = (
        df.columns.astype(str)
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace(r"[^\w\s]", "", regex=True)
    )
    return df


def remove_duplicates(df: pd.DataFrame, subset: Optional[List[str]] = None) -> pd.DataFrame:
    """
    Remove duplicated rows and print count summary.
    """
    df = df.copy()
    initial_count = len(df)
    df = df.drop_duplicates(subset=subset)
    removed = initial_count - len(df)
    print(f"Removed {removed} duplicate rows (Remaining: {len(df)})")
    return df


def summarize_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """
    Calculate counts and percentages of missing values across all columns.
    """
    missing_count = df.isnull().sum()
    missing_pct = (missing_count / len(df)) * 100
    summary = pd.DataFrame({"missing_count": missing_count, "missing_percent": missing_pct})
    return summary[summary["missing_count"] > 0].sort_values(by="missing_count", ascending=False)
