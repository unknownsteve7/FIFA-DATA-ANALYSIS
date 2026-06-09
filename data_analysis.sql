-- From how many years world cup has been organised?
SELECT COUNT(year) from editions;

-- Which country hosted the most world cup finals?
SELECT host ,Count(host) as no_of_times from editions group by host order by no_of_times desc limit 1;

-- highest champion over the years
select champion, count(*) as total_championship from editions group by champion order by total_championship desc limit 1;
-- highest number of runners over the years
select runner_up, count(*) as runners from editions group by runner_up order by runners desc limit 1;

-- average goals per decade
select (year div 10)*10 as decade, round(avg(goals_per_match)) from editions group by decade;
-- -- Countries that appeared in final most (champion + runner_up both count)
select country, count(*) as finals from (
	select champion as country from editions union all select runner_up from editions
) t group by country order by finals desc limit 5;

-- Which country won back to back titles?

select e1.champion, e1.year, e2.year as next_year
from editions e1 join editions e2 
on e1.champion = e2.champion 
and e2.year = (select min(year) from editions where year >e1.year);

-- Host country performance -- champion, runner_up, or neither?
SELECT host, champion,
  CASE 
    WHEN host = champion THEN 'Won'
    WHEN host = runner_up THEN 'Runner Up'
    WHEN host = third_place THEN 'Third Place'
    ELSE 'Did Not Place'
  END as host_performance
FROM editions ORDER BY year;

-- Tournament size growth -- teams and matches over decades
SELECT (year DIV 10)*10 as decade,
       AVG(teams) as avg_teams,
       AVG(matches) as avg_matches
FROM editions GROUP BY decade ORDER BY decade;


-- Total matches played per year

select year,count(*) as matches from matches group by year;

-- Which country played most matches overall?
select country, count(*) as matches from (
	select team1 as country from matches union all select team2 from matches
) t group by country order by matches desc limit 1;

-- Highest scoring match ever 
SELECT year, stage, team1, team2, 
       (score1 + score2) as total_goals
FROM matches
ORDER BY total_goals DESC
LIMIT 1;

-- How many finals ended in a draw 
select date, team1, team2,score1 as score from matches where stage = 'Final' and score1 = score2;

-- Which country has best win percentage in knockout stages vs group stages
SELECT 
    team,
    stage_type,
    COUNT(*) as total_matches,
    SUM(won) as total_wins,
    ROUND((SUM(won) / COUNT(*)) * 100, 2) as win_pct
FROM (
    SELECT 
        team1 as team,
        score1,
        score2,
        CASE 
            WHEN stage IN ('Group Stage', 'Round Robin', 
                          'Final Round', 'Semi-final Round') 
            THEN 'Group'
            ELSE 'Knockout'
        END as stage_type,
        CASE WHEN score1>score2 THEN 1 ELSE 0 END as won  -- team1 won condition
    FROM matches
    
    UNION ALL
    
    SELECT 
        team2 as team,
        score1,
        score2,
        CASE 
            WHEN stage IN ('Group Stage', 'Round Robin', 
                          'Final Round', 'Semi-final Round') 
            THEN 'Group'
            ELSE 'Knockout'
        END as stage_type,
        CASE WHEN score2>score1 THEN 1 ELSE 0 END as won  -- team2 won condition
    FROM matches
) t
GROUP BY team, stage_type
ORDER BY team, stage_type;  -- country alphabetically, then stage type0

-- Which venue hosted most matches?
select venue, count(*) as matches_hosted from matches group by venue order by matches_hosted desc;

--  Average goals per match — group stage vs knockout stage comparison
SELECT 
    stage_type,
    ROUND(AVG(total_goals), 2) as avg_goals
FROM (
    SELECT 
        (score1 + score2) as total_goals,
        CASE 
            WHEN stage IN ('Group Stage', 'Round Robin', 
                          'Final Round', 'Semi-final Round') 
            THEN 'Group'
            ELSE 'Knockout'
        END as stage_type
    FROM matches
) t
GROUP BY stage_type;

-- Highest goals ever by a top scorer in single tournament

select year,player,country,goals from scorers order by goals desc limit 1;

-- Which country produced most top scorers
select * from scorers;
select country, count(player) as players from scorers group by country order by players desc;
-- Top scorers whose team won the championship

SELECT player, country, goals 
FROM scorers 
WHERE team_result = 'Champions'
ORDER BY goals DESC;
-- Goals per match ratio — most efficient top scorer
SELECT player, country,
       ROUND(goals / matches_played, 2) as goals_per_match
FROM scorers
ORDER BY goals_per_match DESC;



select * from teams;
-- How many teams per confederation — continent wise representation
select confederation, count(team) as Teams from teams group by confederation order by Teams desc;
-- Which group has highest average FIFA ranking — toughest group

SELECT `group` as G, 
       ROUND(AVG(fifa_rank), 2) as avg_fifa_rank 
FROM teams 
GROUP BY `group` 
ORDER BY avg_fifa_rank;

select * from teams where `group` = 'F';

-- How many teams are making their debut in 2026

select * from teams where debut_2026 = 'Yes';
-- Which confederation has best average FIFA ranking

select confederation, round(avg(fifa_rank),2) avg_f_rank from teams group by confederation order by avg_f_rank;
-- Top 5 highest ranked teams — who are favorites

select team,fifa_rank from teams  order by fifa_rank limit 5;
select * from fixtures;
-- Which host country has most matches
select country,count(*) as num_matches from fixtures group by country order by num_matches desc;

-- Toughest match — highest combined FIFA rank gap
SELECT team1, team2,
       ABS(team1_fifa_rank - team2_fifa_rank) as rank_gap
FROM fixtures
WHERE team1_fifa_rank IS NOT NULL
ORDER BY rank_gap DESC
LIMIT 5;

--  Which city hosts most matches
select city,count(*) as num_matches from fixtures group by city order by num_matches desc;
--  Confederation clash analysis
SELECT team1_confederation, team2_confederation, 
       COUNT(*) as matches
FROM fixtures
WHERE team1_confederation IS NOT NULL  
GROUP BY team1_confederation, team2_confederation
ORDER BY matches DESC;

