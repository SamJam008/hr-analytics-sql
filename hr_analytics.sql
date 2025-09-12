-- Average salary by department
select Department, round(Avg(MonthlyIncome),2) as avg_salary
from employee
group by department
order by avg_salary desc;

-- Attrition by department & Tenure
select Department ,
case 
when YearsAtCompany between 0 and 2 then '0-2 years'
when YearsAtCompany between 3 and 5 then '3-5 years'
when YearsAtCompany between 6 and 10 then '6-10 years'
else '10+ years'
end as tenure_band,
round(100.0 * sum(case when Attrition ='Yes' then 1 else 0 end)/count(*),2) as attrition_rate
from employee
group by Department , tenure_band
order by attrition_rate desc;

-- Top 10% employees by performance rating
with ranked as(
select EmployeeNumber, Department, PerformanceRating, percent_rank() over (order by PerformanceRating desc) as pct_rank
from employee
)
select * from ranked
where pct_rank <= 0.10;

-- Salary Anomalies
WITH dept_stats AS (
    SELECT Department,
           AVG(MonthlyIncome) AS dept_avg,
           STDDEV(MonthlyIncome) AS dept_std
    FROM employee
    GROUP BY Department
)
SELECT e.EmployeeNumber, e.Department, e.MonthlyIncome,
       ROUND((e.MonthlyIncome - d.dept_avg) / d.dept_std, 2) AS z_score
FROM employee e
JOIN dept_stats d ON e.Department = d.Department
WHERE ABS((e.MonthlyIncome - d.dept_avg) / d.dept_std) > 2
ORDER BY z_score DESC;
