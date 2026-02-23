-- =====================================================================
-- SAN FRANCISCO GIANTS - 100 DATABASE VIEWS
-- Team-specific analytics for the San Francisco Giants (teamID = 'SFN')
-- Franchise established: 1883
-- =====================================================================


-- ============================================================
-- View 1: giants_season_results
-- Purpose: Year-by-year W/L record with postseason flags and
--          run differential for every Giants season.
-- Key formulas: W%, run_diff = R - RA,
--   Pyth W% = R^2 / (R^2 + RA^2)
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_season_results AS
SELECT
    t.yearID,
    t.lgID,
    t.divID,
    t.teamRank,
    t.G,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.R,
    t.RA,
    (t.R - t.RA)                                               AS run_diff,
    ROUND(
        POWER(t.R, 2) / NULLIF(POWER(t.R, 2) + POWER(t.RA, 2), 0), 3
    )                                                          AS pyth_W_pct,
    ROUND(
        POWER(t.R, 2) / NULLIF(POWER(t.R, 2) + POWER(t.RA, 2), 0) * (t.W + t.L), 0
    )                                                          AS pyth_W,
    t.DivWin,
    t.WCWin,
    t.LgWin,
    t.WSWin,
    t.attendance,
    t.name AS team_name,
    t.park
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY t.yearID;

-- ============================================================
-- View 2: giants_decade_summary
-- Purpose: Giants performance aggregated by decade.
-- Key formulas: W%, total R, total RA, run differential,
--   division titles, playoff appearances per decade.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_decade_summary AS
SELECT
    CONCAT(FLOOR(t.yearID / 10) * 10, 's')                    AS decade,
    COUNT(*)                                                   AS seasons,
    SUM(t.W)                                                   AS total_W,
    SUM(t.L)                                                   AS total_L,
    ROUND(SUM(t.W) / NULLIF(SUM(t.W) + SUM(t.L), 0), 3)      AS W_pct,
    SUM(t.R)                                                   AS total_R,
    SUM(t.RA)                                                  AS total_RA,
    SUM(t.R) - SUM(t.RA)                                      AS run_diff,
    SUM(CASE WHEN t.DivWin = 'Y' THEN 1 ELSE 0 END)          AS div_titles,
    SUM(CASE WHEN t.WCWin = 'Y' THEN 1 ELSE 0 END)           AS wc_wins,
    SUM(CASE WHEN t.LgWin = 'Y' THEN 1 ELSE 0 END)           AS pennants,
    SUM(CASE WHEN t.WSWin = 'Y' THEN 1 ELSE 0 END)           AS ws_titles,
    ROUND(AVG(t.attendance), 0)                                AS avg_attendance
FROM teams t
WHERE t.teamID = 'SFN'
GROUP BY FLOOR(t.yearID / 10)
ORDER BY MIN(t.yearID);

-- ============================================================
-- View 3: giants_all_time_roster
-- Purpose: Every player who appeared for the Giants with
--          years active and primary role (batter/pitcher).
-- Key formulas: Uses appearances table to determine years and
--   classify player type.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_all_time_roster AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(a.yearID)                                              AS first_year,
    MAX(a.yearID)                                              AS last_year,
    COUNT(DISTINCT a.yearID)                                   AS seasons_with_sea,
    SUM(COALESCE(a.G_all, 0))                                 AS total_G,
    CASE
        WHEN SUM(COALESCE(a.G_p, 0)) >= 0.5 * SUM(COALESCE(a.G_all, 0))
            THEN 'Pitcher'
        ELSE 'Position Player'
    END                                                        AS player_type,
    p.bats,
    p.throws,
    p.birthCountry,
    p.birthState
FROM appearances a
JOIN people p ON p.playerID = a.playerID
WHERE a.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, p.bats, p.throws,
         p.birthCountry, p.birthState
ORDER BY first_year, p.nameLast;

-- ============================================================
-- View 4: giants_managers_record
-- Purpose: All Giants managers with win/loss record and
--          seasons managed.
-- Key formulas: W%, years managed.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_managers_record AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(m.yearID)                                              AS first_year,
    MAX(m.yearID)                                              AS last_year,
    COUNT(DISTINCT m.yearID)                                   AS seasons,
    SUM(m.G)                                                   AS G,
    SUM(m.W)                                                   AS W,
    SUM(m.L)                                                   AS L,
    ROUND(SUM(m.W) / NULLIF(SUM(m.W) + SUM(m.L), 0), 3)      AS W_pct,
    SUM(CASE WHEN m.teamRank = 1 THEN 1 ELSE 0 END)           AS first_place_finishes
FROM managers m
JOIN people p ON p.playerID = m.playerID
WHERE m.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY SUM(m.W) DESC;

-- ============================================================
-- View 5: giants_attendance_history
-- Purpose: Yearly attendance figures with league rank context.
-- Key formulas: Attendance per game = attendance / Ghome.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_attendance_history AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.attendance,
    t.Ghome,
    ROUND(t.attendance / NULLIF(t.Ghome, 0), 0)               AS avg_per_game,
    t.park,
    RANK() OVER (PARTITION BY t.yearID
                 ORDER BY t.attendance DESC)                   AS mlb_attendance_rank
FROM teams t
WHERE t.teamID = 'SFN'
  AND t.attendance IS NOT NULL
ORDER BY t.yearID;

-- ============================================================
-- View 6: giants_home_parks
-- Purpose: Home stadiums/parks used by the Giants over time.
-- Key formulas: Games and attendance by park.
-- Qualifiers: teamkey = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_home_parks AS
SELECT
    hg.yearkey                                                 AS yearID,
    pk.parkname,
    pk.city,
    pk.state,
    hg.games,
    hg.openings,
    hg.attendance,
    ROUND(hg.attendance / NULLIF(hg.openings, 0), 0)          AS avg_per_opening,
    hg.spanfirst,
    hg.spanlast
FROM homegames hg
JOIN parks pk ON pk.ID = hg.park_ID
WHERE hg.teamkey = 'SFN'
ORDER BY hg.yearkey, pk.parkname;

-- ============================================================
-- View 7: giants_run_differential
-- Purpose: Detailed run differential analysis with Pythagorean
--          record and luck factor per season.
-- Key formulas: Pyth W% = R^2/(R^2+RA^2),
--   luck = actual_W_pct - pyth_W_pct
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_run_differential AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.R,
    t.RA,
    (t.R - t.RA)                                               AS run_diff,
    ROUND(t.R / NULLIF(t.G, 0), 2)                            AS runs_per_game,
    ROUND(t.RA / NULLIF(t.G, 0), 2)                           AS ra_per_game,
    ROUND(
        POWER(t.R, 2) / NULLIF(POWER(t.R, 2) + POWER(t.RA, 2), 0), 3
    )                                                          AS pyth_W_pct,
    ROUND(
        POWER(t.R, 2) / NULLIF(POWER(t.R, 2) + POWER(t.RA, 2), 0)
        * (t.W + t.L), 0
    )                                                          AS pyth_W,
    ROUND(
        t.W / NULLIF(t.W + t.L, 0)
        - POWER(t.R, 2) / NULLIF(POWER(t.R, 2) + POWER(t.RA, 2), 0),
        3
    )                                                          AS luck_factor,
    t.DivWin,
    t.WCWin,
    t.LgWin
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY t.yearID;

-- ============================================================
-- View 8: giants_nl_west_standings
-- Purpose: Giants standing within the NL West each year,
--          compared to division rivals.
-- Key formulas: W%, team rank within division.
-- Qualifiers: NL West teams (divID = 'W', lgID = 'NL')
-- Notes: Shows full NL West standings for context.
-- ============================================================
CREATE OR REPLACE VIEW giants_nl_west_standings AS
SELECT
    t.yearID,
    t.teamID,
    t.name                                                     AS team_name,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.teamRank,
    t.R,
    t.RA,
    (t.R - t.RA)                                               AS run_diff,
    t.DivWin,
    t.WCWin,
    CASE WHEN t.teamID = 'SFN' THEN 'Y' ELSE 'N' END         AS is_giants
FROM teams t
WHERE t.lgID = 'NL'
  AND t.divID = 'W'
  AND t.yearID >= 1883
ORDER BY t.yearID DESC, t.teamRank ASC;

-- ============================================================
-- View 9: giants_postseason_years
-- Purpose: Summary of every Giants postseason appearance.
-- Key formulas: W%, postseason flags from teams table.
-- Qualifiers: teamID = 'SFN', made postseason
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_years AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    (t.R - t.RA)                                               AS run_diff,
    t.DivWin,
    t.WCWin,
    t.LgWin,
    t.WSWin,
    t.attendance,
    t.park
FROM teams t
WHERE t.teamID = 'SFN'
  AND (t.DivWin = 'Y' OR t.WCWin = 'Y')
ORDER BY t.yearID;

-- ============================================================
-- View 10: giants_franchise_milestones
-- Purpose: Cumulative franchise stats: all-time W/L, total R,
--          total HR, total attendance, etc.
-- Key formulas: SUMs across all franchise seasons.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_franchise_milestones AS
SELECT
    COUNT(DISTINCT t.yearID)                                   AS total_seasons,
    SUM(t.G)                                                   AS total_G,
    SUM(t.W)                                                   AS total_W,
    SUM(t.L)                                                   AS total_L,
    ROUND(SUM(t.W) / NULLIF(SUM(t.W) + SUM(t.L), 0), 3)      AS alltime_W_pct,
    SUM(t.R)                                                   AS total_R,
    SUM(t.RA)                                                  AS total_RA,
    SUM(t.R) - SUM(t.RA)                                      AS total_run_diff,
    SUM(t.HR)                                                  AS total_HR,
    SUM(t.H)                                                   AS total_H,
    SUM(t.SB)                                                  AS total_SB,
    SUM(t.SO)                                                  AS total_SO,
    SUM(t.attendance)                                          AS total_attendance,
    ROUND(SUM(t.attendance) / NULLIF(COUNT(DISTINCT t.yearID), 0), 0) AS avg_yearly_attendance,
    SUM(CASE WHEN t.DivWin = 'Y' THEN 1 ELSE 0 END)          AS div_titles,
    SUM(CASE WHEN t.WCWin = 'Y' THEN 1 ELSE 0 END)           AS wc_berths,
    SUM(CASE WHEN t.LgWin = 'Y' THEN 1 ELSE 0 END)           AS pennants,
    SUM(CASE WHEN t.WSWin = 'Y' THEN 1 ELSE 0 END)           AS ws_titles,
    MIN(t.yearID)                                              AS first_season,
    MAX(t.yearID)                                              AS latest_season
FROM teams t
WHERE t.teamID = 'SFN';

-- ============================================================
-- View 11: giants_career_batting_standard
-- Purpose: Career batting totals for all Giants hitters
--          (only counting Giants stints), with standard
--          rate stats AVG/OBP/SLG/OPS.
-- Key formulas: Standard rate stats.
-- Qualifiers: Giants stints only (teamID = 'SFN'), AB >= 100
-- ============================================================
CREATE OR REPLACE VIEW giants_career_batting_standard AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(b.yearID)                                              AS first_year,
    MAX(b.yearID)                                              AS last_year,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.G)                                                   AS G,
    SUM(b.AB)                                                  AS AB,
    SUM(b.R)                                                   AS R,
    SUM(b.H)                                                   AS H,
    SUM(b.`2B`)                                                AS `2B`,
    SUM(b.`3B`)                                                AS `3B`,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(COALESCE(b.SB, 0))                                     AS SB,
    SUM(COALESCE(b.CS, 0))                                     AS CS,
    SUM(COALESCE(b.BB, 0))                                     AS BB,
    SUM(COALESCE(b.SO, 0))                                     AS SO,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0))
              + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0))
              + SUM(COALESCE(b.SH, 0))                        AS PA,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0),
        3
    )                                                          AS OBP,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0),
        3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        +
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0),
        3
    )                                                          AS OPS
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(b.AB) >= 100
ORDER BY OPS DESC;

-- ============================================================
-- View 12: giants_career_batting_advanced
-- Purpose: Career advanced batting metrics for Giants hitters:
--          ISO, BABIP, wOBA, BB%, K%.
-- Key formulas: ISO = SLG - AVG, BABIP = (H-HR)/(AB-SO-HR+SF),
--   wOBA with linear weights, BB% = BB/PA, K% = SO/PA
-- Qualifiers: teamID = 'SFN', PA >= 500
-- ============================================================
CREATE OR REPLACE VIEW giants_career_batting_advanced AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0))
              + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0))
              + SUM(COALESCE(b.SH, 0))                        AS PA,
    ROUND(
        (SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS ISO,
    ROUND(
        (SUM(b.H) - SUM(b.HR))
        / NULLIF(SUM(b.AB) - SUM(COALESCE(b.SO, 0))
                 - SUM(b.HR) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS BABIP,
    ROUND(
        (  0.69 * (SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0)))
         + 0.72 * SUM(COALESCE(b.HBP, 0))
         + 0.87 * (SUM(b.H) - SUM(b.`2B`) - SUM(b.`3B`) - SUM(b.HR))
         + 1.22 * SUM(b.`2B`)
         + 1.56 * SUM(b.`3B`)
         + 1.95 * SUM(b.HR)
        )
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 - SUM(COALESCE(b.IBB, 0))
                 + SUM(COALESCE(b.SF, 0))
                 + SUM(COALESCE(b.HBP, 0)), 0), 3
    )                                                          AS wOBA,
    ROUND(
        SUM(COALESCE(b.BB, 0))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0))
                 + SUM(COALESCE(b.SF, 0))
                 + SUM(COALESCE(b.SH, 0)), 0), 3
    )                                                          AS BB_pct,
    ROUND(
        SUM(COALESCE(b.SO, 0))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0))
                 + SUM(COALESCE(b.SF, 0))
                 + SUM(COALESCE(b.SH, 0)), 0), 3
    )                                                          AS K_pct
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0))
       + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0))
       + SUM(COALESCE(b.SH, 0))) >= 500
ORDER BY wOBA DESC;

-- ============================================================
-- View 13: giants_career_batting_counting_leaders
-- Purpose: Career counting stat leaders for Giants:
--          HR, RBI, R, H, SB with DENSE_RANK.
-- Key formulas: Simple SUMs with ranking.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_career_batting_counting_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    SUM(b.H)                                                   AS career_H,
    DENSE_RANK() OVER (ORDER BY SUM(b.H) DESC)               AS H_rank,
    SUM(b.HR)                                                  AS career_HR,
    DENSE_RANK() OVER (ORDER BY SUM(b.HR) DESC)              AS HR_rank,
    SUM(COALESCE(b.RBI, 0))                                    AS career_RBI,
    DENSE_RANK() OVER (ORDER BY SUM(COALESCE(b.RBI, 0)) DESC) AS RBI_rank,
    SUM(b.R)                                                   AS career_R,
    DENSE_RANK() OVER (ORDER BY SUM(b.R) DESC)               AS R_rank,
    SUM(COALESCE(b.SB, 0))                                     AS career_SB,
    DENSE_RANK() OVER (ORDER BY SUM(COALESCE(b.SB, 0)) DESC) AS SB_rank,
    SUM(COALESCE(b.BB, 0))                                     AS career_BB,
    DENSE_RANK() OVER (ORDER BY SUM(COALESCE(b.BB, 0)) DESC) AS BB_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(b.AB) >= 100
