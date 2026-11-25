use edutrack;

-- attendance analysis

-- attendance rate per class
select s.class,
count(distinct a.student_id) as total_students,
sum(case when status = 'present' then 1 else 0 end) as present_days,
sum(case when status = 'absent' then 1 else 0 end) as absent_days,
sum(case when status = 'excused' then 1 else 0 end) as excused_days,
round(sum(case when status = 'present' then 1 else 0 end)/
nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)*100,2) as attendance_percentage
from attendance as a
join students as s
on a.student_id = s.student_id
group by s.class
order by attendance_percentage asc;

-- calculate each student's attendance percentage to identify students who may need attention
select student_id,
sum(case
	when status = 'present' then 1
    else 0
    end) as present_days,
sum(case
	when status = 'absent' then 1
    else 0
    end) as absent_days,
sum(case
	when status = 'excused' then 1
    else 0
    end) as excused_days,
-- to calculate percentage, uses nullif to avoid denominator 0, if sum of present and absent is 0 then it will be null
round(sum(case when status = 'present' then 1 else 0 end) / 
	nullif(sum(case when status in ('present','absent') then 1 else 0 end),0) * 100 , 2) as attendance_percentage
from attendance
group by student_id
order by attendance_percentage asc;

-- students with low attendance , below 75%
select student_id,
present_days,
absent_days,
excused_days,
attendance_percentage
from( select student_id,
sum(case
	when status = 'present' then 1
    else 0
    end) as present_days,
sum(case
	when status = 'absent' then 1
    else 0
    end) as absent_days,
sum(case
	when status = 'excused' then 1
    else 0
    end) as excused_days,
-- to calculate percentage, uses nullif to avoid denominator 0, if sum of present and absent is 0 then it will be null
round(sum(case when status = 'present' then 1 else 0 end) / 
	nullif(sum(case when status in ('present','absent') then 1 else 0 end),0) * 100 , 2) as attendance_percentage
from attendance
group by student_id) as attendance_summary
where attendance_percentage < 75
order by attendance_percentage asc;

-- details of those students
select a.student_id,
s.name,
s.grade,
s.section,
a.present_days,
a.absent_days,
a.excused_days,
a.attendance_percentage
from(select student_id,
sum(case when status = 'present' then 1 else 0 end)as present_days,
sum(case when status = 'absent' then 1 else 0 end) as absent_days,
sum(case when status = 'excused' then 1 else 0 end) as excused_days,
round(sum(case when status = 'present' then 1 else 0 end)/
nullif(sum(case when status in('absent','present') then 1 else 0 end),0) * 100 , 2) as attendance_percentage
from attendance
group by student_id) as a
join students as s
on a.student_id = s.student_id
where a.attendance_percentage < 75
order by a.attendance_percentage asc;

-- attendance rate per grade
use edutrack;
select s.grade,
count(distinct a.student_id) as total_student,
sum(case when a.status = 'present' then 1 else 0 end) as present_days,
sum(case when status = 'absent' then 1 else 0 end) as absent_days,
sum(case when status = 'excused' then 1 else 0 end) as excused_days,
round(sum(case when status = 'present' then 1 else 0 end)/
nullif(sum(case when status in ('present','absent') then 1 else 0 end),0) * 100, 2) as attendance_percentage from attendance as a
join students as s on a.student_id = s.student_id
group by s.grade
order by attendance_percentage asc;

# schools overall attendance pattern
select status,
count(*) as total_days,
round(count(*) * 100 / (select count(*) from attendance),2) as percentage
from attendance
group by status
order by percentage desc;


-- fee analysis --

-- outstanding fee per student
select student_id,
sum(amount_due) as total_fees_due,
sum(amount_paid) as total_paid,
sum(balance_amount) as outstanding_balance
from fees
group by student_id
order by outstanding_balance desc;

-- students with outstanding fees ( students who still have fees to pay)
select student_id,
sum(amount_due) as total_due,
sum(amount_paid) as total_paid,
sum(balance_amount) as outstanding_balance
from fees
group by student_id
having outstanding_balance > 0
order by outstanding_balance desc;

