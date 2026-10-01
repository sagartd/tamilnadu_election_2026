use tnElection;

SELECT
  *
FROM dbo.tn_2026_results
SELECT 
  *
FROM dbo.tn_2021_results
-----------------------------------------------------------------------------------
/* Clean and validate the data first

Create a clean analytical model.

Check 2021
Verify:
1. 234 constituencies
2. No duplicate candidate rows
3. ac_number ranges from 1–234
4. votes are numeric
5. party names are standardized
6. turnout exists

check 2026
Verify:
1. 234 constituencies
2. candidate rows are present
3. votes are numeric
4. party names are standardized
5. ac_number is correct
*/

-----------------------------------------------------------------------------------
-- 2021 :------------
SELECT 
  *
FROM dbo.tn_2021_results
-----------------------------------------------------------------------------------
-- 1. 234 constituencies
SELECT 
  COUNT (DISTINCT ac_number)
FROM dbo.tn_2021_results  -- 234
------------------------------------------
-- 2. No duplicate candidate rows
SELECT
    ac_number,
    candidate,
    party,
    votes,
    COUNT(*) AS row_count
FROM dbo.tn_2026_results
GROUP BY
    ac_number,
    candidate,
    party,
    votes
HAVING COUNT(*) > 1
ORDER BY ac_number, candidate; -- 13 candidates
------------------------------------------
-- 3. ac_number ranges from 1–234
SELECT 
  ac_number
FROM dbo.tn_2021_results
where ac_number IS NULL or ac_number < 1 OR ac_number > 234 -- blank
------------------------------------------
-- 4. votes are numeric
SELECT 
  ISNUMERIC(votes)
FROM dbo.tn_2021_results
where ISNUMERIC(votes) = 0  -- blank
-----------------------
SELECT COUNT(*) AS invalid_votes
FROM dbo.tn_2021_results
WHERE votes IS NULL;
------------------------------------------
-- 5. party names are standardized
SELECT 
  DISTINCT party
FROM dbo.tn_2021_results
ORDER BY party;
------------------------
SELECT
    party,
    LEN(party) AS party_length,
    LEN(LTRIM(RTRIM(party))) AS trimmed_length
FROM dbo.tn_2026_results
WHERE party <> LTRIM(RTRIM(party));
------------------------------------------
-- 6. turnout exists
SELECT 
  count(*)
FROM dbo.tn_2021_results
where turnout is null  -- 0
------------------------------------------
-- check the constituency-level fields
SELECT
    ac_number,
    COUNT(DISTINCT constituency) AS constituency_count,
    COUNT(DISTINCT reserved) AS reserved_count,
    COUNT(DISTINCT region) AS region_count,
    COUNT(DISTINCT turnout) AS turnout_count
FROM dbo.tn_2021_results
GROUP BY ac_number
HAVING
    COUNT(DISTINCT constituency) > 1
    OR COUNT(DISTINCT reserved) > 1
    OR COUNT(DISTINCT region) > 1
    OR COUNT(DISTINCT turnout) > 1;
-----------------------------------------------------------------------------------
-- 2026 :------------
-----------------------------------------------------------------------------------
-- 1. 234 constituencies
SELECT 
  COUNT (DISTINCT ac_number)
FROM dbo.tn_2026_results  -- 234
------------------------------------------
-- 2. candidate rows are present
SELECT
    ac_number,
    candidate,
    party,
    votes,
    COUNT(*) AS row_count
FROM dbo.tn_2026_results
GROUP BY
    ac_number,
    candidate,
    party,
    votes
HAVING COUNT(*) > 1
ORDER BY ac_number, candidate; -- 23 candidates
------------------------------------------
-- 3. votes are numeric
SELECT
  ISNUMERIC(votes)
FROM dbo.tn_2026_results
where ISNUMERIC(votes) = 0  -- blank
-----------------------
SELECT COUNT(*) AS invalid_votes
FROM dbo.tn_2026_results
WHERE votes IS NULL;
------------------------------------------
-- 4. party names are standardized
SELECT
  DISTINCT party
FROM dbo.tn_2026_results
ORDER BY party;
--------------------------
SELECT
    party,
    COUNT(*) AS row_count
FROM dbo.tn_2021_results
GROUP BY party
ORDER BY row_count DESC;
------------------------------------------
-- 5. ac_number is correct
SELECT
   ac_number
FROM dbo.tn_2026_results
where ac_number IS NULL or ac_number < 1 OR ac_number > 234  -- blank

-------------------------------------------
-- check the constituency-level fields
SELECT
    ac_number,
    COUNT(DISTINCT constituency) AS constituency_count,
    COUNT(DISTINCT reserved) AS reserved_count,
    COUNT(DISTINCT region) AS region_count,
    COUNT(DISTINCT turnout) AS turnout_count
FROM dbo.tn_2021_results
GROUP BY ac_number
HAVING
    COUNT(DISTINCT constituency) > 1
    OR COUNT(DISTINCT reserved) > 1
    OR COUNT(DISTINCT region) > 1
    OR COUNT(DISTINCT turnout) > 1;
