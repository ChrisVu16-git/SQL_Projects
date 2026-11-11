/*
Question 4: Which skills have the highest average advertised annual salary
for Data Analyst roles (all locations)? Require at least 30 postings that
report annual salary for each skill. Salary differences are descriptive,
not proof that a skill causes higher pay.
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
    sa.avg_salary DESC NULLS LAST,
    sa.skills ASC;


/*
Finding 1 — Specialized technologies lead the salary ranking. Kafka has the highest average salary, followed by Airflow and Spark. These technologies are commonly associated with engineering-intensive roles.
Finding 2 — SQL and Python have substantially more salary observations. SQL has 3,083 salary-reported postings and Python has 1,840, compared with Kafka's 40. This gives their averages a larger observational base.
Finding 3 — Python is associated with higher average salaries than SQL and Excel. Python's average is approximately $5,077 above SQL and $15,093 above Excel. This is an association, not a causal salary premium.
Finding 4 — The median of the 74 skill-level salary averages is $100,573. This is not the median salary of Data Analyst workers or postings.
*/

-- ============================================================
-- DATA VALIDATION (run after the analysis query)
-- ============================================================

-- verify the minimum 30-job sample  and check salary ranking.
WITH salary_observations AS (
    SELECT sd.skill_id, sd.skills, jpf.job_id, jpf.salary_year_avg
    FROM job_postings_fact jpf
    JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Analyst'
      AND jpf.salary_year_avg IS NOT NULL
),
per_skill AS (
    SELECT skill_id, skills,
           COUNT(DISTINCT job_id) AS salary_job_count,
           ROUND(AVG(salary_year_avg)::NUMERIC, 2) AS avg_salary
    FROM salary_observations
    GROUP BY skill_id, skills
),
eligible AS (
    SELECT * FROM per_skill WHERE salary_job_count >= 30
),
highest AS (
    SELECT * FROM eligible
    ORDER BY avg_salary DESC NULLS LAST, skills ASC LIMIT 1
),
checks AS (
    SELECT
        (SELECT COUNT(*) FROM eligible) AS qualifying_skills,
        (SELECT COUNT(*) FROM eligible WHERE salary_job_count < 30
           OR avg_salary IS NULL OR avg_salary <= 0) AS invalid_rows,
        (SELECT COUNT(*) FROM highest h
         WHERE EXISTS (SELECT 1 FROM eligible e
                       WHERE e.avg_salary > h.avg_salary)) AS ranking_errors,
        (SELECT COUNT(*) FROM salary_observations
         WHERE salary_year_avg <= 0) AS nonpositive_salary_rows
)
SELECT 'Q4: salary by skill' AS validation,
       CASE WHEN qualifying_skills > 0
                  AND invalid_rows = 0 AND ranking_errors = 0
                  AND nonpositive_salary_rows = 0
            THEN 'PASS' ELSE 'FAIL' END AS status,
       qualifying_skills, invalid_rows, ranking_errors, nonpositive_salary_rows
FROM checks;
