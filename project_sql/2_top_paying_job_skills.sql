-- Work in progress

-- Note for later exploration: SAS is surprisingly common

WITH top_paying_jobs AS (

    SELECT
         t1.job_id
        --,t2.name
        ,t1.job_title
        -- ,t1.job_location
        -- ,t1.job_work_from_home
        -- ,t1.job_schedule_type
        ,t1.salary_year_avg
        --,t1.job_posted_date
    FROM job_postings_fact t1
    LEFT JOIN company_dim t2
        ON t1.company_id = t2.company_id
    WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        job_work_from_home = TRUE AND
        salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 100
)

SELECT
     COUNT(tpj.job_id)
    -- ,tpj.name
    -- ,tpj.job_title
    -- ,tpj.salary_year_avg
    -- ,tpj.job_posted_date
    ,sd.skills
FROM top_paying_jobs tpj
LEFT JOIN skills_job_dim sjd
    ON tpj.job_id = sjd.job_id
LEFT JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id
WHERE sd.skills IS NOT NULL
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10
;