-------------------------------------------------------------------------------------------------------------------------------
-- Winner candidate 2021 --
--------------------------
SELECT 
    ac_number,
    candidate,
    constituency,
    party,
    votes,
    region 
FROM
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2021_results
) as d
WHERE vote_rank = 1
order by ac_number -- 234 rows
--------------------------------------------------------
-- Most winner by region for each party --
--------------------------------------------------------
with winner_grain AS
(
SELECT 
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by constituency order by votes desc) as vote_rank
FROM dbo.tn_2021_results
)
SELECT 
  party,
  region,
  count(party) as no_winner_party
FROM winner_grain
where vote_rank = 1
group by party, region
order by region, no_winner_party desc

--------------------------------------------------------
-- Winner candidate 2026 --
--------------------------
SELECT 
    ac_number,
    candidate,
    constituency,
    party,
    votes,
    region
FROM
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2026_results
) as d
WHERE vote_rank = 1
order by ac_number -- 234 rows
--------------------------------------------------------
-- Most winner by region for each party --
--------------------------------------------------------
SELECT 
  region,
  count(candidate) as total_participent
FROM dbo.tn_2026_results
group by  region;
--------------------------------------------
with winner_grain AS
(
SELECT 
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by constituency order by votes desc) as vote_rank
FROM dbo.tn_2026_results
)
SELECT 
  party,
  region,
  count(party) as no_winner_party
FROM winner_grain
where vote_rank = 1
group by party, region
order by region, no_winner_party desc
-------------------------------------------------------------------------------------------------------------------------------
-- Calculate the runner-up and winning margin :-
-- Now we need the top 2 candidates in every constituency :-
-------------------------------------------------------------------------------------------------------------------------------
-- TOP - 2 : 2021 --
with top_two as
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2021_results
) 
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region
FROM top_two
WHERE vote_rank between 1 and 2
order by ac_number -- 468 rows
---------------------------------------------------------------------------
-- TOP 2 : 2026 --
with top_two as
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2026_results
) 
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region
FROM top_two
WHERE vote_rank between 1 and 2
order by ac_number -- 468 rows
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-- Win margin : 2021 --
with top_two as
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2021_results
) 
SELECT 
  ac_number,
  
  max(CASE
     WHEN vote_rank = 1 THEN constituency
  END) AS constituency,

  max(CASE
      WHEN vote_rank = 1 THEN region
  END) AS region,
  --------------------------------
  max(CASE
    WHEN vote_rank = 1 then candidate
  END) as winner_candidate,

  max(CASE
    WHEN vote_rank = 1 then party
  END) as winner_party,

  max(CASE
    WHEN vote_rank = 1 then votes
  END) as winner_votes,
  --------------------------------
  max(CASE
    WHEN vote_rank = 2 then candidate
  END) as runnerUp_candidate,

  max(CASE
    WHEN vote_rank = 2 then party
  END) as runnerUp_party,

  max(CASE
    WHEN vote_rank = 2 then votes
  END) as runnerUp_votes,
  --------------------------------
  max(CASE
    WHEN vote_rank = 1 then votes
  END) 
  -
  max(CASE
    WHEN vote_rank = 2 then votes
  END) as winning_margin
FROM top_two
WHERE vote_rank between 1 and 2
group by ac_number
order by ac_number -- 234 rows

-------------------------------------------------------------------------------------------------------------------------------
-- Win margin : 2026 --
with top_two as
(
SELECT 
  ac_number,
  candidate,
  constituency,
  party,
  votes,
  region,
  ROW_NUMBER() over(partition by ac_number order by votes desc) as vote_rank
FROM dbo.tn_2026_results
) 
SELECT 
  ac_number,

  max(CASE
     WHEN vote_rank = 1 THEN constituency
  END) AS constituency,

  max(CASE
      WHEN vote_rank = 1 THEN region
  END) AS region,
  --------------------------------
  max(CASE
    WHEN vote_rank = 1 then candidate
  END) as winner_candidate,

  max(CASE
    WHEN vote_rank = 1 then party
  END) as winner_party,

  max(CASE
    WHEN vote_rank = 1 then votes
  END) as winner_votes,
  --------------------------------
  max(CASE
    WHEN vote_rank = 2 then candidate
  END) as runnerUp_candidate,

  max(CASE
    WHEN vote_rank = 2 then party
  END) as runnerUp_party,

  max(CASE
    WHEN vote_rank = 2 then votes
  END) as runnerUp_votes,
  --------------------------------
  max(CASE
    WHEN vote_rank = 1 then votes
  END) 
  -
  max(CASE
    WHEN vote_rank = 2 then votes
  END) as winning_margin