ORDER BY career_H DESC;

-- ============================================================
-- View 14: giants_career_ops_leaders
-- Purpose: Top career OPS among Giants hitters with minimum
--          1000 PA for the Giants.
-- Key formulas: OBP + SLG = OPS.
-- Qualifiers: teamID = 'SFN', PA >= 1000
-- ============================================================
CREATE OR REPLACE VIEW giants_career_ops_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0))
              + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0))
              + SUM(COALESCE(b.SH, 0))                        AS PA,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0),
        3
    )                                                          AS OBP,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        +
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    SUM(b.HR)                                                  AS HR,
    RANK() OVER (ORDER BY
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        +
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0)
        DESC
    )                                                          AS ops_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0))
       + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0))
       + SUM(COALESCE(b.SH, 0))) >= 1000
ORDER BY OPS DESC;

-- ============================================================
-- View 15: giants_career_batting_war_approx
-- Purpose: Approximate career WAR for Giants position players
--          using wOBA-based batting runs, baserunning, and
--          positional adjustment.
-- Key formulas:
--   Batting Runs ~ (wOBA - lgwOBA) / 1.15 * PA
--   Baserunning ~ SB*0.2 - CS*0.4
--   Positional adj per 162 G scaled by PA/650
--   Replacement ~ 20 runs per 600 PA
--   WAR ~ (BatRuns + BR + PosAdj + Replacement) / 10
-- Qualifiers: teamID = 'SFN', career PA >= 500
-- ============================================================
CREATE OR REPLACE VIEW giants_career_batting_war_approx AS
WITH sea_batting AS (
    SELECT b.playerID, b.yearID, b.lgID,
        SUM(b.AB) AS AB, SUM(b.H) AS H,
        SUM(COALESCE(b.BB, 0)) AS BB, SUM(COALESCE(b.IBB, 0)) AS IBB,
        SUM(COALESCE(b.HBP, 0)) AS HBP, SUM(COALESCE(b.SF, 0)) AS SF,
        SUM(COALESCE(b.SH, 0)) AS SH,
        SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`, SUM(b.HR) AS HR,
        SUM(COALESCE(b.SB, 0)) AS SB, SUM(COALESCE(b.CS, 0)) AS CS,
        SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
            + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA
    FROM batting b
    WHERE b.teamID = 'SFN'
    GROUP BY b.playerID, b.yearID, b.lgID
),
league_woba AS (
    SELECT b.yearID, b.lgID,
        (0.69 * (SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0)))
         + 0.72 * SUM(COALESCE(b.HBP, 0))
         + 0.87 * (SUM(b.H) - SUM(b.`2B`) - SUM(b.`3B`) - SUM(b.HR))
         + 1.22 * SUM(b.`2B`) + 1.56 * SUM(b.`3B`) + 1.95 * SUM(b.HR))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.HBP, 0)), 0) AS lgwOBA
    FROM batting b
    WHERE b.lgID IN ('AL', 'NL')
    GROUP BY b.yearID, b.lgID
),
primary_pos AS (
    SELECT a.playerID,
        CASE
            WHEN SUM(COALESCE(a.G_c, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'C'
            WHEN SUM(COALESCE(a.G_ss, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'SS'
            WHEN SUM(COALESCE(a.G_2b, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '2B'
            WHEN SUM(COALESCE(a.G_cf, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'CF'
            WHEN SUM(COALESCE(a.G_3b, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '3B'
            WHEN SUM(COALESCE(a.G_rf, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'RF'
            WHEN SUM(COALESCE(a.G_lf, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'LF'
            WHEN SUM(COALESCE(a.G_1b, 0)) >= GREATEST(SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '1B'
            WHEN SUM(COALESCE(a.G_dh, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0))) THEN 'DH'
            ELSE 'OF'
        END AS primary_pos
    FROM appearances a
    WHERE a.teamID = 'SFN'
    GROUP BY a.playerID
),
player_seasons AS (
    SELECT
        sb.playerID, sb.yearID, sb.PA,
        (0.69 * (sb.BB - sb.IBB) + 0.72 * sb.HBP
         + 0.87 * (sb.H - sb.`2B` - sb.`3B` - sb.HR)
         + 1.22 * sb.`2B` + 1.56 * sb.`3B` + 1.95 * sb.HR)
        / NULLIF(sb.AB + sb.BB - sb.IBB + sb.SF + sb.HBP, 0) AS wOBA,
        lw.lgwOBA,
        sb.SB, sb.CS
    FROM sea_batting sb
    JOIN league_woba lw ON lw.yearID = sb.yearID AND lw.lgID = sb.lgID
    WHERE sb.PA > 0
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pp.primary_pos,
    SUM(ps.PA)                                                 AS career_PA,
    ROUND(SUM((COALESCE(ps.wOBA, 0) - COALESCE(ps.lgwOBA, 0)) / 1.15 * ps.PA), 1) AS batting_runs,
    ROUND(SUM(ps.SB * 0.2 - ps.CS * 0.4), 1)                 AS baserunning_runs,
    ROUND(
        SUM(ps.PA) / 650.0 *
        CASE pp.primary_pos
            WHEN 'C'  THEN 12.5
            WHEN 'SS' THEN  7.5
            WHEN '2B' THEN  2.5
            WHEN 'CF' THEN  2.5
            WHEN '3B' THEN -2.5
            WHEN 'RF' THEN -2.5
            WHEN 'LF' THEN -2.5
            WHEN '1B' THEN -12.5
            WHEN 'DH' THEN -17.5
            ELSE 0
        END, 1
    )                                                          AS positional_adj,
    ROUND(SUM(ps.PA) / 600.0 * 20.0, 1)                       AS replacement_runs,
    ROUND(
        (SUM((COALESCE(ps.wOBA, 0) - COALESCE(ps.lgwOBA, 0)) / 1.15 * ps.PA)
         + SUM(ps.SB * 0.2 - ps.CS * 0.4)
         + SUM(ps.PA) / 650.0 *
           CASE pp.primary_pos
               WHEN 'C' THEN 12.5 WHEN 'SS' THEN 7.5
               WHEN '2B' THEN 2.5 WHEN 'CF' THEN 2.5
               WHEN '3B' THEN -2.5 WHEN 'RF' THEN -2.5
               WHEN 'LF' THEN -2.5 WHEN '1B' THEN -12.5
               WHEN 'DH' THEN -17.5 ELSE 0
           END
         + SUM(ps.PA) / 600.0 * 20.0
        ) / 10.0, 1
    )                                                          AS approx_WAR,
    RANK() OVER (ORDER BY
        (SUM((COALESCE(ps.wOBA, 0) - COALESCE(ps.lgwOBA, 0)) / 1.15 * ps.PA)
         + SUM(ps.SB * 0.2 - ps.CS * 0.4)
         + SUM(ps.PA) / 650.0 *
           CASE pp.primary_pos
               WHEN 'C' THEN 12.5 WHEN 'SS' THEN 7.5
               WHEN '2B' THEN 2.5 WHEN 'CF' THEN 2.5
               WHEN '3B' THEN -2.5 WHEN 'RF' THEN -2.5
               WHEN 'LF' THEN -2.5 WHEN '1B' THEN -12.5
               WHEN 'DH' THEN -17.5 ELSE 0
           END
         + SUM(ps.PA) / 600.0 * 20.0
        ) / 10.0
        DESC
    )                                                          AS war_rank
FROM player_seasons ps
JOIN people p ON p.playerID = ps.playerID
JOIN primary_pos pp ON pp.playerID = ps.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, pp.primary_pos
HAVING SUM(ps.PA) >= 500
ORDER BY approx_WAR DESC;

-- ============================================================
-- View 16: giants_career_batting_by_position
-- Purpose: Aggregate batting performance by primary position
--          for Giants players across franchise history.
-- Key formulas: AVG, OBP, SLG, OPS by position.
-- Qualifiers: teamID = 'SFN', PA >= 200 per player
-- ============================================================
CREATE OR REPLACE VIEW giants_career_batting_by_position AS
WITH sea_pos AS (
    SELECT a.playerID,
        CASE
            WHEN SUM(COALESCE(a.G_c, 0)) >= GREATEST(SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'C'
            WHEN SUM(COALESCE(a.G_1b, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '1B'
            WHEN SUM(COALESCE(a.G_2b, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '2B'
            WHEN SUM(COALESCE(a.G_3b, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN '3B'
            WHEN SUM(COALESCE(a.G_ss, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'SS'
            WHEN SUM(COALESCE(a.G_lf, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'LF'
            WHEN SUM(COALESCE(a.G_cf, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_rf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'CF'
            WHEN SUM(COALESCE(a.G_rf, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_dh, 0))) THEN 'RF'
            WHEN SUM(COALESCE(a.G_dh, 0)) >= GREATEST(SUM(COALESCE(a.G_c, 0)), SUM(COALESCE(a.G_1b, 0)), SUM(COALESCE(a.G_2b, 0)), SUM(COALESCE(a.G_3b, 0)), SUM(COALESCE(a.G_ss, 0)), SUM(COALESCE(a.G_lf, 0)), SUM(COALESCE(a.G_cf, 0)), SUM(COALESCE(a.G_rf, 0))) THEN 'DH'
            ELSE 'OF'
        END AS pos
    FROM appearances a
    WHERE a.teamID = 'SFN'
    GROUP BY a.playerID
)
SELECT
    sp.pos                                                     AS position,
    COUNT(DISTINCT b.playerID)                                 AS num_players,
    SUM(b.AB)                                                  AS total_AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    SUM(b.HR)                                                  AS total_HR
FROM batting b
JOIN sea_pos sp ON sp.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY sp.pos
ORDER BY OPS DESC;

-- ============================================================
-- View 17: giants_100_hr_club
-- Purpose: Giants players who hit 100+ HR in their Giants
--          career.
-- Key formulas: SUM(HR), career rate stats.
-- Qualifiers: teamID = 'SFN', career HR >= 100
-- ============================================================
CREATE OR REPLACE VIEW giants_100_hr_club AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(b.yearID)                                              AS first_year,
    MAX(b.yearID)                                              AS last_year,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.HR)                                                  AS HR,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.R)                                                   AS R,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    RANK() OVER (ORDER BY SUM(b.HR) DESC)                     AS hr_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(b.HR) >= 100
ORDER BY HR DESC;

-- ============================================================
-- View 18: giants_1000_hit_club
-- Purpose: Giants players who recorded 1000+ hits for the Giants.
-- Key formulas: SUM(H), career rate stats.
-- Qualifiers: teamID = 'SFN', career H >= 1000
-- ============================================================
CREATE OR REPLACE VIEW giants_1000_hit_club AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(b.yearID)                                              AS first_year,
    MAX(b.yearID)                                              AS last_year,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.H)                                                   AS H,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.`2B`)                                                AS `2B`,
    SUM(b.`3B`)                                                AS `3B`,
    RANK() OVER (ORDER BY SUM(b.H) DESC)                      AS hits_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(b.H) >= 1000
ORDER BY H DESC;

-- ============================================================
-- View 19: giants_career_obp_leaders
-- Purpose: Top career OBP among Giants hitters (min 1000 PA).
-- Key formulas: OBP = (H+BB+HBP)/(AB+BB+HBP+SF)
-- Qualifiers: teamID = 'SFN', PA >= 1000
-- ============================================================
CREATE OR REPLACE VIEW giants_career_obp_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0))
              + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0))
              + SUM(COALESCE(b.SH, 0))                        AS PA,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS OBP,
    SUM(COALESCE(b.BB, 0))                                     AS BB,
    SUM(COALESCE(b.HBP, 0))                                    AS HBP,
    RANK() OVER (ORDER BY
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0) DESC
    )                                                          AS obp_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0))
       + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0))
       + SUM(COALESCE(b.SH, 0))) >= 1000
ORDER BY OBP DESC;

-- ============================================================
-- View 20: giants_career_slg_leaders
-- Purpose: Top career SLG among Giants hitters (min 1000 PA).
-- Key formulas: SLG = (H+2B+2*3B+3*HR)/AB
-- Qualifiers: teamID = 'SFN', PA >= 1000
-- ============================================================
CREATE OR REPLACE VIEW giants_career_slg_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT b.yearID)                                   AS seasons,
    SUM(b.AB)                                                  AS AB,
    SUM(b.HR)                                                  AS HR,
    SUM(b.`2B`)                                                AS `2B`,
    SUM(b.`3B`)                                                AS `3B`,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS ISO,
    RANK() OVER (ORDER BY
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0) DESC
    )                                                          AS slg_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0))
       + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0))
       + SUM(COALESCE(b.SH, 0))) >= 1000
ORDER BY SLG DESC;

-- ============================================================
-- View 21: giants_season_batting_standard
-- Purpose: Individual season batting lines for all Giants
--          hitters, aggregated across stints within a season.
-- Key formulas: AVG, OBP, SLG, OPS. PA = AB+BB+HBP+SF+SH.
-- Qualifiers: teamID = 'SFN', AB >= 50 in that season
-- ============================================================
CREATE OR REPLACE VIEW giants_season_batting_standard AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.G) AS G, SUM(b.AB) AS AB,
    SUM(b.R) AS R, SUM(b.H) AS H,
    SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`, SUM(b.HR) AS HR,
    SUM(COALESCE(b.RBI, 0)) AS RBI,
    SUM(COALESCE(b.SB, 0)) AS SB, SUM(COALESCE(b.CS, 0)) AS CS,
    SUM(COALESCE(b.BB, 0)) AS BB, SUM(COALESCE(b.SO, 0)) AS SO,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.AB) >= 50
ORDER BY b.yearID DESC, OPS DESC;

-- ============================================================
-- View 22: giants_season_batting_advanced
-- Purpose: Season-level advanced batting: ISO, BABIP, wOBA,
--          BB%, K% for Giants hitters.
-- Key formulas: wOBA linear weights, ISO, BABIP.
-- Qualifiers: teamID = 'SFN', PA >= 200
-- ============================================================
CREATE OR REPLACE VIEW giants_season_batting_advanced AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    ROUND(
        (SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS ISO,
    ROUND(
        (SUM(b.H) - SUM(b.HR))
        / NULLIF(SUM(b.AB) - SUM(COALESCE(b.SO, 0))
                 - SUM(b.HR) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS BABIP,
    ROUND(
        (0.69 * (SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0)))
         + 0.72 * SUM(COALESCE(b.HBP, 0))
         + 0.87 * (SUM(b.H) - SUM(b.`2B`) - SUM(b.`3B`) - SUM(b.HR))
         + 1.22 * SUM(b.`2B`) + 1.56 * SUM(b.`3B`) + 1.95 * SUM(b.HR))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.HBP, 0)), 0), 3
    )                                                          AS wOBA,
    ROUND(
        SUM(COALESCE(b.BB, 0))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)), 0), 3
    )                                                          AS BB_pct,
    ROUND(
        SUM(COALESCE(b.SO, 0))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)), 0), 3
    )                                                          AS K_pct
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0))) >= 200
ORDER BY wOBA DESC;

