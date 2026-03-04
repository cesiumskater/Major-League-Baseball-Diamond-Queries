-- Begin Supplemental Indexes, Functions, Procedures, Triggers, and Events --
--   DROP INDEX will create errors on first run through. They are run are harmless (MySQL 1091);
--   DBVisualizer continues and the CREATE INDEX succeeds.
--
-- NOTE ON Foreign Key-BACKED INDEXES (A01, A05, A10, A13, A14, A16, A18, A20,
--   A22, A24, A26, A27, A28, A29, A42, A43, A44, A45, A49, A50, A51):
--   MySQL creates these automatically when the foreign key is defined.
--   They cannot be dropped while the Foreign Key exists (Error 1553), and they
--   already carry the correct name and column set, therefore no further action is needed.

-- SECTION A: ADDITIONAL PERFORMANCE INDEXES
-- 52 indexes covering Foreign Key columns, leaderboard
-- queries, and frequently filtered columns that are
-- not covered by the indexes in the base procedures file.

--  A01 batting: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema.
-- No further action needed (dropping it would require removing the Foreign Key first).

--  A02 batting: HR leaderboard 
-- Covers yearID + lgID filter, returns HR + playerID
-- without touching the clustered row. Used by
-- Yearly_HR_Leaders, sp_league_leaders_batting.

DROP INDEX idx_batting_yr_lg_hr ON batting;
CREATE INDEX idx_batting_yr_lg_hr ON batting (yearID, lgID, HR, playerID);

--  A03 batting: RBI leaderboard 
DROP INDEX idx_batting_yr_lg_rbi ON batting;
CREATE INDEX idx_batting_yr_lg_rbi ON batting (yearID, lgID, RBI, playerID);

--  A04 batting: SB leaderboard 
DROP INDEX idx_batting_yr_lg_sb ON batting;
CREATE INDEX idx_batting_yr_lg_sb ON batting (yearID, lgID, SB, playerID);

--  A05 pitching: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A06 pitching: ERA leaderboard 
-- IPouts included so the IP qualifier can be satisfied
-- from the index without a table lookup.
DROP INDEX idx_pitching_yr_era ON pitching;
CREATE INDEX idx_pitching_yr_era ON pitching (yearID, lgID, IPouts, ERA, playerID);

--  A07 pitching: strikeout leaderboard 
DROP INDEX idx_pitching_yr_so ON pitching;
CREATE INDEX idx_pitching_yr_so ON pitching (yearID, lgID, SO, playerID);

--  A08 pitching: save leaderboard 
DROP INDEX idx_pitching_yr_sv ON pitching;
CREATE INDEX idx_pitching_yr_sv ON pitching (yearID, lgID, SV, playerID);

--  A09 pitching: win leaderboard 
DROP INDEX idx_pitching_yr_w ON pitching;
CREATE INDEX idx_pitching_yr_w ON pitching (yearID, lgID, W, playerID);

--  A10 fielding: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A11 fielding: positional leaders 
-- Covering index for sp_fielding_leaders queries:
-- POS + yearID filter, returns G/PO/A/E for fielding%.
DROP INDEX idx_fielding_pos_yr ON fielding;
CREATE INDEX idx_fielding_pos_yr ON fielding (POS, yearID, playerID, G, PO, A, E);

--  A12 fieldingofsplit: player/year lookup 
DROP INDEX idx_fos_player_year ON fieldingofsplit;
CREATE INDEX idx_fos_player_year ON fieldingofsplit (playerID, yearID);

--  A13 fieldingofsplit: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A14 appearances: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A15 appearances: team roster queries 
-- sp_team_roster filters on yearID + teamID; playerID
-- included as a covering tail to avoid row lookups.
DROP INDEX idx_appearances_yr_team ON appearances;
CREATE INDEX idx_appearances_yr_team ON appearances (yearID, teamID, playerID);

--  A16 allstarfull: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A17 allstarfull: game roster queries 
-- Filters on yearID + lgID; startingPos for ordering.
DROP INDEX idx_allstar_yr_lg ON allstarfull;
CREATE INDEX idx_allstar_yr_lg ON allstarfull (yearID, lgID, startingPos);

--  A18 battingpost: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A19 battingpost: team postseason batting 
DROP INDEX idx_battingpost_yr_team ON battingpost;
CREATE INDEX idx_battingpost_yr_team ON battingpost (yearID, teamID, round);

--  A20 pitchingpost: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A21 pitchingpost: team postseason pitching
DROP INDEX idx_pitchingpost_yr_team ON pitchingpost;
CREATE INDEX idx_pitchingpost_yr_team ON pitchingpost (yearID, teamID, round);

--  A22 fieldingpost: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A23 fieldingpost: position/round queries 
DROP INDEX idx_fieldingpost_yr_pos ON fieldingpost;
CREATE INDEX idx_fieldingpost_yr_pos ON fieldingpost (yearID, POS, round);

