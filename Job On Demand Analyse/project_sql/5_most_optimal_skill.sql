/*
Answer : What are the most optimal skills to learn(high demand or high-paying skill)?
-Identify skills in high demand and associated with high average salaries for DA role
-Concentrates on remote positions with specified salaries
-Why ? targets skills that offer job security (high demand) and financial benefits (high salaries), offer strategic insights for career developement in DA
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
    sa.demand_count,
    ROUND(
        sa.demand_count * 100.0 / t.total_jobs, 2
    ) AS demand_percentage,
    sa.salary_job_count,
    sa.avg_salary
FROM skill_analysis AS sa
CROSS JOIN total_da_jobs AS t
WHERE
    sa.salary_job_count >= 30
ORDER BY
    sa.demand_count DESC;


/*
SQL is the strongest demand signal. It appears in 47.1% of all Data Analyst postings, far more than any specialized tool.
Python offers a useful balance. It appears in 29.2% of postings and has a higher associated average salary than SQL, Excel, Tableau and Power BI in the salary-reported subset.
Specialized skills have higher observed salary averages but much narrower demand. Kafka appears in only 0.61% of postings, compared with SQL's 47.1%.
*/