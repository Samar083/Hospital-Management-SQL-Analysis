-- Question - 1
-- List patients with their appointment doctor and reason.
select p.patient_Id,concat(p.FName," ",p.LName) as patient_full_name,p.Gender, d.doct_id, concat(d.Fname," ",d.Lname) as doctor_full_name, a.reason
from patients p
join appointment a
on p.patient_id = a.patient_id
join doctor d
on a.doct_id = d.doct_id;

-- -- Question - 2
-- Show nurses who have assisted in bed admissions with patient names.
select n.nurse_id, concat(n.Fname," ", n.Lname) as Nurse_name, p.patient_id, concat(p.Fname, " ", p.Lname) as patient_name, b.admission_date
from Nurse n
join Bedrecords b
on n.nurse_id = b.nurse_id
join patients p
on b.patient_id = p.patient_id;

-- Question - 3
-- List rooms used for surgeries, the surgeon, and the surgery type.
select r.room_no, concat(fname," ",lname) as surgon_name, surgery_Type
from room r
join doctor d
on r.dept_id = d.dept_id
join surgeryrecord s
on r.room_no = s.room_no;

-- Question - 4
-- List each department with the number of doctors assigned to it.
select de.dept_id, de.dept_name, count(doct_id) as no_of_doctor
from department de
join doctor d
on de.dept_id = d.dept_id
group by de.dept_id, de.dept_name;

-- Question - 5
-- Show patients who had an appointment and were admitted to a bed.
select concat(p.fname, " ", p.lname) as patient_name, a.appoIntment_Id, b.bed_no,a.appointment_date ,b.admission_date
from patients p
join appointment a
on p.patient_id = a.patient_id
join bedrecords b
on a.patient_id = b.patient_id;

-- Question - 6
-- We have a new patient for the Cardiology Ward and he/she wants a bed on a specific day.
-- We want to find out which beds are empty in that ward on that particular day.
SELECT b.bed_No
FROM Bed b
JOIN Ward w
ON b.ward_No = w.ward_No
join department d 
on w.dept_Id = d.dept_Id
WHERE d.dept_Name = 'Cardiology' and w.ward_No = 502
AND b.bed_No NOT IN
(
    SELECT br.bed_No
    FROM BedRecords br
    WHERE '2025-05-09' BETWEEN br.admission_Date and br.discharge_Date
);

-- Question - 7
-- There is a new virus in the city and the hospital is expecting more patients than a regular
-- day. Management wants to see if they can manage those with the current staff or not.
-- They want to check upcoming appointments for each department on 4 June 2025.

select de.dept_name, count(a.appoIntment_Id) as no_of_appointments
from appointment a
join doctor d
on a.doct_Id = d.doct_Id
join department de
on d.dept_Id = de.dept_Id
where  a.appointment_Date = '2025-06-04'
group by de.dept_Name;

-- Question - 8
-- A doctor is asking for a salary raise due to extra work in the previous month. Verify if he/
-- she deserves a raise by retrieving their total appointments, total visits, total surgeries,
-- and total shifts

with total_appointments as (
select d.doct_id,concat(d.fname,' ', d.lname) as name_of_doctor, count(*) as total_apponitments
from appointment a
join doctor d
on a.doct_Id = d.doct_Id
group by d.doct_Id
),

total_visits as (
select d.doct_id, count(*) as total_no_of_visits
from doctor d
join medicalrecord m
on d.doct_Id = m.doct_Id
group by d.doct_Id
),

total_Surgery as (
select d.doct_id, count(*) as total_surgery
from doctor d
join appointment a
on d.doct_Id = a.doct_Id
join surgeryrecord s
on a.patient_Id = s.patient_Id
group by d.doct_Id
),
 total_shifts as (
 select d.doct_id, count(*) as total_shift
 from doctor d
 join staffshift s
 on d.doct_Id = s.doct_Id
 group by d.doct_Id
 
 )
 
 select ta.doct_id, ta.name_of_doctor,ta.total_apponitments, tv.total_no_of_visits,ts.total_surgery,tsh.total_shift
 from total_appointments ta
 left join total_visits tv
 on ta.doct_id = tv.doct_id
 left join total_Surgery ts
 on ta.doct_id = ts.doct_id
 left join total_shifts tsh
 on ta.doct_id = tsh.doct_id;
 
 -- Question - 9