--  A24 salaries: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A25 salaries: payroll ranking queries 
-- yearID filter; salary for ORDER BY in payroll reports.
DROP INDEX idx_salaries_yr_sal ON salaries;
CREATE INDEX idx_salaries_yr_sal ON salaries (yearID, salary);

--  A26 managers: playerID career lookups 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A27 managers: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A28 managershalf: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A29 homegames: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A30 homegames: year/team attendance 
DROP INDEX idx_homegames_yr_team ON homegames;
CREATE INDEX idx_homegames_yr_team ON homegames (yearkey, teamkey);

--  A31 halloffame: HOF class queries 
-- yearid + inducted='Y' is the most common filter.
-- category included for the category ORDER BY.
DROP INDEX idx_hof_yr_inducted ON halloffame;
CREATE INDEX idx_hof_yr_inducted ON halloffame (yearid, inducted, category);

--  A32 halloffame: voting body analysis 
DROP INDEX idx_hof_voted_by ON halloffame;
CREATE INDEX idx_hof_voted_by ON halloffame (votedBy, yearid);

--  A33 awardsmanagers: manager award history
DROP INDEX idx_awdmgr_player_yr ON awardsmanagers;
CREATE INDEX idx_awdmgr_player_yr ON awardsmanagers (playerID, yearID);

--  A34 awardsmanagers: award type lookups 
DROP INDEX idx_awdmgr_award_yr ON awardsmanagers;
CREATE INDEX idx_awdmgr_award_yr ON awardsmanagers (awardID, yearID, lgID);

--  A35 awardssharemanagers: voting analysis 
DROP INDEX idx_awdshrmgr_award_yr ON awardssharemanagers;
CREATE INDEX idx_awdshrmgr_award_yr ON awardssharemanagers (awardID, yearID, lgID);

--  A36 awardsshareplayers: MVP/Cy Young voting
-- pointsWon at the tail allows ordered scan by votes.
DROP INDEX idx_awdshplyr_yr_award ON awardsshareplayers;
CREATE INDEX idx_awdshplyr_yr_award ON awardsshareplayers (yearID, awardID, lgID, pointsWon);

--  A37 people: career span queries 
-- debut_date is used in age calculations in views
-- (Rookie_BA_Leaders uses DATEDIFF on debut).
DROP INDEX idx_people_debut_date ON people;
CREATE INDEX idx_people_debut_date ON people (debut_date, finalgame_date);

--  A38 people: birth_date for age calcs 
DROP INDEX idx_people_birth_date ON people;
CREATE INDEX idx_people_birth_date ON people (birth_date);

--  A39 people: birthCountry/State geography 
-- Player_Count_By_Country view; sp_birth_country_breakdown.
DROP INDEX idx_people_country_state ON people;
CREATE INDEX idx_people_country_state ON people (birthCountry, birthState);

--  A40 teams: division standings 
-- mlb_season_standings orders by yearID DESC, lgID,
-- divID, teamRank  this composite covers all four.
DROP INDEX idx_teams_yr_lg_div ON teams;
CREATE INDEX idx_teams_yr_lg_div ON teams (yearID, lgID, divID, teamRank);

--  A41 teams: World Series champion filter 
-- Team_WS_Wins view: WHERE WSWin='Y' GROUP BY teamID.
DROP INDEX idx_teams_wswin ON teams;
CREATE INDEX idx_teams_wswin ON teams (WSWin, yearID);

--  A42 teams: div_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A43 teams: league ERA trend queries 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A44 teamshalf: team_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A45 teamshalf: div_ID Foreign Key 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A46 collegeplaying: year/school queries 
DROP INDEX idx_collegeplaying_yr ON collegeplaying;
CREATE INDEX idx_collegeplaying_yr ON collegeplaying (yearID, schoolID);

--  A47 parks: parkkey lookup 
-- homegames.parkkey joins to parks; no index existed
-- on parks.parkkey despite it being the natural key.
DROP INDEX idx_parks_parkkey ON parks;
CREATE INDEX idx_parks_parkkey ON parks (parkkey);

--  A48 parks: city/state geographic lookup 
DROP INDEX idx_parks_city_state ON parks;
CREATE INDEX idx_parks_city_state ON parks (city, state);

--  A49 seriespost: winner Foreign Key + champion query
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A50 seriespost: loser Foreign Key + runner-up query
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A51 divisions: active divisions by league 
-- Already created by the Foreign Key constraint in the base schema. No further action needed.

--  A52 fieldingof: player/year OF split lookup
-- Distinct from the UNIQUE KEY (playerID,yearID,stint)
-- because this serves as a covering index for
-- queries that don't specify stint.
DROP INDEX idx_fieldingof_player_yr ON fieldingof;
CREATE INDEX idx_fieldingof_player_yr ON fieldingof (playerID, yearID);



-- SECTION B: ADDITIONAL SCALAR FUNCTIONS
-- Every function is a single RETURN expression
-- (no BEGIN/END, no DELIMITER required).

