# 🎓 EdTech Student Engagement & Dropout Risk Analysis

### SQL • Python • Pandas • Power BI • SQLite

**32,593 student-course records analyzed** · **40.56% early-disengagement rate among withdrawn students vs. 0.31% among students who passed** · 3-page interactive Power BI dashboard

---

## 📊 Dashboard

<p align="center">
  <img src="https://github.com/Tushaar2208/edtech-student-engagement-analysis/raw/main/screenshots/03_early_warning.png" width="800" alt="Early Warning Dashboard">
</p>

<details>
<summary><b>📁 View all 3 dashboard pages</b></summary>
<br>

**Page 1 — Student Outcomes**
![Student Outcomes](https://github.com/Tushaar2208/edtech-student-engagement-analysis/raw/main/screenshots/01_student_outcomes.png)

**Page 2 — Engagement & Performance**
![Engagement & Performance](https://github.com/Tushaar2208/edtech-student-engagement-analysis/raw/main/screenshots/02_engagement_performance.png)

**Page 3 — Early Warning**
![Early Warning](https://github.com/Tushaar2208/edtech-student-engagement-analysis/raw/main/screenshots/03_early_warning.png)

</details>

---

## 📌 Project Overview

This project investigates how student engagement with an online learning platform relates to academic outcomes, and whether early disengagement can serve as a warning signal for students who eventually fail or withdraw. Using the **Open University Learning Analytics Dataset (OULAD)**, the analysis covers **32,593 student-course records** (~29K unique students) across four outcomes — Distinction, Pass, Fail, and Withdrawn.

**OULAD → SQL / SQLite → Data Aggregation → Python / Pandas → Feature Engineering & Validation → Power BI → Interactive Dashboard**

---

## 🗂 Dataset

Source: Open University Learning Analytics Dataset (OULAD)

- 32,593 student-course records / enrollments (~29K unique students)
- 7 source tables: `studentInfo`, `courses`, `studentRegistration`, `studentVle`, `vle`, `assessments`, `studentAssessments`
- 4 final outcome categories: **Distinction, Pass, Fail, Withdrawn**
- Largest table: `studentVle`, recording every VLE interaction over time — required aggregation before analysis

---

## 🎯 Business Question

**Can early disengagement with the Virtual Learning Environment (VLE) serve as a useful warning signal for students who eventually fail or withdraw?**

---

## 📈 Key Insights

### 1️⃣ Engagement Gradient Across Outcomes

| Outcome | Avg. Total Clicks | Avg. Active Days | Avg. Unique Resources | Avg. Clicks / Active Day |
|---|---|---|---|---|
| Distinction | 2,666.76 | 110.04 | 102.45 | 21.94 |
| Pass | 1,921.81 | 87.04 | 89.06 | 20.46 |
| Fail | 651.85 | 33.18 | 43.08 | 16.29 |
| Withdrawn | 313.95 | 16.29 | 24.23 | 12.05 |

Engagement rises consistently from Withdrawn → Fail → Pass → Distinction. These are **observed associations**, not a claim that engagement causes success.

### 2️⃣ Engagement Persistence, Not Just Volume

| Outcome | Q1 Active | Q2 Active | Q3 Active | Q4 Active |
|---|---|---|---|---|
| Distinction | 99.80% | 99.70% | 99.93% | 99.77% |
| Pass | 99.68% | 99.61% | 99.67% | 99.36% |
| Fail | 94.04% | 68.15% | 50.87% | 36.54% |
| Withdrawn | 70.37% | 29.96% | 14.06% | 3.96% |

Successful students stayed active near 99% through all four course phases. Withdrawn students' activity collapsed from 70.37% to 3.96% by the final phase — shifting the analysis from engagement *volume* to engagement *persistence* over time.

### 3️⃣ Assessment Performance Mirrors Engagement

| Outcome | Avg. Assessment Score | Avg. Assessments Completed |
|---|---|---|
| Distinction | 88.49 | 8.71 |
| Pass | 76.16 | 8.58 |
| Fail | 52.51 | 4.04 |
| Withdrawn | 29.50 | 1.29 |

### 4️⃣ Early Disengagement Is the Strongest Signal

A student was flagged as **early disengagement** if active in Q1 but showed zero recorded activity in Q2:

```python
df["early_disengagement"] = (
    (df["q1_active"] == 1) &
    (df["q2_active"] == 0)
).astype(int)
```

| Outcome | Early Disengagement Rate |
|---|---|
| Withdrawn | 40.56% |
| Fail | 26.42% |
| Pass | 0.31% |
| Distinction | 0.23% |

**40.56% of students who ultimately withdrew** went inactive between Q1 and Q2, compared with just **0.31% of students who passed** — the clearest early-warning pattern in the dataset.

---

## 💡 Potential Applications

- Flag students for early outreach when Q1 → Q2 activity drops to zero
- Prioritize advisor check-ins for the Fail/Withdrawn risk band rather than treating all students uniformly
- Track active days and course-phase persistence alongside raw click counts, not in place of them
- Use assessment completion rate as a secondary risk indicator alongside engagement

---

## ⚙️ Data Pipeline

### 1️⃣ Data Exploration & Aggregation (SQL / SQLite)

- Explored schema, table sizes, and relationships across all 7 OULAD tables
- Established the student + course module + course presentation grain (32,593 records ≠ unique students)
- Aggregated `studentVle` interactions and joined student/course/outcome data into an analytical dataset

📂 View SQL files:  
👉 [01_exploration.sql](https://github.com/Tushaar2208/edtech-student-engagement-analysis/blob/main/sql/01_exploration.sql)  
👉 [02_analysis.sql](https://github.com/Tushaar2208/edtech-student-engagement-analysis/blob/main/sql/02_analysis.sql)

---

### 2️⃣ Feature Engineering & Validation (Python / Pandas)

- Calculated engagement metrics: total clicks, active days, unique resources, clicks/active day
- Built course-phase (Q1–Q4) activity and click fields
- Engineered the `early_disengagement` indicator and validated all findings
- Exported the final analysis-ready dataset for Power BI

📂 View notebooks:  
👉 [01_data_cleaning.ipynb](https://github.com/Tushaar2208/edtech-student-engagement-analysis/blob/main/python/01_data_cleaning.ipynb)  
👉 [02_analysis.ipynb](https://github.com/Tushaar2208/edtech-student-engagement-analysis/blob/main/python/02_analysis.ipynb)

---

### 3️⃣ Dashboard Development (Power BI)

- Built a 3-page dashboard: Student Outcomes → Engagement & Performance → Early Warning
- Created DAX measures for pass/withdrawal/distinction rates, average engagement, and early disengagement rate
- Added slicers for gender, age band, IMD band, and disability

📂 View dashboard file:  
👉 [EdTech_Student_Engagement_Analysis.pbix](https://github.com/Tushaar2208/edtech-student-engagement-analysis/blob/main/dashboard/EdTech_Student_Engagement_Analysis.pbix)

---

## 🛠 Tools & Skills Demonstrated

### Tools

- SQL / SQLite
- Python (Pandas)
- Power BI
- DAX
- Git & GitHub

### Skills

- Data Cleaning & Transformation
- Feature Engineering
- Longitudinal / Course-Phase Analysis
- Early-Warning Indicator Design
- Dashboard Development
- Business Intelligence Reporting
- Data Storytelling

---

## 📋 Scope & Limitations

This project is descriptive analytics, not predictive modeling.

**What it is:** engagement analysis, outcome segmentation, course-phase (longitudinal) analysis, an interpretable early-disengagement indicator, and an interactive BI dashboard.

**What it is not:** a machine-learning model, a causal analysis, a validated prediction system, or a production early-warning tool.

The findings describe strong associations between engagement and outcomes — not proof of causation.

---

## 💼 Why This Project Matters

This project demonstrates the ability to:

- Move from raw multi-table data to a single analysis-ready dataset using SQL
- Engineer interpretable engagement metrics in Python, including a course-phase and early-warning indicator
- Design a multi-page, stakeholder-focused Power BI dashboard with custom DAX measures
- Communicate a clear, well-scoped analytical finding without overstating what the data supports