FROM top_two
WHERE vote_rank between 1 and 2
group by ac_number
order by ac_number -- 234 rows
-----------------------------------------------------------------------------------------------------------------------
-- Join 2021 and 2026, create one table where each row = one constituency.
-----------------------------------------------------------------------------------------------------------------------
go
CREATE OR ALTER VIEW tn_21_26 
AS
WITH results_2021 AS
(
    SELECT 
        ac_number,

        MAX(CASE WHEN vote_rank = 1 THEN constituency END) AS constituency,
        MAX(CASE WHEN vote_rank = 1 THEN region END) AS region,

        MAX(CASE WHEN vote_rank = 1 THEN candidate END) AS winner_2021,
        MAX(CASE WHEN vote_rank = 1 THEN party END) AS winner_party_2021,
        MAX(CASE WHEN vote_rank = 1 THEN votes END) AS winner_votes_2021,

        MAX(CASE WHEN vote_rank = 2 THEN candidate END) AS runnerup_2021,
        MAX(CASE WHEN vote_rank = 2 THEN party END) AS runnerup_party_2021,
        MAX(CASE WHEN vote_rank = 2 THEN votes END) AS runnerup_votes_2021,

        MAX(CASE WHEN vote_rank = 1 THEN votes END)
        -
        MAX(CASE WHEN vote_rank = 2 THEN votes END) AS margin_2021,

        ROUND(MAX(turnout),2) AS turnout_2021

    FROM
    (
        SELECT *,
            ROW_NUMBER() OVER
            (
                PARTITION BY ac_number
                ORDER BY votes DESC
            ) AS vote_rank
        FROM dbo.tn_2021_results
    ) d
    WHERE vote_rank <= 2
    GROUP BY ac_number
),

results_2026 AS
(
    SELECT 
        ac_number,

        MAX(CASE WHEN vote_rank = 1 THEN constituency END) AS constituency,
        MAX(CASE WHEN vote_rank = 1 THEN region END) AS region,

        MAX(CASE WHEN vote_rank = 1 THEN candidate END) AS winner_2026,
        MAX(CASE WHEN vote_rank = 1 THEN party END) AS winner_party_2026,
        MAX(CASE WHEN vote_rank = 1 THEN votes END) AS winner_votes_2026,

        MAX(CASE WHEN vote_rank = 2 THEN candidate END) AS runnerup_2026,
        MAX(CASE WHEN vote_rank = 2 THEN party END) AS runnerup_party_2026,
        MAX(CASE WHEN vote_rank = 2 THEN votes END) AS runnerup_votes_2026,

        MAX(CASE WHEN vote_rank = 1 THEN votes END)
        -
        MAX(CASE WHEN vote_rank = 2 THEN votes END) AS margin_2026
    FROM
    (
        SELECT *,
            ROW_NUMBER() OVER
            (
                PARTITION BY ac_number
                ORDER BY votes DESC
            ) AS vote_rank
        FROM dbo.tn_2026_results
    ) d
    WHERE vote_rank <= 2
    GROUP BY ac_number
)

SELECT
    a.ac_number,
    a.constituency,
    a.region,

    -- 2021
    a.winner_2021,
    a.winner_party_2021,
    a.winner_votes_2021,
    a.runnerup_2021,
    a.runnerup_party_2021,
    a.runnerup_votes_2021,
    a.margin_2021,

    -- 2026
    b.winner_2026,
    b.winner_party_2026,
    b.winner_votes_2026,
    b.runnerup_2026,
    b.runnerup_party_2026,
    b.runnerup_votes_2026,
    b.margin_2026,

    -- analytical column
    b.margin_2026 - a.margin_2021 AS margin_change,

    -- the FLIP column
    CASE
    WHEN a.winner_party_2021 = b.winner_party_2026
        THEN 'No Change'
    ELSE 'Flipped'
    END AS seat_status,

    -- Party transition
    CONCAT(a.winner_party_2021, 
           ' -> ',
           b.winner_party_2026 )
    AS party_transition,

    -- Add Reservation
    r.reserved,

    -- Add Turnout column
    a.turnout_2021,
    t.turnout_2026,
    ROUND((t.turnout_2026 - a.turnout_2021),2) AS turnout_change

FROM results_2021 AS a
INNER JOIN results_2026 AS b
    ON a.ac_number = b.ac_number
-- ORDER BY ac_number;
LEFT JOIN
(
    SELECT DISTINCT
        ac_number,
        reserved
    FROM dbo.tn_2021_results
) AS r
    ON a.ac_number = r.ac_number
LEFT JOIN dbo.tn_2026_turnout_clean AS t
    ON a.ac_number = t.ac_number
go

-----------------------------------------------------------------------------------------------------------------------
-- The party-transition analysis
------------------------------------------
SELECT
    winner_party_2021,
    winner_party_2026,
    COUNT(*) AS constituency_count
FROM tn_21_26
WHERE winner_party_2021 <> winner_party_2026
GROUP BY
    winner_party_2021,
    winner_party_2026
ORDER BY constituency_count DESC;
---------------------------------------------------
-- Validate the transition total
---------------------------------------------------
SELECT
    SUM(constituency_count) AS total_flipped
