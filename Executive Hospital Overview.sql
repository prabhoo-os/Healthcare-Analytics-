SELECT
  (SELECT COUNT(*) FROM patients)                                               AS total_patients,
  (SELECT COUNT(*) FROM admissions)                                             AS total_admissions,
  (SELECT ROUND(SUM(Total_Bill_Amount), 2) FROM billing)                        AS total_revenue,
  (SELECT ROUND(AVG(Treatment_Cost), 2) FROM treatments)                        AS avg_treatment_cost,
  (SELECT ROUND(AVG(Overall_Satisfaction), 2) FROM patient_feedback)            AS avg_patient_rating,
  (SELECT ROUND(100 * SUM(Appointment_Status = 'Cancelled') / COUNT(*), 2)
     FROM appointments)                                                         AS cancellation_rate_pct,
  (SELECT ROUND(AVG(Length_of_Stay_Days), 2) FROM admissions)                   AS avg_length_of_stay_days;
  
  SELECT DATE_FORMAT(Billing_Date, '%Y-%m') AS year_month_key,
       ROUND(SUM(Total_Bill_Amount), 2)   AS revenue
FROM billing
GROUP BY DATE_FORMAT(Billing_Date, '%Y-%m')
ORDER BY year_month_key;

SELECT d.Department_Name,
       COUNT(DISTINCT a.Patient_ID) AS unique_patients,
       COUNT(*)                     AS completed_visits
FROM appointments a
JOIN departments d ON d.Department_ID = a.Department_ID
WHERE a.Appointment_Status = 'Completed'
GROUP BY d.Department_ID, d.Department_Name
ORDER BY unique_patients DESC;

SELECT DATE_FORMAT(Admission_Date, '%Y-%m') AS year_month_key,
       COUNT(*)                             AS admissions
FROM admissions
GROUP BY DATE_FORMAT(Admission_Date, '%Y-%m')
ORDER BY year_month_key;

SELECT Appointment_Status,
       COUNT(*) AS appointments,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM appointments
GROUP BY Appointment_Status
ORDER BY appointments DESC;

SELECT d.Department_Name,
       ROUND(SUM(b.Total_Bill_Amount), 2) AS revenue,
       ROUND(100 * SUM(b.Total_Bill_Amount) / SUM(SUM(b.Total_Bill_Amount)) OVER (), 2) AS pct_of_revenue
FROM billing b
JOIN departments d ON d.Department_ID = b.Department_ID
GROUP BY d.Department_ID, d.Department_Name
ORDER BY revenue DESC;