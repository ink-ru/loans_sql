/*
ORACLE with DUAL dummy table
https://rextester.com/WXXK49768
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

INSERT INTO Loans VALUES
    ('2009-12-12', 111110, 111111, 'RUR', 12000),
    ('2009-12-25', 111110, 111111, 'RUR', 5000),
    ('2010-01-12', 111110, 111111, 'RUR', -10100),
    ('2009-12-12', 111110, 122222, 'RUR', 10000),
    ('2009-12-14', 111110, 122222, 'RUR', -12000),
    ('2009-12-16', 111110, 122222, 'RUR', -20000),
    ('2009-12-29', 111110, 122222, 'RUR', -10000),
    ('2009-11-20', 220000, 222221, 'RUR', 25000),
    ('2009-11-27', 220001, 222221, 'RUR', -30000),
    ('2009-12-20', 220000, 222221, 'RUR', 20000),
    ('2009-12-31', 220001, 222221, 'RUR', -10000);

/* WITH pdcl AS (SELECT * FROM Loans) */

/*
SELECT DISTINCT
    Deal,
    sum(Sum) OVER (PARTITION BY Deal) AS debt_per_deal
FROM Loans
ORDER BY Deal;
*/

SELECT cast(Date AS DATE), Sum FROM Loans WHERE Deal = 222221 ORDER BY Date;

WITH b AS (SELECT
    Deal,
    Date,
    sum(Sum) OVER (PARTITION BY Deal ORDER By Date ASC) AS balance,
    Row_Number() OVER (PARTITION BY Deal ORDER By Date ASC) AS RowNum
FROM Loans
ORDER BY Deal DESC, Date
           ),
s AS (SELECT *, sign(balance) AS sign FROM b
--- WHERE balance < 0 OR RowNum = 1; ---- qualify by number (first)
      )
SELECT *,
CASE WHEN lag(sign) 
       OVER (ORDER BY Deal DESC) != sign 
       THEN RowNum END AS lo,
  CASE WHEN lead(sign) 
       OVER (ORDER BY Deal DESC) != sign 
       THEN coalesce(RowNum, 0) END AS hi
FROM s