FROM
(
    SELECT
        winner_party_2021,
        winner_party_2026,
        COUNT(*) AS constituency_count
    FROM tn_21_26
    WHERE winner_party_2021 <> winner_party_2026
    GROUP BY
        winner_party_2021,
        winner_party_2026
) AS transitions;
---------------------------------------------------
-- Analyze flips by region
---------------------------------------------------
SELECT
    region,
    COUNT(*) AS flipped_constituencies
FROM tn_21_26
WHERE winner_party_2021 <> winner_party_2026
GROUP BY region
ORDER BY flipped_constituencies DESC;
--------------------------
SELECT
    region,
    winner_party_2021,
    winner_party_2026,
    COUNT(*) AS constituency_count
FROM tn_21_26
WHERE winner_party_2021 <> winner_party_2026
GROUP BY
    region,
    winner_party_2021,
    winner_party_2026
ORDER BY
    region,
    constituency_count DESC;
---------------------------------------------------
-- Any missing party values:
---------------------------------------------------
SELECT
    COUNT(*) AS missing_party
FROM tn_21_26
WHERE winner_party_2021 IS NULL
   OR winner_party_2026 IS NULL;
---------------------------------------------------
-- Regional seat distribution:
---------------------------------------------------
SELECT
    region,
    winner_party_2021 AS party,
    '2021' AS election_year,
    COUNT(*) AS seats
FROM tn_21_26
GROUP BY
    region,
    winner_party_2021

UNION ALL

SELECT
    region,
    winner_party_2026 AS party,
    '2026' AS election_year,
    COUNT(*) AS seats
FROM tn_21_26
GROUP BY
    region,
    winner_party_2026

ORDER BY
    region,
    party,
    election_year;
---------------------------------------------------
-- Calculate the actual seat change
---------------------------------------------------
-- 2021
SELECT
    SUM(seats_2021) AS total_2021_seats
FROM
(
    SELECT
        region,
        winner_party_2021,
        COUNT(*) AS seats_2021
    FROM tn_21_26
    GROUP BY region, winner_party_2021
) d;
-------------------------
-- 2026
SELECT
    SUM(seats_2026) AS total_2026_seats
FROM
(
    SELECT
        region,
        winner_party_2026,
        COUNT(*) AS seats_2026
    FROM tn_21_26
    GROUP BY region, winner_party_2026
) d;
-----------------------------------------------------------------------------------------------------------------------
-- 2021 vs 2026 regional seat table
-------------------------------------------------------------------------------------------------
WITH seats_2021 AS
(
    SELECT
        region,
        winner_party_2021 AS party,
        COUNT(*) AS seats_2021
    FROM tn_21_26
    GROUP BY
        region,
        winner_party_2021
),

seats_2026 AS
(
    SELECT
        region,
        winner_party_2026 AS party,
        COUNT(*) AS seats_2026
    FROM tn_21_26
    GROUP BY
        region,
        winner_party_2026
)

SELECT
    COALESCE(a.region, b.region) AS region,
    COALESCE(a.party, b.party) AS party,
    COALESCE(a.seats_2021, 0) AS seats_2021,
    COALESCE(b.seats_2026, 0) AS seats_2026,
    COALESCE(b.seats_2026, 0)
      - COALESCE(a.seats_2021, 0) AS seat_change
FROM seats_2021 a
FULL OUTER JOIN seats_2026 b
    ON a.region = b.region
   AND a.party = b.party
ORDER BY
    region,
    seat_change DESC;
----------------------------------------------
-- Validate the result
----------------------------------------------
WITH seats_2021 AS
(
    SELECT
        region,
        winner_party_2021 AS party,
        COUNT(*) AS seats_2021
    FROM tn_21_26
    GROUP BY region, winner_party_2021
),
seats_2026 AS
(
    SELECT
        region,
        winner_party_2026 AS party,
        COUNT(*) AS seats_2026
    FROM tn_21_26
    GROUP BY region, winner_party_2026
),
seat_change AS
(
    SELECT
        COALESCE(a.region, b.region) AS region,
        COALESCE(a.party, b.party) AS party,
        COALESCE(a.seats_2021, 0) AS seats_2021,
        COALESCE(b.seats_2026, 0) AS seats_2026
    FROM seats_2021 a
    FULL OUTER JOIN seats_2026 b
        ON a.region = b.region
       AND a.party = b.party
)
SELECT
    SUM(seats_2021) AS total_2021,
    SUM(seats_2026) AS total_2026
FROM seat_change;

-----------------------------------------------------------------------------------------------------------------------
-- calculate state-level party seat change
------------------------------------------------------------------------------------------------
-- 2021
SELECT
    winner_party_2021 AS party,
    COUNT(*) AS seats_2021
FROM tn_21_26
GROUP BY winner_party_2021
ORDER BY seats_2021 DESC;
-----------------------------------
-- 2026
SELECT
    winner_party_2026 AS party,
    COUNT(*) AS seats_2026
