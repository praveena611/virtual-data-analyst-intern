"""
Data loading and extraction utility functions.
"""

from pathlib import Path
from typing import Optional, Union
import pandas as pd
from .config import RAW_DATA_DIR, PROCESSED_DATA_DIR


def load_raw_csv(filename: Union[str, Path], **kwargs) -> pd.DataFrame:
    """
    Load a raw CSV dataset from the data/raw directory.
    """
    filepath = RAW_DATA_DIR / filename
    if not filepath.exists():
        raise FileNotFoundError(f"File not found: {filepath}")
    return pd.read_csv(filepath, **kwargs)


def load_processed_csv(filename: Union[str, Path], **kwargs) -> pd.DataFrame:
    """
    Load a processed CSV dataset from the data/processed directory.
    """
    filepath = PROCESSED_DATA_DIR / filename
    if not filepath.exists():
        raise FileNotFoundError(f"File not found: {filepath}")
    return pd.read_csv(filepath, **kwargs)


def save_processed_data(df: pd.DataFrame, filename: Union[str, Path], index: bool = False, **kwargs) -> Path:
    """
    Save cleaned dataframe to data/processed directory.
    """
    PROCESSED_DATA_DIR.mkdir(parents=True, exist_ok=True)
    target_path = PROCESSED_DATA_DIR / filename
    df.to_csv(target_path, index=index, **kwargs)
    return target_path
