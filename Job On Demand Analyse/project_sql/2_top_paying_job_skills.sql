/*
Question 2: Which skills appear in the 10 highest-paying remote Data Analyst jobs?
Select the 10 highest-paid postings with location 'Anywhere' and non-null
annual salaries, then join each job to its listed skills.
*/

WITH top_paying_jobs as (
    SELECT
    job_id,
    job_title,
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
    salary_year_avg DESC, job_id ASC
LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM
    top_paying_jobs
INNER JOIN skills_job_dim
    ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id;

/*
- Data querying and programming: SQL, Python, R, Go
- Data visualization and reporting: Tableau, Power BI, Excel, Crystal Reports
- Python analytics ecosystem: Pandas, NumPy, Jupyter
- Cloud and data engineering: AWS, Azure, Snowflake, Databricks, PySpark, Hadoop
- Collaboration and DevOps: Jira, Confluence, GitLab, Bitbucket, Jenkins, Git
The presence of cloud platforms and data engineering tools suggests that some of these senior analyst roles involve responsibilities beyond reporting and dashboard creation.
*/

-- ============================================================
-- DATA VALIDATION (run after the analysis query)
-- ============================================================

--Confirm only skills belonging to the selected ten jobs are returned and the job-skill bridge does not duplicate pairs
WITH top_ten AS (
    SELECT job_id
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
      AND salary_year_avg IS NOT NULL
      AND job_location = 'Anywhere'
    ORDER BY salary_year_avg DESC, job_id ASC
    LIMIT 10
),
job_skills AS (
    SELECT sjd.job_id, sjd.skill_id, sd.skills
    FROM top_ten t
    JOIN skills_job_dim sjd ON t.job_id = sjd.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
),
checks AS (
    SELECT
        (SELECT COUNT(*) FROM top_ten) AS selected_jobs,
        (SELECT COUNT(*) FROM job_skills) AS joined_rows,
        (SELECT COUNT(*) FROM skills_job_dim
         WHERE job_id IN (SELECT job_id FROM top_ten)) AS bridge_rows,
        (SELECT COUNT(*) FROM (
            SELECT job_id, skill_id
            FROM job_skills GROUP BY job_id, skill_id HAVING COUNT(*) > 1
         ) duplicates) AS duplicate_pairs,
        (SELECT COUNT(*) FROM job_skills WHERE skills IS NULL) AS missing_skill_names
)
SELECT 'Q2: skills in highest-paying jobs' AS validation,
       CASE WHEN selected_jobs > 0 AND joined_rows = bridge_rows
                  AND duplicate_pairs = 0 AND missing_skill_names = 0
            THEN 'PASS' ELSE 'FAIL' END AS status,
       selected_jobs, joined_rows, bridge_rows, duplicate_pairs, missing_skill_names
FROM checks;