-- ============================================================
-- View 23: giants_single_season_hr_leaders
-- Purpose: Top HR seasons in Giants franchise history.
-- Key formulas: SUM(HR) per player per year.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_hr_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.HR)                                                  AS HR,
    SUM(b.AB)                                                  AS AB,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    RANK() OVER (ORDER BY SUM(b.HR) DESC)                     AS hr_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.HR) > 0
ORDER BY HR DESC;

-- ============================================================
-- View 24: giants_single_season_avg_leaders
-- Purpose: Top batting average seasons in Giants history
--          (qualified: PA >= 400).
-- Key formulas: AVG = H/AB.
-- Qualifiers: teamID = 'SFN', PA >= 400
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_avg_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    SUM(b.AB)                                                  AS AB,
    SUM(b.H)                                                   AS H,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    RANK() OVER (ORDER BY SUM(b.H) / NULLIF(SUM(b.AB), 0) DESC) AS avg_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0))) >= 400
ORDER BY AVG DESC;

-- ============================================================
-- View 25: giants_single_season_ops_leaders
-- Purpose: Top OPS seasons in Giants franchise history
--          (qualified: PA >= 400).
-- Key formulas: OPS = OBP + SLG.
-- Qualifiers: teamID = 'SFN', PA >= 400
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_ops_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
        / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    RANK() OVER (ORDER BY
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0) DESC
    )                                                          AS ops_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0))) >= 400
ORDER BY OPS DESC;

-- ============================================================
-- View 26: giants_single_season_rbi_leaders
-- Purpose: Top RBI seasons in Giants history.
-- Key formulas: SUM(RBI) per player per year.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_rbi_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.HR)                                                  AS HR,
    SUM(b.H)                                                   AS H,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    RANK() OVER (ORDER BY SUM(COALESCE(b.RBI, 0)) DESC)       AS rbi_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(COALESCE(b.RBI, 0)) > 0
ORDER BY RBI DESC;

-- ============================================================
-- View 27: giants_single_season_sb_leaders
-- Purpose: Top stolen base seasons in Giants history.
-- Key formulas: SUM(SB) with CS and SB% = SB/(SB+CS).
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_sb_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(COALESCE(b.SB, 0))                                     AS SB,
    SUM(COALESCE(b.CS, 0))                                     AS CS,
    ROUND(
        SUM(COALESCE(b.SB, 0))
        / NULLIF(SUM(COALESCE(b.SB, 0)) + SUM(COALESCE(b.CS, 0)), 0), 3
    )                                                          AS SB_pct,
    SUM(b.G)                                                   AS G,
    RANK() OVER (ORDER BY SUM(COALESCE(b.SB, 0)) DESC)        AS sb_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(COALESCE(b.SB, 0)) > 0
ORDER BY SB DESC;

-- ============================================================
-- View 28: giants_200_hit_seasons
-- Purpose: All 200+ hit seasons in Giants history.
-- Key formulas: SUM(H) per season.
-- Qualifiers: teamID = 'SFN', H >= 200
-- Notes: Ichiro's domain.
-- ============================================================
CREATE OR REPLACE VIEW giants_200_hit_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.H)                                                   AS H,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(b.`2B`)                                                AS `2B`,
    SUM(b.`3B`)                                                AS `3B`,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.SB, 0))                                     AS SB,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    RANK() OVER (ORDER BY SUM(b.H) DESC)                      AS hits_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.H) >= 200
ORDER BY H DESC;

-- ============================================================
-- View 29: giants_30_hr_seasons
-- Purpose: All 30+ HR seasons by Giants players.
-- Key formulas: SUM(HR) per player-season.
-- Qualifiers: teamID = 'SFN', HR >= 30
-- ============================================================
CREATE OR REPLACE VIEW giants_30_hr_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    RANK() OVER (ORDER BY SUM(b.HR) DESC)                     AS hr_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.HR) >= 30
ORDER BY HR DESC;

-- ============================================================
-- View 30: giants_power_speed_seasons
-- Purpose: Giants 20/20 (HR/SB) and 30/30 seasons.
-- Key formulas: SUM(HR) and SUM(SB) per player-season.
-- Qualifiers: teamID = 'SFN', HR >= 20 AND SB >= 20
-- ============================================================
CREATE OR REPLACE VIEW giants_power_speed_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.SB, 0))                                     AS SB,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.R)                                                   AS R,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    CASE
        WHEN SUM(b.HR) >= 30 AND SUM(COALESCE(b.SB, 0)) >= 30
            THEN '30/30'
        ELSE '20/20'
    END                                                        AS club
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.HR) >= 20 AND SUM(COALESCE(b.SB, 0)) >= 20
ORDER BY (SUM(b.HR) + SUM(COALESCE(b.SB, 0))) DESC;

-- ============================================================
-- View 31: giants_100_rbi_seasons
-- Purpose: All 100+ RBI seasons by Giants players.
-- Key formulas: SUM(RBI) per player-season.
-- Qualifiers: teamID = 'SFN', RBI >= 100
-- ============================================================
CREATE OR REPLACE VIEW giants_100_rbi_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    SUM(b.HR)                                                  AS HR,
    SUM(b.H)                                                   AS H,
    SUM(b.AB)                                                  AS AB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS,
    RANK() OVER (ORDER BY SUM(COALESCE(b.RBI, 0)) DESC)       AS rbi_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(COALESCE(b.RBI, 0)) >= 100
ORDER BY RBI DESC;

-- ============================================================
-- View 32: giants_dh_seasons
-- Purpose: DH-focused seasons for Giants (G_dh > 50).
-- Key formulas: Standard batting stats. Uses appearances table
--   for DH game counts.
-- Qualifiers: teamID = 'SFN', G_dh > 50
-- ============================================================
CREATE OR REPLACE VIEW giants_dh_seasons AS
WITH dh_games AS (
    SELECT a.playerID, a.yearID,
        SUM(COALESCE(a.G_dh, 0)) AS G_dh,
        SUM(COALESCE(a.G_all, 0)) AS G_all
    FROM appearances a
    WHERE a.teamID = 'SFN'
    GROUP BY a.playerID, a.yearID
    HAVING SUM(COALESCE(a.G_dh, 0)) > 50
)
SELECT
    p.playerID, p.nameFirst, p.nameLast,
    dg.yearID,
    dg.G_dh,
    dg.G_all,
    SUM(b.AB) AS AB, SUM(b.H) AS H, SUM(b.HR) AS HR,
    SUM(COALESCE(b.RBI, 0)) AS RBI,
    SUM(COALESCE(b.BB, 0)) AS BB, SUM(COALESCE(b.SO, 0)) AS SO,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS
FROM dh_games dg
JOIN batting b ON b.playerID = dg.playerID AND b.yearID = dg.yearID AND b.teamID = 'SFN'
JOIN people p ON p.playerID = dg.playerID
GROUP BY p.playerID, p.nameFirst, p.nameLast, dg.yearID, dg.G_dh, dg.G_all
ORDER BY OPS DESC;

-- ============================================================
-- View 33: giants_rookie_batting
-- Purpose: Rookie season batting stats for Giants players.
-- Key formulas: Standard batting stats. Rookie = first year
--   appearing in batting table.
-- Qualifiers: teamID = 'SFN', player's first MLB year
-- ============================================================
CREATE OR REPLACE VIEW giants_rookie_batting AS
WITH first_year AS (
    SELECT playerID, MIN(yearID) AS rookie_year
    FROM batting
    GROUP BY playerID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID                                                   AS rookie_year,
    SUM(b.G) AS G, SUM(b.AB) AS AB,
    SUM(b.H) AS H, SUM(b.HR) AS HR,
    SUM(COALESCE(b.RBI, 0)) AS RBI,
    SUM(COALESCE(b.SB, 0)) AS SB,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0), 3
    )                                                          AS OPS
FROM batting b
JOIN people p ON p.playerID = b.playerID
JOIN first_year fy ON fy.playerID = b.playerID AND fy.rookie_year = b.yearID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING SUM(b.AB) >= 50
ORDER BY OPS DESC;

-- ============================================================
-- View 34: giants_career_pitching_standard
-- Purpose: Career pitching totals for Giants pitchers
--          (only Giants stints) with standard metrics.
-- Key formulas: IP = IPouts/3, ERA = 9*ER/IP,
--   WHIP = (BB+H)/IP, W% = W/(W+L)
-- Qualifiers: teamID = 'SFN', IPouts >= 90 (30+ IP)
-- ============================================================
CREATE OR REPLACE VIEW giants_career_pitching_standard AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(pi.yearID)                                             AS first_year,
    MAX(pi.yearID)                                             AS last_year,
    COUNT(DISTINCT pi.yearID)                                  AS seasons,
    SUM(pi.W)                                                  AS W,
    SUM(pi.L)                                                  AS L,
    ROUND(SUM(pi.W) / NULLIF(SUM(pi.W) + SUM(pi.L), 0), 3)   AS W_pct,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.G)                                                  AS G,
    SUM(pi.GS)                                                 AS GS,
    SUM(pi.CG)                                                 AS CG,
    SUM(pi.SHO)                                                AS SHO,
    SUM(COALESCE(pi.SV, 0))                                    AS SV,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                             AS IP,
    SUM(pi.H)                                                  AS H,
    SUM(pi.ER)                                                 AS ER,
    SUM(pi.HR)                                                 AS HR,
    SUM(COALESCE(pi.BB, 0))                                    AS BB,
    SUM(pi.SO)                                                 AS SO,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.IPouts) >= 90
ORDER BY ERA ASC;

-- ============================================================
-- View 35: giants_career_pitching_advanced
-- Purpose: Career advanced pitching metrics for Giants
--          pitchers: K/9, BB/9, K/BB, HR/9, FIP, BABIP, K%, BB%.
-- Key formulas: FIP = (13*HR+3*(BB+HBP)-2*SO)/IP + 3.10
-- Qualifiers: teamID = 'SFN', IPouts >= 300 (100+ IP)
-- ============================================================
CREATE OR REPLACE VIEW giants_career_pitching_advanced AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    ROUND(9.0 * SUM(COALESCE(pi.BB, 0)) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS BB_per_9,
    ROUND(SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BB, 0)), 0), 2) AS K_BB,
    ROUND(9.0 * SUM(pi.HR) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS HR_per_9,
    ROUND(
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10, 2
    )                                                          AS FIP,
    ROUND(
        (SUM(pi.H) - SUM(pi.HR))
        / NULLIF(SUM(COALESCE(pi.BFP, 0)) - SUM(COALESCE(pi.BB, 0))
                 - SUM(COALESCE(pi.HBP, 0)) - SUM(pi.SO) - SUM(pi.HR), 0), 3
    )                                                          AS BABIP,
    ROUND(SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3) AS K_pct,
    ROUND(SUM(COALESCE(pi.BB, 0)) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3) AS BB_pct
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.IPouts) >= 300
ORDER BY FIP ASC;

-- ============================================================
-- View 36: giants_career_pitching_counting_leaders
-- Purpose: Career pitching counting stat leaders: W, SO, SV,
--          CG, SHO, IP with DENSE_RANK.
-- Key formulas: Simple SUMs with ranking.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_career_pitching_counting_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    SUM(pi.W)                                                  AS career_W,
    DENSE_RANK() OVER (ORDER BY SUM(pi.W) DESC)              AS W_rank,
    SUM(pi.SO)                                                 AS career_SO,
    DENSE_RANK() OVER (ORDER BY SUM(pi.SO) DESC)             AS SO_rank,
    SUM(COALESCE(pi.SV, 0))                                    AS career_SV,
    DENSE_RANK() OVER (ORDER BY SUM(COALESCE(pi.SV, 0)) DESC) AS SV_rank,
    SUM(pi.CG)                                                 AS career_CG,
    DENSE_RANK() OVER (ORDER BY SUM(pi.CG) DESC)             AS CG_rank,
    SUM(pi.SHO)                                                AS career_SHO,
    DENSE_RANK() OVER (ORDER BY SUM(pi.SHO) DESC)            AS SHO_rank,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS career_IP,
    DENSE_RANK() OVER (ORDER BY SUM(pi.IPouts) DESC)          AS IP_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.IPouts) >= 90
ORDER BY career_W DESC;

-- ============================================================
-- View 37: giants_career_starter_stats
-- Purpose: Career stats for Giants starting pitchers
--          (career GS >= 50% of G, and >= 20 GS).
-- Key formulas: ERA, WHIP, K/9, W-L, FIP.
-- Qualifiers: teamID = 'SFN', GS >= 50% of G, GS >= 20
-- ============================================================
CREATE OR REPLACE VIEW giants_career_starter_stats AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(pi.yearID)                                             AS first_year,
    MAX(pi.yearID)                                             AS last_year,
    SUM(pi.G)                                                  AS G,
    SUM(pi.GS)                                                 AS GS,
    SUM(pi.W)                                                  AS W,
    SUM(pi.L)                                                  AS L,
    ROUND(SUM(pi.W) / NULLIF(SUM(pi.W) + SUM(pi.L), 0), 3)   AS W_pct,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.CG)                                                 AS CG,
    SUM(pi.SHO)                                                AS SHO,
    SUM(pi.SO)                                                 AS SO,
    SUM(COALESCE(pi.BB, 0))                                    AS BB,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    ROUND(
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10, 2
    )                                                          AS FIP
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.GS) >= 0.5 * SUM(pi.G)
   AND SUM(pi.GS) >= 20
ORDER BY ERA ASC;

-- ============================================================
-- View 38: giants_career_reliever_stats
-- Purpose: Career stats for Giants relievers
--          (career GS < 10% of G, G >= 50).
-- Key formulas: ERA, WHIP, K/9, SV, holds proxy, FIP.
-- Qualifiers: teamID = 'SFN', GS < 10% of G, G >= 50
-- ============================================================
CREATE OR REPLACE VIEW giants_career_reliever_stats AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    SUM(pi.G)                                                  AS G,
    SUM(pi.GS)                                                 AS GS,
    SUM(COALESCE(pi.GF, 0))                                    AS GF,
    SUM(COALESCE(pi.SV, 0))                                    AS SV,
    GREATEST(SUM(COALESCE(pi.GF, 0)) - SUM(COALESCE(pi.SV, 0)), 0) AS holds_proxy,
    SUM(pi.W)                                                  AS W,
    SUM(pi.L)                                                  AS L,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    ROUND(SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BB, 0)), 0), 2) AS K_BB,
    ROUND(
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10, 2
    )                                                          AS FIP
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.G) >= 50
   AND SUM(pi.GS) < 0.10 * SUM(pi.G)
ORDER BY SV DESC;

