import pandas as pd
df = pd.read_csv("data/raw_data/attendance.csv")

# standardise status col
df["status"] = df["status"].str.strip().str.title()

print("\n attendance status after cleaning:")
print(df["status"].value_counts())

# checks unexpected values
valid_statuses = ["Present","Absent","Excused"]
unexpected = df[~df["status"].isin(valid_statuses)]
print("\n unexpected records:")
print(unexpected)

# to save cleaned dataset
df.to_csv("data/cleaned_data/attendance.csv", index=False)
print("Saved cleaned attendance dataset")

#to verify it is cleaned
cleaned_df = pd.read_csv("data/cleaned_data/attendance.csv")
print("\n verification:")
print("\n Total records:",len(cleaned_df))
print("\n Missing value counts:",cleaned_df.isnull().sum().sum())
print("Duplicate rows:", cleaned_df.duplicated().sum())
print("\nunique statuses:",cleaned_df["status"].unique())