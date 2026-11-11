/*
Question 5: Which skills combine high demand and higher average advertised
annual salaries for Data Analyst roles? Demand uses ALL Data Analyst postings
(including jobs without salary or with non-remote locations). Salary averages
use only jobs with non-null annual salary. Minimum salary sample: 30 jobs.
This is a descriptive comparison, not a job-security or salary guarantee.
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
    sa.demand_count DESC,
    sa.skills ASC;


/*
SQL is the strongest demand signal. It appears in 47.1% of all Data Analyst postings, far more than any specialized tool.
Python offers a useful balance. It appears in 29.2% of postings and has a higher associated average salary than SQL, Excel, Tableau and Power BI in the salary-reported subset.
Specialized skills have higher observed salary averages but much narrower demand. Kafka appears in only 0.61% of postings, compared with SQL's 47.1%.
*/

-- ============================================================
-- DATA VALIDATION (run after the analysis query)
-- ============================================================

-- Verify demand percentages use ALL Data Analyst postings,while average salary uses only postings with annual salary data.
WITH totals AS (
    SELECT COUNT(*) AS total_da_jobs
    FROM job_postings_fact WHERE job_title_short = 'Data Analyst'
),
per_skill AS (
    SELECT sd.skill_id, sd.skills,
           COUNT(DISTINCT jpf.job_id) AS demand_count,
           COUNT(DISTINCT jpf.job_id) FILTER (
               WHERE jpf.salary_year_avg IS NOT NULL
           ) AS salary_job_count,
           ROUND(AVG(jpf.salary_year_avg)::NUMERIC, 2) AS avg_salary
    FROM job_postings_fact jpf
    JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Analyst'
    GROUP BY sd.skill_id, sd.skills
),
eligible AS (
    SELECT p.*,
           ROUND(p.demand_count * 100.0 / NULLIF(t.total_da_jobs, 0), 2)
               AS demand_percentage
    FROM per_skill p CROSS JOIN totals t
    WHERE p.salary_job_count >= 30
),
checks AS (
    SELECT
        (SELECT total_da_jobs FROM totals) AS total_da_jobs,
        (SELECT COUNT(*) FROM eligible) AS qualifying_skills,
        (SELECT COUNT(*) FROM eligible
         WHERE demand_count < salary_job_count
            OR demand_percentage < 0 OR demand_percentage > 100
            OR avg_salary IS NULL) AS invalid_metrics,
        (SELECT COUNT(*) FROM (
           SELECT sjd.job_id, sjd.skill_id
           FROM skills_job_dim sjd
           GROUP BY sjd.job_id, sjd.skill_id HAVING COUNT(*) > 1
         ) duplicate_pairs) AS duplicate_job_skill_pairs
)
SELECT 'demand versus salary' AS validation,
       CASE WHEN total_da_jobs > 0 AND qualifying_skills > 0
                  AND invalid_metrics = 0 AND duplicate_job_skill_pairs = 0
            THEN 'PASS' ELSE 'FAIL' END AS status,
       total_da_jobs, qualifying_skills, invalid_metrics,
       duplicate_job_skill_pairs
FROM checks;
