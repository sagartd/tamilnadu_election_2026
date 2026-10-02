Tamil Nadu Assembly Election Analysis — 2021 vs 2026

    SQL Server | Power BI | DAX
------------------------------------------------------   
Project Overview:
----------------
234 constituencies

comparison of 2021 vs 2026

SQL Server for preparation/validation

Power BI for interactive analysis 

------------------------------------------------------
Business Questions:
-------------------
How many constituencies changed winning party?

Which party transitions occurred most frequently?

How did winning margins change?

How did turnout change?

Which regions/constituencies had the largest turnout changes?

How did an individual constituency change?

------------------------------------------------------
Data Workflow:
--------------
Raw Data

   ↓
   
SQL Server

   ↓
   
Cleaning & Validation

   ↓
   
Winner / Runner-up

   ↓
   
Margin + Turnout Analysis

   ↓
   
dbo.tn_21_26

   ↓
   
Power BI

-------------------------------------------------------------------
Key Findings:
-------------
163 / 234 constituencies flipped

Average winning margin changed from 22,870.55 to 16,784.24 votes

Average turnout increased from 73.37% to 85.82% (+12.45 pp)

-------------------------------------------------------------------
Dashboard:
----------
ELECTION ANALYSIS:
<img width="962" height="537" alt="Screenshot 2026-10-02 212621" src="https://github.com/user-attachments/assets/1177204f-29fb-47b5-afca-3868ec0fd7a1" />

PARTY PERFORMANCE:
<img width="966" height="540" alt="Screenshot 2026-10-02 212633" src="https://github.com/user-attachments/assets/25375a9a-546b-4b09-a7c2-e563fc36bf82" />

CONSTITUENCY DETAILS:
<img width="1030" height="537" alt="Screenshot 2026-10-02 212645" src="https://github.com/user-attachments/assets/fe88cfc5-3d6d-4b5f-91e5-a3b69e4320b9" />
-------------------------------------------------------------------
SQL Highlights:
---------------

ROW_NUMBER()

CTEs

joins

aggregation

validation queries

analytical view creation

-------------------------------------------------------------------
Power BI / DAX:
---------------

KPI measures

interactive slicers

conditional formatting

page navigation

constituency-level filtering

-------------------------------------------------------------------
Data Validation:
----------------

234 constituencies

duplicate AC numbers

winners

votes

margins

turnout

final seat-status counts

-------------------------------------------------------------------
Limitations:
----------------

The analysis is descriptive and does not establish causal relationships.

-------------------------------------------------------------------
