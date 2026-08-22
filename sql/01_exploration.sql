-- ==========================================================
-- OULAD PROJECT — INITIAL DATA EXPLORATION
-- ==========================================================
-- 1. See all tables
SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;
-- 2. Check row counts
SELECT 'assessments' AS table_name,
    COUNT(*) AS rows
FROM assessments
UNION ALL
SELECT 'courses',
    COUNT(*)
FROM courses
UNION ALL
SELECT 'studentAssessments',
    COUNT(*)
FROM studentAssessments
UNION ALL
SELECT 'studentInfo',
    COUNT(*)
FROM studentInfo
UNION ALL
SELECT 'studentRegistration',
    COUNT(*)
FROM studentRegistration
UNION ALL
SELECT 'studentVle',
    COUNT(*)
FROM studentVle
UNION ALL
SELECT 'vle',
    COUNT(*)
FROM vle;
-- 3. Look at student outcomes
SELECT final_result,
    COUNT(*) AS students
FROM studentInfo
GROUP BY final_result
ORDER BY students DESC;
-- 4. Look at courses
SELECT *
FROM courses
LIMIT 10;
-- 5. Look at student information
SELECT *
FROM studentInfo
LIMIT 10;
-- 6. Look at registration data
SELECT *
FROM studentRegistration
LIMIT 10;
-- 7. Look at assessment data
SELECT *
FROM assessments
LIMIT 10;
-- 8. Look at student assessment results
SELECT *
FROM studentAssessments
LIMIT 10;
-- 9. Look at VLE activity
SELECT *
FROM studentVle
LIMIT 10;
-- 10. Look at VLE materials
SELECT *
FROM vle
LIMIT 10;

-- ==========================================================
-- UNDERSTANDING THE STUDENT-COURSE GRAIN
-- ==========================================================
-- 1. Total records vs unique students
SELECT COUNT(*) AS total_records,
    COUNT(DISTINCT id_student) AS unique_students
FROM studentInfo;
-- 2. Unique student-course combinations
SELECT COUNT(
        DISTINCT id_student || '-' || code_module || '-' || code_presentation
    ) AS student_course_combinations
FROM studentInfo;
-- 3. Students by course presentation
SELECT code_module,
    code_presentation,
    COUNT(*) AS students
FROM studentInfo
GROUP BY code_module,
    code_presentation
ORDER BY code_module,
    code_presentation; 

-- ==========================================================
-- STUDENT ENGAGEMENT METRICS
-- ==========================================================
SELECT id_student,
    code_module,
    code_presentation,
    -- Total number of interactions
    SUM(sum_click) AS total_clicks,
    -- Number of days the student was active
    COUNT(DISTINCT date) AS active_days,
    -- Number of different learning resources accessed
    COUNT(DISTINCT id_site) AS unique_resources,
    -- Average interactions per active day
    ROUND(
        CAST(SUM(sum_click) AS FLOAT) / COUNT(DISTINCT date),
        2
    ) AS avg_clicks_per_active_day
FROM studentVle
GROUP BY id_student,
    code_module,
    code_presentation
LIMIT 20;
-- ==========================================================
-- ENGAGEMENT + COURSE OUTCOME
-- ==========================================================
SELECT sv.id_student,
    sv.code_module,
    sv.code_presentation,
    -- Engagement metrics
    SUM(sv.sum_click) AS total_clicks,
    COUNT(DISTINCT sv.date) AS active_days,
    COUNT(DISTINCT sv.id_site) AS unique_resources,
    ROUND(
        CAST(SUM(sv.sum_click) AS FLOAT) / COUNT(DISTINCT sv.date),
        2
    ) AS avg_clicks_per_active_day,
    -- Course outcome
    si.final_result
FROM studentVle sv
    JOIN studentInfo si ON sv.id_student = si.id_student
    AND sv.code_module = si.code_module
    AND sv.code_presentation = si.code_presentation
GROUP BY sv.id_student,
    sv.code_module,
    sv.code_presentation,
    si.final_result
LIMIT 20;
-- ==========================================================
-- ENGAGEMENT BY COURSE OUTCOME
-- ==========================================================
SELECT si.final_result,
    COUNT(DISTINCT sv.id_student) AS students,
    ROUND(AVG(sv.total_clicks), 2) AS avg_total_clicks,
    ROUND(AVG(sv.active_days), 2) AS avg_active_days,
    ROUND(AVG(sv.unique_resources), 2) AS avg_unique_resources,
    ROUND(AVG(sv.avg_clicks_per_active_day), 2) AS avg_clicks_per_day
