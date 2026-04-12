import pandas as pd
import numpy as np

try:
    df = pd.read_csv('../Resume.csv')
    print("Columns:", df.columns.tolist())
    print("Categories:", df['Category'].unique().tolist())
    print("\nSamples per Category:\n", df['Category'].value_counts())
except Exception as e:
    print(f"Error reading dataset: {e}")