--  B01 fn_full_name 
-- Formats a player's full name from first and last,
-- trimming extra whitespace and handling NULLs.
-- Usage: fn_full_name(p.nameFirst, p.nameLast)
DROP FUNCTION IF EXISTS fn_full_name;
CREATE FUNCTION fn_full_name(p_first VARCHAR(255), p_last VARCHAR(255))
RETURNS VARCHAR(511) DETERMINISTIC NO SQL
RETURN TRIM(CONCAT(COALESCE(p_first,''), ' ', COALESCE(p_last,'')));

--  B02 fn_win_pct 
-- Returns W/(W+L) win percentage, NULL-safe.
-- Avoids division-by-zero for 0-game seasons.
DROP FUNCTION IF EXISTS fn_win_pct;
CREATE FUNCTION fn_win_pct(p_W INT, p_L INT)
RETURNS DECIMAL(5,3) DETERMINISTIC NO SQL
RETURN IF(COALESCE(p_W,0)+COALESCE(p_L,0)=0, NULL,
    ROUND(COALESCE(p_W,0)/(COALESCE(p_W,0)+COALESCE(p_L,0)),3));

--  B03 fn_hr_rate 
-- Home run rate = HR/AB. Useful for power-hitter
-- analysis across eras with differing AB totals.
DROP FUNCTION IF EXISTS fn_hr_rate;
CREATE FUNCTION fn_hr_rate(p_HR INT, p_AB INT)
RETURNS DECIMAL(6,4) DETERMINISTIC NO SQL
RETURN IF(COALESCE(p_AB,0)=0, NULL,
    ROUND(COALESCE(p_HR,0)/p_AB,4));

--  B04 fn_sb_success 
-- Stolen base success rate = SB/(SB+CS).
-- Threshold: typically >=67% is break-even.
DROP FUNCTION IF EXISTS fn_sb_success;
CREATE FUNCTION fn_sb_success(p_SB INT, p_CS INT)
RETURNS DECIMAL(5,3) DETERMINISTIC NO SQL
RETURN IF(COALESCE(p_SB,0)+COALESCE(p_CS,0)=0, NULL,
    ROUND(COALESCE(p_SB,0)/(COALESCE(p_SB,0)+COALESCE(p_CS,0)),3));

--  B05 fn_format_salary 
-- Human-readable salary display: '$1.25M' or '$450,000'.
-- Returns 'N/A' for NULL salary (pre-1985 records).
DROP FUNCTION IF EXISTS fn_format_salary;
CREATE FUNCTION fn_format_salary(p_salary DOUBLE)
RETURNS VARCHAR(20) DETERMINISTIC NO SQL
RETURN IF(p_salary IS NULL, 'N/A',
    IF(p_salary >= 1000000,
        CONCAT('$', ROUND(p_salary/1000000,2), 'M'),
        CONCAT('$', FORMAT(p_salary,0))));

--  B06 fn_career_length 
-- Number of calendar years a player was active
-- (debut year through final game year, inclusive).
DROP FUNCTION IF EXISTS fn_career_length;
CREATE FUNCTION fn_career_length(p_debut DATE, p_final DATE)
RETURNS INT DETERMINISTIC NO SQL
RETURN IF(p_debut IS NULL OR p_final IS NULL, NULL,
    YEAR(p_final) - YEAR(p_debut) + 1);

--  B07 fn_era_label 
-- Converts a numeric ERA to a qualitative tier.
-- Thresholds based on modern MLB context (post-1960).
DROP FUNCTION IF EXISTS fn_era_label;
CREATE FUNCTION fn_era_label(p_ERA DECIMAL(5,2))
RETURNS VARCHAR(20) DETERMINISTIC NO SQL
RETURN CASE
    WHEN p_ERA IS NULL   THEN 'N/A'
    WHEN p_ERA <  2.00   THEN 'Elite'
    WHEN p_ERA <  3.00   THEN 'Excellent'
    WHEN p_ERA <  3.75   THEN 'Above Average'
    WHEN p_ERA <  4.50   THEN 'Average'
    WHEN p_ERA <  5.50   THEN 'Below Average'
    ELSE 'Poor'
END;

--  B08 fn_ops_label 
-- Converts a numeric OPS to a qualitative tier.
-- Standard FanGraphs scale applied.
DROP FUNCTION IF EXISTS fn_ops_label;
CREATE FUNCTION fn_ops_label(p_OPS DECIMAL(5,3))
RETURNS VARCHAR(20) DETERMINISTIC NO SQL
RETURN CASE
    WHEN p_OPS IS NULL   THEN 'N/A'
    WHEN p_OPS >= 1.000  THEN 'Elite'
    WHEN p_OPS >= 0.900  THEN 'Excellent'
    WHEN p_OPS >= 0.800  THEN 'Above Average'
    WHEN p_OPS >= 0.700  THEN 'Average'
    WHEN p_OPS >= 0.600  THEN 'Below Average'
    ELSE 'Poor'
END;

