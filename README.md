# Project Overview

This project demonstrates how SQL can be used for HR Analytics to generate actionable insights from employee records.
The dataset contains ~50K rows with fields such as:

employee_id

department

job_role

salary

hire_date

tenure_years

attrition_flag

performance_rating

gender, age, education

The main goal is to analyze attrition, salary trends, and performance patterns to highlight workforce risks and opportunities.

## Key Steps
### 1. Data Cleaning

Loaded dataset into SQL database.

Standardized department/job_role names.

Handled missing values (salary, performance).

Created tenure bands:

0–2 yrs

3–5 yrs

6–10 yrs

10+ yrs

### 2. Business Questions & Queries
 1. Average salary by department
  ```sql  
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;
```

 2. Attrition rate by department & tenure band
   
```sql
SELECT department, 
       tenure_band,
       ROUND(100.0 * SUM(CASE WHEN attrition_flag = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM employees
GROUP BY department, tenure_band
ORDER BY attrition_rate DESC;
```
 3. Top 10% employees by performance rating
    
```sql
WITH ranked AS (
    SELECT employee_id, department, performance_rating,
           PERCENT_RANK() OVER (ORDER BY performance_rating DESC) AS pct_rank
    FROM employees
)
SELECT * FROM ranked
WHERE pct_rank <= 0.10;
```
 4. Salary anomalies (employees outside ±2 std dev of dept average)
    
```sql
WITH dept_stats AS (
    SELECT department,
           AVG(salary) AS dept_avg,
           STDDEV(salary) AS dept_std
    FROM employees
    GROUP BY department
)
SELECT e.employee_id, e.department, e.salary,
       ROUND((e.salary - d.dept_avg) / d.dept_std, 2) AS z_score
FROM employees e
JOIN dept_stats d ON e.department = d.department
WHERE ABS((e.salary - d.dept_avg) / d.dept_std) > 2
ORDER BY z_score DESC;
```
## Insights & Findings

### Attrition Hotspot: 
Sales department shows 18% attrition, mostly in employees with 0–2 yrs tenure → signals onboarding/engagement issues.

### Salary Gaps: 
HR and Support have significantly lower average salaries compared to Tech & Finance.

### High Performers: 
Top 10% of performers are concentrated in R&D, which may warrant retention strategies.

### Pay Disparities: 
12 employees flagged with salaries ±50% from dept averages, highlighting inequities.

## Deliverables

hr_analytics.sql → All queries with comments.

README.md → Documentation (this file).

Visualizations in Tableau/Excel for attrition & salary trends.
