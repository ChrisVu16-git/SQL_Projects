/*
Question : what are the most in-demand skills for data analysts ? 
-Join job posting to inner join table similar to query 2 
-Identify the top 5 in-demand skills for a DA
-Focus on all job postings
-Why ? Retrieves the top 5 skills with the highest demand in the job market
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
    demand_count DESC
LIMIT 10

/*
SQL is the most demanded skill. It appears 92,470 times, approximately 38% more often than Excel and 62% more often than Python. This supports making SQL a central part of your Data Analyst learning.

Excel remains highly relevant. With 66,901 mentions, it ranks second, ahead of Python. Employers continue to value spreadsheet-based reporting and analysis alongside programming.

Python is the leading general-purpose programming language in this list. Its 57,238 mentions exceed R's 30,038 by approximately 91%. Python is a strong first language for automation, cleaning and exploratory analysis.

Tableau leads Power BI in this sample. Tableau has 46,469 mentions versus Power BI's 39,419, approximately 18% more. This does not necessarily mean Tableau leads in every country or industry.

Business communication tools also matter. PowerPoint and Word appear among the top 10, indicating that presenting and documenting findings are relevant to analyst roles.
*/