--  B09 fn_era_name 
-- Maps a yearID to the conventional baseball era name.
-- Mirrors the CASE expressions in sp_era_comparison.
DROP FUNCTION IF EXISTS fn_era_name;
CREATE FUNCTION fn_era_name(p_yearID SMALLINT)
RETURNS VARCHAR(30) DETERMINISTIC NO SQL
RETURN CASE
    WHEN p_yearID BETWEEN 1871 AND 1900 THEN 'Early Era'
    WHEN p_yearID BETWEEN 1901 AND 1919 THEN 'Dead Ball Era'
    WHEN p_yearID BETWEEN 1920 AND 1941 THEN 'Live Ball Era'
    WHEN p_yearID BETWEEN 1942 AND 1960 THEN 'Integration Era'
    WHEN p_yearID BETWEEN 1961 AND 1976 THEN 'Expansion Era'
    WHEN p_yearID BETWEEN 1977 AND 1993 THEN 'Free Agency Era'
    WHEN p_yearID BETWEEN 1994 AND 2005 THEN 'Steroid Era'
    WHEN p_yearID >= 2006               THEN 'Modern Era'
    ELSE 'Unknown'
END;

--  B10 fn_decade 
-- Floors a yearID to its decade (e.g. 1998 -> 1990).
-- Used by sp_decade_batting_leaders and mlb_decade_summary.
DROP FUNCTION IF EXISTS fn_decade;
CREATE FUNCTION fn_decade(p_yearID SMALLINT)
RETURNS SMALLINT DETERMINISTIC NO SQL
RETURN FLOOR(p_yearID / 10) * 10;

--  B11 fn_ip_to_outs 
-- Converts traditional IP display (e.g. 200.2) back
-- to the raw IPouts integer stored in the schema.
-- Inverse of fn_ip_display. Useful for data loading.
DROP FUNCTION IF EXISTS fn_ip_to_outs;
CREATE FUNCTION fn_ip_to_outs(p_ip DECIMAL(7,1))
RETURNS INT DETERMINISTIC NO SQL
RETURN IF(p_ip IS NULL, NULL,
    (FLOOR(p_ip) * 3) + ROUND((p_ip - FLOOR(p_ip)) * 10));



-- SECTION C: ADDITIONAL STORED PROCEDURES (Part 1)
-- C01  C11: standings, rosters, payroll, parks,
--             schools, and single-season leaders.
-- Each procedure is a single SELECT statement;
-- no BEGIN/END or DELIMITER change required.


--  C01 sp_division_standings 
-- Season standings for one division in one year.
-- Returns win%, run differential, Pythagorean W%,
-- and postseason flags for every team in the division.
DROP PROCEDURE IF EXISTS sp_division_standings;
CREATE PROCEDURE sp_division_standings(
    IN p_yearID SMALLINT,
    IN p_lgID   CHAR(3),
    IN p_divID  CHAR(1)
)
SELECT
    t.teamID,
    t.name                              AS team_name,
    t.G, t.W, t.L,
    fn_win_pct(t.W, t.L)               AS W_pct,
    t.teamRank,
    t.R, t.RA,
    (t.R - t.RA)                        AS run_diff,
    fn_pythagorean_wpct(t.R, t.RA)     AS pyth_wpct,
    t.DivWin, t.WCWin, t.LgWin, t.WSWin,
    t.attendance
FROM teams t
WHERE t.yearID = p_yearID
  AND t.lgID   = p_lgID
  AND t.divID  = p_divID
ORDER BY t.teamRank;

--  C02 sp_all_star_game 
-- All-Star selections for a given year and league.
-- Pass p_lgID = NULL to retrieve both leagues.
DROP PROCEDURE IF EXISTS sp_all_star_game;
CREATE PROCEDURE sp_all_star_game(
    IN p_yearID SMALLINT,
    IN p_lgID   CHAR(3)
)
SELECT
    asf.yearID,
    asf.lgID,
    asf.gameID,
    asf.gameNum,
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast) AS player_name,
    asf.teamID,
    asf.startingPos,
    asf.GP
FROM allstarfull asf
JOIN people p ON p.playerID = asf.playerID
WHERE asf.yearID = p_yearID
  AND (p_lgID IS NULL OR asf.lgID = p_lgID)
ORDER BY asf.lgID, asf.startingPos, p.nameLast;

--  C03 sp_payroll_rankings 
-- Payroll totals, rank, average, and max salary
-- for every team in a given season.
DROP PROCEDURE IF EXISTS sp_payroll_rankings;
CREATE PROCEDURE sp_payroll_rankings(IN p_yearID SMALLINT)
SELECT
    s.yearID,
    s.teamID,
    s.lgID,
    SUM(s.salary)                              AS payroll,
    RANK() OVER (ORDER BY SUM(s.salary) DESC)  AS payroll_rank,
    COUNT(DISTINCT s.playerID)                 AS roster_size,
    ROUND(AVG(s.salary), 0)                    AS avg_salary,
    MAX(s.salary)                              AS max_salary,
    fn_format_salary(SUM(s.salary))            AS payroll_display