FROM (
        SELECT id_student,
            code_module,
            code_presentation,
            SUM(sum_click) AS total_clicks,
            COUNT(DISTINCT date) AS active_days,
            COUNT(DISTINCT id_site) AS unique_resources,
            CAST(SUM(sum_click) AS FLOAT) / COUNT(DISTINCT date) AS avg_clicks_per_active_day
        FROM studentVle
        GROUP BY id_student,
            code_module,
            code_presentation
    ) sv
    JOIN studentInfo si ON sv.id_student = si.id_student
    AND sv.code_module = si.code_module
    AND sv.code_presentation = si.code_presentation
GROUP BY si.final_result
ORDER BY avg_total_clicks DESC;


SELECT c.code_module,
    c.code_presentation,
    c.module_presentation_length
FROM courses c
ORDER BY c.code_module,
    c.code_presentation;

-- ==========================================================
-- ENGAGEMENT BY COURSE PHASE
-- ==========================================================
SELECT si.final_result,
    CASE
        WHEN sv.date <= c.module_presentation_length * 0.25 THEN 'Q1 - Early'
        WHEN sv.date <= c.module_presentation_length * 0.50 THEN 'Q2 - Developing'
        WHEN sv.date <= c.module_presentation_length * 0.75 THEN 'Q3 - Later'
        ELSE 'Q4 - Final'
    END AS course_phase,
    COUNT(DISTINCT sv.id_student) AS active_students,
    ROUND(AVG(sv.sum_click), 2) AS avg_clicks_per_activity_record
FROM studentVle sv
    JOIN studentInfo si ON sv.id_student = si.id_student
    AND sv.code_module = si.code_module
    AND sv.code_presentation = si.code_presentation
    JOIN courses c ON sv.code_module = c.code_module
    AND sv.code_presentation = c.code_presentation
GROUP BY si.final_result,
    course_phase
ORDER BY si.final_result,
    course_phase;
    -- ==========================================================
-- STUDENT ENGAGEMENT BY COURSE PHASE
-- One row = one student + one course + one phase
-- ==========================================================
WITH student_quarterly AS (
    SELECT sv.id_student,
        sv.code_module,
        sv.code_presentation,
        CASE
            WHEN sv.date <= c.module_presentation_length * 0.25 THEN 'Q1 - Early'
            WHEN sv.date <= c.module_presentation_length * 0.50 THEN 'Q2 - Developing'
            WHEN sv.date <= c.module_presentation_length * 0.75 THEN 'Q3 - Later'
            ELSE 'Q4 - Final'
        END AS course_phase,
        SUM(sv.sum_click) AS total_clicks,
        COUNT(DISTINCT sv.date) AS active_days,
        COUNT(DISTINCT sv.id_site) AS unique_resources
    FROM studentVle sv
        JOIN courses c ON sv.code_module = c.code_module
        AND sv.code_presentation = c.code_presentation
    GROUP BY sv.id_student,
        sv.code_module,
        sv.code_presentation,
        course_phase
)
SELECT sq.course_phase,
    si.final_result,
    COUNT(*) AS student_course_records,
    ROUND(AVG(sq.total_clicks), 2) AS avg_clicks,
    ROUND(AVG(sq.active_days), 2) AS avg_active_days,
    ROUND(AVG(sq.unique_resources), 2) AS avg_unique_resources
FROM student_quarterly sq
    JOIN studentInfo si ON sq.id_student = si.id_student
    AND sq.code_module = si.code_module
    AND sq.code_presentation = si.code_presentation
GROUP BY sq.course_phase,
    si.final_result
ORDER BY si.final_result,
    sq.course_phase;

-- ==========================================================
-- STUDENT ACTIVITY RETENTION BY COURSE PHASE
-- Every enrolled student gets all four phases
-- ==========================================================
WITH phases AS (
    SELECT 'Q1 - Early' AS course_phase
    UNION ALL
    SELECT 'Q2 - Developing'
    UNION ALL
    SELECT 'Q3 - Later'
    UNION ALL
    SELECT 'Q4 - Final'
),
student_cohort AS (
    SELECT id_student,
        code_module,
        code_presentation,
        final_result
    FROM studentInfo
)
SELECT sc.id_student,
    sc.code_module,
    sc.code_presentation,
    sc.final_result,
    p.course_phase