-- fee status summary
select payment_status,
count(*) as total_fee_records,
sum(amount_due) as total_due,
sum(amount_paid) as total_paid,
sum(balance_amount) as total_outstanding
from fees
group by payment_status
order by total_outstanding;

-- checking error and solving col values payment_status and date_check are swapped during importing

select * from fees where payment_status = 'no payment date';
-- not showing records with unpaid date_check 
select distinct
concat('[',date_check,']') as date_check_value,
length(date_check) as value_length,
hex(date_check) as stored_value
from fees
where payment_status = 'no payment date';

-- swapping 126 records with values 'unpaid' in date_check col and 'no payment date' in payment_status col
update fees
set
payment_status = 'Unpaid',
date_check = 'No payment date'
where fee_id > 0 and payment_status = 'no payment date';
select * from fees where payment_status = 'unpaid' and date_check = 'no payment date';

-- fees collection by term - find which term has highest outstanding fees
select term,
count(*) as total_fee_records,
sum(amount_due) as total_due,
sum(amount_paid) as total_paid,
sum(balance_amount) as outstanding_balance
from fees
group by term
order by outstanding_balance desc;

-- fee collection by grade
select s.grade,
sum(f.amount_due) as total_due,
sum(f.amount_paid) as total_paid,
sum(f.balance_amount) as outstanding_balance,
round(100*sum(f.amount_paid)/sum(f.amount_due),1) as collection_perc
from fees as f
join students as s on f.student_id = s.student_id
group by s.grade
order by s.grade;


-- exam results analysis --

-- average marks by subject and term
select
subject,
term,
count(*) as total_exam_records,
count(score) as assessed_records,
(count(*) - count(score)) as missed_score_records,
round(avg(score),2) as avg_score,
min(score) as lowest_score,
max(score) as highest_score
from exam_results
group by subject, term
order by subject, term;

-- score change for each student between terms
select student_id,
round(avg(case when term = 'term 1' then score end),2) as term1_avg,
round(avg(case when term = 'term 2' then score end),2) as term2_avg,
round(avg(case when term = 'term 2' then score end) - avg(case when term = 'term 1' then score end),2) as score_change
from exam_results
group by student_id
order by score_change;

-- score change per student per subject in terms
select student_id,
subject,
max(case when term = 'term 1' then score end) as term1_score,
max(case when term = 'term 2' then score end) as term2_score,
round(max(case when term = 'term 2' then score end) - max(case when term = 'term 1' then score end),2) as score_change
from exam_results
group by student_id, subject
order by student_id, subject;

-- average mark per student

select student_id,
count(*) as total_exam_records,
count(score) as assessed_records,
(count(*) - count(score)) as missed_exam_records,
round(avg(score),2) as avg_score,
min(score) as lowest_score,
max(score) as highest_score
from exam_results
group by student_id
order by avg_score asc;

-- identify students with average score less than 40
select student_id,
count(score) as assessed_records,
round(avg(score),2) as avg_score
from exam_results
group by student_id
having avg_score < 40
order by avg_score asc;

-- student academic performance report
select s.student_id,
s.name,
s.grade,
s.class,
count(e.score) as assessed_records,
round(avg(e.score),2) as average_score,
case
	when avg(e.score) < 40 then 'Needs academic review'
    when avg(e.score) <60 then 'Below target'
    else 'satisfactory'
    end as performance_status
from students as s
join exam_results as e
on s.student_id = e.student_id
group by
s.student_id,
s.name,
s.grade,
s.class
order by average_score asc;

-- average mark per student per subject
select student_id,
subject,
count(score) as assessed_records,
round(avg(score),2) as avg_score
from exam_results
group by student_id, subject
order by student_id,avg_score asc;

-- performance comparison to identify whether each student improved, declined or same using 2 CTEs stdent_scores and score_changes
use edutrack;
with student_scores as (select student_id,
	subject,
	max(case when term = 'term 1' then score end) as term1_score,
	max(case when term = 'term 2' then score end) as term2_score
	from exam_results
	group by student_id,subject),
    score_changes as (select student_id,
    subject,
    term1_score,
    term2_score,
    round(term2_score - term1_score,2) as score_change
    from student_scores)
select *,
case when term1_score is null or term2_score is null then 'insufficient data'
	when score_change > 0 then 'Improved'
    when score_change < 0 then 'Declined'
    else 'No change'