FROM salaries s
WHERE s.yearID = p_yearID
GROUP BY s.yearID, s.teamID, s.lgID
ORDER BY payroll DESC;

--  C04 sp_payroll_vs_wins 
-- Moneyball-style correlation: team payroll vs wins.
-- Includes cost-per-win for efficiency comparison.
DROP PROCEDURE IF EXISTS sp_payroll_vs_wins;
CREATE PROCEDURE sp_payroll_vs_wins(IN p_yearID SMALLINT)
SELECT
    t.teamID,
    t.name                                        AS team_name,
    t.lgID,
    t.W, t.L,
    fn_win_pct(t.W, t.L)                          AS W_pct,
    t.WSWin,
    SUM(s.salary)                                 AS payroll,
    fn_format_salary(SUM(s.salary))               AS payroll_display,
    ROUND(SUM(s.salary) / NULLIF(t.W, 0), 0)     AS cost_per_win
FROM teams t
JOIN salaries s ON s.yearID = t.yearID AND s.teamID = t.teamID
WHERE t.yearID = p_yearID
GROUP BY t.yearID, t.teamID, t.name, t.lgID, t.W, t.L, t.WSWin
ORDER BY payroll DESC;

--  C05 sp_birth_country_breakdown 
-- Count of MLB players by birth country (all-time),
-- with first/last debut year to track pipeline trends.
DROP PROCEDURE IF EXISTS sp_birth_country_breakdown;
CREATE PROCEDURE sp_birth_country_breakdown()
SELECT
    p.birthCountry,
    COUNT(DISTINCT p.playerID)                             AS total_players,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM people), 2) AS pct_of_total,
    MIN(YEAR(p.debut_date))                                AS first_mlb_debut,
    MAX(YEAR(p.debut_date))                                AS last_mlb_debut
FROM people p
WHERE p.birthCountry IS NOT NULL
GROUP BY p.birthCountry
ORDER BY total_players DESC;

--  C06 sp_player_fielding_career 
-- Career fielding stats aggregated by position
-- for a single player. Includes fielding percentage.
DROP PROCEDURE IF EXISTS sp_player_fielding_career;
CREATE PROCEDURE sp_player_fielding_career(IN p_playerID VARCHAR(9))
SELECT
    p.nameFirst, p.nameLast,
    f.POS,
    SUM(f.G)       AS G,
    SUM(f.GS)      AS GS,
    SUM(f.InnOuts) AS InnOuts,
    SUM(f.PO)      AS PO,
    SUM(f.A)       AS A,
    SUM(f.E)       AS E,
    SUM(f.DP)      AS DP,
    fn_fielding_pct(SUM(f.PO), SUM(f.A), SUM(f.E)) AS FLD_pct,
    MIN(f.yearID)  AS first_year,
    MAX(f.yearID)  AS last_year
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.playerID = p_playerID
GROUP BY f.playerID, p.nameFirst, p.nameLast, f.POS
ORDER BY G DESC;

--  C07 sp_fielding_leaders 
-- Top fielders at a position for a season, ranked
-- by fielding percentage. Minimum games threshold
-- defaults to 20 if not specified.
DROP PROCEDURE IF EXISTS sp_fielding_leaders;
CREATE PROCEDURE sp_fielding_leaders(
    IN p_yearID SMALLINT,
    IN p_POS    VARCHAR(2),
    IN p_min_G  SMALLINT
)
SELECT
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)           AS player_name,
    f.teamID, f.yearID, f.POS,
    SUM(f.G)  AS G,
    SUM(f.PO) AS PO,
    SUM(f.A)  AS A,
    SUM(f.E)  AS E,
    SUM(f.DP) AS DP,
    fn_fielding_pct(SUM(f.PO), SUM(f.A), SUM(f.E)) AS FLD_pct
FROM fielding f
JOIN people p ON p.playerID = f.playerID
WHERE f.yearID = p_yearID AND f.POS = p_POS
GROUP BY f.playerID, p.nameFirst, p.nameLast, f.teamID, f.yearID, f.POS
HAVING SUM(f.G) >= COALESCE(p_min_G, 20)
ORDER BY FLD_pct DESC, SUM(f.PO) DESC
LIMIT 25;

--  C08 sp_manager_career 
-- Lifetime managerial record: W, L, W%, seasons,
-- all teams managed (comma-separated), and
-- player-manager flag.
DROP PROCEDURE IF EXISTS sp_manager_career;
CREATE PROCEDURE sp_manager_career(IN p_playerID VARCHAR(10))
SELECT
    p.nameFirst, p.nameLast,
    MIN(m.yearID)                                     AS first_year,
    MAX(m.yearID)                                     AS last_year,
    COUNT(DISTINCT m.yearID)                          AS seasons,
    SUM(m.G)                                          AS G,
    SUM(m.W)                                          AS W,
    SUM(m.L)                                          AS L,
    fn_win_pct(SUM(m.W), SUM(m.L))                   AS W_pct,
    GROUP_CONCAT(DISTINCT m.teamID ORDER BY m.yearID) AS teams_managed,
    MAX(m.plyrMgr)                                    AS player_manager
