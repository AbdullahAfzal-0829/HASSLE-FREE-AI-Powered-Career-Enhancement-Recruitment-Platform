import pandas as pd
import numpy as np
import torch
import os
from sklearn.model_selection import train_test_split
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments
from datasets import Dataset

# 1. Load and Prepare Data
print("Loading dataset...")
df = pd.read_csv('../Resume.csv')
df = df[['Resume_str', 'Category']].dropna()

# 2. Encode Labels
categories = sorted(df['Category'].unique().tolist())
label2id = {label: i for i, label in enumerate(categories)}
id2label = {i: label for i, label in enumerate(categories)}
np.save('classes.npy', np.array(categories))
print(f"Categories found: {len(categories)}")

df['label'] = df['Category'].map(label2id)

# 3. Create Train/Test Split
train_df, val_df = train_test_split(df, test_size=0.1, stratify=df['label'], random_state=42)

# 4. Tokenization
model_name = "distilbert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)

def tokenize_function(examples):
    return tokenizer(examples['Resume_str'], padding="max_length", truncation=True, max_length=512)

train_ds = Dataset.from_pandas(train_df[['Resume_str', 'label']])
val_ds = Dataset.from_pandas(val_df[['Resume_str', 'label']])

print("Tokenizing data...")
train_ds = train_ds.map(tokenize_function, batched=True)
val_ds = val_ds.map(tokenize_function, batched=True)

# 5. Load Model
model = AutoModelForSequenceClassification.from_pretrained(
    model_name, 
    num_labels=len(categories),
    id2label=id2label,
    label2id=label2id
)

# 6. Training Configuration
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=2,              # 2 epochs balance time and accuracy
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    warmup_steps=100,
    weight_decay=0.01,
    logging_dir="./logs",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    logging_steps=50,
)

# 7. Trainer Object
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_ds,
    eval_dataset=val_ds,
)

# 8. Start Training
print("Starting training (this may take a few minutes)...")
trainer.train()

# 9. Save Final Model
output_path = "hassle_free_model"
model.save_pretrained(output_path)
tokenizer.save_pretrained(output_path)
print(f"Success! Model saved to {output_path}")
print(f"Classes saved to classes.npy")
