WITH pdcl AS (
SELECT to_date ('12.12.2009', 'dd.mm.yyyy') "Date", 111110 Customer, 111111 Deal, 'RUR' Currency, 12000 "Sum" FROM dual UNION ALL
SELECT to_date ('25.12.2009', 'dd.mm.yyyy') "Date", 111110 Customer, 111111 Deal, 'RUR' Currency, 5000 "Sum" FROM dual UNION ALL
SELECT to_date ('12.12.2009', 'dd.mm.yyyy') "Date", 111110 Customer, 122222 Deal, 'RUR' Currency, 10000 "Sum" FROM dual UNION ALL
SELECT to_date ('12.01.2010', 'dd.mm.yyyy') "Date", 111110 Customer, 111111 Deal, 'RUR' Currency, -10100 "Sum" FROM dual UNION ALL
SELECT to_date ('20.11.2009', 'dd.mm.yyyy') "Date", 220000 Customer, 222221 Deal, 'RUR' Currency, 25000 "Sum" FROM dual UNION ALL
SELECT to_date ('20.12.2009', 'dd.mm.yyyy') "Date", 220000 Customer, 222221 Deal, 'RUR' Currency, 20000 "Sum" FROM dual UNION ALL
SELECT to_date ('31.12.2009', 'dd.mm.yyyy') "Date", 220001 Customer, 222221 Deal, 'RUR' Currency, -10000 "Sum" FROM dual UNION ALL
SELECT to_date ('29.12.2009', 'dd.mm.yyyy') "Date", 111110 Customer, 122222 Deal, 'RUR' Currency, -10000 "Sum" FROM dual UNION ALL
SELECT to_date ('27.11.2009', 'dd.mm.yyyy') "Date", 220001 Customer, 222221 Deal, 'RUR' Currency, -30000 "Sum" FROM dual
)
SELECT Deal,
    max(debt_amount) keep (dense_rank first ORDER BY "Date" DESC) debt_total,
    min(case when exclude_sign is null then "Date" end) debt_date
FROM (SELECT "Date", Deal, debt_amount,
        lead(nullif(sign(debt_amount),1) ignore nulls, 1, nullif(sign(debt_amount),1)) over (partition by Deal ORDER BY "Date") exclude_sign
    FROM (SELECT "Date", Deal, sum("Sum") over(partition by Deal ORDER BY "Date") debt_amount FROM pdcl)
      )
GROUP BY Deal
