WITH top_paying_jobs AS (
    SELECT
         job_id 
        ,salary_year_avg
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 100
)
SELECT
     t3.skills
    ,COUNT (DISTINCT t1.job_id) AS skill_count  
                                                -- To see what's happening here, comment out lines 11 and 12 as well as 23-25, and
                                                -- uncomment lines 15-17.
    --  t3.skills                               
    -- ,t1.job_id
    -- ,salary_year_avg
FROM top_paying_jobs t1
INNER JOIN skills_job_dim t2
    ON t1.job_id = t2.job_id
INNER JOIN skills_dim t3
    ON t2.skill_id = t3.skill_id
GROUP BY t3.skills
ORDER BY skill_count DESC
LIMIT 10
;

-- In a first step, select the 100 top paying jobs, then add the skills colums, then perform
-- a COUNT DISTINCT of job_id grouped per skill in order to see how many times a given skill 
-- shows up. You can play around with the LIMIT in line 8 to see whether the trend stays stable
-- with an increase of your sample.


