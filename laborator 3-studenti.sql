



--------- Adaugam metricile la nivel de zi


--- Creati si populati la fel tests_new, recovered_new,deaths_new, hosp_new, vent_new, icu_new

-- confirmed_new (cu fixarea nullurilor)

ALTER TABLE covid_data drop confirmed_new ;
ALTER TABLE covid_data ADD confirmed_new NUMERIC(15) ;




UPDATE covid_data c1
SET confirmed_new =
	(SELECT confirmed_new
	 FROM
		(SELECT country_code, report_date, COALESCE(confirmed -
			COALESCE(LAG (confirmed, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric
		 	AS confirmed_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date) ;

-- Verificam

select * 
from covid_data
where confirmed_new >0 and country_code ='ROU';

ALTER TABLE covid_data drop recovered_new ;
ALTER TABLE covid_data ADD recovered_new NUMERIC(15) ;

-- recovered_new
UPDATE covid_data c1
SET recovered_new =
	(SELECT recovered_new
	 FROM
		(SELECT country_code, report_date, COALESCE(recovered -
			COALESCE(LAG (recovered, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric
		 	AS recovered_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date) ;



---
ALTER TABLE covid_data drop deaths_new ;
ALTER TABLE covid_data drop hosp_new ;
ALTER TABLE covid_data drop vent_new ;
ALTER TABLE covid_data drop icu_new ;
ALTER TABLE covid_data drop tests_new ;

ALTER TABLE covid_data ADD deaths_new NUMERIC(15) ;
ALTER TABLE covid_data ADD hosp_new NUMERIC(15) ;
ALTER TABLE covid_data ADD vent_new NUMERIC(15) ;
ALTER TABLE covid_data ADD icu_new NUMERIC(15) ;
ALTER TABLE covid_data ADD tests_new NUMERIC(15) ;
-- deaths_new

UPDATE covid_data c1
SET deaths_new =
	(SELECT deaths_new
	 FROM
		(SELECT country_code, report_date, deaths -
			COALESCE(LAG (deaths, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0)
		 	AS deaths_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date),
    hosp_new =
	(SELECT hosp_new
	 FROM
		(SELECT country_code, report_date, hosp -
			COALESCE(LAG (hosp, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0)
		 	AS hosp_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date),
	vent_new =
	(SELECT vent_new
	 FROM
		(SELECT country_code, report_date, vent -
			COALESCE(LAG (vent, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0)
		 	AS vent_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date),
	icu_new =
	(SELECT icu_new
	 FROM
		(SELECT country_code, report_date, icu -
			COALESCE(LAG (icu, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0)
		 	AS icu_new
		 FROM covid_data) x
	WHERE country_code = c1.country_code AND report_date = c1.report_date);


--- verificam

select cd.country_code ,cd.deaths, cd.deaths_new ,cd.confirmed_new
from covid_data cd 
where country_code ='ROU'
order by report_date desc;


-- rescrieti folosind CTE pentru simplificare


with calculare as
(SELECT icu_new,hosp_new,vent_new,deaths_new, country_code , report_date 
	 FROM
		(SELECT country_code, 
		        report_date, 
		         COALESCE(icu - COALESCE(LAG (icu, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric AS icu_new,
		         COALESCE(hosp - COALESCE(LAG (hosp, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric  AS hosp_new,
		         COALESCE(vent - COALESCE(LAG (vent, 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric  AS vent_new,
		         COALESCE(deaths - COALESCE(LAG (deaths , 1) OVER (PARTITION BY country_code ORDER BY report_date), 0),0)::numeric  AS deaths_new
		 FROM covid_data cd) x) 
update covid_data cd1
    set icu_new = c.icu_new,
        hosp_new = c.hosp_new,
        vent_new = c.vent_new,
        deaths_new = c.deaths_new
    from calculare c    
WHERE cd1.country_code = c.country_code AND cd1.report_date = c.report_date;    
   




-----------------------------------------------------------------------
 Care este tara cu cea mai mare rata de decese a populatiei?
-----------------------------------------------------------------------


-- la laborator

-- sol. 2 -- avand in vedere ca datele sunt cumulative

-- la laborator



-------------------------------------------------



----------------------------------------------------------------------


----TOP 3 tari cu cele mai mari rate de testare a populatiei?
	
-- la laborator
        
		
		
		



-- Care este regiunea geografica cu cele mai multe noi cazuri zilnice
SELECT *
FROM country_gen_info ;

-- la laborator

-- L8. Calculați rata zilnică a cazurilor depistate (procent), raportat la total populație


-- la laborator


-- L9. Calculați rata zilnică a cazurilor depistate (procent), raportat la numărul de teste
-- 10 min

-- pregatitoare Calculati, pentru fiecare tara , numarul de zile de la momentul inceputului pandemiei in tara respectiva

select age('2021-09-30','2021-02-01')	
select date_part ('day', age('2021-09-30','2021-02-01'))


-- la laborator





-- L10. Calculați, pentru fiecare țară și dată, numărul de zile de la prima zi a pandemiei în țara respectivă


-- la laborator



--ALL ANY

drop table if exists test1;
create table test1 as
select 'mere' as col1, 100 as col2 UNION ALL
select 'mere' as col1, 1000 as col2 UNION ALL
select 'mere' as col1, 500 as col2 UNION ALL
select 'mere' as col1, 300;

drop table if exists test2;
create table test2 as
select 'pere' as col1, 10 as col2 UNION ALL
select 'pere' as col1, 3000 as col2 UNION ALL
select 'pere' as col1, 400 as col2 UNION ALL
select 'pere' as col1, 200;


select * from test1;
select * from test2;

select * from test1 
where col2 > ANY (select col2 from test2);

select * from test1 
where col2 > ALL (select col2 from test2);

select * from test2 
where col2 > ALL (select col2 from test1);


---- Tara cu numarul cel mai mare de confirmari decat toate celelalte tari


select * from covid_data cd 
where cd.confirmed = (select max(confirmed) from covid_data cd2)

where cd.confirmed  >= all (select confirmed from covid_data cd2)







---Tara si data cu cele mai multe noi cazuri


-- la laborator



---Calculati corelatia dintre numarul de cazuri zilnic si PIB pe locuitor
--https://chartio.com/learn/postgresql/using-the-postgres-corr-function/

-- la laborator
