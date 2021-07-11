create database ipl_analysis ;
use ipl_analysis;

-- import table from the import table data wizard and name it as "ipldata"

select * from ipldata order by date;
describe ipldata;

-- since the date is in text data type convert it to date data type - 
alter table ipldata modify date date;

-- SOLVE THE FOLLOWING QUERIES -

-- 1)  FIND ALL THE DISTINCT TEAMS WHICH PLAYED IN IPL.
select  distinct(team1) as ipl_teams from ipldata;

-- 2) FIND ALL DEATAILS OF TOP 10 GAMES BASED ON RESULT MARGIN.
select * from ipldata order by result_margin desc limit 10;

-- 3) FIND THE TEAMWISE COUNT OF WINNER TEAMS FOR THE YEAR 2015.
select winner as team, count(*) from ipldata where date like "2015%" group by winner;

-- 4) FIND THE TEAMS WHICH WON TOSS,CHOSE TO FIELD AND WON THE MATCH.
select date,toss_winner, toss_decision, winner from ipldata where toss_decision='field' and toss_winner=winner;

-- 5) FIND THE SECOND HIGHEST result_margin.
select max(result_margin) as second_highest from ipldata where result_margin not in(select max(result_margin) from ipldata) ;

-- 6) FIND DETAILS ABOUT IPL MATHCHES IN ID RANGE OF 170 TO 200.
select * from ipldata where id between 170 and 200;

-- 7) FIND PLAYER WHO HAS WON MAXIMUM PLAYER OF MATCH AWARDS.
select count(*) as count,player_of_match from ipldata group by player_of_match order by count desc;
select count(*) as count,player_of_match from ipldata group by player_of_match having count(*)=22 ;

-- 8) FIND THE GAMES WHICH WERE UMPIRED BY 'Nitin Menon' AND 'YC Barde'.
select date,venue,umpire1,umpire2 from ipldata where (umpire1='Nitin Menon' and umpire2='YC Barde') or (umpire2='Nitin Menon' and umpire1='YC Barde');

-- 9) FIND THE NUMBER OF MATCHES PLAYED AND MATCHES WON BY RCB FOR YEAR 2020.
select team1 as team_for_2020, sum(case when team1='Royal Challengers Bangalore' or team2='Royal Challengers Bangalore'
then 1 else 0 end) as matches_played, sum(case when winner='Royal Challengers Bangalore' then 1 else 0 end) as
matches_won from ipldata where date like '2020%' and team1='Royal Challengers Bangalore'; 

-- CREATING VIEWS

create view ipl_views as select date,team1,team2,toss_winner,winner FROM ipldata 
WHERE team1 = 'Mumbai Indians' OR team2 = 'Mumbai Indians';
select * from ipl_views;


-- CREATING STORED PROCEDURES

-- 1)
delimiter //
create procedure team_name()
begin
select distinct(team1) as teams from ipldata;
end //
delimiter ;
call team_name();

-- 2)
delimiter //
create procedure team_matches(in team varchar(100))
begin
select date,team1,team2 from ipldata where team1=team or team2=team;
end //
delimiter ;
call team_matches('Royal Challengers Bangalore');

-- 3)
delimiter //
create procedure total_matches_of_input_team(in team varchar(100),out total_matches int)
begin
select count(*) into total_matches from ipldata where team1=team or team2=team;
end //
delimiter ;
call total_matches_of_input_team('Mumbai Indians',@total);
select @total as no_of_matches;

-- 4) 
delimiter //
create procedure ifelse_margin(in matchdate date,out level varchar(20))
begin
declare margin int;
select result_margin into margin from ipldata where date = matchdate;
if margin>100 then set level = 'excellent' ;
elseif margin>=50 and margin<=100 then set level= 'good' ;
else set level = 'average' ;
end if ;
end // 
delimiter ;
call ifelse_margin('2008-04-18',@grade);
select @grade as margin_grade;
call ifelse_margin('2008-04-25',@grade);
select @grade as margin_grade;
call ifelse_margin('2008-04-21',@grade);
select @grade as margin_grade;

-- 5)
delimiter //
create procedure loopleaveiterate()
begin
declare x int;
declare string_value varchar(50);
set x=0;
set string_value = '';
loop_name : loop
if x>20 then leave loop_name;
end if;
set x=x+1;
if (x mod 2) then iterate loop_name;      -- printing only even values 
else set string_value = concat(string_value,x,' ');
end if ;
end loop;
select string_value;
end //
delimiter ;
call loopleaveiterate();

-- 6)
-- Insert into table using Stored Procedure
create table ipl2021(
date date, team1 varchar(50), team2 varchar(50), target int,winner varchar(20)
);
delimiter //
create procedure insertdata_intotable(in date date,in team1 varchar(50),in team2 varchar(20),in target int, in winner varchar(50)) 
begin
insert into ipl2021 values(date, team1, team2 , target,winner);
end //
delimiter ;
call insertdata_intotable('2021-04-27','mi','rcb',150,'rcb');
call insertdata_intotable('2021-04-28','csk','dc',138,'dc');
call insertdata_intotable('2021-04-29','kkr','kxip',156,'kkr');
-- Insert into table using Stored Procedure


-- CREATING STORED FUNCTIONS

-- 1)
delimiter //
create function get_level(margin int)
returns varchar(50) deterministic
begin
declare level varchar(50);
if margin<50 then set level='decent';
elseif margin >=50 and margin<100 then set level = 'good';
else set level='excellent';
end if;
return level;
end //
delimiter ;
select date,result_margin,get_level(result_margin) as grade from ipldata order by date;



