# Tamil Nadu Assembly Election Analysis — 2021 vs 2026

**SQL Server | Power BI | DAX**

## Project Overview

This project analyzes Tamil Nadu Assembly election results across **234 constituencies**, comparing the 2021 and 2026 results at constituency level.

The analysis was built using SQL Server for data preparation, winner identification, validation, and analytical transformations, followed by Power BI for data modeling, DAX calculations, and interactive visualization.

The objective is to understand constituency-level changes between the two election years, including winning-party transitions, winning margins, turnout changes, and regional patterns.

---

## Analytical Questions

- How many constituencies changed their winning party between 2021 and 2026?
- How many constituencies retained the same winning party?
- How did winning margins change between the two elections?
- How did voter turnout change at constituency and regional levels?
- Which party-to-party transitions occurred most frequently?
- Which constituencies experienced the largest turnout increases?
- How can individual constituency results be explored through filters?

---

## Tools & Technologies

- **SQL Server**
- **T-SQL**
- **Power BI Desktop**
- **DAX**
- **Power Query**
- **GitHub**

---

## Data Workflow

```text
Raw Election Data
       ↓
SQL Server
       ↓
Data Cleaning & Validation
       ↓
Winner Identification
       ↓
Top-2 & Winning Margin Calculation
       ↓
Constituency-Level Analytical View
       ↓
Final QA
       ↓
Power BI Data Model
       ↓
DAX Measures
       ↓
Interactive Dashboard
```

---

## SQL Analysis

The SQL work was separated into four stages:

### 01 — Data Cleaning

`SQL/01_Data_Cleaning.sql`

Includes:

- Source data inspection
- Column and data validation
- Constituency and candidate checks
- Numeric field validation
- Turnout mapping and validation
- Preparation of clean analytical inputs

### 02 — Winner Identification

`SQL/02_Winner_Identification.sql`

Includes:

- Winner identification using `ROW_NUMBER()`
- Top-two candidate extraction
- Runner-up identification
- Winning vote calculations
- Winning margin calculations
- Creation of the constituency-level analytical view

### 03 — Analysis

`SQL/03_Analysis.sql`

Includes:

- Seat movement analysis
- Party transitions
- Winning-margin analysis
- Vote-share analysis
- Reservation-category analysis
- Turnout analysis
- Regional analysis
- Key constituency-level findings

### 04 — Final QA

`SQL/04_Final_QA.sql`

Includes validation for:

- Total row count
- Distinct constituency count
- Duplicate constituency IDs
- Missing critical fields
- Seat-status distribution
- Margin-direction distribution
- Turnout-direction validation

---

## Analytical Data Model

The main analytical dataset is:

```text
dbo.tn_21_26
```

The dataset has **one row per constituency**, resulting in **234 constituency records**.

It brings together:

- 2021 winner
- 2021 winning party
- 2021 winning votes
- 2021 runner-up
- 2021 runner-up party
- 2021 runner-up votes
- 2021 winning margin
- 2026 winner
- 2026 winning party
- 2026 winning votes
- 2026 runner-up
- 2026 runner-up party
- 2026 runner-up votes
- 2026 winning margin
- Margin change
- Seat status
- Party transition
- Reservation category
- 2021 turnout
- 2026 turnout
- Turnout change

---

## Key Findings

### Seat Movement

- **234** constituencies were analyzed.
- **163** constituencies changed their winning party.
- **71** constituencies retained the same winning party.

### Winning Margins

Average winning margin changed from:

| Election | Average Winning Margin |
|---|---:|
| 2021 | 22,870.55 votes |
| 2026 | 16,784.24 votes |

The average margin changed by **-6,086.30 votes**.

At constituency level:

- **138** constituencies had a decreased winning margin.
- **96** had an increased winning margin.
- **0** had no change.

### Turnout

Average turnout changed from:

| Election | Average Turnout |
|---|---:|
| 2021 | 73.37% |
| 2026 | 85.82% |

Average turnout change was **+12.45 percentage points**.

Across the dataset:

- **234** constituencies increased in turnout.
- **0** decreased.
- **0** remained unchanged.

### Regional Turnout

| Region | 2021 | 2026 | Change |
|---|---:|---:|---:|
| Chennai Metro | 63.41% | 84.21% | +20.80 pp |
| Kongu | 73.06% | 87.83% | +14.77 pp |
| North | 78.05% | 89.60% | +11.55 pp |
| South | 71.27% | 81.75% | +10.47 pp |
| Central | 78.92% | 89.26% | +10.35 pp |
| Delta | 74.91% | 84.05% | +9.14 pp |

