/*
Question : what are the most in-demand skills for data analysts ? 
-Join job posting to inner join table similar to query 2 
-Identify the top 10 in-demand skills for a DA
-Focus on all job postings
-Why ? Retrieves the top 10 skills with the highest demand in the job market
*/


SELECT 
    skills,
    count(skills_job_dim.job_id) as demand_count
FROM
    job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location is not NULL
GROUP BY
    skills
ORDER BY
    demand_count DESC, skills ASC
LIMIT 10;

/*
SQL is the most demanded skill. It appears 92,470 times, approximately 38% more often than Excel and 62% more often than Python. This supports making SQL a central part of your Data Analyst learning.

Excel remains highly relevant. With 66,901 mentions, it ranks second, ahead of Python. Employers continue to value spreadsheet-based reporting and analysis alongside programming.

Python is the leading general-purpose programming language in this list. Its 57,238 mentions exceed R's 30,038 by approximately 91%. Python is a strong first language for automation, cleaning and exploratory analysis.

Tableau leads Power BI in this sample. Tableau has 46,469 mentions versus Power BI's 39,419, approximately 18% more. This does not necessarily mean Tableau leads in every country or industry.

Business communication tools also matter. PowerPoint and Word appear among the top 10, indicating that presenting and documenting findings are relevant to analyst roles.
*/

-- ============================================================
-- DATA VALIDATION (run after the analysis query)
-- ============================================================

--Check the ranked skill counts against distinct job IDs and confirm the exact non-null-location filter
WITH ranked_skills AS (
    SELECT sd.skill_id, sd.skills,
           COUNT(sjd.job_id) AS mentions,
           COUNT(DISTINCT sjd.job_id) AS unique_jobs
    FROM job_postings_fact jpf
    JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Analyst'
      AND jpf.job_location IS NOT NULL
    GROUP BY sd.skill_id, sd.skills
),
top_ten AS (
    SELECT * FROM ranked_skills
    ORDER BY mentions DESC, skills ASC
    LIMIT 10
),
checks AS (
    SELECT
        (SELECT COUNT(*) FROM top_ten) AS actual_rows,
        (SELECT LEAST(COUNT(*), 10) FROM ranked_skills) AS expected_rows,
        (SELECT COUNT(*) FROM ranked_skills WHERE mentions <> unique_jobs) AS duplicate_job_skill_counts,
        (SELECT COUNT(*) FROM top_ten WHERE skills IS NULL OR mentions <= 0) AS invalid_top_skills,
        (SELECT COUNT(*) FROM top_ten t
         WHERE EXISTS (SELECT 1 FROM ranked_skills s
                       WHERE s.mentions > t.mentions
                         AND s.skill_id NOT IN (SELECT skill_id FROM top_ten))) AS ranking_errors
)
SELECT 'most demanded skills' AS validation,
       CASE WHEN expected_rows > 0 AND actual_rows = expected_rows
                  AND duplicate_job_skill_counts = 0
                  AND invalid_top_skills = 0 AND ranking_errors = 0
            THEN 'PASS' ELSE 'FAIL' END AS status,
       actual_rows, expected_rows, duplicate_job_skill_counts,
       invalid_top_skills, ranking_errors
FROM checks;