FROM student_cohort sc
    CROSS JOIN phases p
LIMIT 20;

-- ==========================================================
-- ADD VLE ACTIVITY TO THE STUDENT-QUARTER COHORT
-- ==========================================================
WITH phases AS (
    SELECT 'Q1 - Early' AS course_phase
    UNION ALL
    SELECT 'Q2 - Developing'
    UNION ALL
    SELECT 'Q3 - Later'
    UNION ALL
    SELECT 'Q4 - Final'
),
student_cohort AS (
    SELECT id_student,
        code_module,
        code_presentation,
        final_result
    FROM studentInfo
),
activity_by_phase AS (
    SELECT sv.id_student,
        sv.code_module,
        sv.code_presentation,
        CASE
            WHEN sv.date <= c.module_presentation_length * 0.25 THEN 'Q1 - Early'
            WHEN sv.date <= c.module_presentation_length * 0.50 THEN 'Q2 - Developing'
            WHEN sv.date <= c.module_presentation_length * 0.75 THEN 'Q3 - Later'
            ELSE 'Q4 - Final'
        END AS course_phase
    FROM studentVle sv
        JOIN courses c ON sv.code_module = c.code_module
        AND sv.code_presentation = c.code_presentation
    GROUP BY sv.id_student,
        sv.code_module,
        sv.code_presentation,
        course_phase
)
SELECT sc.id_student,
    sc.code_module,
    sc.code_presentation,
    sc.final_result,
    p.course_phase,
    CASE
        WHEN ap.id_student IS NOT NULL THEN 1
        ELSE 0
    END AS active
FROM student_cohort sc
    CROSS JOIN phases p
    LEFT JOIN activity_by_phase ap ON sc.id_student = ap.id_student
    AND sc.code_module = ap.code_module
    AND sc.code_presentation = ap.code_presentation
    AND p.course_phase = ap.course_phase
LIMIT 30;

-- ==========================================================
-- ACTIVITY RETENTION BY OUTCOME
-- ==========================================================
WITH phases AS (
    SELECT 'Q1 - Early' AS course_phase
    UNION ALL
    SELECT 'Q2 - Developing'
    UNION ALL
    SELECT 'Q3 - Later'
    UNION ALL
    SELECT 'Q4 - Final'
),
student_cohort AS (
    SELECT id_student,
        code_module,
        code_presentation,
        final_result
    FROM studentInfo
),
activity_by_phase AS (
    SELECT sv.id_student,
        sv.code_module,
        sv.code_presentation,
        CASE
            WHEN sv.date <= c.module_presentation_length * 0.25 THEN 'Q1 - Early'
            WHEN sv.date <= c.module_presentation_length * 0.50 THEN 'Q2 - Developing'
            WHEN sv.date <= c.module_presentation_length * 0.75 THEN 'Q3 - Later'
            ELSE 'Q4 - Final'
        END AS course_phase
    FROM studentVle sv
        JOIN courses c ON sv.code_module = c.code_module
        AND sv.code_presentation = c.code_presentation
    GROUP BY sv.id_student,
        sv.code_module,
        sv.code_presentation,
        course_phase
),
student_phase_activity AS (
    SELECT sc.id_student,
        sc.code_module,
        sc.code_presentation,
        sc.final_result,
        p.course_phase,
        CASE
            WHEN ap.id_student IS NOT NULL THEN 1
            ELSE 0
        END AS active
    FROM student_cohort sc
        CROSS JOIN phases p
        LEFT JOIN activity_by_phase ap ON sc.id_student = ap.id_student
        AND sc.code_module = ap.code_module
        AND sc.code_presentation = ap.code_presentation
        AND p.course_phase = ap.course_phase
)
SELECT final_result,
    course_phase,
    COUNT(*) AS total_students,
    SUM(active) AS active_students,
    ROUND(
        100.0 * SUM(active) / COUNT(*),
        2
    ) AS activity_rate
FROM student_phase_activity
GROUP BY final_result,
    course_phase
ORDER BY final_result,
    CASE
        course_phase
        WHEN 'Q1 - Early' THEN 1
        WHEN 'Q2 - Developing' THEN 2
        WHEN 'Q3 - Later' THEN 3
        WHEN 'Q4 - Final' THEN 4
    END;