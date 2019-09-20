# Loans report



Online DEMO on ORACLE - https://rextester.com/WXXK49768

Написать реализацию на PostgreSQL несколько сложнее чем на ORACLE. Чать синтаксического сахара нужно заменять [окнами](https://habr.com/ru/post/268983/) Но некоторые функции заменить сложно, например в БД Sybase SQL Anywhere, DB2, Redshift и Oracle можно использовать лексему "IGNORE NULLS".

ignore nulls in Postgress:
https://dba.stackexchange.com/questions/224332/window-function-ignore-nulls-workaround-for-postgresql

keep in Postgress:
https://stackoverflow.com/questions/29750563/convert-keep-dense-rank-from-oracle-query-into-postgres

Первая часть задания выполняется достаточно просто:
```sql
SELECT DISTINCT
    Deal,
    sum(Sum) OVER (PARTITION BY Deal) AS debt_per_deal
FROM Loans
ORDER BY Deal;
```
Как выполнить остальные чатси запроса описано тут:
* https://habr.com/ru/post/270573/

Based on discussions:
* https://www.sql.ru/forum/1313400/raschyot-zadolzhennosti-po-lifo
* https://www.sql.ru/forum/1313467-a/raschyot-daty-vozniknoveniya-zadolzhennosti-t-sql
