-- On the basis of earlier queries:

-- 1. find jobs with highest salary

WITH top_paying_jobs AS (
    SELECT
         job_id 
        ,salary_year_avg
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 1000
),

-- 2. find skills associated with highest paid jobs

top_paying_skills AS (
    SELECT
         t3.skills
        ,COUNT (DISTINCT t1.job_id) AS count_tps  
    FROM top_paying_jobs t1
    INNER JOIN skills_job_dim t2
        ON t1.job_id = t2.job_id
    INNER JOIN skills_dim t3
        ON t2.skill_id = t3.skill_id
    GROUP BY t3.skills
    ORDER BY count_tps DESC
    LIMIT 10
),

-- 3. find top in demand skills for Data Analysts

top_in_demand_skills AS (
    SELECT
         skills
        ,SUM(no_of_skills) AS count_tids
    FROM (
        SELECT
             t1.job_title_short 
            ,t3.skills 
            ,COUNT(t1.job_id) as no_of_skills
        FROM job_postings_fact t1
        LEFT JOIN skills_job_dim t2
            ON t1.job_id = t2.job_id
        LEFT JOIN skills_dim t3
            ON t2.skill_id = t3.skill_id
        WHERE 
            skills IS NOT NULL
        GROUP BY t3.skills, t1.job_title_short
        ORDER BY no_of_skills DESC
    )
    WHERE job_title_short = 'Data Analyst'
    GROUP BY skills
    ORDER BY count_tids DESC
    LIMIT 10
)

-- and then:

-- 4. find overlap of top paying skills and top in demand skills

SELECT
     tps.skills
    ,count_tids
    ,count_tps
FROM top_in_demand_skills tids
INNER JOIN top_paying_skills tps
    ON tids.skills = tps.skills
;