FROM tn_21_26
GROUP BY winner_party_2026
ORDER BY seats_2026 DESC;
-----------------------------------------------------------------------------------------------------------------------
-- Margin analysis
-------------------------------------------------------------------------------------------------
-- validate zero/tied margins
-------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS zero_margin_constituencies
FROM tn_21_26
WHERE margin_2021 = 0
   OR margin_2026 = 0;
-------------------------------------------------------------------------------------------------
-- Calculate average winning margin
-------------------------------------------------------------------------------------------------
SELECT
    AVG(CAST(margin_2021 AS DECIMAL(18,2))) AS avg_margin_2021,
    AVG(CAST(margin_2026 AS DECIMAL(18,2))) AS avg_margin_2026
FROM tn_21_26;
-------------------------------------------------------------------------------------------------
-- Calculate average winning margin difference:
-------------------------------------------------------------------------------------------------
SELECT
    CAST(ROUND(AVG(margin_2021), 0) AS INT) AS avg_margin_2021,

    CAST(ROUND(AVG(margin_2026), 0) AS INT) AS avg_margin_2026,

    CAST(
        ROUND(
            AVG(margin_2026) - AVG(margin_2021),
            0
        )
        AS INT
    ) AS avg_margin_change
FROM tn_21_26;

-------------------------------------------------------------------------------------------------
-- Calculate margin change for every constituency
-------------------------------------------------------------------------------------------------
SELECT
    ac_number,
    constituency,
    region,
    margin_2021,
    margin_2026,
    margin_2026 - margin_2021 AS margin_change
FROM tn_21_26
ORDER BY margin_change;
-------------------------------------------------------------------------------------------------
-- Calculate margin change for every constituency
-------------------------------------------------------------------------------------------------
SELECT
    ac_number,
    constituency,
    region,
    margin_2021,
    margin_2026,
    margin_2026 - margin_2021 AS margin_change
FROM tn_21_26
ORDER BY margin_change;
-----------------------------------------------------------------------------------------------------------------------
-- calculate winner vote share
-------------------------------------------------------------------------------------------------
-- 2021
WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2021_results
    GROUP BY ac_number
)
SELECT
    c.ac_number,
    c.constituency,
    c.winner_party_2021,
    c.winner_votes_2021,
    v.total_votes,
    CAST(  
       CAST(c.winner_votes_2021 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) 
    AS winner_vote_share
FROM tn_21_26 as c
JOIN constituency_votes as v
    ON c.ac_number = v.ac_number;
-----------------------------------------
-- 2026

WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2026_results
    GROUP BY ac_number
)
SELECT
    c.ac_number,
    c.constituency,
    c.winner_party_2026,
    c.winner_votes_2026,
    v.total_votes,
    CAST(  
       CAST(c.winner_votes_2026 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) 
    AS winner_vote_share
FROM tn_21_26 c
JOIN constituency_votes v
    ON c.ac_number = v.ac_number;
-------------------------------------------------------------------------------------------------
-- Count winners above 50%
-------------------------------------------------------------------------------------------------
-- 2021
WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2021_results
    GROUP BY ac_number
)
SELECT
     COUNT(*) as winners_above50
FROM tn_21_26 c
JOIN constituency_votes v
    ON c.ac_number = v.ac_number
WHERE     CAST(  
       CAST(c.winner_votes_2021 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) > 50;

-------------------------------------------------------------------------------------------------
-- 2026
WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2026_results
    GROUP BY ac_number
)
SELECT
    COUNT(*) as winners_above50
FROM tn_21_26 c
JOIN constituency_votes v
    ON c.ac_number = v.ac_number
WHERE     CAST(  
       CAST(c.winner_votes_2026 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) > 50;
-------------------------------------------------------------------------------------------------
-- Count winners below 35%
-------------------------------------------------------------------------------------------------
-- 2021
WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2021_results
    GROUP BY ac_number
)
SELECT
     COUNT(*) as winners_bellow35
FROM tn_21_26 c
JOIN constituency_votes v
    ON c.ac_number = v.ac_number
