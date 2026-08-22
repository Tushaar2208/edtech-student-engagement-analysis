-- ==========================================================
-- OULAD STUDENT ENGAGEMENT & OUTCOME ANALYSIS
-- 02_analysis.sql
--
-- Grain:
-- One row = one student + one course presentation
-- ==========================================================
WITH engagement AS (
    -- ------------------------------------------------------
    -- Overall VLE engagement
    -- ------------------------------------------------------
    SELECT id_student,
        code_module,
        code_presentation,
        SUM(sum_click) AS total_clicks,
        COUNT(DISTINCT date) AS active_days,
        COUNT(DISTINCT id_site) AS unique_resources,
        ROUND(
            CAST(SUM(sum_click) AS FLOAT) / COUNT(DISTINCT date),
            2
        ) AS avg_clicks_per_active_day
    FROM studentVle
    GROUP BY id_student,
        code_module,
        code_presentation
),
quarterly_activity AS (
    -- ------------------------------------------------------
    -- Engagement by course phase
    -- ------------------------------------------------------
    SELECT sv.id_student,
        sv.code_module,
        sv.code_presentation,
        CASE
            WHEN sv.date <= c.module_presentation_length * 0.25 THEN 'Q1'
            WHEN sv.date <= c.module_presentation_length * 0.50 THEN 'Q2'
            WHEN sv.date <= c.module_presentation_length * 0.75 THEN 'Q3'
            ELSE 'Q4'
        END AS course_phase,
        SUM(sv.sum_click) AS phase_clicks
    FROM studentVle sv
        JOIN courses c ON sv.code_module = c.code_module
        AND sv.code_presentation = c.code_presentation
    GROUP BY sv.id_student,
        sv.code_module,
        sv.code_presentation,
        course_phase
),
quarterly_features AS (
    -- ------------------------------------------------------
    -- Convert quarterly activity into columns
    -- ------------------------------------------------------
    SELECT id_student,
        code_module,
        code_presentation,
        -- Activity indicators
        MAX(
            CASE
                WHEN course_phase = 'Q1' THEN 1
                ELSE 0
            END
        ) AS q1_active,
        MAX(
            CASE
                WHEN course_phase = 'Q2' THEN 1
                ELSE 0
            END
        ) AS q2_active,
        MAX(
            CASE
                WHEN course_phase = 'Q3' THEN 1
                ELSE 0
            END
        ) AS q3_active,
        MAX(
            CASE
                WHEN course_phase = 'Q4' THEN 1
                ELSE 0
            END
        ) AS q4_active,
        -- Clicks by phase
        MAX(
            CASE
                WHEN course_phase = 'Q1' THEN phase_clicks
                ELSE 0
            END
        ) AS q1_clicks,
        MAX(
            CASE
                WHEN course_phase = 'Q2' THEN phase_clicks
                ELSE 0
            END
        ) AS q2_clicks,
        MAX(
            CASE
                WHEN course_phase = 'Q3' THEN phase_clicks
                ELSE 0
            END
        ) AS q3_clicks,
        MAX(
            CASE
                WHEN course_phase = 'Q4' THEN phase_clicks
                ELSE 0
            END
        ) AS q4_clicks
    FROM quarterly_activity
    GROUP BY id_student,
        code_module,
        code_presentation
),
assessment_performance AS (
    -- ------------------------------------------------------
    -- Assessment performance
    -- ------------------------------------------------------
    SELECT sa.id_student,
        a.code_module,
        a.code_presentation,
        COUNT(sa.id_assessment) AS assessments_completed,
        ROUND(
            AVG(sa.score),
            2
        ) AS average_assessment_score
    FROM studentAssessments sa
        JOIN assessments a ON sa.id_assessment = a.id_assessment
    GROUP BY sa.id_student,
        a.code_module,
        a.code_presentation
) -- ==========================================================
-- FINAL ANALYTICAL DATASET
-- ==========================================================
SELECT -- ------------------------------------------------------
    -- Student / course identifiers
    -- ------------------------------------------------------
    si.id_student,
    si.code_module,
    si.code_presentation,
    -- ------------------------------------------------------
    -- Student characteristics
    -- ------------------------------------------------------
    si.gender,
    si.age_band,
    si.imd_band,
    si.num_of_prev_attempts,
    si.studied_credits,
    si.disability,
    -- ------------------------------------------------------
    -- Final outcome
    -- ------------------------------------------------------
    si.final_result,
    -- ------------------------------------------------------
    -- Overall engagement
    -- ------------------------------------------------------
    COALESCE(e.total_clicks, 0) AS total_clicks,
    COALESCE(e.active_days, 0) AS active_days,
    COALESCE(e.unique_resources, 0) AS unique_resources,
    COALESCE(e.avg_clicks_per_active_day, 0) AS avg_clicks_per_active_day,
    -- ------------------------------------------------------
    -- Quarterly activity
    -- ------------------------------------------------------
    COALESCE(qf.q1_active, 0) AS q1_active,
    COALESCE(qf.q2_active, 0) AS q2_active,
    COALESCE(qf.q3_active, 0) AS q3_active,
    COALESCE(qf.q4_active, 0) AS q4_active,
    -- ------------------------------------------------------
    -- Quarterly engagement
    -- ------------------------------------------------------
    COALESCE(qf.q1_clicks, 0) AS q1_clicks,
    COALESCE(qf.q2_clicks, 0) AS q2_clicks,
    COALESCE(qf.q3_clicks, 0) AS q3_clicks,
    COALESCE(qf.q4_clicks, 0) AS q4_clicks,
    -- ------------------------------------------------------
    -- Assessment performance
    -- ------------------------------------------------------
    COALESCE(ap.assessments_completed, 0) AS assessments_completed,
    COALESCE(ap.average_assessment_score, 0) AS average_assessment_score
FROM studentInfo si -- ----------------------------------------------------------
    -- Overall engagement
    -- ----------------------------------------------------------
    LEFT JOIN engagement e ON si.id_student = e.id_student
    AND si.code_module = e.code_module
    AND si.code_presentation = e.code_presentation -- ----------------------------------------------------------
    -- Quarterly engagement
    -- ----------------------------------------------------------
    LEFT JOIN quarterly_features qf ON si.id_student = qf.id_student
    AND si.code_module = qf.code_module
    AND si.code_presentation = qf.code_presentation -- ----------------------------------------------------------
    -- Assessment performance
    -- ----------------------------------------------------------
    LEFT JOIN assessment_performance ap ON si.id_student = ap.id_student
    AND si.code_module = ap.code_module
    AND si.code_presentation = ap.code_presentation;