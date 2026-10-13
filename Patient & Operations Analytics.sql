use hospital_db;

SELECT Gender, COUNT(*) AS patients,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients
GROUP BY Gender;

SELECT City, COUNT(*) AS patients
FROM patients
GROUP BY City
ORDER BY patients DESC;

SELECT Insurance_Flag, COUNT(*) AS patients,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM patients
GROUP BY Insurance_Flag;

SELECT CASE WHEN p.Age < 15 THEN '0-14'
            WHEN p.Age < 30 THEN '15-29'
            WHEN p.Age < 45 THEN '30-44'
            WHEN p.Age < 60 THEN '45-59'
            WHEN p.Age < 75 THEN '60-74'
            ELSE '75+' END                           AS age_group,
       COUNT(DISTINCT p.Patient_ID)                  AS patients,
       COUNT(a.Appointment_ID)                       AS completed_visits
FROM patients p
LEFT JOIN appointments a
       ON a.Patient_ID = p.Patient_ID AND a.Appointment_Status = 'Completed'
GROUP BY age_group
ORDER BY MIN(p.Age);

SELECT Diagnosis, COUNT(*) AS admissions,
       ROUND(AVG(Length_of_Stay_Days), 1) AS avg_los_days
FROM admissions
GROUP BY Diagnosis
ORDER BY admissions DESC
LIMIT 10;

SELECT Department_Name, Diagnosis, admissions
FROM (
  SELECT d.Department_Name, a.Diagnosis, COUNT(*) AS admissions,
         ROW_NUMBER() OVER (PARTITION BY d.Department_Name ORDER BY COUNT(*) DESC) AS rn
  FROM admissions a
  JOIN departments d ON d.Department_ID = a.Department_ID
  GROUP BY d.Department_Name, a.Diagnosis
) t
WHERE rn = 1
ORDER BY admissions DESC;

SELECT DATE_FORMAT(a.Appointment_Date, '%Y-%m') AS year_month_key,
       p.Patient_ID,
       p.Patient_Name,
       p.City,
       a.Appointment_Status,
       COUNT(*) AS appointments
FROM appointments a
JOIN patients p ON p.Patient_ID = a.Patient_ID
WHERE a.Appointment_Date >= '2023-01-01'
  AND a.Appointment_Date <  '2026-01-01'
GROUP BY DATE_FORMAT(a.Appointment_Date, '%Y-%m'),
         p.Patient_ID, p.Patient_Name, p.City,
         a.Appointment_Status
ORDER BY year_month_key, p.Patient_Name, a.Appointment_Status;
SELECT DAYNAME(Appointment_Date) AS weekday,
       WEEKDAY(Appointment_Date) AS weekday_sort,   -- 0 = Monday, use to sort the axis
       COUNT(*) AS appointments
FROM appointments
GROUP BY DAYNAME(Appointment_Date), WEEKDAY(Appointment_Date)
ORDER BY weekday_sort;

SELECT d.Department_Name,
       COUNT(DISTINCT dr.Doctor_ID) AS doctors,
       SUM(a.Appointment_Status = 'Completed') AS completed_visits,
       ROUND(SUM(a.Appointment_Status = 'Completed') / COUNT(DISTINCT dr.Doctor_ID), 0) AS visits_per_doctor
FROM departments d
JOIN doctors dr ON dr.Department_ID = d.Department_ID
LEFT JOIN appointments a ON a.Doctor_ID = dr.Doctor_ID
GROUP BY d.Department_Name
ORDER BY visits_per_doctor DESC;

SELECT d.Department_Name, d.Bed_Capacity,
       SUM(a.Length_of_Stay_Days) AS bed_days_used,
       ROUND(100 * SUM(a.Length_of_Stay_Days) / (d.Bed_Capacity * 365), 1) AS occupancy_pct
FROM departments d
JOIN admissions a ON a.Department_ID = d.Department_ID
WHERE YEAR(a.Admission_Date) = 2025
GROUP BY d.Department_Name, d.Bed_Capacity
ORDER BY occupancy_pct DESC;

SELECT Ward_Type, COUNT(*) AS admissions, ROUND(AVG(Length_of_Stay_Days), 1) AS avg_los_days
FROM admissions
GROUP BY Ward_Type
ORDER BY avg_los_days DESC;
