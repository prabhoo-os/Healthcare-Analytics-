SELECT ROUND(SUM(Total_Bill_Amount), 2)                                    AS total_revenue,
       ROUND(SUM(Insurance_Covered_Amount), 2)                             AS insurance_paid,
       ROUND(SUM(Patient_Paid_Amount), 2)                                  AS patient_paid,
       ROUND(SUM(Discount_Amount), 2)                                      AS discounts,
       ROUND(SUM(Total_Bill_Amount - Insurance_Covered_Amount
                 - Discount_Amount - Patient_Paid_Amount), 2)              AS outstanding,
       ROUND(100 * SUM(Insurance_Covered_Amount) / SUM(Total_Bill_Amount), 1) AS insurance_pct,
       ROUND(SUM(Total_Bill_Amount) / COUNT(DISTINCT Patient_ID), 0)       AS avg_revenue_per_patient,
       ROUND(AVG(Total_Bill_Amount), 0)                                    AS avg_bill
FROM billing;

SELECT Treatment_Name,
       Treatment_Type,
       COUNT(*)                         AS times_performed,
       ROUND(SUM(Treatment_Cost), 2)    AS treatment_revenue,
       ROUND(AVG(Treatment_Cost), 0)    AS avg_cost
FROM treatments
GROUP BY Treatment_Name, Treatment_Type
ORDER BY treatment_revenue DESC
LIMIT 10;
 
-- Q3b. Revenue by treatment type (donut)
SELECT Treatment_Type,
       ROUND(SUM(Treatment_Cost), 2) AS treatment_revenue,
       ROUND(100 * SUM(Treatment_Cost) / SUM(SUM(Treatment_Cost)) OVER (), 1) AS pct
FROM treatments
GROUP BY Treatment_Type
ORDER BY treatment_revenue DESC;

WITH yearly AS (
  SELECT YEAR(Billing_Date) AS yr, SUM(Total_Bill_Amount) AS revenue
  FROM billing
  GROUP BY YEAR(Billing_Date)
)
SELECT yr,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY yr)) / LAG(revenue) OVER (ORDER BY yr), 1) AS yoy_growth_pct
FROM yearly
ORDER BY yr;