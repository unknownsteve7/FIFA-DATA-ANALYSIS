-- Active: 1780921289468@@127.0.0.1@3306@sample
create DATABASE FIFA_FOOTBALL;
use FIFA_FOOTBALL;

select * from editions;
select * from matches;
select * from scorers;
select * from fixtures;
select * from teams;

-- From how many years World Cup has been organised?
create view editions_summary as
    select count(year) from editions;

select * from editions_summary;

-- Which country has hosted World Cup most times?
create view host_counts as
    select host, count(year) as num_times from editions group by host;

select * from host_counts order by num_times desc;

-- Who has scored most goals in World Cup?
create view total_goals as
    select sum(goals_scored) as total_goals from scorers;

select * from total_goals;