FROM managers m
JOIN people p ON p.playerID = m.playerID
WHERE m.playerID = p_playerID
GROUP BY m.playerID, p.nameFirst, p.nameLast;

--  C09 sp_park_history 
-- Attendance and game history for a specific park.
-- Includes average attendance per opening.
DROP PROCEDURE IF EXISTS sp_park_history;
CREATE PROCEDURE sp_park_history(IN p_parkkey VARCHAR(255))
SELECT
    pk.parkname, pk.city, pk.state, pk.country,
    hg.yearkey,
    hg.teamkey,
    hg.games,
    hg.openings,
    hg.attendance,
    ROUND(hg.attendance / NULLIF(hg.openings, 0), 0) AS avg_attendance,
    hg.spanfirst_date,
    hg.spanlast_date
FROM parks pk
JOIN homegames hg ON hg.parkkey = pk.parkkey
WHERE pk.parkkey = p_parkkey
ORDER BY hg.yearkey DESC;

--  C10 sp_school_players 
-- All MLB players who played at a given college.
-- Useful for scouting pipeline and alumni reports.
DROP PROCEDURE IF EXISTS sp_school_players;
CREATE PROCEDURE sp_school_players(IN p_schoolID VARCHAR(15))
SELECT
    sc.name_full                                        AS school_name,
    sc.city, sc.state,
    cp.yearID                                           AS college_year,
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)               AS player_name,
    p.debut_date,
    p.finalgame_date,
    fn_career_length(p.debut_date, p.finalgame_date)    AS career_years
FROM collegeplaying cp
JOIN schools sc ON sc.schoolID = cp.schoolID
JOIN people  p  ON p.playerID  = cp.playerID
WHERE cp.schoolID = p_schoolID
ORDER BY cp.yearID, p.nameLast;

--  C11 sp_top_HR_seasons 
-- All-time single-season HR leaders (AL/NL only).
-- Accepts a LIMIT parameter for flexible reporting.
DROP PROCEDURE IF EXISTS sp_top_HR_seasons;
CREATE PROCEDURE sp_top_HR_seasons(IN p_limit INT)
SELECT
    b.yearID,
    b.teamID,
    b.lgID,
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)       AS player_name,
    SUM(b.HR)                                   AS HR,
    fn_batting_avg(SUM(b.H), SUM(b.AB))         AS AVG,
    fn_era_name(b.yearID)                       AS era
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE b.lgID IN ('AL','NL')
GROUP BY b.playerID, b.yearID, b.teamID, b.lgID, p.nameFirst, p.nameLast
ORDER BY HR DESC
LIMIT p_limit;



-- SECTION C: ADDITIONAL STORED PROCEDURES (Part 2)
-- C12  C21: pitching leaders, World Series, HOF,
--             career leaders, similarity, decades,
--             and franchise payroll.


--  C12 sp_top_pitching_seasons 
-- All-time single-season ERA leaders (AL/NL only)
-- with a configurable IP qualifier (default 162 IP).
DROP PROCEDURE IF EXISTS sp_top_pitching_seasons;
CREATE PROCEDURE sp_top_pitching_seasons(
    IN p_limit    INT,
    IN p_min_ip   DECIMAL(7,1)
)
SELECT
    pi.yearID,
    pi.teamID,
    pi.lgID,
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)                AS player_name,
    fn_era(SUM(pi.ER), SUM(pi.IPouts))                   AS ERA,
    fn_ip_display(SUM(pi.IPouts))                        AS IP,
    SUM(pi.W)  AS W,
    SUM(pi.L)  AS L,
    SUM(pi.SO) AS SO,
    fn_whip(SUM(COALESCE(pi.BB,0)), SUM(pi.H), SUM(pi.IPouts))   AS WHIP,
    fn_fip(SUM(pi.HR), SUM(COALESCE(pi.BB,0)),
           SUM(COALESCE(pi.HBP,0)), SUM(pi.SO), SUM(pi.IPouts))  AS FIP,
    fn_era_name(pi.yearID)                               AS era
FROM pitching pi
JOIN people p ON p.playerID = pi.playerID
WHERE pi.lgID IN ('AL','NL')
GROUP BY pi.playerID, pi.yearID, pi.teamID, pi.lgID, p.nameFirst, p.nameLast
HAVING fn_ip_display(SUM(pi.IPouts)) >= COALESCE(p_min_ip, 162.0)
ORDER BY ERA ASC
LIMIT p_limit;

--  C13 sp_world_series_history 
-- Complete World Series history (seriespost round='WS')
-- with champion and runner-up team names resolved
-- via a self-join on teams.
DROP PROCEDURE IF EXISTS sp_world_series_history;
CREATE PROCEDURE sp_world_series_history()
SELECT
    sp.yearID,
    sp.teamIDwinner                                          AS champion,
    tw.name                                                  AS champion_name,
    sp.lgIDwinner,
    sp.teamIDloser                                           AS runner_up,
    tl.name                                                  AS runner_up_name,
    sp.lgIDloser,
    sp.wins, sp.losses, sp.ties,
    CONCAT(sp.wins,'-',sp.losses,
           IF(sp.ties > 0, CONCAT('-',sp.ties),''))          AS series_record