end as performance_trend
from score_changes
order by student_id,subject;


-- attendance summary
with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id)
select * from attendance_summary
order by attendance_perc asc;

-- academic summary
with academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id)
select *,
round(term2_avg - term1_avg) as score_change
from academic_summary
order by score_change asc;

-- fees summary, outstanding fees per student
with fee_summary as ( select student_id,
sum(amount_due) as total_due,
sum(amount_paid) as total_paid,
sum(balance_amount) as outstanding_balance
from fees
group by student_id)
select * from fee_summary
order by outstanding_balance desc;

-- student report
with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id),

	academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id),

	fee_summary as ( select student_id,
	sum(amount_due) as total_due,
	sum(amount_paid) as total_paid,
	sum(balance_amount) as outstanding_balance
	from fees
	group by student_id)

select 
s.student_id,
s.name,
s.grade,
s.class,
a.attendance_perc,
ac.term1_avg,
ac.term2_avg,
round(ac.term2_avg - ac.term1_avg,2) as score_change,
f.total_due,
f.total_paid,
f.outstanding_balance

from students s
left join attendance_summary a
on s.student_id = a.student_id
left join academic_summary ac
on s.student_id = ac.student_id
left join fee_summary f
on s.student_id = f.student_id 
order by s.student_id;

-- student report with early warning flag

with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id),

	academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id),

	fee_summary as ( select student_id,
	sum(amount_due) as total_due,
	sum(amount_paid) as total_paid,
	sum(balance_amount) as outstanding_balance
	from fees
	group by student_id)

select 
s.student_id,
s.name,
s.grade,
s.class,
a.attendance_perc,
ac.term1_avg,
ac.term2_avg,
round(term2_avg - term1_avg) as score_change,
f.outstanding_balance,

case 
	when a.attendance_perc is null then 'No attendance data'
    when a.attendance_perc < 75 then 'Attendance Review'
    else 'Normal'
end as attendance_flag,
case 
	when ac.term2_avg is null then 'Not Assessed'
    when ac.term2_avg < 40 then 'Academic Review'
    else 'Normal'
end as academic_flag,
case
	when f.outstanding_balance > 0 then 'Fee Follow-up'
    else 'No Outstanding Fees'
end as fee_flag

from students s
left join attendance_summary a 
on s.student_id = a.student_id

left join academic_summary ac
on s.student_id = ac.student_id

left join fee_summary f
on s.student_id = f.student_id 
order by student_id;

-- student over all support status report
with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id),

	academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id),

	fee_summary as ( select student_id,
	sum(amount_due) as total_due,
	sum(amount_paid) as total_paid,
	sum(balance_amount) as outstanding_balance
	from fees
	group by student_id),
    
    student_report as (select s.student_id,
    s.name,
    s.grade,
    s.class,
    a.attendance_perc,
    ac.term1_avg,
    ac.term2_avg,
    round(ac.term2_avg - ac.term1_avg) as score_change,
    f.outstanding_balance 
    from students s 
    left join attendance_summary a 
    on s.student_id = a.student_id
    left join academic_summary ac
    on s.student_id = ac.student_id
    left join fee_summary f 
    on s.student_id = f.student_id)
    
select *,
case 
	when attendance_perc is null or term2_avg is null then 'Data Review Required'
    when attendance_perc < 75 and (term2_avg < 40 or score_change <= -8) and outstanding_balance > 0 then 'Multiple Follow-ups'
    when attendance_perc < 75 and ( term2_avg < 40 or score_change <= -8 ) then 'Attendance and Academic Support'
    when attendance_perc < 75 and outstanding_balance > 0 then 'Attendance Support and Fee Follow-up'
    when ( term2_avg < 40 or score_change <= -8 ) and outstanding_balance > 0 then 'academic Support and Fee Follow-up'
    when attendance_perc < 75 then 'Attendance Support'
    when (term2_avg < 40 or score_change <= -8) then 'Academic Support'
    when outstanding_balance > 0 then 'Fee Follow-up'
    else 'No Current Flag'
end as overall_support_status
from student_report
order by student_id;
    
