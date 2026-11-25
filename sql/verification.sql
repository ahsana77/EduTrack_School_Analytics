-- checking how many attendance records in each month
use edutrack;
select
	year(`date`) as attendance_year,
    month(`date`) as month_no,
    monthname(`date`) as month_name,
    count(*) as total_records
from attendance
group by 
	year(`date`),month(`date`),monthname(`date`)
order by
	attendance_year,
    month_no;

# verify KPIs
# total count of students
use edutrack;
select count(*) as total_students
from students;

# verify overall attendance
select
	sum(case when status = "present"
then 1 else 0 end) as present_days,
	sum(case when status = "absent"
then 1 else 0 end) as absent_days,
	sum(case when status = "excused"
then 1 else 0 end) as excused_days,
round(
sum(case when status = "present" then 1 else 0 end) * 100 /
	sum(case when status in('present','absent') then 1 else 0 end),2) as attendance_perc
    from attendance;
    
#verify average exam score
select round(avg(score),2) as avg_score,
count(*) as valid_exam_record
from exam_results
where score_check = "valid";

# verify outstanding fees
select round(sum(balance_amount),2) as outstanding_balance
from fees;

# total amount paid
select round(sum(amount_paid),2) as total_paid
from fees;

# v erify fee collection rate
select round(sum(amount_paid) * 100 /
sum(amount_paid+balance_amount),2) as fee_collection_rate
from fees;

# students who paid full,partial and unpaid
select payment_status,
count(*) 
from( select
student_id,
sum(amount_paid) as total_paid,
sum(balance_amount) as total_balance,
case
when sum(amount_paid) = 0
then 'Unpaid'
when sum(balance_amount) = 0
then 'Paid fully'
when sum(amount_paid) > 0 and sum(balance_amount) > 0
then 'partially paid'
else 'Needs Review'
end as payment_status
from fees
group by student_id) as total_students
group by payment_status; 

#academic support students
select count(distinct student_id)  as academic_support_students
from view_student_warning
where overall_support_status like '%academic support%' or score_change <= -8; 

select overall_support_status, count(*)
from view_student_warning
group by overall_support_status;

# improving students
select count(distinct student_id) as improving
from view_student_warning
where score_change > 0;

# verify high academic performers
select count(distinct student_id)
from( select student_id,
avg(score) as average_score
from exam_results
where score_check = 'valid'
group by student_id
having average_score >= 85) as high_performers;

# verify exceptional performers
select count(distinct student_id) from
(select student_id,
avg(score) as avg_score
from exam_results
where score_check = 'valid'
group by student_id
having avg_score >= 90)
as exceptional_performers;

# academic risk classification
select
case when score_change <= -15 then 'High'
when score_change <= -8 then 'Medium'
else 'Low'
end as risk_level,
count(*) as total_students
from view_student_warning
where score_change is not null
group by risk_level;

# data quality 
select count(*) as total_records,
count(distinct student_id) as unique_records
from view_student_warning;