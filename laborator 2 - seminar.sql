--- SELECT RECAP

select country_code,
	   sum(confirmed)
from covid_data
where confirmed>0
group by country_code
having sum(confirmed) >100000
order by 2 desc
;

-- la laborator

-- Joins

--https://www.postgresqltutorial.com/postgresql-joins/

-- Inner join

select * from country__pop_coord;



--- Left join
-- la laborator

-- Validating
select * from country__other_data cpd where country_code_iso3= 'FSM'

select * from country__pop_coord cpd where country_code3= 'FSM'

select * from country__other_data a
inner join country__pop_coord b
on a.country_code_iso3=b.country_code3

-- Right join


select * from country_gen_info;

select * from country__other_data a
right join country__pop_coord b
on a.country_code_iso3=b.country_code3



-- la laborator

-- Natural Join

-- solutie eronata!!!!
SELECT pop_65
FROM country_gen_info NATURAL JOIN country__other_data
WHERE country_name = 'Romania' 

--- But why

-- la laborator

I1. populatia fiecare regiuni geografice

select * from country_gen_info;
select * from country__pop_coord;
-- la laborator

	
	
	
	select region,
	      sum(population)
	from country_gen_info
	inner join country__pop_coord 
	on country_code=country_code3
	group by region
	order by 2 desc
	limit 1
	
I2 tara cu cea mai mare populatie

-- la laborator


I3. tara cu cel mai mare procent de varstnici
I4. tara cu cel mai mare procent de barbati fumatori

I8. Top 3 tari cu cea mai mare populatie

-- la laborator


select country_code_iso3 ,country_name,trunc(pop_65) from country__other_data cod 
inner join country_gen_info
	on country_code=country_code_iso3
order by 3 desc
limit 3
-- top 3, top 5

drop table if exists test;
CREATE TABLE test AS
SELECT 'a' col1 UNION ALL
SELECT 'a'   UNION ALL
SELECT 'a'   UNION ALL
SELECT 'b'   UNION ALL
SELECT 'c'   UNION ALL
SELECT 'c'   UNION ALL
SELECT 'd'   UNION all
SELECT 'd'   UNION ALL
SELECT 'd'   UNION all
SELECT 'd'   UNION ALL
SELECT 'e';

select * from test

-- row_number

select col1, row_number() over (order by col1)
from test;

-- rank

select col1, rank() over (order by col1)
from test;

-- dense_rank
select col1, dense_rank() over (order by col1)
from test;
-- Adding also partitioning
drop table if exists test;
CREATE TABLE test AS
SELECT 'mere' col1, 'fructe' col2 UNION ALL
SELECT 'pere' col1, 'fructe' col2 UNION ALL
SELECT 'mere' col1, 'fructe' col2 UNION ALL
SELECT 'cartofi' col1, 'delicatese' col2 UNION ALL
SELECT 'conopida' col1, 'delicatese' col2;

select col1,col2, 
       row_number() over (partition by col2 order by col1)
from test;

select col1,col2, 
       dense_rank() over (partition by col2 order by col1)
from test;

-- Inainte si inapoi

drop table if exists test;
CREATE TABLE test AS
SELECT 'mere' col1, '100' col2, '01-Oct-2021' col3 UNION ALL
SELECT 'mere' col1, '115' col2, '07-Oct-2021' col3 UNION ALL
SELECT 'mere' col1, '90' col2, '04-Oct-2021' col3 UNION ALL
SELECT 'mere' col1, '100' col2, '03-Oct-2021' col3 UNION ALL
SELECT 'mere' col1, '115' col2, '02-Oct-2021' col3;


select col1,col2,col3, 
       lag(col2,1) over (order by col3) as "Pretul de ieri",
	   lead(col2,1) over (order by col3) as "Pretul de maine"
from test;


I9. Top 3 tari cu cel mai mare procent de varstnici

select * from country__other_data
-- la laborator
select * 
from (
select country_name,
       trunc(pop_65),
	   rank()  over(order by trunc(pop_65) desc ) as "poz1",
	   dense_rank()  over(order by trunc(pop_65) desc ) as "poz2"
from country__other_data
inner join country_gen_info on country_code = country_code_iso3
)tab1
where poz2 <=5


I.10 TOP 3 tari cu cel mai mare PIB pe cap de locuitor
I.11 TOP 5 tari cu cel mai mare procent de femei
I.13 TOP 3 zone geografice cele mai populate 


drop table if exists test1;
CREATE TABLE test1 AS
SELECT 'mere' col1, 'fructe' col2 UNION ALL
SELECT 'pere' col1, 'fructe' col2 UNION ALL
SELECT 'mere' col1, 'fructe' col2 UNION ALL
SELECT 'conopida' col1, 'delicatese' col2;

drop table if exists test2;
CREATE TABLE test2 AS
SELECT 'mere' col1, 'fructe' col2 UNION ALL
SELECT 'pere' col1, 'fructe' col2 UNION ALL
SELECT 'cartofi' col1, 'delicatese' col2 ;

select * from test1
union all 
select * from test2;

select * from test1
union 
select * from test2;


select * from test1
intersect 
select * from test2;

select * from test1
except 
select * from test2;


select * from test2
except 
select * from test1;




-- adaugam atribut nou 'confirmed_new'

ALTER TABLE covid_data DROP confirmed_new;
ALTER TABLE covid_data ADD confirmed_new NUMERIC(15) ;

UPDATE covid_data c1
SET confirmed_new =
	(SELECT confirmed_new
	 FROM
		(SELECT country_code, report_date, confirmed -
			COALESCE(LAG (confirmed, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0)
		 	AS confirmed_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date) ;

-- L6. Care a fost cel mai mare număr de cazuri noi (zilnice) în România


select confirmed_new from covid_data
where country_code = 'ROU' and confirmed_new is not null
order by confirmed_new desc
limit 1
-- la laborator

-- L6.1 In ce zi(le) a(u) fost cel mai mare număr de cazuri noi (zilnice) în România

-- la laborator
select * from covid_data
where confirmed_new =
(select confirmed_new from covid_data
where country_code = 'ROU' and confirmed_new is not null
order by confirmed_new desc
limit 1)
