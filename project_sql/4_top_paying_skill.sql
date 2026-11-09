/*
Anser : what are the top skills based on salary ? 
-Look at the average salary associated with each skill for DA position
-Focuses on rolse with specified salsries , regardless of location
-Why ? It reveals how different skills impact salary levels for DA and helps identify the most financially rewarding skills to acquire or improve
*/

WITH total_da_jobs AS (
    SELECT
        COUNT(*) AS total_jobs
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
),

skill_analysis AS (
    SELECT
        sd.skills,
        COUNT(DISTINCT jpf.job_id) AS demand_count,
        COUNT(DISTINCT jpf.job_id) FILTER (
            WHERE jpf.salary_year_avg IS NOT NULL
        ) AS salary_job_count,
        ROUND(
            AVG(jpf.salary_year_avg)::NUMERIC, 2
        ) AS avg_salary
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd
        ON sjd.skill_id = sd.skill_id
    WHERE
        jpf.job_title_short = 'Data Analyst'
    GROUP BY
        sd.skills
)

SELECT
    sa.skills,
    sa.salary_job_count,
    sa.avg_salary
FROM skill_analysis AS sa
CROSS JOIN total_da_jobs AS t
WHERE
    sa.salary_job_count >= 30
ORDER BY
    sa.demand_count DESC;


/*
Finding 1 — Specialized technologies lead the salary ranking. Kafka has the highest average salary, followed by Airflow and Scala. These technologies are commonly associated with engineering-intensive roles.
Finding 2 — SQL and Python have substantially more salary observations. SQL has 3,083 salary-reported postings and Python has 1,840, compared with Kafka's 40. This gives their averages a larger observational base.
Finding 3 — Python is associated with higher average salaries than SQL and Excel. Python's average is approximately $5,077 above SQL and $15,093 above Excel. This is an association, not a causal salary premium.
Finding 4 — The median of the 74 skill-level salary averages is $100,573. This is not the median salary of Data Analyst workers or postings.
For your portfolio, Chart 3 is especially useful: it demonstrates that a high average salary may be supported by relatively few observations, which is an important consideration when interpreting salary rankings.
*/