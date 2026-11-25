import pandas as pd

# read original dataset
df = pd.read_csv("data/raw_data/exam_results.csv")

# check original no.of records
print("Original records:",len(df))

# count exact duplicate rows
duplicates = df.duplicated().sum()
print("\n Duplicate rows:",duplicates)

#identify repeated student - subject - term combinations
# count missing marks
missing = df["score"].isna().sum()
print("Total missing scores:",missing)

# Check score range
print("Minimum score",df["score"].min())
print("Max score:",df["score"].max())

# check invalid scores
invalid_scores = df[(df["score"]<0) | (df["score"]>100)]
print("\nInvalid scores:",len(invalid_scores))
print(invalid_scores)

# detect outliers using IQR
Q1 = df["score"].quantile(0.25)
Q3 = df["score"].quantile(0.75)
IQR = Q3 - Q1
lower_limit = Q1 - 1.5*IQR
upper_limit = Q3 + 1.5*IQR

outliers = df[(df["score"] < lower_limit)|(df["score"] > upper_limit)]
print("\n IQR lower limits:",lower_limit)
print("\n IQR upper limits:",upper_limit)
print("\noutliers:",len(outliers))
print("\n outlier records:")
print(outliers[["student_id","subject","term","score"]].sort_values("score"))

# save outliers seperatly for review
outliers.to_csv("data/cleaned_data/exam_outliers.csv",index=False)


#remove duplicate records
df = df.drop_duplicates()

#identify repeated student - subject - term combinations with different marks
duplicate_records = df[df.duplicated(subset=["student_id","subject","term"],keep=False)].sort_values(by=["student_id","subject","term"])
print("\nrepeated student-subject-term records:",duplicate_records)
print("\n total non exact duplicates: ",len(duplicate_records))

# flag missing and invalid scores
df["score_check"] = "valid"
df.loc[df["score"].isna(),"score_check"] = "Missing score - Review"
df.loc[(df["score"] < 0) | (df["score"]>100),"score_check"] = "Invalid score - Review"

# flag outliers
df["outlier_check"] = "Normal range"
df.loc[(df["score"]<lower_limit) | (df["score"]>upper_limit),"outlier_check"] = "Outlier - Review"
df.loc[df["score"].isna(),"outlier_check"] = "Missing score"

# save cleaned dataset
df.to_csv("data/cleaned_data/exam_results.csv",index=False)

# verify cleaned dataset
print("\n After cleaning:")
print("\nTotal records:",len(df))
print("\nRemaining duplicates:",df.duplicated().sum())
print("\n Missing scores:",df["score"].isna().sum())
print("\n score summary:",df["score_check"].value_counts(dropna=False))
print("\n outlier summary:",df["outlier_check"].value_counts(dropna=False))


print("\n Exam results cleaning completed!")

missing_scoresdf = df[df["score"].isnull()]
missing_scoresdf.to_csv("data/cleaned_data/missing_exam_c" \
"scores.csv",index = False)
print("Missing score records:",len(missing_scoresdf))