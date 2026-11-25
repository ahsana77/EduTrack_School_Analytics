import pandas as pd

#read fees dataset
df = pd.read_csv('data/raw_data/fees.csv')

#records with missing payment date
missing_dates = df[df["paid_date"].isnull()]
print("\n records with missing payment dates:")
print("Total:",len(missing_dates))

print("\npayment amounts for missing dates:")
print(missing_dates["amount_paid"].value_counts(dropna=False))

#checks payment was made without a payment date
paid_withoutdate = df[(df["amount_paid"]>0) & (df["paid_date"].isnull())]
print("\n missing date but paid amount")
print(paid_withoutdate)

#checks whether there is payment date and amount paid is 0
date_withoutpayment = df[(df["amount_paid"] == 0) & (df["paid_date"].notnull())]
print("\n amount paid is zero but payment date exists")
print(date_withoutpayment)

#check whether amount paid exceeds amount due
exceed = df[df["amount_paid"]>df["amount_due"]]
print("\nPayments exceeding amount due:")
print(exceed)

# inspect future payment dates
df["paid_date"] = pd.to_datetime(df["paid_date"],errors="coerce")
reference_date = pd.Timestamp("2026-10-31")
future_payment = df[df["paid_date"] > reference_date]
print("\n Future payment dates:")
print("Total:",len(future_payment))

#future payment by term
print("\n Future payment by term:")
print(future_payment["term"].value_counts())

#Future payment date range
print("\nFuture payment date range")
print("Earliest:",future_payment["paid_date"].min())
print("Latest:",future_payment["paid_date"].max())

#Future payments by amount paid
print("\nAmount paid distribution:")
print(future_payment["amount_paid"].value_counts())

#sample future records
print("\nbFirst 10 future payment:")
print(future_payment.head(10).to_string(index=False))

# adds flag to identify future dated records
# adds 'valid' first as value of entire col date_check
df["date_check"] = "Valid date"
# then change the value 'valid' date to 'verify' if paid date is in future
df.loc[df["paid_date"] > reference_date,"date_check"] = "Future dated - Verify"
print("\n date validation summary")
print(df["date_check"].value_counts())