WHERE     CAST(  
       CAST(c.winner_votes_2021 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) < 35;

-------------------------------------------------------------------------------------------------
-- 2026
WITH constituency_votes AS
(
    SELECT
        ac_number,
        SUM(votes) AS total_votes
    FROM dbo.tn_2026_results
    GROUP BY ac_number
)
SELECT
    COUNT(*) as winners_bellow35
FROM tn_21_26 c
JOIN constituency_votes v
    ON c.ac_number = v.ac_number
WHERE     CAST(  
       CAST(c.winner_votes_2026 AS DECIMAL(18,2)) * 100
         / 
       NULLIF(v.total_votes, 0) AS DECIMAL(5,2)) < 35;

-----------------------------------------------------------------------------------------------------------------------
-- Validate the reservation counts
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(DISTINCT ac_number) AS constituency_count
FROM dbo.tn_2021_results
GROUP BY reserved
ORDER BY reserved;
----------------------------------
SELECT
    reserved,
    COUNT(DISTINCT ac_number) AS constituency_count
FROM dbo.tn_2026_results
GROUP BY reserved
ORDER BY reserved;

-------------------------------------------------------------------------------------------------
-- Compare party seats by reservation category
-------------------------------------------------------------------------------------------------
-- A reservation mapping
SELECT DISTINCT
    ac_number,
    reserved
FROM dbo.tn_2021_results
ORDER BY ac_number;
-------------------------------------------------------------------------------------------------
-- Add reservation to your tn_21_26
-------------------------------------------------------------------------------------------------
-- check line number 630 resrvation column is added with left join
------------------------------------------------
-- check view added this reserved column
SELECT * FROM dbo.tn_21_26
-------------------------------------------------------------------------------------------------
-- Seat distribution by reservation category
-------------------------------------------------------------------------------------------------
-- 2021

SELECT
    reserved,
    winner_party_2021 AS party,
    COUNT(*) AS seats_2021
FROM tn_21_26
GROUP BY
    reserved,
    winner_party_2021
ORDER BY
    reserved,
    seats_2021 DESC;
-----------------------------------
-- 2026

SELECT
    reserved,
    winner_party_2026 AS party,
    COUNT(*) AS seats_2026
FROM tn_21_26
GROUP BY
    reserved,
    winner_party_2026
ORDER BY
    reserved,
    seats_2026 DESC;
-------------------------------------------------------------------------------------------------
-- Compare 2021 vs 2026 directly for reservation
-------------------------------------------------------------------------------------------------
WITH seats_2021 AS
(
    SELECT
        reserved,
        winner_party_2021 AS party,
        COUNT(*) AS seats_2021
    FROM tn_21_26
    GROUP BY
        reserved,
        winner_party_2021
),
seats_2026 AS
(
    SELECT
        reserved,
        winner_party_2026 AS party,
        COUNT(*) AS seats_2026
    FROM tn_21_26
    GROUP BY
        reserved,
        winner_party_2026
)
SELECT
    COALESCE(a.reserved, b.reserved) AS reserved,
    COALESCE(a.party, b.party) AS party,
    COALESCE(a.seats_2021, 0) AS seats_2021,
    COALESCE(b.seats_2026, 0) AS seats_2026,
    COALESCE(b.seats_2026, 0)
      - COALESCE(a.seats_2021, 0) AS seat_change
FROM seats_2021 a
FULL OUTER JOIN seats_2026 b
    ON a.reserved = b.reserved
   AND a.party = b.party
ORDER BY
    reserved,
    seat_change DESC;
-------------------------------------------------------------------------------------------------
-- Also compare the number of flips
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(*) AS total_constituencies,
    SUM(
        CASE
            WHEN winner_party_2021 <> winner_party_2026
            THEN 1
            ELSE 0
        END
    ) AS flipped,
    SUM(
        CASE
            WHEN winner_party_2021 = winner_party_2026
            THEN 1
            ELSE 0
        END
    ) AS no_change
FROM tn_21_26
GROUP BY reserved
ORDER BY reserved;
-------------------------------------------------------------------------------------------------
-- Reservation validation → confirm 188 / 44 / 2 for both years.
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(*) AS total_constituencies,
    SUM(CASE WHEN winner_party_2021 <> winner_party_2026 THEN 1 ELSE 0 END) AS flipped,
    SUM(CASE WHEN winner_party_2021 = winner_party_2026 THEN 1 ELSE 0 END) AS no_change
FROM tn_21_26
GROUP BY reserved
ORDER BY reserved;
-----------------------------------------------------------------------------------------------------------------------
-- Calculate flip rate.
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(*) AS total_constituencies,

    SUM(
        CASE
            WHEN winner_party_2021 <> winner_party_2026
            THEN 1
            ELSE 0
        END
    ) AS flipped,

    SUM(
        CASE
            WHEN winner_party_2021 = winner_party_2026
            THEN 1
            ELSE 0
        END
    ) AS no_change,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN winner_party_2021 <> winner_party_2026
                THEN 1
                ELSE 0
            END
        )
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS flip_rate

FROM tn_21_26
GROUP BY reserved
ORDER BY reserved;

-------------------------------------------------------------------------------------------------
-- Check whether the reservation categories themselves changed
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(*) AS constituencies
FROM tn_21_26
GROUP BY reserved
ORDER BY reserved;

-------------------------------------------------------------------------------------------------
-- Party distribution within reserved seats
-------------------------------------------------------------------------------------------------
-- 2021
SELECT
    reserved,
    winner_party_2021 AS party,
    COUNT(*) AS seats_2021
FROM tn_21_26
GROUP BY
    reserved,
    winner_party_2021
ORDER BY
    reserved,
    seats_2021 DESC;
------------------------------------
-- 2026
SELECT
    reserved,
    winner_party_2026 AS party,
    COUNT(*) AS seats_2026
