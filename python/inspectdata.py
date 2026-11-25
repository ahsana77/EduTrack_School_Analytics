import pandas as pd

# # read students dataset
# df = pd.read_csv("data/raw_data/students.csv")
# # first 5 records
# print(df.head())
# # number of rows and cols
# print("\nDataset shape : ")
# print(df.shape)
# # dataset informations
# print("\nDataset informations : ")
# print(df.info())

# dataset file paths
files = {'students':"data/raw_data/students.csv",'attendance':'data/raw_data/attendance.csv','fees':'data/raw_data/fees.csv','exam results':'data/raw_data/exam_results.csv'}

# to save inspection report as text file
with open("inspection_report.txt","w") as report:
# inspect each dataset
    for name, path in files.items():
        print('\n' + "=" * 60,file=report)
        print(f"\nDATASET : {name}\n",file=report)
        print('\n' + "=" * 60,file=report)
        df = pd.read_csv(path)

        print('\n First 5 records:',file=report)
        print(df.head(),file=report)

        print("\n No.of rows and cols:",file=report)
        print(df.shape,file=report)

        print("\nColumn names:",file=report)
        print(df.columns.to_list(),file=report)

        print("\n Datatypes and non null counts:",file=report)
        df.info(buf=report)

        print("\nMissing values:",file=report)
        print(df.isnull().sum().to_string(),file=report)

        print("\nDuplicate rows:",file=report)
        print(df.duplicated().sum(),file=report)

        if name == 'attendance':
            print("\n Attendance status values:", file = report)
            print(df["status"].value_counts(dropna=False).to_string(),file=report)

        if name == 'exam results':
            print("\n duplicate student-subject-term combinations:",file=report)
            duplicates = df.duplicated(subset=['student_id','subject','term'],keep = False)
            print(df[duplicates].sort_values(['student_id','subject','term']).to_string(index=False),file=report)

    print("\n inspection report created successfully")


