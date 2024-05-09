-- Work in progress

SELECT
     t1.job_id
    ,t2.name
    ,t1.job_title
    ,t1.job_location
    ,t1.job_work_from_home
    ,t1.job_schedule_type
    ,t1.salary_year_avg
    ,t1.job_posted_date
FROM job_postings_fact t1
LEFT JOIN company_dim t2
    ON t1.company_id = t2.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    job_work_from_home = TRUE AND
    salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10
;