FROM tn_21_26
GROUP BY
    reserved,
    winner_party_2026
ORDER BY
    reserved,
    seats_2026 DESC;
-----------------------------------------------------------------------------------------------------------------------
-- Turnout Analysis
-------------------------------------------------------------------------------------------------
-- Add 2026 turnout
-- 2026 table dont have ac_number
-- First check constituency uniqueness
SELECT
    constituency,
    COUNT(*) AS row_count
FROM dbo.tn_2026
GROUP BY constituency
HAVING COUNT(*) > 1;
-------------------------------------
-- Inspect both Tiruppattur rows
SELECT *
FROM dbo.tn_2026
WHERE constituency = 'Tiruppattur';
-------------------------------------
--find the two AC numbers
SELECT *
FROM dbo.constituency_master
WHERE constituency = 'Tiruppattur';
-------------------------------------
SELECT
    ac_number,
    constituency,
    candidate,
    party,
    votes
FROM dbo.tn_2026_results
WHERE candidate IN
(
    'Dr. Thirupathi. N',
    'Seenivasa Sethupathy. R'
)
ORDER BY ac_number, votes DESC;
-------------------------------------
-- Let's check whether other constituency names are duplicated in the 2026 turnout table.
SELECT
    constituency,
    COUNT(*) AS row_count
FROM dbo.tn_2026
GROUP BY constituency
HAVING COUNT(*) > 1
ORDER BY constituency;
-------------------------------------------------------------------------------------------------
-- Map turnout to AC using winner information
-------------------------------------------------------------------------------------------------
SELECT
    t.constituency,
    t.Winner,
    t.Winner_party,
    t.Winner_votes,
    r.ac_number,
    r.candidate,
    r.party,
    r.votes
FROM dbo.tn_2026 AS t
JOIN dbo.tn_2026_results AS r
    ON  t.Winner_votes = r.votes
        AND LOWER(t.Winner) = LOWER(REPLACE(r.candidate, '  ', ' '))
ORDER BY r.ac_number;
-------------------------------------------------------------------------------------------------
-- Create the clean turnout mapping
-------------------------------------------------------------------------------------------------
SELECT
    r.ac_number,
    t.constituency,
    CAST(ROUND(t.Turnout, 2) AS DECIMAL(5,2)) AS turnout_2026
INTO dbo.tn_2026_turnout_clean
FROM dbo.tn_2026 AS t
JOIN dbo.tn_2026_results AS r
    ON t.Winner_votes = r.votes
    AND LOWER(t.Winner) = LOWER(REPLACE(r.candidate, '  ', ' '));
------------------------------------------------------
SELECT * FROM tn_2026_turnout_clean;
------------------------------------------------------
-- Validate it
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ac_number) AS distinct_ac,
    COUNT(*) - COUNT(turnout_2026) AS missing_turnout
FROM dbo.tn_2026_turnout_clean;
------------------------------------------------------
-- Check duplicate ACs:
SELECT
    ac_number,
    COUNT(*) AS row_count
FROM dbo.tn_2026_turnout_clean
GROUP BY ac_number
HAVING COUNT(*) > 1;
-------------------------------------------------------------------------------------------------
-- Add 2026 turnout to your comparison
-- Added : Goto line : 634, which added by LEFT JOIN of tn_2026_turnout_clean
-------------------------------------------------------------------------------------------------
-- Validate turnout
-------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_constituencies,
    COUNT(turnout_2021) AS turnout_2021_available,
    COUNT(turnout_2026) AS turnout_2026_available
FROM tn_21_26;
-------------------------------
SELECT *
FROM dbo.tn_21_26
ORDER BY ac_number;
-------------------------------
-- Check for impossible turnout values:
SELECT
    COUNT(*) AS invalid_turnout
FROM dbo.tn_21_26
WHERE turnout_2021 < 0
   OR turnout_2021 > 100
   OR turnout_2026 < 0
   OR turnout_2026 > 100;
-------------------------------------------------------------------------------------------------
-- Calculate average turnout
-------------------------------------------------------------------------------------------------
SELECT
    CAST(ROUND(AVG(turnout_2021), 2) AS DECIMAL(5,2)) AS avg_turnout_2021,

    CAST(ROUND(AVG(turnout_2026), 2) AS DECIMAL(5,2)) AS avg_turnout_2026,

    CAST(
        ROUND(
            AVG(turnout_2026) - AVG(turnout_2021),
            2
        )
        AS DECIMAL(5,2)
    ) AS avg_turnout_change
FROM dbo.tn_21_26;

-------------------------------------------------------------------------------------------------
-- Calculate turnout change for every constituency
-------------------------------------------------------------------------------------------------
SELECT
    ac_number,
    constituency,
    region,
    reserved,
    turnout_2021,
    turnout_2026,
    turnout_change
