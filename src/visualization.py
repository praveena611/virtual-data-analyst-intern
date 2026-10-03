"""
Reusable visualization functions using Matplotlib and Seaborn.
"""

from pathlib import Path
from typing import Optional, Tuple
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from .config import FIGURES_DIR, DEFAULT_FIGSIZE, DPI

# Apply clean visual styling
sns.set_theme(style="whitegrid", palette="muted")


def plot_distribution(
    df: pd.DataFrame,
    column: str,
    title: Optional[str] = None,
    save_filename: Optional[str] = None,
    figsize: Tuple[int, int] = DEFAULT_FIGSIZE,
) -> plt.Figure:
    """
    Plot a histogram with KDE overlay for a numerical column.
    """
    fig, ax = plt.subplots(figsize=figsize)
    sns.histplot(df[column], kde=True, ax=ax, color="#2b5c8f")
    ax.set_title(title or f"Distribution of {column}", fontsize=14, fontweight="bold", pad=12)
    ax.set_xlabel(column.replace("_", " ").title(), fontsize=12)
    ax.set_ylabel("Frequency", fontsize=12)
    plt.tight_layout()

    if save_filename:
        save_plot(fig, save_filename)
    return fig


def save_plot(fig: plt.Figure, filename: str, dpi: int = DPI) -> Path:
    """
    Save figure to reports/figures directory.
    """
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    out_path = FIGURES_DIR / filename
    fig.savefig(out_path, dpi=dpi, bbox_inches="tight")
    print(f"Figure saved to {out_path}")
    return out_path
