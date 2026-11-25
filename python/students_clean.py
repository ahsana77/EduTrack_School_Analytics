import pandas as pd
df = pd.read_csv("data/raw_data/students.csv")

print("Total original records:",len(df))

#check exact duplicates
duplicates = df.duplicated().sum()
print("\n Exact duplicates:",duplicates)

# duplicate student's ids
print("\n Duplicate student ids",df["student_id"].duplicated().sum())

#check missing values
print("\n missing values:",df.isnull().sum())

#remove unnecessary spaces from text cols
# selects col names that have dtype object to text_col as a list
text_cols = df.select_dtypes(include=["object","string"]).columns
for column in text_cols:
    df[column] = df[column].str.strip()

# remove duplicate rows
df = df.drop_duplicates()
print("Gender:",df["gender"].unique())
print("Grades:",sorted(df["grade"].unique()))
print("Sections:",df["section"].unique())
print("Nationalities:",df["nationality"].unique())

#to check whether the class is same as combined value of grade and section
# grade is numeric change it into text
mismatch = (df["class"] != df["grade"].astype(str) + df["section"]).sum()
print("class mismatches:",mismatch)



# save cleaned dataset
df.to_csv("data/cleaned_data/students.csv",index = False)

print("\n After cleaning:")
print("\n Total records:",len(df))
print("Duplicate student ids:",df["student_id"].duplicated().sum())

print("\n Student data cleaning completed!")

