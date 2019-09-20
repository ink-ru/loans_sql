WITH t ("Date" ,"Deal" ,"Sum") AS (
	SELECT to_date('12.12.2009' , 'DD.MM.YYYY'), 111111, 12000 FROM DUAL UNION ALL
	SELECT to_date('25.12.2009' , 'DD.MM.YYYY'), 111111, 5000  FROM DUAL UNION ALL
	SELECT to_date('12.12.2009' , 'DD.MM.YYYY'), 122222, 10000 FROM DUAL UNION ALL
	SELECT to_date('12.01.2010' , 'DD.MM.YYYY'), 111111,-10100 FROM DUAL UNION ALL
	SELECT to_date('20.11.2009' , 'DD.MM.YYYY'), 222221, 25000 FROM DUAL UNION ALL
	SELECT to_date('20.12.2009' , 'DD.MM.YYYY'), 222221, 20000 FROM DUAL UNION ALL
	SELECT to_date('31.12.2009' , 'DD.MM.YYYY'), 222221,-10000 FROM DUAL UNION ALL
	SELECT to_date('29.12.2009' , 'DD.MM.YYYY'), 122222,-10000 FROM DUAL UNION ALL
	SELECT to_date('27.11.2009' , 'DD.MM.YYYY'), 222221,-30000 FROM DUAL UNION ALL
	SELECT to_date('27.11.2009' , 'DD.MM.YYYY'), 222221,-1000  FROM DUAL UNION ALL
	SELECT to_date('27.11.2009' , 'DD.MM.YYYY'), 333331,-10000 FROM DUAL UNION ALL
	SELECT to_date('28.11.2009' , 'DD.MM.YYYY'), 333331, 5000  FROM DUAL UNION ALL
	SELECT to_date('29.11.2009' , 'DD.MM.YYYY'), 333331, 1000  FROM DUAL UNION ALL
	SELECT to_date('02.12.2009' , 'DD.MM.YYYY'), 333331, 2000  FROM DUAL UNION ALL
	SELECT to_date('01.12.2009' , 'DD.MM.YYYY'), 555551, 15000 FROM DUAL UNION ALL
	SELECT to_date('02.12.2009' , 'DD.MM.YYYY'), 555551,-15000 FROM DUAL UNION ALL
	SELECT to_date('03.12.2009' , 'DD.MM.YYYY'), 555551,  5000 FROM DUAL UNION ALL
	SELECT to_date('04.12.2009' , 'DD.MM.YYYY'), 555551, -5000 FROM DUAL UNION ALL
	SELECT to_date('05.12.2009' , 'DD.MM.YYYY'), 555551, 12000 FROM DUAL UNION ALL
	SELECT to_date('06.12.2009' , 'DD.MM.YYYY'), 555551,  2000 FROM DUAL UNION ALL
	SELECT to_date('07.12.2009' , 'DD.MM.YYYY'), 555551,  2000 FROM DUAL UNION ALL
	SELECT to_date('08.12.2009' , 'DD.MM.YYYY'), 555551,-16000 FROM DUAL
), a AS
(
		SELECT "Date", "Deal", "Sum"
				 , trunc(sysdate) - "Date" - 3400 AS Days														-- количество дней прошедших с этой даты
				 , sum("Sum") OVER (partition by "Deal" ORDER BY "Date") AS Balance -- сумма всех операций по каждому кредиту отдельно
			FROM t
), b AS
(
		SELECT "Date", "Deal", "Sum", Balance, Days
				 , CASE WHEN sign(Balance) <= 0 THEN 0 ELSE 1 END AS sign						-- знак баланса на текущую дату
				 , CASE WHEN sign(Balance) > 0  THEN 0 ELSE 1 END AS sign_inverted	-- инвертированный знак баланса
			FROM a
), q AS
(
		SELECT "Date", "Deal", "Sum", Balance, Days, sign, sign_inverted
				 , sign * (sum(sign_inverted) OVER (ORDER BY "Deal", "Date") + 1) weight -- вес операции по отношению к операциям за все время
			FROM b
		  ORDER BY "Deal", "Date"
), r AS
(
	  SELECT to_char("Date", 'DD.MM.YY') AS "Date", "Deal", "Sum", Balance, Days, sign, sign_inverted, weight
		 -- to_char - преобразование типа для форматирования даты
		 , last_value(Balance) OVER (partition by "Deal" ORDER BY  "Date" RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) "Debt_1"
		 -- last_value возвращает одно значение на самую последнюю дату за счет сортировки
		 -- UNBOUNDED PRECEDING начиная с первого элемента окна
		 -- UNBOUNDED FOLLOWING заканчивая последним элементом окна
		 , to_char(first_value(CASE WHEN weight = 0 THEN null ELSE "Date" END)
		 		-- first_value первая дата из окна
				  OVER (partition by "Deal" ORDER BY weight desc, "Date" asc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), 'DD.MM.YY') "Debt_date_2"
		 		-- сортировка по весу
		 , CASE WHEN last_value(Balance) OVER (partition by "Deal" ORDER BY  "Date" RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) > 0
		 				-- проверка на положительность баланса
						THEN first_value(CASE WHEN weight = 0 THEN null ELSE Days END)
								 OVER (partition by "Deal" ORDER BY weight desc, "Date" asc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
						-- первое значение дней с сортировкой по весу
						ELSE null END "Debt_days_3"
			FROM q
)
SELECT DISTINCT "Deal", "Debt_1" AS "1. Debt", CASE WHEN "Debt_days_3" IS NOT NULL THEN "Debt_date_2" ELSE NULL END AS "2. Debt date", "Debt_days_3" AS "3. Debt days" FROM r
