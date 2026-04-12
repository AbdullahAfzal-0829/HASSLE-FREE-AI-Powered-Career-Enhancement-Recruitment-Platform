import pandas as pd
import numpy as np
import pickle
import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

print("Loading dataset...")
df = pd.read_csv('../Resume.csv')
df = df[['Resume_str', 'Category']].dropna()

print("Preparing vectors (TF-IDF)...")
vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
X = vectorizer.fit_transform(df['Resume_str'])
y = df['Category']

print("Training model (Logistic Regression)...")
model = LogisticRegression(max_iter=1000)
model.fit(X, y)

print("Saving model files...")
os.makedirs("hassle_free_model", exist_ok=True)
with open('hassle_free_model/model.pkl', 'wb') as f:
    pickle.dump(model, f)
with open('hassle_free_model/vectorizer.pkl', 'wb') as f:
    pickle.dump(vectorizer, f)

# Save the category list
categories = sorted(df['Category'].unique().tolist())
np.save('classes.npy', np.array(categories))

print(f"Success! Model trained on {len(df)} resumes.")
print("Model saved to hassle_free_model/model.pkl")
print("Vectorizer saved to hassle_free_model/vectorizer.pkl")
