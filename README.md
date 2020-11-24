# Loans report

Иммеем произвольный набор данных следкющей структуры:
|Date |Deal |Sum|
|---|---|---|
|12.12.2009 |111111 |12000|
|25.12.2009 |111111 |5000|
|12.12.2009 |122222 |10000|
|12.01.2010 |111111 |-10100|
|20.11.2009 |222221 |25000|
|20.12.2009 |222221 |20000|
|31.12.2009 |222221 |-10000|
|29.12.2009 |122222 |-10000|
|27.11.2009 |222221 |-30000|

Date - Дата
Customer - Номер клиента
Deal - Номер кредита
Currency - Валюта кредита
Sum - сумма, вынесенная на просрочку ("+") или выплаченная ("-")

Нужно найти
1. Общую (накопленную) сумму просроченного долга непогашенную (не выплаченную) к моменту расчета.
2. Дату начала текущей (последней) просрочки. Под датой начала просрочки, в данной задаче понимается первая дата непрерывного периода, в котором общая сумма просроченного непогашенного долга > 0.Учесть, что периодов просрочек может быть несколько.
3. Кол-во дней текущей просрочки.

Online DEMO:
* https://rextester.com/BGG79548 ([source](https://github.com/ink-ru/loans_sql/blob/master/oracle3.sql))
* https://rextester.com/TGCV48872 

Изначально стояла цель выполнить задания без использования временных таблиц и хранимых процедур.

Написать реализацию на PostgreSQL несколько сложнее чем на ORACLE. Чать синтаксического сахара нужно заменять [окнами](https://habr.com/ru/post/268983/) Но некоторые функции заменить сложно, например в БД Sybase SQL Anywhere, DB2, Redshift и Oracle можно использовать лексему "IGNORE NULLS".

![Схема последовательности обработки условий окон](https://www.sqlite.org/images/syntax/frame-spec.gif)

`ignore nulls` in Postgress:
https://dba.stackexchange.com/questions/224332/window-function-ignore-nulls-workaround-for-postgresql

`keep` in Postgress:
https://stackoverflow.com/questions/29750563/convert-keep-dense-rank-from-oracle-query-into-postgres

Первая часть задания выполняется достаточно просто. Как выполнить остальные чатси запроса описано тут:
* https://habr.com/ru/post/270573/


Другие ваианты решений на базе ORACLE:
* https://rextester.com/ERU78446 ([source](https://github.com/ink-ru/loans_sql/blob/master/oracle2.sql))
* https://rextester.com/WXXK49768 ([source](https://github.com/ink-ru/loans_sql/blob/master/oracle.sql))

Based on discussions:
* https://www.sql.ru/forum/1313400/raschyot-zadolzhennosti-po-lifo
* https://www.sql.ru/forum/1313467-a/raschyot-daty-vozniknoveniya-zadolzhennosti-t-sql
