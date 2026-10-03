"""
Analytical modeling, statistical summaries, and KPI computation module.
"""

from typing import Dict, Any, List
import pandas as pd
import numpy as np


def compute_summary_statistics(df: pd.DataFrame, numerical_cols: List[str]) -> pd.DataFrame:
    """
    Compute comprehensive descriptive statistics (mean, median, std, IQR).
    """
    stats = df[numerical_cols].describe().T
    stats["median"] = df[numerical_cols].median()
    stats["iqr"] = stats["75%"] - stats["25%"]
    return stats


def compute_kpis(df: pd.DataFrame, metric_col: str, group_by_col: str) -> pd.DataFrame:
    """
    Aggregate metrics by group to derive key business indicators.
    """
    kpis = df.groupby(group_by_col).agg(
        total_count=(metric_col, "count"),
        total_value=(metric_col, "sum"),
        average_value=(metric_col, "mean"),
        median_value=(metric_col, "median"),
    ).reset_index()
    return kpis.sort_values(by="total_value", ascending=False)