-- The hospital is analyzing its daily revenue and wants to calculate the revenue generated
-- on 10 May 2025 (including appointment revenue, room revenue, and bed revenue).
with appointment_revenue AS (
SELECT sum(payment_amount) as total_appointment_revenue
from appointment 
where appointment_Date = '2025-05-10'
),
room_revenue as ( 
select sum(amount) as total_room_revenue
from roomrecords 
where (admission_Date = '2025-05-10') or (discharge_Date = '2025-05-10')
),
bed_revenue as (
select  sum(amount) as total_bed_revenue
from bedrecords 
where (admission_Date = '2025-05-10') or (discharge_Date = '2025-05-10')
)

select (total_appointment_revenue) + (total_room_revenue) + (total_bed_revenue)
from appointment_revenue,
bed_revenue,
room_revenue;

-- Question - 10
-- The hospital decided to give some discounts to its old customers on some services.
-- Identify patients who have visited the hospital more than 4 times in the past year.

select p.patient_id, concat(p.fname,' ',p.lname) as name_of_patient, count(a.appoIntment_Id) as no_of_times_visit
from patients p
join appointment a
on p.patient_Id = a.patient_Id
where (a.appointment_Date >= '2025-05-20' - INTERVAL 1 YEAR) and (a.appointment_status = 'Completed')
group by p.patient_Id
having 
count(a.appoIntment_Id) >= 4;

-- Question - 11
-- Management received a report that a patient was given the wrong amount of anesthesia
-- during surgery. Track which staff (surgeon, nurse, and helper) was present during the
-- surgery of patient 967 on 16 May 2024 between 11 to 12 at night

SELECT
p.patient_id, CONCAT(p.fname,' ',p.lname) AS patient_name,
d.doct_id, CONCAT(d.fname,' ',d.lname) AS doctor_name,
n.nurse_id, CONCAT(n.fname,' ',n.lname) AS nurse_name,
h.helper_id,CONCAT(h.fname,' ',h.lname) AS helper_name
FROM surgeryrecord s
JOIN patients p
ON s.patient_id = p.patient_id
JOIN doctor d
ON s.surgeon_id = d.doct_id
JOIN nurse n
ON s.nurse_id = n.nurse_id
JOIN helpers h
ON s.helper_id = h.helper_id
WHERE s.patient_id = 967
AND s.surgery_date = '2024-05-16'
AND s.start_time >= '23:00:00'
AND s.end_time <= '23:59:59';

-- Question - 12
-- The management wants to pay salaries for this month and wants a record of working hours. 
-- Each staff member should have 200 hours this month. For the month of May 2025,
-- calculate the total working hours of each staff member (doctors, nurses, helpers) to
-- check total hours according to the 200 hours baseline.

SELECT d.doct_id,
     CONCAT(d.fname,' ',d.lname) AS staff_name,
    'Doctor' AS role,
    SUM(TIMESTAMPDIFF(HOUR,s.shift_start,s.shift_end)) AS total_hours
FROM doctor d
JOIN staffshift s
ON d.doct_id=s.doct_id
WHERE YEAR(s.shift_date)=2025
AND MONTH(s.shift_date)=5
GROUP BY d.doct_id,d.fname,d.lname;

-- Question - 13
-- The hospital wants to analyze the performance of its surgeons' surgeries. Give the
-- percentage of stable patients as per declared in the notes after surgery
 
 SELECT
    surgeon_id,
    ROUND(
        SUM(CASE
                WHEN notes = 'Stable' THEN 1
                ELSE 0
            END) * 100.0
        / COUNT(*), 2
    ) AS stable_percentage
FROM surgeryrecord
GROUP BY surgeon_id;

-- Question - 14
-- List all patients who have a follow-up appointment due this week, based on their last
-- next_Visit from MedicalRecord
SELECT
    p.patient_id,
    CONCAT(p.fname,' ',p.lname) AS patient_name,
    m.next_visit
FROM patients p
JOIN medicalrecord m
ON p.patient_id = m.patient_id
WHERE m.next_visit
BETWEEN CURDATE()
AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

-- Question - 15
-- Find the most preferred payment method chosen by upper-class people (defined by
-- users of super deluxe room types)
select a.mode_of_payment ,count(*) as no_of_payment_done
from appointment a
join roomrecords r
on a.patient_Id = r.patient_Id 
join room ro
on r.room_no = ro.room_No
where ro.room_Type = 'Super Deluxe Room'
group by a.mode_of_payment 
order by no_of_payment_done  desc
limit 1;
