-- work in progress

-- First up, I can perform a general analysis and find the most demanded 
-- skills across the whole dataset (see the inner query). But let's say I
-- want to see the results for particular job roles. Then I can write the 
-- inner query into a subquery.

SELECT
     skills
    ,SUM(no_of_skills) AS skill_count
FROM (
    SELECT
         t3.skills 
        ,t1.job_title_short
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
GROUP BY skills, job_title_short
ORDER BY skill_count DESC
LIMIT 5
;

-- SELECT
--     job_title_short,
--     skills,
--     SUM(no_of_skills) AS skill_count
-- FROM (
--     SELECT
--         t3.skills,
--         t1.job_title_short,
--         COUNT(t1.job_id) as no_of_skills
--     FROM job_postings_fact t1
--     LEFT JOIN skills_job_dim t2 ON t1.job_id = t2.job_id
--     LEFT JOIN skills_dim t3 ON t2.skill_id = t3.skill_id
--     WHERE skills IS NOT NULL
--     GROUP BY t3.skills, t1.job_title_short
    
-- )
-- GROUP BY job_title_short, skills
-- ORDER BY job_title_short, skill_count DESC;

WITH ranked_skills AS (
    SELECT
        job_title_short,
        skills,
        SUM(no_of_skills) AS skill_count,
        ROW_NUMBER() OVER (PARTITION BY job_title_short ORDER BY SUM(no_of_skills) DESC) AS rn
    FROM (
        SELECT
            t3.skills,
            t1.job_title_short,
            COUNT(t1.job_id) as no_of_skills
        FROM job_postings_fact t1
        LEFT JOIN skills_job_dim t2 ON t1.job_id = t2.job_id
        LEFT JOIN skills_dim t3 ON t2.skill_id = t3.skill_id
        WHERE skills IS NOT NULL
        GROUP BY t3.skills, t1.job_title_short
    ) inner_query
    GROUP BY job_title_short, skills
)
SELECT
    job_title_short,
    skills,
    skill_count
FROM ranked_skills
WHERE rn <= 5
ORDER BY job_title_short, skill_count DESC;

-- The inner query tells me how many job postings for a particular job title demand a particular skill.
-- For example, if you run this as a standalone query, you'll find that azure was demanded in 60823 job 
-- postings for Data Engineers.

-- The window function (ROW_NUMBER in this case) takes the result set from the inner query
-- and divides it up into partitions: one partition per job_title_short. Then, within each 
-- partition (e.g. Business Analyst, Data Engineer, etc.), it displays the demanded skills
-- order by how frequently they are demanded for that job_title_short. For example, there
-- were 17372 job postings for Business Analysts that demanded SQL as a skill.

-- Finally, the inner query together with its outer query (the one that applies the window function),
-- is stored as a CTE (note the WITH ranked_skills AS command). Out of the result set produced by the 
-- CTE, I can the easily select the variables that I'm interested in, but I don't need to produce a never
-- ending result set: the row number (rn) assinged in the outer query provides a great filtering variable.
-- Therefore, I can select the top 5 skills per job_title_short by indicating that I only want those rows
-- where rn is less than or eqal to 5.