FROM dbo.tn_21_26
ORDER BY turnout_change DESC;
-------------------------------------------------------------------------------------------------
-- Top 20 turnout increases
-------------------------------------------------------------------------------------------------
SELECT TOP 20
    ac_number,
    constituency,
    region,
    reserved,
    turnout_2021,
    turnout_2026,
    turnout_change
FROM dbo.tn_21_26
ORDER BY turnout_change DESC;
-------------------------------------------------------------------------------------------------
-- Check whether the top 20 have a regional pattern
-------------------------------------------------------------------------------------------------
SELECT
    region,
    COUNT(*) AS top20_constituencies
FROM
(
    SELECT TOP 20
        region
    FROM dbo.tn_21_26
    ORDER BY turnout_change DESC
) x
GROUP BY region
ORDER BY top20_constituencies DESC;
-------------------------------------------------------------------------------------------------
-- Check reservation pattern
-------------------------------------------------------------------------------------------------
SELECT
    reserved,
    COUNT(*) AS top20_constituencies
FROM
(
    SELECT TOP 20
        reserved
    FROM dbo.tn_21_26
    ORDER BY turnout_change DESC
) x
GROUP BY reserved
ORDER BY top20_constituencies DESC;
-------------------------------------------------------------------------------------------------
-- Calculate average turnout change by region
-------------------------------------------------------------------------------------------------
SELECT
    region,
    COUNT(*) AS constituencies,

    CAST(
        ROUND(AVG(turnout_2021), 2)
        AS DECIMAL(5,2)
    ) AS avg_turnout_2021,

    CAST(
        ROUND(AVG(turnout_2026), 2)
        AS DECIMAL(5,2)
    ) AS avg_turnout_2026,

    CAST(
        ROUND(AVG(turnout_change), 2)
        AS DECIMAL(5,2)
    ) AS avg_turnout_change

FROM dbo.tn_21_26
GROUP BY region
ORDER BY avg_turnout_change DESC;

-------------------------------------------------------------------------------------------------
-- Which 20 constituencies had the largest increase in turnout?
-------------------------------------------------------------------------------------------------
SELECT TOP 20
    ac_number,
    constituency,
    region,
    reserved,
    turnout_2021,
    turnout_2026,
    turnout_change
FROM dbo.tn_21_26
ORDER BY turnout_change DESC;

-------------------------------------------------------------------------------------------------
-- Calculate the percentage of each region's constituencies that appear in the top 20:
-------------------------------------------------------------------------------------------------
WITH top20 AS
(
    SELECT TOP 20
        ac_number,
        region
    FROM dbo.tn_21_26
    ORDER BY turnout_change DESC
),
region_totals AS
(
    SELECT
        region,
        COUNT(*) AS total_constituencies
    FROM dbo.tn_21_26
    GROUP BY region
)
SELECT
    r.region,
    r.total_constituencies,
    COUNT(t.ac_number) AS top20_count,

    CAST(
        ROUND(
            100.0 * COUNT(t.ac_number) / r.total_constituencies,
            2
        )
        AS DECIMAL(5,2)
    ) AS pct_of_region_in_top20

FROM region_totals r
LEFT JOIN top20 t
    ON r.region = t.region
GROUP BY
    r.region,
    r.total_constituencies
ORDER BY pct_of_region_in_top20 DESC;
-----------------------------------------------------------------------------------------------------------------------
-- The strongest data stories
-------------------------------------------------------------------------------------------------
-- Story 1 — Seat-level political change
-------------------------------------------------------------------------------------------------
SELECT
    party_transition,
    COUNT(*) AS constituency_count
FROM dbo.tn_21_26
GROUP BY party_transition
ORDER BY constituency_count DESC;
-------------------------------------------------------------------------------------------------
-- Story 2 — Winning margins became smaller : 
-- Quantify how many constituencies became more competitive.
-------------------------------------------------------------------------------------------------
SELECT
    CASE
        WHEN margin_change < 0 THEN 'Margin Decreased'
        WHEN margin_change > 0 THEN 'Margin Increased'
        ELSE 'No Change'
    END AS margin_direction,
    COUNT(*) AS constituency_count
FROM dbo.tn_21_26
GROUP BY
    CASE
        WHEN margin_change < 0 THEN 'Margin Decreased'
        WHEN margin_change > 0 THEN 'Margin Increased'
        ELSE 'No Change'
    END
ORDER BY constituency_count DESC;

-------------------------------------------------------------------------------------------------
-- Story 3 — Turnout increased substantially
-- Let's calculate the overall statewide turnout change before putting this into the final story.
-------------------------------------------------------------------------------------------------
SELECT
    CAST(ROUND(AVG(turnout_2021), 2) AS DECIMAL(5,2)) AS avg_turnout_2021,
    CAST(ROUND(AVG(turnout_2026), 2) AS DECIMAL(5,2)) AS avg_turnout_2026,
    CAST(
        ROUND(AVG(turnout_change), 2)
        AS DECIMAL(5,2)
    ) AS avg_turnout_change
FROM dbo.tn_21_26;
-----------------------------------------------------------------------------------------------------------------------