### Party Transitions

The most frequent winning-party transitions in the analytical dataset include:

| 2021 → 2026 | Constituencies |
|---|---:|
| DMK → TVK | 65 |
| DMK → DMK | 40 |
| AIADMK → TVK | 26 |
| DMK → AIADMK | 22 |
| AIADMK → AIADMK | 22 |
| AIADMK → DMK | 15 |
| INC → TVK | 11 |
| INC → INC | 7 |

These figures describe constituency-level winning-party transitions and should not be interpreted as vote-share changes.

---

## Power BI Dashboard

The Power BI report contains three pages.

### 1. Election Analysis

Provides the overall comparison between 2021 and 2026.

Key visuals include:

- Total constituencies
- Seats flipped
- Seats with no change
- Average turnout comparison
- Average turnout change
- Average margin change
- Seat movement
- Margin direction
- Party transitions
- Regional turnout comparison
- Top 20 constituencies by turnout change

### 2. Party Performance

Focuses on winning-party movement across constituencies.

Includes:

- Party transition analysis
- 2021 → 2026 transition matrix
- Regional winner-party distribution

### 3. Constituency Details

Provides row-level constituency exploration.

Users can filter by:

- Region
- Reservation category
- 2021 winning party
- 2026 winning party
- Seat status
- Constituency

The detailed table provides winner, votes, margins, turnout, and change metrics for individual constituencies.

---

## DAX Measures

Examples of the measures used in the report:

```DAX
Total Constituencies =
DISTINCTCOUNT(tn_21_26[ac_number])
```

```DAX
Seats Flipped =
CALCULATE(
    DISTINCTCOUNT(tn_21_26[ac_number]),
    tn_21_26[seat_status] = "Flipped"
)
```

```DAX
Seats No Change =
CALCULATE(
    DISTINCTCOUNT(tn_21_26[ac_number]),
    tn_21_26[seat_status] = "No Change"
)
```

```DAX
Avg Turnout 2021 =
AVERAGE(tn_21_26[turnout_2021])
```

```DAX
Avg Turnout 2026 =
AVERAGE(tn_21_26[turnout_2026])
```

```DAX
Avg Turnout Change =
AVERAGE(tn_21_26[turnout_change])
```

```DAX
Avg Margin Change =
AVERAGE(tn_21_26[margin_change])
```

---

## Data Validation & QA

Validation was performed at multiple stages rather than relying only on the Power BI output.

Checks included:

- Row-count validation
- Distinct constituency validation
- Duplicate `ac_number` checks
- Missing critical-field checks
- Candidate-level duplicate checks
- Winner identification validation
- Top-two candidate validation
- Seat-status validation
- Margin-direction validation
- Turnout-direction validation
- Constituency-level turnout mapping validation

The final analytical dataset contains **234 rows representing 234 constituencies**.

---

## Project Structure

```text
Tamil-Nadu-Election-Analysis/
│
├── README.md
│
├── datasets/
│   ├── constituency_master.csv
│   ├── tn-2026.csv
│   ├── tn_2021_results.csv
│   └── tn_2026_results.csv
│
├── scripts/
│   └── tne_validation_analysis.sql
│
├── PowerBI/
│   └── Tamilnadu_Election_2026.pbix
│
├── documents/
│   └── Tamil_Nadu_Election_Analysis_2021_2026_Portfolio_Documentation.docx
│
├── Screenshots/
│   ├── 01_Election_Analysis.png
│   ├── 02_Party_Performance.png
│   └── 03_Constituency_Details.png
│
└── Data/
    └── README.md
```

---

## Analytical Limitations

This project focuses on descriptive constituency-level analysis.

The findings show **what changed between the two election datasets**, but they do not establish why those changes occurred.

In particular:

- A change in winning margin does not identify its cause.
- Higher turnout does not establish which party benefited from that change.
- Party-transition counts describe winning-party changes, not overall vote-share movement.
- The analysis does not attempt to predict future election outcomes.

---

## Portfolio Value

This project demonstrates an end-to-end data analytics workflow:

**SQL → Data Validation → Data Modeling → DAX → Power BI → Analytical Storytelling**

It demonstrates practical experience with:

- SQL data preparation
- Window functions
- CTEs
- Views
- Aggregations
- Data validation
- Relational data modeling
- Power BI
- DAX measures
- Interactive filtering
- KPI design
- Analytical documentation

---

## Author

**SAGAR TAKORE**

Data Analyst / Power BI Developer — Portfolio Project

Skills demonstrated: **SQL Server | Power BI | DAX | Data Analysis | Data Visualization**
