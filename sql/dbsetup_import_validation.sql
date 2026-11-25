create database edutrack;
show databases;
use edutrack;
create table students(student_id varchar(10) primary key,
name varchar(100),
grade int,
section varchar(20),
gender varchar(20),
nationality varchar(50),
class varchar(20));
show table status;
describe students;
select * from students;

create table attendance(attendance_id int auto_increment primary key,
student_id varchar(10) not null,
`date` date,
status varchar(20),
foreign key(student_id) references students(student_id));
select count(*) as total_records from attendance;
select status,count(*) as total from attendance group by status;

create table fees(fee_id int auto_increment primary key,
student_id varchar(10) not null,
term varchar(20),
amount_due dec(10,2),
amount_paid decimal(10,2),
paid_date date null,
balance_amount decimal(10,2),
payment_status varchar(30),
date_check varchar(40),
foreign key(student_id) references students(student_id));
select count(*) as total_records from fees;
select payment_status,count(*) as total from fees group by payment_status;
select count(*) as missing_date from fees where paid_date is null;
describe fees;

show variables like 'local_infile';
set global local_infile = 1;

use edutrack;
load data local infile
'C:/Users/aquib/OneDrive/Desktop/EduTrack/data/cleaned_data/unpaid_fees.csv'
into table fees
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
student_id,
term,
amount_due,
amount_paid,
@paid_date,
balance_amount,
payment_status,
date_check
)
set paid_date = nullif(@paid_date,'');
select count(*) from fees;
select payment_status,count(*) as total from fees group by payment_status;
select count(*) as missing_dates from fees where paid_date is null;
select count(distinct fee_id) as unique_ids from fees;

-- create exam_results table
create table exam_results ( exam_result_id int auto_increment primary key,
student_id varchar(10) not null,
subject varchar(50),
term varchar(20),
score decimal(5,2) null,
score_check varchar(40),
outlier_check varchar(40),
foreign key(student_id) references students(student_id));

-- to import null value included rows
load data local infile
'C:/Users/aquib/OneDrive/Desktop/EduTrack/data/cleaned_data/missing_exam_cscores.csv'
into table exam_results
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(
student_id,
subject,
term,
@score,
score_check,
outlier_check
)
set score = nullif(@score,'');
select count(*) as total_records from exam_results;
select count(*) as missing_scores from exam_results where score is null;

-- to verify all tables
-- col table_name with values 'student','attendance','fees' and 'exam_results' with corresponding record counts
select 'student' as table_name,count(*) as students_count from students
union all
select 'attendance',count(*) as attendance_count from attendance
union all
select 'fees',count(*) as fees_count from fees
union all
select 'exam_results',count(*) as exam_result_count from exam_results;