-- ============================================================
-- View 39: giants_career_era_leaders
-- Purpose: Best career ERA among Giants pitchers (min 200 IP).
-- Key formulas: ERA = 9*ER/(IPouts/3)
-- Qualifiers: teamID = 'SFN', IPouts >= 600
-- ============================================================
CREATE OR REPLACE VIEW giants_career_era_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT pi.yearID)                                  AS seasons,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.W)                                                  AS W,
    SUM(pi.L)                                                  AS L,
    SUM(pi.SO)                                                 AS SO,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    RANK() OVER (ORDER BY
        9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0) ASC
    )                                                          AS era_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pi.IPouts) >= 600
ORDER BY ERA ASC;

-- ============================================================
-- View 40: giants_season_pitching_standard
-- Purpose: Individual season pitching lines for all Giants
--          pitchers, aggregated across stints within a season.
-- Key formulas: ERA, WHIP, K/9, W-L.
-- Qualifiers: teamID = 'SFN', IPouts >= 30 (10+ IP)
-- ============================================================
CREATE OR REPLACE VIEW giants_season_pitching_standard AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(SUM(pi.W) / NULLIF(SUM(pi.W) + SUM(pi.L), 0), 3)   AS W_pct,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.G) AS G, SUM(pi.GS) AS GS,
    SUM(pi.CG) AS CG, SUM(pi.SHO) AS SHO,
    SUM(COALESCE(pi.SV, 0)) AS SV,
    ROUND(SUM(pi.IPouts) / 3.0, 1) AS IP,
    SUM(pi.H) AS H, SUM(pi.ER) AS ER,
    SUM(pi.HR) AS HR,
    SUM(COALESCE(pi.BB, 0)) AS BB,
    SUM(pi.SO) AS SO,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 30
ORDER BY pi.yearID DESC, ERA ASC;

-- ============================================================
-- View 41: giants_season_pitching_advanced
-- Purpose: Season-level advanced pitching stats for Giants:
--          FIP, K%, BB%, HR/9, BABIP.
-- Key formulas: FIP = (13*HR+3*(BB+HBP)-2*SO)/IP + 3.10
-- Qualifiers: teamID = 'SFN', IPouts >= 90 (30+ IP)
-- ============================================================
CREATE OR REPLACE VIEW giants_season_pitching_advanced AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10, 2
    )                                                          AS FIP,
    ROUND(SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3) AS K_pct,
    ROUND(SUM(COALESCE(pi.BB, 0)) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3) AS BB_pct,
    ROUND(
        (SUM(pi.SO) - SUM(COALESCE(pi.BB, 0)))
        / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3
    )                                                          AS K_BB_pct,
    ROUND(9.0 * SUM(pi.HR) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS HR_per_9,
    ROUND(
        (SUM(pi.H) - SUM(pi.HR))
        / NULLIF(SUM(COALESCE(pi.BFP, 0)) - SUM(COALESCE(pi.BB, 0))
                 - SUM(COALESCE(pi.HBP, 0)) - SUM(pi.SO) - SUM(pi.HR), 0), 3
    )                                                          AS BABIP
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 90
ORDER BY FIP ASC;

-- ============================================================
-- View 42: giants_single_season_era_leaders
-- Purpose: Best single-season ERA in Giants history (min 100 IP).
-- Key formulas: ERA = 9*ER/(IPouts/3)
-- Qualifiers: teamID = 'SFN', IPouts >= 300
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_era_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(SUM(pi.IPouts) / 3.0, 1) AS IP,
    SUM(pi.SO) AS SO,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    RANK() OVER (ORDER BY
        9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0) ASC
    )                                                          AS era_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 300
ORDER BY ERA ASC;

-- ============================================================
-- View 43: giants_single_season_k_leaders
-- Purpose: Top single-season strikeout totals in Giants history.
-- Key formulas: SUM(SO), K/9.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_k_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(pi.SO)                                                 AS SO,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    RANK() OVER (ORDER BY SUM(pi.SO) DESC)                    AS so_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.SO) > 0
ORDER BY SO DESC;

-- ============================================================
-- View 44: giants_single_season_win_leaders
-- Purpose: Top single-season win totals in Giants history.
-- Key formulas: SUM(W), W-L, ERA.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_win_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(pi.W)                                                  AS W,
    SUM(pi.L)                                                  AS L,
    ROUND(SUM(pi.W) / NULLIF(SUM(pi.W) + SUM(pi.L), 0), 3)   AS W_pct,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.SO)                                                 AS SO,
    RANK() OVER (ORDER BY SUM(pi.W) DESC)                     AS wins_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.W) > 0
ORDER BY W DESC;

-- ============================================================
-- View 45: giants_single_season_save_leaders
-- Purpose: Top single-season save totals in Giants history.
-- Key formulas: SUM(SV), ERA, WHIP.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_save_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(COALESCE(pi.SV, 0))                                    AS SV,
    SUM(pi.G)                                                  AS G,
    SUM(COALESCE(pi.GF, 0))                                    AS GF,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.SO)                                                 AS SO,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    RANK() OVER (ORDER BY SUM(COALESCE(pi.SV, 0)) DESC)       AS save_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(COALESCE(pi.SV, 0)) > 0
ORDER BY SV DESC;

-- ============================================================
-- View 46: giants_single_season_whip_leaders
-- Purpose: Best single-season WHIP in Giants history (100+ IP).
-- Key formulas: WHIP = (BB+H)/(IPouts/3)
-- Qualifiers: teamID = 'SFN', IPouts >= 300
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_whip_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    RANK() OVER (ORDER BY
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) ASC
    )                                                          AS whip_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 300
ORDER BY WHIP ASC;

-- ============================================================
-- View 47: giants_innings_eater_seasons
-- Purpose: Seasons with the most innings pitched in Giants
--          history.
-- Key formulas: IPouts/3 = IP.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_innings_eater_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.GS)                                                 AS GS,
    SUM(pi.CG)                                                 AS CG,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.SO)                                                 AS SO,
    RANK() OVER (ORDER BY SUM(pi.IPouts) DESC)                AS ip_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) > 0
ORDER BY IP DESC;

-- ============================================================
-- View 48: giants_starter_vs_reliever_split
-- Purpose: Giants pitchers classified as SP vs RP each season.
-- Key formulas: SP = GS >= 50% of G, RP = GS < 50%.
-- Qualifiers: teamID = 'SFN', IPouts >= 30
-- ============================================================
CREATE OR REPLACE VIEW giants_starter_vs_reliever_split AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    CASE WHEN SUM(pi.GS) >= 0.5 * SUM(pi.G) THEN 'SP' ELSE 'RP' END AS role,
    SUM(pi.G) AS G, SUM(pi.GS) AS GS,
    SUM(COALESCE(pi.SV, 0)) AS SV,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 30
ORDER BY pi.yearID DESC, role, ERA;

-- ============================================================
-- View 49: giants_complete_game_seasons
-- Purpose: All Giants pitcher-seasons with complete games.
-- Key formulas: CG, SHO, ERA.
-- Qualifiers: teamID = 'SFN', CG >= 1
-- ============================================================
CREATE OR REPLACE VIEW giants_complete_game_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(pi.CG)                                                 AS CG,
    SUM(pi.SHO)                                                AS SHO,
    SUM(pi.GS)                                                 AS GS,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    RANK() OVER (ORDER BY SUM(pi.CG) DESC)                    AS cg_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.CG) >= 1
ORDER BY CG DESC, pi.yearID;

-- ============================================================
-- View 50: giants_single_season_fip_leaders
-- Purpose: Best single-season FIP in Giants history (100+ IP).
-- Key formulas: FIP = (13*HR+3*(BB+HBP)-2*SO)/IP + 3.10
-- Qualifiers: teamID = 'SFN', IPouts >= 300
-- ============================================================
CREATE OR REPLACE VIEW giants_single_season_fip_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10, 2
    )                                                          AS FIP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.SO)                                                 AS SO,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    RANK() OVER (ORDER BY
        (13.0 * SUM(pi.HR) + 3.0 * (SUM(COALESCE(pi.BB, 0)) + SUM(COALESCE(pi.HBP, 0)))
         - 2.0 * SUM(pi.SO))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0) + 3.10 ASC
    )                                                          AS fip_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 300
ORDER BY FIP ASC;

-- ============================================================
-- View 51: giants_career_fielding_by_position
-- Purpose: Career fielding stats by position for Giants
--          players with >= 100 G at that position.
-- Key formulas: Fld% = (PO+A)/(PO+A+E)
-- Qualifiers: teamID = 'SFN', G >= 100 at position
-- ============================================================
CREATE OR REPLACE VIEW giants_career_fielding_by_position AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    f.POS,
    SUM(f.G)                                                   AS G,
    SUM(COALESCE(f.GS, 0))                                    AS GS,
    SUM(f.PO)                                                  AS PO,
    SUM(f.A)                                                   AS A,
    SUM(f.E)                                                   AS E,
    SUM(COALESCE(f.DP, 0))                                    AS DP,
    ROUND(
        (SUM(f.PO) + SUM(f.A))
        / NULLIF(SUM(f.PO) + SUM(f.A) + SUM(f.E), 0), 4
    )                                                          AS Fld_pct,
    ROUND(SUM(COALESCE(f.InnOuts, 0)) / 3.0, 1)              AS Inn
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, f.POS
HAVING SUM(f.G) >= 100
ORDER BY f.POS, Fld_pct DESC;

-- ============================================================
-- View 52: giants_season_fielding
-- Purpose: Season fielding stats for Giants players.
-- Key formulas: Fld% = (PO+A)/(PO+A+E)
-- Qualifiers: teamID = 'SFN', G >= 20
-- ============================================================
CREATE OR REPLACE VIEW giants_season_fielding AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    f.yearID,
    f.POS,
    SUM(f.G)                                                   AS G,
    SUM(COALESCE(f.GS, 0))                                    AS GS,
    SUM(f.PO)                                                  AS PO,
    SUM(f.A)                                                   AS A,
    SUM(f.E)                                                   AS E,
    SUM(COALESCE(f.DP, 0))                                    AS DP,
    ROUND(
        (SUM(f.PO) + SUM(f.A))
        / NULLIF(SUM(f.PO) + SUM(f.A) + SUM(f.E), 0), 4
    )                                                          AS Fld_pct
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, f.yearID, f.POS
HAVING SUM(f.G) >= 20
ORDER BY f.yearID DESC, f.POS, Fld_pct DESC;

-- ============================================================
-- View 53: giants_gold_glove_winners
-- Purpose: Giants players who won Gold Glove awards.
-- Key formulas: Joins awardsplayers with batting/fielding.
-- Qualifiers: awardID = 'Gold Glove', player on SEA roster
-- ============================================================
CREATE OR REPLACE VIEW giants_gold_glove_winners AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    ap.yearID,
    ap.lgID,
    ap.notes
FROM awardsplayers ap
JOIN people p ON p.playerID = ap.playerID
WHERE ap.awardID = 'Gold Glove'
  AND EXISTS (
      SELECT 1 FROM batting b
      WHERE b.playerID = ap.playerID
        AND b.yearID = ap.yearID
        AND b.teamID = 'SFN'
      UNION ALL
      SELECT 1 FROM pitching pi
      WHERE pi.playerID = ap.playerID
        AND pi.yearID = ap.yearID
        AND pi.teamID = 'SFN'
  )
ORDER BY ap.yearID;

