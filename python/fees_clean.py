import pandas as pd
df = pd.read_csv("data/raw_data/fees.csv")

# convert paid_date into date format
df["paid_date"] = pd.to_datetime(df["paid_date"],errors="coerce")

reference_date = pd.Timestamp("2026-10-31")
df["balance_amount"] = (df["amount_due"] - df["amount_paid"])

df["date_check"] = "Valid date"
# then change the value 'valid' date to 'verify' if paid date is in future
df.loc[df["paid_date"].isna(),"date_check"] = "No payment date"
df.loc[df["paid_date"] > reference_date,"date_check"] = "Future dated - Verify"

# creating balance amount col

# create payment status col
df["payment_status"] = "Partially Paid"
df.loc[df["amount_paid"] == 0,"payment_status"] = "Unpaid"
df.loc[df["balance_amount"] == 0,"payment_status"] = "Paid"


# save cleaned dataset
df.to_csv("data/cleaned_data/fees.csv",index=False)


#to verify results
print("Payment status counts:")
print(df["payment_status"].value_counts())

print("\nMissing payment dates:")
print(df["paid_date"].isnull().sum())

print("\nBlank paid dates:",df["paid_date"].isna().sum())

print("\n Balance amount total:")
print(df["balance_amount"].sum())

print("\nDate Validation:")
print(df["date_check"].value_counts())

print("\nTotal records:",len(df))

unpaid_df = df[df["payment_status"] == "Unpaid"]
unpaid_df.to_csv("data/cleaned_data/unpaid_fees.csv",index = False)
print("unpaid records exported:",len(unpaid_df))


print("\n Cleaned fees dataset saved")