-- students count by overall support status
with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id),

	academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id),

	fee_summary as ( select student_id,
	sum(amount_due) as total_due,
	sum(amount_paid) as total_paid,
	sum(balance_amount) as outstanding_balance
	from fees
	group by student_id),
    
    student_report as (select s.student_id,
    s.name,
    s.grade,
    s.class,
    a.attendance_perc,
    ac.term1_avg,
    ac.term2_avg,
    round(ac.term2_avg - ac.term1_avg) as score_change,
    f.outstanding_balance 
    from students s 
    left join attendance_summary a 
    on s.student_id = a.student_id
    left join academic_summary ac
    on s.student_id = ac.student_id
    left join fee_summary f 
    on s.student_id = f.student_id)
    
select
case
	when attendance_perc is null or term2_avg is null then 'Data Review Required'
    when attendance_perc < 75 and (term2_avg < 40 or score_change <= -8) and outstanding_balance > 0 then 'Multiple Follow-ups'
    when attendance_perc < 75 and ( term2_avg < 40 or score_change <= -8 ) then 'Attendance and Academic Support'
    when attendance_perc < 75 and outstanding_balance > 0 then 'Attendance Support and Fee Follow-up'
    when ( term2_avg < 40 or score_change <= -8 ) and outstanding_balance > 0 then 'academic Support and Fee Follow-up'
    when attendance_perc < 75 then 'Attendance Support'
    when (term2_avg < 40 or score_change <= -8) then 'Academic Support'
    when outstanding_balance > 0 then 'Fee Follow-up'
    else 'No Current Flag'
end as overall_support_status,
count(*) as total_students
from student_report
group by overall_support_status
order by total_students desc;

-- save student early warning report as a MySQL view

create or replace view view_student_warning as
with attendance_summary as(select student_id,
	sum(case when status = 'present' then 1 else 0 end) as present_days,
    sum(case when status = 'absent' then 1 else 0 end) as absent_days,
    sum(case when status = 'excused' then 1 else 0 end) as excused_days,
    round((sum(case when status = 'present' then 1 else 0 end) /
		nullif(sum(case when status in ('present','absent') then 1 else 0 end),0)) * 100 , 2)
	as attendance_perc
	from attendance
	group by student_id),

	academic_summary as(select student_id,
	round(avg(case when term = 'term 1' then score end),2) as term1_avg,
    round(avg(case when term = 'term 2' then score end),2) as term2_avg
    from exam_results
    group by student_id),

	fee_summary as ( select student_id,
	sum(amount_due) as total_due,
	sum(amount_paid) as total_paid,
	sum(balance_amount) as outstanding_balance
	from fees
	group by student_id),
    
    student_report as (select s.student_id,
    s.name,
    s.grade,
    s.class,
    a.attendance_perc,
    ac.term1_avg,
    ac.term2_avg,
    round(ac.term2_avg - ac.term1_avg) as score_change,
    f.outstanding_balance 
    from students s 
    left join attendance_summary a 
    on s.student_id = a.student_id
    left join academic_summary ac
    on s.student_id = ac.student_id
    left join fee_summary f 
    on s.student_id = f.student_id)
    
select *,
case 
	when attendance_perc is null or term2_avg is null then 'Data Review Required'
    when attendance_perc < 75 and (term2_avg < 40 or score_change <= -8) and outstanding_balance > 0 then 'Multiple Follow-ups'
    when attendance_perc < 75 and ( term2_avg < 40 or score_change <= -8 ) then 'Attendance and Academic Support'
    when attendance_perc < 75 and outstanding_balance > 0 then 'Attendance Support and Fee Follow-up'
    when ( term2_avg < 40 or score_change <= -8 ) and outstanding_balance > 0 then 'academic Support and Fee Follow-up'
    when attendance_perc < 75 then 'Attendance Support'
    when (term2_avg < 40 or score_change <= -8) then 'Academic Support'
    when outstanding_balance > 0 then 'Fee Follow-up'
    else 'No Current Flag'
end as overall_support_status
from student_report
order by student_id;

-- checking view
select * from view_student_warning;

select overall_support_status,
count(*) as total_students
from view_student_warning
group by overall_support_status
order by total_students desc;
    
    