/*
From ORACLE

https://rextester.com/WXXK49768
https://rextester.com/JEATP10708

https://rextester.com/LPDK29606
https://rextester.com/HWL98099
https://rextester.com/NON43124

based on discussion
https://www.sql.ru/forum/1313400/raschyot-zadolzhennosti-po-lifo

T-SQL
https://www.sql.ru/forum/1313467-a/raschyot-daty-vozniknoveniya-zadolzhennosti-t-sql

https://habr.com/ru/post/268983/
*/

/* SET lc_time = 'ru_RU.UTF-8'; */

CREATE TABLE Loans (
    Date DATE DEFAULT current_date,
    Customer INT NOT NULL,
    Deal INT NOT NULL,
    Currency VARCHAR(6) DEFAULT 'RUR',
    Sum INT
);

/* 2017-08-15 */

INSERT INTO Loans VALUES
	('2009-12-12', 111110, 111111, 'RUR', 12000),
	('2009-12-25', 111110, 111111, 'RUR', 5000),
	('2009-12-12', 111110, 122222, 'RUR', 10000),
	('2010-01-12', 111110, 111111, 'RUR', -10100),
	('2009-11-20', 220000, 222221, 'RUR', 25000),
	('2009-12-20', 220000, 222221, 'RUR', 20000),
	('2009-12-31', 220001, 222221, 'RUR', -10000),
	('2009-12-29', 111110, 122222, 'RUR', -10000),
	('2009-11-27', 220001, 222221, 'RUR', -30000);
  
/* SELECT * FROM Loans; */

/* SELECT 'https://rextester.com/WXXK49768' AS "ORACLE_realisation"; */

WITH pdcl AS (SELECT * FROM Loans)
select Deal
     , max(over_sum) as liability_sum
     ---, DENSE_RANK() OVER ( partition by Deal order by Date desc) as liability_sum2
     , min(case when exclude_sign is null then Date end) as liability_date
  from (select Date
             , Deal
             , over_sum
             , lead(nullif(sign(over_sum),1), 1, nullif(sign(over_sum),1)) over (partition by Deal order by Date) as exclude_sign
          from ( select Date, Deal, sum(Sum) over(partition by Deal order by Date) as over_sum from pdcl
               ) as th1
       ) as th2
group by Deal