FROM seriespost sp
LEFT JOIN teams tw
    ON tw.yearID = sp.yearID AND tw.teamID = sp.teamIDwinner
LEFT JOIN teams tl
    ON tl.yearID = sp.yearID AND tl.teamID = sp.teamIDloser
WHERE sp.round = 'WS'
ORDER BY sp.yearID DESC;

--  C14 sp_hof_class 
-- Hall of Fame inductees for a specific year,
-- including vote percentage for BBWAA elections.
DROP PROCEDURE IF EXISTS sp_hof_class;
CREATE PROCEDURE sp_hof_class(IN p_yearID SMALLINT)
SELECT
    h.yearid,
    h.votedBy,
    h.category,
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)              AS player_name,
    h.votes, h.ballots,
    ROUND(h.votes / NULLIF(h.ballots, 0) * 100, 1)    AS vote_pct
FROM halloffame h
JOIN people p ON p.playerID = h.playerID
WHERE h.yearid = p_yearID AND h.inducted = 'Y'
ORDER BY h.category, vote_pct DESC;

--  C15 sp_hof_vote_history 
-- Full ballot history for a player across all years
-- and voting bodies, including vote percentage trend.
DROP PROCEDURE IF EXISTS sp_hof_vote_history;
CREATE PROCEDURE sp_hof_vote_history(IN p_playerID VARCHAR(10))
SELECT
    h.yearid,
    h.votedBy,
    h.category,
    h.votes, h.ballots, h.needed,
    ROUND(h.votes / NULLIF(h.ballots, 0) * 100, 1)    AS vote_pct,
    h.inducted,
    h.needed_note
FROM halloffame h
WHERE h.playerID = p_playerID
ORDER BY h.yearid, h.votedBy;

--  C16 sp_career_batting_leaders 
-- All-time career batting leaders (from cache).
-- p_category: H | HR | RBI | SB | BB | OPS | AVG
-- Minimum 1,000 AB qualifier.
DROP PROCEDURE IF EXISTS sp_career_batting_leaders;
CREATE PROCEDURE sp_career_batting_leaders(
    IN p_category VARCHAR(5),
    IN p_limit    INT
)
SELECT
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)   AS player_name,
    c.first_year, c.last_year, c.seasons,
    c.G, c.AB, c.H, c.HR, c.RBI, c.SB, c.BB,
    c.AVG, c.OBP, c.SLG, c.OPS, c.wOBA,
    CASE p_category
        WHEN 'H'   THEN c.H   + 0.0
        WHEN 'HR'  THEN c.HR  + 0.0
        WHEN 'RBI' THEN c.RBI + 0.0
        WHEN 'SB'  THEN c.SB  + 0.0
        WHEN 'BB'  THEN c.BB  + 0.0
        WHEN 'OPS' THEN c.OPS + 0.0
        WHEN 'AVG' THEN c.AVG + 0.0
        ELSE c.OPS + 0.0
    END AS sort_stat
FROM cache_career_batting c
JOIN people p ON p.playerID = c.playerID
WHERE c.AB >= 1000
ORDER BY sort_stat DESC
LIMIT p_limit;

--  C17 sp_career_pitching_leaders 
-- All-time career pitching leaders (from cache).
-- p_category: SO | W | SV | ERA | WHIP | FIP
-- Minimum 500.0 IP qualifier.
DROP PROCEDURE IF EXISTS sp_career_pitching_leaders;
CREATE PROCEDURE sp_career_pitching_leaders(
    IN p_category VARCHAR(5),
    IN p_limit    INT
)
SELECT
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)   AS player_name,
    c.first_year, c.last_year, c.seasons,
    c.W, c.L, c.G, c.GS, c.SV,
    c.IP, c.SO, c.ERA, c.WHIP, c.K_per_9, c.FIP, c.BABIP,
    CASE p_category
        WHEN 'SO'   THEN c.SO   + 0.0
        WHEN 'W'    THEN c.W    + 0.0
        WHEN 'SV'   THEN c.SV   + 0.0
        WHEN 'ERA'  THEN c.ERA  + 0.0
        WHEN 'WHIP' THEN c.WHIP + 0.0
        WHEN 'FIP'  THEN c.FIP  + 0.0
        ELSE c.SO + 0.0
    END AS sort_stat
FROM cache_career_pitching c
JOIN people p ON p.playerID = c.playerID
WHERE c.IP >= 500.0
ORDER BY
    CASE WHEN p_category IN ('ERA','WHIP','FIP') THEN sort_stat ELSE NULL END ASC,
    CASE WHEN p_category NOT IN ('ERA','WHIP','FIP') THEN sort_stat ELSE NULL END DESC
