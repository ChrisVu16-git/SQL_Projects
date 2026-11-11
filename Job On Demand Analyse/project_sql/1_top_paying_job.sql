/*
Question : what are the top-paying DA jobs ?
-Identify the top 10 highest-paying DA role that available remotely
-Focus on job postings with specific salaries
-Why ? Highlight the top paying opportunities for DA , offering insights into employment operation
*/



SELECT
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    name as company_name
FROM
    job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg is NOT NULL AND
    job_location = 'Anywhere'
ORDER BY
    salary_year_avg DESC,
    job_postings_fact.job_id ASC
LIMIT 10;

-- ============================================================
-- DATA VALIDATION (run after the analysis query)
-- ============================================================

-- VALIDATION 1: Confirm the top-ten selection is unique, salary-reporting,
-- remote by the dataset's 'Anywhere' definition, and correctly ranked.
WITH eligible AS (
    SELECT job_id, salary_year_avg
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
      AND job_location = 'Anywhere'
      AND salary_year_avg IS NOT NULL
),
top_ten AS (
    SELECT job_id, salary_year_avg
    FROM eligible
    ORDER BY salary_year_avg DESC, job_id ASC
    LIMIT 10
),
checks AS (
    SELECT
        (SELECT COUNT(*) FROM top_ten) AS actual_rows,
        (SELECT LEAST(COUNT(*), 10) FROM eligible) AS expected_rows,
        (SELECT COUNT(DISTINCT job_id) FROM top_ten) AS distinct_jobs,
        (SELECT COUNT(*) FROM top_ten WHERE salary_year_avg <= 0) AS invalid_salaries,
        (SELECT COUNT(*)
         FROM top_ten t
         WHERE EXISTS (
             SELECT 1 FROM eligible e
             WHERE e.salary_year_avg > t.salary_year_avg
               AND e.job_id NOT IN (SELECT job_id FROM top_ten)
         )) AS ranking_errors
)
SELECT 'Q1: highest-paying remote jobs' AS validation,
       CASE WHEN expected_rows > 0
                  AND actual_rows = expected_rows
                  AND distinct_jobs = actual_rows
                  AND invalid_salaries = 0
                  AND ranking_errors = 0
            THEN 'PASS' ELSE 'FAIL' END AS status,
       actual_rows, expected_rows, invalid_salaries, ranking_errors
FROM checks;
