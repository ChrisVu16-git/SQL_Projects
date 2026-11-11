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
    salary_year_avg DESC
LIMIT 10