LIMIT p_limit;

--  C18 sp_attendance_trends 
-- Yearly MLB-wide attendance totals between two years.
-- Useful for charting attendance growth over time.
DROP PROCEDURE IF EXISTS sp_attendance_trends;
CREATE PROCEDURE sp_attendance_trends(
    IN p_from_year SMALLINT,
    IN p_to_year   SMALLINT
)
SELECT
    t.yearID,
    COUNT(DISTINCT t.teamID)    AS teams,
    SUM(t.attendance)           AS total_attendance,
    ROUND(AVG(t.attendance), 0) AS avg_per_team,
    MAX(t.attendance)           AS highest_team_attendance
FROM teams t
WHERE t.yearID BETWEEN COALESCE(p_from_year, 1871)
                   AND COALESCE(p_to_year,   2025)
  AND t.attendance > 0
GROUP BY t.yearID
ORDER BY t.yearID;

--  C19 sp_player_similar_batters 
-- Finds the 20 career batters most similar to a given
-- player using a weighted distance on OPS, HR, SB,
-- and AVG from the career batting cache.
-- Requires cache_career_batting to be populated.
DROP PROCEDURE IF EXISTS sp_player_similar_batters;
CREATE PROCEDURE sp_player_similar_batters(IN p_playerID VARCHAR(9))
SELECT
    c2.playerID,
    fn_full_name(p2.nameFirst, p2.nameLast)   AS comparable_player,
    c2.seasons, c2.AB, c2.HR, c2.RBI, c2.SB,
    c2.AVG, c2.OBP, c2.SLG, c2.OPS,
    ROUND(
        ABS(c2.OPS - ref.OPS) * 100
      + ABS(c2.HR  - ref.HR)  *  0.1
      + ABS(c2.SB  - ref.SB)  *  0.1
      + ABS(c2.AVG - ref.AVG) * 50,
    2) AS similarity_distance
FROM cache_career_batting c2
JOIN people p2  ON p2.playerID  = c2.playerID
JOIN cache_career_batting ref ON ref.playerID = p_playerID
WHERE c2.playerID != p_playerID
  AND c2.AB >= 1000
ORDER BY similarity_distance ASC
LIMIT 20;

--  C20 sp_decade_batting_leaders 
-- Top batters by OPS accumulated during a single
-- decade. Minimum 200 AB in the decade to qualify.
-- p_limit must be non-NULL; pass 25 for the default.

DROP PROCEDURE IF EXISTS sp_decade_batting_leaders;
CREATE PROCEDURE sp_decade_batting_leaders(
    IN p_decade SMALLINT,
    IN p_limit  INT
)
SELECT
    p.playerID,
    fn_full_name(p.nameFirst, p.nameLast)       AS player_name,
    COUNT(DISTINCT b.yearID)                    AS seasons_in_decade,
    SUM(b.G)   AS G,
    SUM(b.AB)  AS AB,
    SUM(b.H)   AS H,
    SUM(b.HR)  AS HR,
    SUM(COALESCE(b.RBI,0))                      AS RBI,
    fn_batting_avg(SUM(b.H), SUM(b.AB))         AS AVG,
    fn_ops(SUM(b.H), SUM(b.`2B`), SUM(b.`3B`), SUM(b.HR),
           SUM(COALESCE(b.BB,0)), SUM(COALESCE(b.HBP,0)),
           SUM(b.AB), SUM(COALESCE(b.SF,0)))    AS OPS
FROM batting b
JOIN people p ON p.playerID = b.playerID
WHERE fn_decade(b.yearID) = p_decade
  AND b.lgID IN ('AL','NL')
GROUP BY b.playerID, p.nameFirst, p.nameLast
HAVING SUM(b.AB) >= 200
ORDER BY OPS DESC
LIMIT p_limit;

--  C21 sp_franchise_payroll_history 
-- Year-by-year payroll history for an entire franchise
-- (all teams under the same franchID), including W/L
-- and World Series flags. Pre-1985 years show NULL payroll.
DROP PROCEDURE IF EXISTS sp_franchise_payroll_history;
CREATE PROCEDURE sp_franchise_payroll_history(IN p_franchID VARCHAR(3))
SELECT
    t.yearID,
    t.teamID,
    t.name                                     AS team_name,
    t.lgID,
    t.W, t.L,
    fn_win_pct(t.W, t.L)                       AS W_pct,
    t.WSWin,
    SUM(s.salary)                              AS payroll,
    fn_format_salary(SUM(s.salary))            AS payroll_display,
    COUNT(DISTINCT s.playerID)                 AS roster_size
FROM teams t
JOIN teamsfranchises tf ON tf.franchID = t.franchID
LEFT JOIN salaries s    ON s.yearID = t.yearID AND s.teamID = t.teamID
WHERE t.franchID = p_franchID
GROUP BY t.yearID, t.teamID, t.name, t.lgID, t.W, t.L, t.WSWin
ORDER BY t.yearID DESC;