-- ============================================================
-- View 54: giants_catcher_stats
-- Purpose: Career catcher fielding + batting for Giants
--          catchers with >= 50 G at catcher.
-- Key formulas: CS% = CS/(CS+SB), Fld%, batting rate stats.
-- Qualifiers: teamID = 'SFN', G at C >= 50
-- ============================================================
CREATE OR REPLACE VIEW giants_catcher_stats AS
WITH catcher_field AS (
    SELECT
        f.playerID,
        SUM(f.G)                                               AS G_c,
        SUM(f.PO)                                              AS PO,
        SUM(f.A)                                               AS A,
        SUM(f.E)                                               AS E,
        SUM(COALESCE(f.PB, 0))                                AS PB,
        SUM(COALESCE(f.SB, 0))                                AS SB_allowed,
        SUM(COALESCE(f.CS, 0))                                AS CS_caught,
        ROUND(
            (SUM(f.PO) + SUM(f.A))
            / NULLIF(SUM(f.PO) + SUM(f.A) + SUM(f.E), 0), 4
        )                                                      AS Fld_pct,
        ROUND(
            SUM(COALESCE(f.CS, 0))
            / NULLIF(SUM(COALESCE(f.CS, 0)) + SUM(COALESCE(f.SB, 0)), 0), 3
        )                                                      AS CS_pct
    FROM fielding f
    WHERE f.POS = 'C' AND f.teamID = 'SFN'
    GROUP BY f.playerID
    HAVING SUM(f.G) >= 50
),
catcher_bat AS (
    SELECT
        b.playerID,
        SUM(b.AB) AS AB, SUM(b.H) AS H, SUM(b.HR) AS HR,
        SUM(COALESCE(b.RBI, 0)) AS RBI,
        SUM(COALESCE(b.BB, 0)) AS BB,
        SUM(COALESCE(b.HBP, 0)) AS HBP,
        SUM(COALESCE(b.SF, 0)) AS SF,
        SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`
    FROM batting b
    WHERE b.teamID = 'SFN'
    GROUP BY b.playerID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    cf.G_c,
    cb.AB, cb.H, cb.HR, cb.RBI,
    ROUND(cb.H / NULLIF(cb.AB, 0), 3)                         AS AVG,
    ROUND(
        (cb.H + cb.BB + cb.HBP)
        / NULLIF(cb.AB + cb.BB + cb.HBP + cb.SF, 0), 3
    )                                                          AS OBP,
    ROUND(
        (cb.H + cb.`2B` + 2 * cb.`3B` + 3 * cb.HR)
        / NULLIF(cb.AB, 0), 3
    )                                                          AS SLG,
    cf.PB,
    cf.SB_allowed,
    cf.CS_caught,
    cf.CS_pct,
    cf.Fld_pct,
    cf.E
FROM catcher_field cf
JOIN catcher_bat cb ON cb.playerID = cf.playerID
JOIN people p ON p.playerID = cf.playerID
ORDER BY cf.G_c DESC;

-- ============================================================
-- View 55: giants_utility_players
-- Purpose: Giants players who appeared at 3+ positions in a
--          single season (versatile defenders).
-- Key formulas: COUNT(DISTINCT POS) from fielding.
-- Qualifiers: teamID = 'SFN', 3+ positions in a season
-- ============================================================
CREATE OR REPLACE VIEW giants_utility_players AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    f.yearID,
    COUNT(DISTINCT f.POS)                                      AS positions_played,
    GROUP_CONCAT(DISTINCT f.POS ORDER BY f.POS)               AS positions,
    SUM(f.G)                                                   AS total_G
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, f.yearID
HAVING COUNT(DISTINCT f.POS) >= 3
ORDER BY positions_played DESC, f.yearID DESC;

-- ============================================================
-- View 56: giants_defensive_appearances
-- Purpose: Games at each defensive position by year, from the
--          appearances table.
-- Key formulas: G_c, G_1b, G_2b, etc from appearances.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_defensive_appearances AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    a.yearID,
    SUM(COALESCE(a.G_all, 0))                                 AS G_all,
    SUM(COALESCE(a.G_p, 0))                                   AS G_p,
    SUM(COALESCE(a.G_c, 0))                                   AS G_c,
    SUM(COALESCE(a.G_1b, 0))                                  AS G_1b,
    SUM(COALESCE(a.G_2b, 0))                                  AS G_2b,
    SUM(COALESCE(a.G_3b, 0))                                  AS G_3b,
    SUM(COALESCE(a.G_ss, 0))                                  AS G_ss,
    SUM(COALESCE(a.G_lf, 0))                                  AS G_lf,
    SUM(COALESCE(a.G_cf, 0))                                  AS G_cf,
    SUM(COALESCE(a.G_rf, 0))                                  AS G_rf,
    SUM(COALESCE(a.G_of, 0))                                  AS G_of,
    SUM(COALESCE(a.G_dh, 0))                                  AS G_dh
FROM appearances a
JOIN people p ON p.playerID = a.playerID
WHERE a.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, a.yearID
ORDER BY a.yearID DESC, G_all DESC;

-- ============================================================
-- View 57: giants_fielding_pct_leaders
-- Purpose: Best single-season fielding percentage by position
--          in Giants history (min 50 G at position).
-- Key formulas: Fld% = (PO+A)/(PO+A+E)
-- Qualifiers: teamID = 'SFN', G >= 50 at position
-- ============================================================
CREATE OR REPLACE VIEW giants_fielding_pct_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    f.yearID,
    f.POS,
    SUM(f.G)                                                   AS G,
    ROUND(
        (SUM(f.PO) + SUM(f.A))
        / NULLIF(SUM(f.PO) + SUM(f.A) + SUM(f.E), 0), 4
    )                                                          AS Fld_pct,
    SUM(f.E)                                                   AS E,
    RANK() OVER (PARTITION BY f.POS ORDER BY
        (SUM(f.PO) + SUM(f.A))
        / NULLIF(SUM(f.PO) + SUM(f.A) + SUM(f.E), 0) DESC
    )                                                          AS pos_rank
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, f.yearID, f.POS
HAVING SUM(f.G) >= 50
ORDER BY f.POS, Fld_pct DESC;

-- ============================================================
-- View 58: giants_all_stars
-- Purpose: All Giants All-Star Game selections.
-- Key formulas: Joins allstarfull with people.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_all_stars AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    asf.yearID,
    asf.gameNum,
    asf.GP,
    asf.startingPos
FROM allstarfull asf
JOIN people p ON p.playerID = asf.playerID
WHERE asf.teamID = 'SFN'
ORDER BY asf.yearID, p.nameLast;

-- ============================================================
-- View 59: giants_all_star_count
-- Purpose: Giants players ranked by number of All-Star
--          selections while with the team.
-- Key formulas: COUNT(DISTINCT yearID).
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_all_star_count AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT asf.yearID)                                 AS allstar_selections,
    MIN(asf.yearID)                                            AS first_selection,
    MAX(asf.yearID)                                            AS last_selection,
    SUM(CASE WHEN asf.startingPos IS NOT NULL THEN 1 ELSE 0 END) AS times_started
FROM allstarfull asf
JOIN people p ON p.playerID = asf.playerID
WHERE asf.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY allstar_selections DESC;

-- ============================================================
-- View 60: giants_mvp_voting
-- Purpose: Giants players who received MVP votes.
-- Key formulas: pointsWon, votesFirst from awardsshareplayers.
-- Qualifiers: awardID = 'MVP', player on SEA roster
-- ============================================================
CREATE OR REPLACE VIEW giants_mvp_voting AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    asp.yearID,
    asp.pointsWon,
    asp.pointsMax,
    ROUND(asp.pointsWon / NULLIF(asp.pointsMax, 0), 3)        AS vote_pct,
    asp.votesFirst,
    RANK() OVER (PARTITION BY asp.yearID
                 ORDER BY asp.pointsWon DESC)                  AS year_rank
FROM awardsshareplayers asp
JOIN people p ON p.playerID = asp.playerID
WHERE asp.awardID = 'MVP'
  AND EXISTS (
      SELECT 1 FROM batting b
      WHERE b.playerID = asp.playerID
        AND b.yearID = asp.yearID
        AND b.teamID = 'SFN'
      UNION ALL
      SELECT 1 FROM pitching pi
      WHERE pi.playerID = asp.playerID
        AND pi.yearID = asp.yearID
        AND pi.teamID = 'SFN'
  )
ORDER BY asp.yearID DESC, asp.pointsWon DESC;

-- ============================================================
-- View 61: giants_cy_young_voting
-- Purpose: Giants pitchers who received Cy Young votes.
-- Key formulas: pointsWon, votesFirst from awardsshareplayers.
-- Qualifiers: awardID = 'Cy Young', player on SEA roster
-- ============================================================
CREATE OR REPLACE VIEW giants_cy_young_voting AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    asp.yearID,
    asp.pointsWon,
    asp.pointsMax,
    ROUND(asp.pointsWon / NULLIF(asp.pointsMax, 0), 3)        AS vote_pct,
    asp.votesFirst,
    RANK() OVER (PARTITION BY asp.yearID
                 ORDER BY asp.pointsWon DESC)                  AS year_rank
FROM awardsshareplayers asp
JOIN people p ON p.playerID = asp.playerID
WHERE asp.awardID = 'Cy Young'
  AND EXISTS (
      SELECT 1 FROM pitching pi
      WHERE pi.playerID = asp.playerID
        AND pi.yearID = asp.yearID
        AND pi.teamID = 'SFN'
  )
ORDER BY asp.yearID DESC, asp.pointsWon DESC;

-- ============================================================
-- View 62: giants_award_winners
-- Purpose: All individual award winners while with the Giants.
-- Key formulas: Joins awardsplayers to team roster.
-- Qualifiers: Player on SEA roster in award year
-- ============================================================
CREATE OR REPLACE VIEW giants_award_winners AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    ap.awardID,
    ap.yearID,
    ap.lgID,
    ap.notes
FROM awardsplayers ap
JOIN people p ON p.playerID = ap.playerID
WHERE EXISTS (
    SELECT 1 FROM batting b
    WHERE b.playerID = ap.playerID
      AND b.yearID = ap.yearID
      AND b.teamID = 'SFN'
    UNION ALL
    SELECT 1 FROM pitching pi
    WHERE pi.playerID = ap.playerID
      AND pi.yearID = ap.yearID
      AND pi.teamID = 'SFN'
)
ORDER BY ap.yearID DESC, ap.awardID;

-- ============================================================
-- View 63: giants_hof_players
-- Purpose: Hall of Famers who played for the Giants.
-- Key formulas: Joins halloffame with appearances.
-- Qualifiers: inducted = 'Y', played for SEA
-- ============================================================
CREATE OR REPLACE VIEW giants_hof_players AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    h.yearid                                                   AS induction_year,
    h.votedBy,
    h.category,
    MIN(a.yearID)                                              AS first_sea_year,
    MAX(a.yearID)                                              AS last_sea_year,
    COUNT(DISTINCT a.yearID)                                   AS sea_seasons,
    SUM(COALESCE(a.G_all, 0))                                 AS sea_games
FROM halloffame h
JOIN people p ON p.playerID = h.playerID
JOIN appearances a ON a.playerID = h.playerID AND a.teamID = 'SFN'
WHERE h.inducted = 'Y'
GROUP BY p.playerID, p.nameFirst, p.nameLast,
         h.yearid, h.votedBy, h.category
ORDER BY h.yearid;

-- ============================================================
-- View 64: giants_silver_slugger_winners
-- Purpose: Giants Silver Slugger award winners.
-- Key formulas: Joins awardsplayers with roster.
-- Qualifiers: awardID = 'Silver Slugger', on SEA roster
-- ============================================================
CREATE OR REPLACE VIEW giants_silver_slugger_winners AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    ap.yearID,
    ap.lgID,
    ap.notes
FROM awardsplayers ap
JOIN people p ON p.playerID = ap.playerID
WHERE ap.awardID = 'Silver Slugger'
  AND EXISTS (
      SELECT 1 FROM batting b
      WHERE b.playerID = ap.playerID
        AND b.yearID = ap.yearID
        AND b.teamID = 'SFN'
  )
ORDER BY ap.yearID;

-- ============================================================
-- View 65: giants_rookie_of_year_voting
-- Purpose: Giants players who received ROY votes.
-- Key formulas: pointsWon from awardsshareplayers.
-- Qualifiers: awardID = 'Rookie of the Year', on SEA roster
-- ============================================================
CREATE OR REPLACE VIEW giants_rookie_of_year_voting AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    asp.yearID,
    asp.pointsWon,
    asp.pointsMax,
    ROUND(asp.pointsWon / NULLIF(asp.pointsMax, 0), 3)        AS vote_pct,
    asp.votesFirst,
    RANK() OVER (PARTITION BY asp.yearID
                 ORDER BY asp.pointsWon DESC)                  AS year_rank
FROM awardsshareplayers asp
JOIN people p ON p.playerID = asp.playerID
WHERE asp.awardID = 'Rookie of the Year'
  AND EXISTS (
      SELECT 1 FROM batting b
      WHERE b.playerID = asp.playerID
        AND b.yearID = asp.yearID
        AND b.teamID = 'SFN'
      UNION ALL
      SELECT 1 FROM pitching pi
      WHERE pi.playerID = asp.playerID
        AND pi.yearID = asp.yearID
        AND pi.teamID = 'SFN'
  )
ORDER BY asp.yearID DESC, asp.pointsWon DESC;

-- ============================================================
-- View 66: giants_postseason_batting
-- Purpose: Postseason batting stats for Giants players.
-- Key formulas: AVG, OBP, SLG, OPS from battingpost.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_batting AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    bp.yearID,
    bp.round,
    SUM(bp.G) AS G, SUM(bp.AB) AS AB,
    SUM(COALESCE(bp.R, 0)) AS R,
    SUM(bp.H) AS H,
    SUM(bp.`2B`) AS `2B`, SUM(bp.`3B`) AS `3B`,
    SUM(bp.HR) AS HR,
    SUM(COALESCE(bp.RBI, 0)) AS RBI,
    SUM(COALESCE(bp.BB, 0)) AS BB,
    SUM(COALESCE(bp.SO, 0)) AS SO,
    ROUND(SUM(bp.H) / NULLIF(SUM(bp.AB), 0), 3)               AS AVG,
    ROUND(
        (SUM(bp.H) + SUM(COALESCE(bp.BB, 0)) + SUM(COALESCE(bp.HBP, 0)))
        / NULLIF(SUM(bp.AB) + SUM(COALESCE(bp.BB, 0))
                 + SUM(COALESCE(bp.HBP, 0)) + SUM(COALESCE(bp.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(bp.H) + SUM(bp.`2B`) + 2 * SUM(bp.`3B`) + 3 * SUM(bp.HR))
        / NULLIF(SUM(bp.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(bp.H) + SUM(COALESCE(bp.BB, 0)) + SUM(COALESCE(bp.HBP, 0)))
        / NULLIF(SUM(bp.AB) + SUM(COALESCE(bp.BB, 0))
                 + SUM(COALESCE(bp.HBP, 0)) + SUM(COALESCE(bp.SF, 0)), 0)
        + (SUM(bp.H) + SUM(bp.`2B`) + 2 * SUM(bp.`3B`) + 3 * SUM(bp.HR))
          / NULLIF(SUM(bp.AB), 0), 3
    )                                                          AS OPS
FROM battingpost bp
JOIN people p ON p.playerID = bp.playerID
WHERE bp.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, bp.yearID, bp.round
ORDER BY bp.yearID, bp.round, OPS DESC;

-- ============================================================
-- View 67: giants_postseason_pitching
-- Purpose: Postseason pitching stats for Giants pitchers.
-- Key formulas: ERA, WHIP, K/9 from pitchingpost.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_pitching AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pp.yearID,
    pp.round,
    SUM(pp.G) AS G, SUM(pp.GS) AS GS,
    SUM(pp.W) AS W, SUM(pp.L) AS L,
    SUM(COALESCE(pp.SV, 0)) AS SV,
    ROUND(SUM(pp.IPouts) / 3.0, 1)                            AS IP,
    SUM(pp.H) AS H, SUM(pp.ER) AS ER,
    SUM(pp.SO) AS SO,
    SUM(COALESCE(pp.BB, 0)) AS BB,
    ROUND(9.0 * SUM(pp.ER) / NULLIF(SUM(pp.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(
        (SUM(COALESCE(pp.BB, 0)) + SUM(pp.H))
        / NULLIF(SUM(pp.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pp.SO) / NULLIF(SUM(pp.IPouts) / 3.0, 0), 2) AS K_per_9
FROM pitchingpost pp
JOIN people p ON p.playerID = pp.playerID
WHERE pp.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pp.yearID, pp.round
ORDER BY pp.yearID, pp.round, ERA ASC;

-- ============================================================
-- View 68: giants_postseason_career_batting
-- Purpose: Career postseason batting totals for Giants players
--          (all rounds combined, SEA only).
-- Key formulas: AVG, OBP, SLG, OPS.
-- Qualifiers: teamID = 'SFN', AB >= 5
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_career_batting AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT bp.yearID)                                  AS ps_years,
    SUM(bp.G) AS G, SUM(bp.AB) AS AB,
    SUM(bp.H) AS H, SUM(bp.HR) AS HR,
    SUM(COALESCE(bp.RBI, 0)) AS RBI,
    SUM(COALESCE(bp.BB, 0)) AS BB,
    ROUND(SUM(bp.H) / NULLIF(SUM(bp.AB), 0), 3)               AS AVG,
    ROUND(
        (SUM(bp.H) + SUM(COALESCE(bp.BB, 0)) + SUM(COALESCE(bp.HBP, 0)))
        / NULLIF(SUM(bp.AB) + SUM(COALESCE(bp.BB, 0))
                 + SUM(COALESCE(bp.HBP, 0)) + SUM(COALESCE(bp.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(bp.H) + SUM(bp.`2B`) + 2 * SUM(bp.`3B`) + 3 * SUM(bp.HR))
        / NULLIF(SUM(bp.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(bp.H) + SUM(COALESCE(bp.BB, 0)) + SUM(COALESCE(bp.HBP, 0)))
        / NULLIF(SUM(bp.AB) + SUM(COALESCE(bp.BB, 0))
                 + SUM(COALESCE(bp.HBP, 0)) + SUM(COALESCE(bp.SF, 0)), 0)
        + (SUM(bp.H) + SUM(bp.`2B`) + 2 * SUM(bp.`3B`) + 3 * SUM(bp.HR))
          / NULLIF(SUM(bp.AB), 0), 3
    )                                                          AS OPS
FROM battingpost bp
JOIN people p ON p.playerID = bp.playerID
WHERE bp.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(bp.AB) >= 5
ORDER BY OPS DESC;

-- ============================================================
-- View 69: giants_postseason_career_pitching
-- Purpose: Career postseason pitching totals for Giants
--          pitchers (all rounds combined, SEA only).
-- Key formulas: ERA, WHIP, K/9.
-- Qualifiers: teamID = 'SFN', IPouts >= 3
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_career_pitching AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT pp.yearID)                                  AS ps_years,
    SUM(pp.G) AS G, SUM(pp.GS) AS GS,
    SUM(pp.W) AS W, SUM(pp.L) AS L,
    SUM(COALESCE(pp.SV, 0)) AS SV,
    ROUND(SUM(pp.IPouts) / 3.0, 1)                            AS IP,
    SUM(pp.SO) AS SO,
    ROUND(9.0 * SUM(pp.ER) / NULLIF(SUM(pp.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(
        (SUM(COALESCE(pp.BB, 0)) + SUM(pp.H))
        / NULLIF(SUM(pp.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pp.SO) / NULLIF(SUM(pp.IPouts) / 3.0, 0), 2) AS K_per_9
FROM pitchingpost pp
JOIN people p ON p.playerID = pp.playerID
WHERE pp.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING SUM(pp.IPouts) >= 3
ORDER BY ERA ASC;

-- ============================================================
-- View 70: giants_postseason_series
-- Purpose: Giants postseason series results from seriespost.
-- Key formulas: Wins, losses, ties per series.
-- Qualifiers: teamIDwinner = 'SFN' OR teamIDloser = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_series AS
SELECT
    sp.yearID,
    sp.round,
    CASE
        WHEN sp.teamIDwinner = 'SFN' THEN 'Won'
        ELSE 'Lost'
    END                                                        AS result,
    CASE
        WHEN sp.teamIDwinner = 'SFN' THEN sp.teamIDloser
        ELSE sp.teamIDwinner
    END                                                        AS opponent,
    sp.wins,
    sp.losses,
    sp.ties
FROM seriespost sp
WHERE sp.teamIDwinner = 'SFN' OR sp.teamIDloser = 'SFN'
ORDER BY sp.yearID, sp.round;

-- ============================================================
-- View 71: giants_salary_history
-- Purpose: Player salary history for the Giants.
-- Key formulas: salary from salaries table.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_salary_history AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    s.yearID,
    s.salary,
    RANK() OVER (PARTITION BY s.yearID ORDER BY s.salary DESC) AS team_salary_rank
FROM salaries s
JOIN people p ON p.playerID = s.playerID
WHERE s.teamID = 'SFN'
ORDER BY s.yearID DESC, s.salary DESC;

-- ============================================================
-- View 72: giants_highest_paid_players
-- Purpose: All-time highest paid Giants players by total and
--          peak salary.
-- Key formulas: SUM(salary), MAX(salary).
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_highest_paid_players AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT s.yearID)                                   AS salary_years,
    SUM(s.salary)                                              AS total_salary,
    MAX(s.salary)                                              AS peak_salary,
    ROUND(AVG(s.salary), 0)                                    AS avg_salary,
    MIN(s.yearID)                                              AS first_year,
    MAX(s.yearID)                                              AS last_year,
    RANK() OVER (ORDER BY SUM(s.salary) DESC)                 AS total_rank
FROM salaries s
JOIN people p ON p.playerID = s.playerID
WHERE s.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY total_salary DESC;

-- ============================================================
-- View 73: giants_payroll_by_year
-- Purpose: Total team payroll by year and league rank.
-- Key formulas: SUM(salary), rank among all teams.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_payroll_by_year AS
WITH team_payrolls AS (
    SELECT yearID, teamID, SUM(salary) AS total_payroll
    FROM salaries
    GROUP BY yearID, teamID
)
SELECT
    tp.yearID,
    tp.total_payroll                                           AS sea_payroll,
    RANK() OVER (PARTITION BY tp.yearID
                 ORDER BY tp.total_payroll DESC)               AS mlb_payroll_rank,
    (SELECT COUNT(DISTINCT teamID) FROM salaries s2
     WHERE s2.yearID = tp.yearID)                              AS total_teams
FROM team_payrolls tp
WHERE tp.teamID = 'SFN'
ORDER BY tp.yearID DESC;

-- ============================================================
-- View 74: giants_salary_efficiency
-- Purpose: Salary vs performance: cost per win, payroll with
--          team W-L record.
-- Key formulas: cost_per_win = payroll / W
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_salary_efficiency AS
WITH team_payrolls AS (
    SELECT yearID, teamID, SUM(salary) AS total_payroll
    FROM salaries
    GROUP BY yearID, teamID
)
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    tp.total_payroll,
    ROUND(tp.total_payroll / NULLIF(t.W, 0), 0)               AS cost_per_win,
    t.DivWin,
    t.WCWin,
    t.attendance
FROM teams t
JOIN team_payrolls tp ON tp.yearID = t.yearID AND tp.teamID = t.teamID
WHERE t.teamID = 'SFN'
ORDER BY t.yearID DESC;

-- ============================================================
-- View 75: giants_players_by_birthplace
-- Purpose: Where Giants players were born (country/state).
-- Key formulas: COUNT by birthCountry/birthState.
-- Qualifiers: Players who appeared for SEA
-- ============================================================
CREATE OR REPLACE VIEW giants_players_by_birthplace AS
SELECT
    p.birthCountry,
    p.birthState,
    COUNT(DISTINCT p.playerID)                                 AS player_count
FROM people p
WHERE EXISTS (
    SELECT 1 FROM appearances a
    WHERE a.playerID = p.playerID AND a.teamID = 'SFN'
)
GROUP BY p.birthCountry, p.birthState
ORDER BY player_count DESC;

-- ============================================================
-- View 76: giants_college_pipeline
-- Purpose: Colleges that produced the most Giants players.
-- Key formulas: COUNT(DISTINCT playerID) by school.
-- Qualifiers: Players who appeared for SEA
-- ============================================================
CREATE OR REPLACE VIEW giants_college_pipeline AS
SELECT
    sc.schoolID,
    sc.name_full                                               AS school_name,
    sc.city,
    sc.state,
    COUNT(DISTINCT cp.playerID)                                AS player_count,
    GROUP_CONCAT(DISTINCT CONCAT(p.nameFirst, ' ', p.nameLast)
                 ORDER BY p.nameLast SEPARATOR ', ')           AS players
FROM collegeplaying cp
JOIN schools sc ON sc.schoolID = cp.schoolID
JOIN people p ON p.playerID = cp.playerID
WHERE EXISTS (
    SELECT 1 FROM appearances a
    WHERE a.playerID = cp.playerID AND a.teamID = 'SFN'
)
GROUP BY sc.schoolID, sc.name_full, sc.city, sc.state
ORDER BY player_count DESC;

-- ============================================================
-- View 77: giants_international_players
-- Purpose: Giants players born outside the USA.
-- Key formulas: COUNT by country, individual player list.
-- Qualifiers: Players who appeared for SEA, birthCountry != 'USA'
-- ============================================================
CREATE OR REPLACE VIEW giants_international_players AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    p.birthCountry,
    p.birthState,
    p.birthCity,
    MIN(a.yearID)                                              AS first_sea_year,
    MAX(a.yearID)                                              AS last_sea_year,
    SUM(COALESCE(a.G_all, 0))                                 AS sea_games
FROM people p
JOIN appearances a ON a.playerID = p.playerID
WHERE a.teamID = 'SFN'
  AND p.birthCountry != 'USA'
  AND p.birthCountry IS NOT NULL
GROUP BY p.playerID, p.nameFirst, p.nameLast,
         p.birthCountry, p.birthState, p.birthCity
ORDER BY p.birthCountry, p.nameLast;

-- ============================================================
-- View 78: giants_player_tenure
-- Purpose: Length of each player's Giants tenure.
-- Key formulas: COUNT(DISTINCT yearID), span of years.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_player_tenure AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    MIN(a.yearID)                                              AS first_year,
    MAX(a.yearID)                                              AS last_year,
    COUNT(DISTINCT a.yearID)                                   AS seasons,
    (MAX(a.yearID) - MIN(a.yearID) + 1)                       AS year_span,
    SUM(COALESCE(a.G_all, 0))                                 AS total_games,
    RANK() OVER (ORDER BY COUNT(DISTINCT a.yearID) DESC)      AS tenure_rank
FROM appearances a
JOIN people p ON p.playerID = a.playerID
WHERE a.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast
ORDER BY seasons DESC, total_games DESC;

-- ============================================================
-- View 79: giants_debut_players
-- Purpose: Players whose MLB debut was with the Giants.
-- Key formulas: Player's first year in batting/pitching matches
--   their first year with SEA.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_debut_players AS
WITH first_mlb AS (
    SELECT playerID, MIN(yearID) AS debut_year
    FROM appearances
    GROUP BY playerID
),
first_sea AS (
    SELECT playerID, MIN(yearID) AS sea_debut
    FROM appearances
    WHERE teamID = 'SFN'
    GROUP BY playerID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    fm.debut_year,
    p.birthCountry,
    p.birthState,
    CASE
        WHEN EXISTS (SELECT 1 FROM appearances a2
                     WHERE a2.playerID = p.playerID
                       AND a2.teamID = 'SFN'
                       AND COALESCE(a2.G_p, 0) >= 0.5 * COALESCE(a2.G_all, 1))
            THEN 'Pitcher'
        ELSE 'Position Player'
    END                                                        AS player_type
FROM first_mlb fm
JOIN first_sea fs ON fs.playerID = fm.playerID
JOIN people p ON p.playerID = fm.playerID
WHERE fm.debut_year = fs.sea_debut
ORDER BY fm.debut_year DESC, p.nameLast;

-- ============================================================
-- View 80: giants_player_ages
-- Purpose: Age distribution of Giants rosters by year.
-- Key formulas: age = yearID - birthYear.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_player_ages AS
SELECT
    a.yearID,
    COUNT(DISTINCT a.playerID)                                 AS roster_size,
    ROUND(AVG(a.yearID - p.birthYear), 1)                     AS avg_age,
    MIN(a.yearID - p.birthYear)                                AS youngest,
    MAX(a.yearID - p.birthYear)                                AS oldest
FROM appearances a
JOIN people p ON p.playerID = a.playerID
WHERE a.teamID = 'SFN'
  AND p.birthYear IS NOT NULL
GROUP BY a.yearID
ORDER BY a.yearID;

-- ============================================================
-- View 81: giants_team_batting_by_year
-- Purpose: Team-level batting aggregates by year from the
--          teams table.
-- Key formulas: R/G, HR, BA proxy, OBP-like, SLG-like, OPS.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_team_batting_by_year AS
SELECT
    t.yearID,
    t.G,
    t.W,
    t.L,
    t.R,
    ROUND(t.R / NULLIF(t.G, 0), 2)                            AS runs_per_game,
    t.AB,
    t.H,
    t.`2B`,
    t.`3B`,
    t.HR,
    t.BB,
    t.SO,
    t.SB,
    t.CS,
    ROUND(t.H / NULLIF(t.AB, 0), 3)                           AS team_AVG,
    ROUND(
        (t.H + t.BB + COALESCE(t.HBP, 0))
        / NULLIF(t.AB + t.BB + COALESCE(t.HBP, 0) + COALESCE(t.SF, 0), 0), 3
    )                                                          AS team_OBP,
    ROUND(
        (t.H + t.`2B` + 2 * t.`3B` + 3 * t.HR)
        / NULLIF(t.AB, 0), 3
    )                                                          AS team_SLG,
    ROUND(
        (t.H + t.BB + COALESCE(t.HBP, 0))
        / NULLIF(t.AB + t.BB + COALESCE(t.HBP, 0) + COALESCE(t.SF, 0), 0)
        + (t.H + t.`2B` + 2 * t.`3B` + 3 * t.HR)
          / NULLIF(t.AB, 0), 3
    )                                                          AS team_OPS
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY t.yearID;

-- ============================================================
-- View 82: giants_team_pitching_by_year
-- Purpose: Team-level pitching aggregates by year from the
--          teams table.
-- Key formulas: ERA, WHIP, K/9 at team level.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_team_pitching_by_year AS
SELECT
    t.yearID,
    t.G,
    t.W,
    t.L,
    t.RA,
    ROUND(t.RA / NULLIF(t.G, 0), 2)                           AS ra_per_game,
    t.ERA,
    ROUND(t.IPouts / 3.0, 1)                                  AS IP,
    t.CG,
    t.SHO,
    t.SV,
    t.HA                                                       AS H_allowed,
    t.HRA                                                      AS HR_allowed,
    t.BBA                                                      AS BB_allowed,
    t.SOA                                                      AS SO_recorded,
    ROUND(
        (COALESCE(t.BBA, 0) + COALESCE(t.HA, 0))
        / NULLIF(t.IPouts / 3.0, 0), 3
    )                                                          AS team_WHIP,
    ROUND(9.0 * COALESCE(t.SOA, 0) / NULLIF(t.IPouts / 3.0, 0), 2) AS team_K_per_9,
    ROUND(9.0 * COALESCE(t.BBA, 0) / NULLIF(t.IPouts / 3.0, 0), 2) AS team_BB_per_9,
    t.FP                                                       AS team_Fld_pct,
    t.E                                                        AS team_errors
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY t.yearID;

-- ============================================================
-- View 83: giants_best_seasons
-- Purpose: Best Giants team seasons ranked by win percentage.
-- Key formulas: W%, run differential, Pythagorean record.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_best_seasons AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.R,
    t.RA,
    (t.R - t.RA)                                               AS run_diff,
    t.DivWin,
    t.WCWin,
    t.LgWin,
    t.WSWin,
    t.attendance,
    RANK() OVER (ORDER BY t.W / NULLIF(t.W + t.L, 0) DESC)   AS season_rank
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY W_pct DESC;

-- ============================================================
-- View 84: giants_worst_seasons
-- Purpose: Worst Giants team seasons ranked by win percentage.
-- Key formulas: W%, run differential.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_worst_seasons AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    t.R,
    t.RA,
    (t.R - t.RA)                                               AS run_diff,
    t.teamRank,
    t.attendance,
    RANK() OVER (ORDER BY t.W / NULLIF(t.W + t.L, 0) ASC)    AS season_rank
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY W_pct ASC;

-- ============================================================
-- View 85: giants_win_pct_trend
-- Purpose: Win percentage trend with 3-year rolling average.
-- Key formulas: W%, rolling 3-year AVG.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_win_pct_trend AS
SELECT
    t.yearID,
    t.W,
    t.L,
    ROUND(t.W / NULLIF(t.W + t.L, 0), 3)                     AS W_pct,
    ROUND(
        AVG(t.W / NULLIF(t.W + t.L, 0))
        OVER (ORDER BY t.yearID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 3
    )                                                          AS rolling_3yr_W_pct,
    (t.R - t.RA)                                               AS run_diff,
    t.DivWin,
    t.WCWin
FROM teams t
WHERE t.teamID = 'SFN'
ORDER BY t.yearID;

-- ============================================================
-- View 86: giants_era_comparison
-- Purpose: Compare Giants performance across different eras.
-- Key formulas: W%, R/G, HR/G, ERA, attendance avg by era.
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_era_comparison AS
SELECT
    CASE
        WHEN t.yearID BETWEEN 1977 AND 1993 THEN 'Early Years (1977-1993)'
        WHEN t.yearID BETWEEN 1994 AND 2005 THEN 'Golden Era (1994-2005)'
        WHEN t.yearID BETWEEN 2006 AND 2015 THEN 'Rebuild (2006-2015)'
        WHEN t.yearID >= 2016                THEN 'Modern (2016+)'
    END                                                        AS era_name,
    COUNT(*)                                                   AS seasons,
    SUM(t.W)                                                   AS total_W,
    SUM(t.L)                                                   AS total_L,
    ROUND(SUM(t.W) / NULLIF(SUM(t.W) + SUM(t.L), 0), 3)      AS W_pct,
    ROUND(SUM(t.R) / NULLIF(SUM(t.G), 0), 2)                  AS runs_per_game,
    ROUND(SUM(t.HR) / NULLIF(SUM(t.G), 0), 2)                 AS hr_per_game,
    ROUND(SUM(t.RA) / NULLIF(SUM(t.G), 0), 2)                 AS ra_per_game,
    ROUND(AVG(t.ERA), 2)                                       AS avg_ERA,
    SUM(CASE WHEN t.DivWin = 'Y' THEN 1 ELSE 0 END)          AS div_titles,
    SUM(CASE WHEN t.WCWin = 'Y' THEN 1 ELSE 0 END)           AS wc_berths,
    ROUND(AVG(t.attendance), 0)                                AS avg_attendance
FROM teams t
WHERE t.teamID = 'SFN'
GROUP BY era_name
ORDER BY MIN(t.yearID);

-- ============================================================
-- View 87: giants_players_also_played_for
-- Purpose: Giants players who also played for other teams,
--          showing which other teams they played for.
-- Key formulas: GROUP_CONCAT of non-SEA teamIDs.
-- Qualifiers: Players who appeared for SEA
-- ============================================================
CREATE OR REPLACE VIEW giants_players_also_played_for AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT CASE WHEN a.teamID = 'SFN' THEN a.yearID END) AS sea_seasons,
    COUNT(DISTINCT CASE WHEN a.teamID != 'SFN' THEN a.teamID END) AS other_teams_count,
    GROUP_CONCAT(DISTINCT CASE WHEN a.teamID != 'SFN' THEN a.teamID END
                 ORDER BY a.teamID SEPARATOR ', ')             AS other_teams
FROM appearances a
JOIN people p ON p.playerID = a.playerID
WHERE EXISTS (
    SELECT 1 FROM appearances a2
    WHERE a2.playerID = a.playerID AND a2.teamID = 'SFN'
)
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING COUNT(DISTINCT CASE WHEN a.teamID != 'SFN' THEN a.teamID END) > 0
ORDER BY other_teams_count DESC;

-- ============================================================
-- View 88: giants_career_arc_batting
-- Purpose: Age-bucket batting arcs for Giants players showing
--          performance by age group (Giants stints only).
-- Key formulas: AVG/OBP/SLG/OPS by age bucket.
-- Qualifiers: teamID = 'SFN', career PA >= 500 for the Giants
-- ============================================================
CREATE OR REPLACE VIEW giants_career_arc_batting AS
WITH player_seasons AS (
    SELECT
        b.playerID,
        b.yearID,
        (b.yearID - p.birthYear)                               AS age,
        SUM(b.AB) AS AB, SUM(b.H) AS H,
        SUM(COALESCE(b.BB, 0)) AS BB, SUM(COALESCE(b.HBP, 0)) AS HBP,
        SUM(COALESCE(b.SF, 0)) AS SF,
        SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`, SUM(b.HR) AS HR,
        SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
            + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA
    FROM batting b
    JOIN people p ON p.playerID = b.playerID
    WHERE b.teamID = 'SFN' AND p.birthYear IS NOT NULL
    GROUP BY b.playerID, b.yearID, p.birthYear
),
career_pa AS (
    SELECT playerID, SUM(PA) AS total_PA
    FROM player_seasons
    GROUP BY playerID
    HAVING SUM(PA) >= 500
)
SELECT
    ps.playerID,
    pe.nameFirst,
    pe.nameLast,
    CASE
        WHEN ps.age < 25 THEN '20-24'
        WHEN ps.age BETWEEN 25 AND 29 THEN '25-29'
        WHEN ps.age BETWEEN 30 AND 34 THEN '30-34'
        WHEN ps.age BETWEEN 35 AND 39 THEN '35-39'
        WHEN ps.age >= 40 THEN '40+'
    END                                                        AS age_bucket,
    SUM(ps.PA) AS bucket_PA,
    SUM(ps.HR) AS bucket_HR,
    ROUND(SUM(ps.H) / NULLIF(SUM(ps.AB), 0), 3)               AS AVG,
    ROUND(
        (SUM(ps.H) + SUM(ps.BB) + SUM(ps.HBP))
        / NULLIF(SUM(ps.AB) + SUM(ps.BB) + SUM(ps.HBP) + SUM(ps.SF), 0), 3
    )                                                          AS OBP,
    ROUND(
        (SUM(ps.H) + SUM(ps.`2B`) + 2 * SUM(ps.`3B`) + 3 * SUM(ps.HR))
        / NULLIF(SUM(ps.AB), 0), 3
    )                                                          AS SLG,
    ROUND(
        (SUM(ps.H) + SUM(ps.BB) + SUM(ps.HBP))
        / NULLIF(SUM(ps.AB) + SUM(ps.BB) + SUM(ps.HBP) + SUM(ps.SF), 0)
        + (SUM(ps.H) + SUM(ps.`2B`) + 2 * SUM(ps.`3B`) + 3 * SUM(ps.HR))
          / NULLIF(SUM(ps.AB), 0), 3
    )                                                          AS OPS
FROM player_seasons ps
JOIN career_pa cp ON cp.playerID = ps.playerID
JOIN people pe ON pe.playerID = ps.playerID
GROUP BY ps.playerID, pe.nameFirst, pe.nameLast, age_bucket
HAVING SUM(ps.AB) > 0
ORDER BY ps.playerID, age_bucket;

-- ============================================================
-- View 89: giants_high_k_rate_pitcher_seasons
-- Purpose: Giants pitcher seasons with the highest strikeout
--          rates (K%, min 50 IP).
-- Key formulas: K% = SO/BFP, K/9.
-- Qualifiers: teamID = 'SFN', IPouts >= 150
-- ============================================================
CREATE OR REPLACE VIEW giants_high_k_rate_pitcher_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    SUM(pi.SO)                                                 AS SO,
    ROUND(SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0), 3) AS K_pct,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    SUM(pi.W) AS W, SUM(pi.L) AS L,
    RANK() OVER (ORDER BY
        SUM(pi.SO) / NULLIF(SUM(COALESCE(pi.BFP, 0)), 0) DESC
    )                                                          AS k_rate_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 150
ORDER BY K_pct DESC;

-- ============================================================
-- View 90: giants_low_era_relief_seasons
-- Purpose: Best ERA seasons by Giants relievers (min 30 IP,
--          GS < 3).
-- Key formulas: ERA, WHIP, K/9 for relief-only seasons.
-- Qualifiers: teamID = 'SFN', IPouts >= 90, GS < 3
-- ============================================================
CREATE OR REPLACE VIEW giants_low_era_relief_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pi.yearID,
    SUM(pi.G)                                                  AS G,
    SUM(pi.GS)                                                 AS GS,
    SUM(COALESCE(pi.SV, 0))                                    AS SV,
    ROUND(SUM(pi.IPouts) / 3.0, 1)                            AS IP,
    ROUND(9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS ERA,
    ROUND(
        (SUM(COALESCE(pi.BB, 0)) + SUM(pi.H))
        / NULLIF(SUM(pi.IPouts) / 3.0, 0), 3
    )                                                          AS WHIP,
    ROUND(9.0 * SUM(pi.SO) / NULLIF(SUM(pi.IPouts) / 3.0, 0), 2) AS K_per_9,
    RANK() OVER (ORDER BY
        9.0 * SUM(pi.ER) / NULLIF(SUM(pi.IPouts) / 3.0, 0) ASC
    )                                                          AS era_rank
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, pi.yearID
HAVING SUM(pi.IPouts) >= 90 AND SUM(pi.GS) < 3
ORDER BY ERA ASC;

-- ============================================================
-- View 91: giants_season_batting_ops_plus
-- Purpose: Season OPS+ for Giants hitters using dynamic
--          league averages (PA >= 300).
-- Key formulas: OPS+ = 100*(OBP/lgOBP + SLG/lgSLG - 1)
-- Qualifiers: teamID = 'SFN', PA >= 300
-- ============================================================
CREATE OR REPLACE VIEW giants_season_batting_ops_plus AS
WITH season_bat AS (
    SELECT
        b.playerID, b.yearID, b.lgID,
        SUM(b.AB) AS AB, SUM(b.H) AS H,
        SUM(COALESCE(b.BB, 0)) AS BB, SUM(COALESCE(b.HBP, 0)) AS HBP,
        SUM(COALESCE(b.SF, 0)) AS SF, SUM(COALESCE(b.SH, 0)) AS SH,
        SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`, SUM(b.HR) AS HR,
        SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
            + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA
    FROM batting b
    WHERE b.teamID = 'SFN'
    GROUP BY b.playerID, b.yearID, b.lgID
),
league_avg AS (
    SELECT yearID, lgID,
        (SUM(H) + SUM(COALESCE(BB, 0)) + SUM(COALESCE(HBP, 0)))
        / NULLIF(SUM(AB) + SUM(COALESCE(BB, 0)) + SUM(COALESCE(HBP, 0))
                 + SUM(COALESCE(SF, 0)), 0) AS lgOBP,
        (SUM(H) + SUM(`2B`) + 2 * SUM(`3B`) + 3 * SUM(HR))
        / NULLIF(SUM(AB), 0) AS lgSLG
    FROM batting
    WHERE lgID IN ('AL', 'NL')
    GROUP BY yearID, lgID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    sb.yearID,
    sb.PA,
    ROUND(sb.H / NULLIF(sb.AB, 0), 3)                         AS AVG,
    ROUND(
        (sb.H + sb.BB + sb.HBP)
        / NULLIF(sb.AB + sb.BB + sb.HBP + sb.SF, 0), 3
    )                                                          AS OBP,
    ROUND(
        (sb.H + sb.`2B` + 2 * sb.`3B` + 3 * sb.HR)
        / NULLIF(sb.AB, 0), 3
    )                                                          AS SLG,
    ROUND(
        100 * (
            (sb.H + sb.BB + sb.HBP) / NULLIF(sb.AB + sb.BB + sb.HBP + sb.SF, 0) / la.lgOBP
          + (sb.H + sb.`2B` + 2 * sb.`3B` + 3 * sb.HR) / NULLIF(sb.AB, 0) / la.lgSLG
          - 1
        ), 1
    )                                                          AS OPS_plus,
    sb.HR,
    RANK() OVER (ORDER BY
        100 * (
            (sb.H + sb.BB + sb.HBP) / NULLIF(sb.AB + sb.BB + sb.HBP + sb.SF, 0) / la.lgOBP
          + (sb.H + sb.`2B` + 2 * sb.`3B` + 3 * sb.HR) / NULLIF(sb.AB, 0) / la.lgSLG
          - 1
        ) DESC
    )                                                          AS ops_plus_rank
FROM season_bat sb
JOIN league_avg la ON la.yearID = sb.yearID AND la.lgID = sb.lgID
JOIN people p ON p.playerID = sb.playerID
WHERE sb.PA >= 300 AND la.lgOBP > 0 AND la.lgSLG > 0
ORDER BY OPS_plus DESC;

-- ============================================================
-- View 92: giants_season_pitching_era_plus
-- Purpose: Season ERA+ for Giants pitchers using dynamic
--          league ERA (IPouts >= 150).
-- Key formulas: ERA+ = 100 * (lgERA / playerERA)
-- Qualifiers: teamID = 'SFN', IPouts >= 150
-- ============================================================
CREATE OR REPLACE VIEW giants_season_pitching_era_plus AS
WITH season_pitch AS (
    SELECT
        pi.playerID, pi.yearID, pi.lgID,
        SUM(pi.IPouts) AS IPouts, SUM(pi.ER) AS ER,
        SUM(pi.W) AS W, SUM(pi.L) AS L,
        SUM(pi.SO) AS SO
    FROM pitching pi
    WHERE pi.teamID = 'SFN'
    GROUP BY pi.playerID, pi.yearID, pi.lgID
),
league_era AS (
    SELECT yearID, lgID,
        9.0 * SUM(ER) / NULLIF(SUM(IPouts) / 3.0, 0) AS lgERA
    FROM pitching
    WHERE lgID IN ('AL', 'NL')
    GROUP BY yearID, lgID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    sp.yearID,
    ROUND(sp.IPouts / 3.0, 1)                                 AS IP,
    ROUND(9.0 * sp.ER / NULLIF(sp.IPouts / 3.0, 0), 2)       AS ERA,
    ROUND(le.lgERA, 2)                                        AS lgERA,
    ROUND(
        CASE WHEN sp.ER > 0 AND sp.IPouts > 0
             THEN 100.0 * le.lgERA / (9.0 * sp.ER / (sp.IPouts / 3.0))
             ELSE NULL
        END, 1
    )                                                          AS ERA_plus,
    sp.W, sp.L, sp.SO,
    RANK() OVER (ORDER BY
        CASE WHEN sp.ER > 0 AND sp.IPouts > 0
             THEN 100.0 * le.lgERA / (9.0 * sp.ER / (sp.IPouts / 3.0))
             ELSE NULL
        END DESC
    )                                                          AS era_plus_rank
FROM season_pitch sp
JOIN league_era le ON le.yearID = sp.yearID AND le.lgID = sp.lgID
JOIN people p ON p.playerID = sp.playerID
WHERE sp.IPouts >= 150 AND sp.ER > 0
ORDER BY ERA_plus DESC;

-- ============================================================
-- View 93: giants_season_woba_leaders
-- Purpose: Top single-season wOBA for Giants hitters.
-- Key formulas: wOBA with linear weights.
-- Qualifiers: teamID = 'SFN', PA >= 300
-- ============================================================
CREATE OR REPLACE VIEW giants_season_woba_leaders AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    ROUND(
        (0.69 * (SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0)))
         + 0.72 * SUM(COALESCE(b.HBP, 0))
         + 0.87 * (SUM(b.H) - SUM(b.`2B`) - SUM(b.`3B`) - SUM(b.HR))
         + 1.22 * SUM(b.`2B`) + 1.56 * SUM(b.`3B`) + 1.95 * SUM(b.HR))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.HBP, 0)), 0), 3
    )                                                          AS wOBA,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(b.HR)                                                  AS HR,
    SUM(COALESCE(b.RBI, 0))                                    AS RBI,
    RANK() OVER (ORDER BY
        (0.69 * (SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0)))
         + 0.72 * SUM(COALESCE(b.HBP, 0))
         + 0.87 * (SUM(b.H) - SUM(b.`2B`) - SUM(b.`3B`) - SUM(b.HR))
         + 1.22 * SUM(b.`2B`) + 1.56 * SUM(b.`3B`) + 1.95 * SUM(b.HR))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0)) - SUM(COALESCE(b.IBB, 0))
                 + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.HBP, 0)), 0) DESC
    )                                                          AS woba_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0))) >= 300
ORDER BY wOBA DESC;

-- ============================================================
-- View 94: giants_multi_award_winners
-- Purpose: Giants players who won multiple different awards
--          while with the team.
-- Key formulas: COUNT(DISTINCT awardID), list of awards.
-- Qualifiers: Player on SEA roster, 2+ distinct awards
-- ============================================================
CREATE OR REPLACE VIEW giants_multi_award_winners AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    COUNT(DISTINCT ap.awardID)                                 AS distinct_awards,
    COUNT(*)                                                   AS total_awards,
    GROUP_CONCAT(DISTINCT ap.awardID ORDER BY ap.awardID SEPARATOR ', ') AS award_list,
    MIN(ap.yearID)                                             AS first_award_year,
    MAX(ap.yearID)                                             AS last_award_year
FROM awardsplayers ap
JOIN people p ON p.playerID = ap.playerID
WHERE EXISTS (
    SELECT 1 FROM batting b
    WHERE b.playerID = ap.playerID
      AND b.yearID = ap.yearID
      AND b.teamID = 'SFN'
    UNION ALL
    SELECT 1 FROM pitching pi
    WHERE pi.playerID = ap.playerID
      AND pi.yearID = ap.yearID
      AND pi.teamID = 'SFN'
)
GROUP BY p.playerID, p.nameFirst, p.nameLast
HAVING COUNT(DISTINCT ap.awardID) >= 2
ORDER BY distinct_awards DESC, total_awards DESC;

-- ============================================================
-- View 95: giants_high_obp_seasons
-- Purpose: Giants seasons with OBP >= .370 (qualified).
-- Key formulas: OBP = (H+BB+HBP)/(AB+BB+HBP+SF)
-- Qualifiers: teamID = 'SFN', PA >= 400, OBP >= .370
-- ============================================================
CREATE OR REPLACE VIEW giants_high_obp_seasons AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    b.yearID,
    ROUND(
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0), 3
    )                                                          AS OBP,
    ROUND(SUM(b.H) / NULLIF(SUM(b.AB), 0), 3)                 AS AVG,
    SUM(COALESCE(b.BB, 0))                                     AS BB,
    SUM(COALESCE(b.HBP, 0))                                    AS HBP,
    SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
              + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
    RANK() OVER (ORDER BY
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0) DESC
    )                                                          AS obp_rank
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, b.yearID
HAVING (SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
       + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0))) >= 400
   AND (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
       / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0) >= 0.370
ORDER BY OBP DESC;

-- ============================================================
-- View 96: giants_salary_by_position
-- Purpose: Average salary by primary position for Giants.
-- Key formulas: AVG(salary) grouped by primary position.
-- Qualifiers: teamID = 'SFN', salary data available
-- ============================================================
CREATE OR REPLACE VIEW giants_salary_by_position AS
WITH sea_pos AS (
    SELECT a.playerID, a.yearID,
        CASE
            WHEN COALESCE(a.G_p, 0) >= GREATEST(COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN 'P'
            WHEN COALESCE(a.G_c, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN 'C'
            WHEN COALESCE(a.G_1b, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN '1B'
            WHEN COALESCE(a.G_2b, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN '2B'
            WHEN COALESCE(a.G_3b, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN '3B'
            WHEN COALESCE(a.G_ss, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN 'SS'
            WHEN COALESCE(a.G_cf, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN 'CF'
            WHEN COALESCE(a.G_rf, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_dh, 0)) THEN 'RF'
            WHEN COALESCE(a.G_lf, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0), COALESCE(a.G_dh, 0)) THEN 'LF'
            WHEN COALESCE(a.G_dh, 0) >= GREATEST(COALESCE(a.G_p, 0), COALESCE(a.G_c, 0), COALESCE(a.G_1b, 0), COALESCE(a.G_2b, 0), COALESCE(a.G_3b, 0), COALESCE(a.G_ss, 0), COALESCE(a.G_lf, 0), COALESCE(a.G_cf, 0), COALESCE(a.G_rf, 0)) THEN 'DH'
            ELSE 'OF'
        END AS pos
    FROM appearances a
    WHERE a.teamID = 'SFN'
)
SELECT
    sp.pos                                                     AS position,
    COUNT(*)                                                   AS player_seasons,
    ROUND(AVG(s.salary), 0)                                    AS avg_salary,
    MAX(s.salary)                                              AS max_salary,
    ROUND(SUM(s.salary), 0)                                    AS total_salary
FROM salaries s
JOIN sea_pos sp ON sp.playerID = s.playerID AND sp.yearID = s.yearID
WHERE s.teamID = 'SFN'
GROUP BY sp.pos
ORDER BY avg_salary DESC;

-- ============================================================
-- View 97: giants_postseason_fielding
-- Purpose: Postseason fielding stats for Giants.
-- Key formulas: Fld% = (PO+A)/(PO+A+E)
-- Qualifiers: teamID = 'SFN'
-- ============================================================
CREATE OR REPLACE VIEW giants_postseason_fielding AS
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    fp.yearID,
    fp.round,
    fp.POS,
    SUM(fp.G)                                                  AS G,
    SUM(fp.PO)                                                 AS PO,
    SUM(fp.A)                                                  AS A,
    SUM(fp.E)                                                  AS E,
    ROUND(
        (SUM(fp.PO) + SUM(fp.A))
        / NULLIF(SUM(fp.PO) + SUM(fp.A) + SUM(fp.E), 0), 4
    )                                                          AS Fld_pct
FROM fieldingpost fp
JOIN people p ON p.playerID = fp.playerID
WHERE fp.teamID = 'SFN'
GROUP BY p.playerID, p.nameFirst, p.nameLast, fp.yearID, fp.round, fp.POS
ORDER BY fp.yearID, fp.round, fp.POS;

-- ============================================================
-- View 98: giants_composite_player_value
-- Purpose: Composite player value score for Giants hitters
--          combining OPS, counting stats, and longevity.
-- Key formulas:
--   Score = (OPS/0.800)*30 + (HR/200)*15 + (H/1000)*15
--         + (SB/100)*10 + (seasons/10)*15 + (AllStar/5)*15
-- Qualifiers: teamID = 'SFN', PA >= 1000
-- ============================================================
CREATE OR REPLACE VIEW giants_composite_player_value AS
WITH career AS (
    SELECT
        b.playerID,
        SUM(b.AB) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0))
                   + SUM(COALESCE(b.SF, 0)) + SUM(COALESCE(b.SH, 0)) AS PA,
        SUM(b.H) AS H, SUM(b.HR) AS HR,
        SUM(COALESCE(b.SB, 0)) AS SB,
        COUNT(DISTINCT b.yearID) AS seasons,
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0) AS OPS
    FROM batting b
    WHERE b.teamID = 'SFN'
    GROUP BY b.playerID
),
allstars AS (
    SELECT playerID, COUNT(DISTINCT yearID) AS allstar_cnt
    FROM allstarfull
    WHERE teamID = 'SFN'
    GROUP BY playerID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    c.PA,
    ROUND(c.OPS, 3) AS OPS,
    c.HR, c.H, c.SB, c.seasons,
    COALESCE(a.allstar_cnt, 0) AS allstar_appearances,
    ROUND(
        COALESCE(c.OPS / 0.800, 0) * 30
      + LEAST(c.HR / 200.0, 2.0) * 15
      + LEAST(c.H / 1000.0, 2.0) * 15
      + LEAST(c.SB / 100.0, 2.0) * 10
      + LEAST(c.seasons / 10.0, 2.0) * 15
      + LEAST(COALESCE(a.allstar_cnt, 0) / 5.0, 2.0) * 15, 1
    )                                                          AS composite_score,
    RANK() OVER (ORDER BY
        COALESCE(c.OPS / 0.800, 0) * 30
      + LEAST(c.HR / 200.0, 2.0) * 15
      + LEAST(c.H / 1000.0, 2.0) * 15
      + LEAST(c.SB / 100.0, 2.0) * 10
      + LEAST(c.seasons / 10.0, 2.0) * 15
      + LEAST(COALESCE(a.allstar_cnt, 0) / 5.0, 2.0) * 15 DESC
    )                                                          AS value_rank
FROM career c
JOIN people p ON p.playerID = c.playerID
LEFT JOIN allstars a ON a.playerID = c.playerID
WHERE c.PA >= 1000
ORDER BY composite_score DESC;

-- ============================================================
-- View 99: giants_all_time_best_by_position
-- Purpose: Best Giants at each position by career OPS
--          (min 200 G at that position for the Giants).
-- Key formulas: OPS, games at position from fielding.
-- Qualifiers: teamID = 'SFN', G at position >= 200
-- ============================================================
CREATE OR REPLACE VIEW giants_all_time_best_by_position AS
WITH pos_games AS (
    SELECT f.playerID, f.POS, SUM(f.G) AS G_at_pos
    FROM fielding f
    WHERE f.teamID = 'SFN'
    GROUP BY f.playerID, f.POS
    HAVING SUM(f.G) >= 200
),
player_ops AS (
    SELECT
        b.playerID,
        SUM(b.AB) AS AB, SUM(b.H) AS H,
        SUM(b.HR) AS HR,
        SUM(COALESCE(b.BB, 0)) AS BB,
        SUM(COALESCE(b.HBP, 0)) AS HBP,
        SUM(COALESCE(b.SF, 0)) AS SF,
        SUM(b.`2B`) AS `2B`, SUM(b.`3B`) AS `3B`,
        (SUM(b.H) + SUM(COALESCE(b.BB, 0)) + SUM(COALESCE(b.HBP, 0)))
        / NULLIF(SUM(b.AB) + SUM(COALESCE(b.BB, 0))
                 + SUM(COALESCE(b.HBP, 0)) + SUM(COALESCE(b.SF, 0)), 0)
        + (SUM(b.H) + SUM(b.`2B`) + 2 * SUM(b.`3B`) + 3 * SUM(b.HR))
          / NULLIF(SUM(b.AB), 0) AS OPS
    FROM batting b
    WHERE b.teamID = 'SFN'
    GROUP BY b.playerID
)
SELECT
    pg.POS,
    p.playerID,
    p.nameFirst,
    p.nameLast,
    pg.G_at_pos,
    po.AB,
    po.HR,
    ROUND(po.H / NULLIF(po.AB, 0), 3)                         AS AVG,
    ROUND(po.OPS, 3)                                           AS OPS,
    ROW_NUMBER() OVER (PARTITION BY pg.POS
                       ORDER BY po.OPS DESC)                   AS pos_rank
FROM pos_games pg
JOIN player_ops po ON po.playerID = pg.playerID
JOIN people p ON p.playerID = pg.playerID
ORDER BY pg.POS, pos_rank;

-- ============================================================
-- View 100: giants_hall_of_fame_monitor
-- Purpose: HOF-relevant stats for Giants players: career
--          totals, awards, all-star appearances, and whether
--          the player is primarily a batter or pitcher.
-- Key formulas: Career batting/pitching aggregates plus awards
--   and all-star data (Giants stints only).
-- Qualifiers: PA >= 1000 OR IP >= 300 for the Giants
-- ============================================================
CREATE OR REPLACE VIEW giants_hall_of_fame_monitor AS
WITH bat_career AS (
    SELECT playerID,
        SUM(AB) AS AB, SUM(H) AS H, SUM(HR) AS HR,
        SUM(COALESCE(RBI, 0)) AS RBI,
        SUM(AB) + SUM(COALESCE(BB, 0)) + SUM(COALESCE(HBP, 0))
                + SUM(COALESCE(SF, 0)) + SUM(COALESCE(SH, 0)) AS PA,
        ROUND(SUM(H) / NULLIF(SUM(AB), 0), 3) AS AVG,
        ROUND(
            (SUM(H) + SUM(COALESCE(BB, 0)) + SUM(COALESCE(HBP, 0)))
            / NULLIF(SUM(AB) + SUM(COALESCE(BB, 0))
                     + SUM(COALESCE(HBP, 0)) + SUM(COALESCE(SF, 0)), 0)
            + (SUM(H) + SUM(`2B`) + 2 * SUM(`3B`) + 3 * SUM(HR))
              / NULLIF(SUM(AB), 0), 3
        ) AS OPS
    FROM batting WHERE teamID = 'SFN'
    GROUP BY playerID
),
pitch_career AS (
    SELECT playerID,
        SUM(W) AS W, SUM(L) AS L,
        SUM(COALESCE(SV, 0)) AS SV,
        ROUND(SUM(IPouts) / 3.0, 1) AS IP,
        SUM(SO) AS SO,
        ROUND(9.0 * SUM(ER) / NULLIF(SUM(IPouts) / 3.0, 0), 2) AS ERA,
        SUM(IPouts) AS IPouts
    FROM pitching WHERE teamID = 'SFN'
    GROUP BY playerID
),
awards AS (
    SELECT ap.playerID, COUNT(*) AS award_cnt
    FROM awardsplayers ap
    WHERE EXISTS (
        SELECT 1 FROM batting b WHERE b.playerID = ap.playerID
            AND b.yearID = ap.yearID AND b.teamID = 'SFN'
        UNION ALL
        SELECT 1 FROM pitching pi WHERE pi.playerID = ap.playerID
            AND pi.yearID = ap.yearID AND pi.teamID = 'SFN'
    )
    GROUP BY ap.playerID
),
allstars AS (
    SELECT playerID, COUNT(DISTINCT yearID) AS allstar_cnt
    FROM allstarfull WHERE teamID = 'SFN'
    GROUP BY playerID
),
hof AS (
    SELECT playerID,
        MAX(CASE WHEN inducted = 'Y' THEN 'Y' ELSE 'N' END) AS inducted
    FROM halloffame
    GROUP BY playerID
)
SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    CASE WHEN COALESCE(bc.PA, 0) >= COALESCE(pc.IPouts, 0) THEN 'Batter' ELSE 'Pitcher' END AS player_type,
    bc.PA, bc.AVG, bc.OPS, bc.HR AS bat_HR, bc.RBI,
    pc.W, pc.L, pc.SV, pc.ERA, pc.IP, pc.SO,
    COALESCE(aw.award_cnt, 0) AS total_awards,
    COALESCE(ast.allstar_cnt, 0) AS allstar_games,
    COALESCE(h.inducted, 'N') AS hof_inducted
FROM people p
LEFT JOIN bat_career bc ON bc.playerID = p.playerID
LEFT JOIN pitch_career pc ON pc.playerID = p.playerID
LEFT JOIN awards aw ON aw.playerID = p.playerID
LEFT JOIN allstars ast ON ast.playerID = p.playerID
LEFT JOIN hof h ON h.playerID = p.playerID
WHERE COALESCE(bc.PA, 0) >= 1000 OR COALESCE(pc.IPouts, 0) >= 900
ORDER BY COALESCE(ast.allstar_cnt, 0) DESC,
         COALESCE(bc.PA, 0) + COALESCE(pc.IPouts, 0) DESC;
