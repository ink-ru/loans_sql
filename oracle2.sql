WITH pdcl AS
(SELECT to_date ('12.12.2009', 'dd.mm.yyyy') DDate, 111110 Customer, 111111 deal, 'RUR' Currency, 12000 SSum FROM dual UNION ALL
SELECT to_date ('25.12.2009', 'dd.mm.yyyy') DDate, 111110 Customer, 111111 deal, 'RUR' Currency, 5000 SSum FROM dual UNION ALL
SELECT to_date ('12.12.2009', 'dd.mm.yyyy') DDate, 111110 Customer, 122222 deal, 'RUR' Currency, 10000 SSum FROM dual UNION ALL
SELECT to_date ('12.01.2010', 'dd.mm.yyyy') DDate, 111110 Customer, 111111 deal, 'RUR' Currency, -10100 SSum FROM dual UNION ALL
SELECT to_date ('20.11.2009', 'dd.mm.yyyy') DDate, 220000 Customer, 222221 deal, 'RUR' Currency, 25000 SSum FROM dual UNION ALL
SELECT to_date ('20.12.2009', 'dd.mm.yyyy') DDate, 220000 Customer, 222221 deal, 'RUR' Currency, 20000 SSum FROM dual UNION ALL
SELECT to_date ('31.12.2009', 'dd.mm.yyyy') DDate, 220001 Customer, 222221 deal, 'RUR' Currency, -10000 SSum FROM dual UNION ALL
SELECT to_date ('29.12.2009', 'dd.mm.yyyy') DDate, 111110 Customer, 122222 deal, 'RUR' Currency, -10000 SSum FROM dual UNION ALL
SELECT to_date ('27.11.2009', 'dd.mm.yyyy') DDate, 220001 Customer, 222221 deal, 'RUR' Currency, -30000 SSum FROM dual),
t AS (
	SELECT nvl(LEAD(a.DDate) OVER (partition by a.deal ORDER BY a.DDate), to_date('01.01.4000','dd.mm.yyyy')) next_date
				,a.DDate, a.deal, a.SSum
				,nvl(SUM(CASE WHEN PR.SSum > 0 THEN PR.SSum END),0) prev_date
				,nvl(SUM(CASE WHEN PR.SSum < 0 THEN PR.SSum END),0) prev_payment
				,nvl(SUM(CASE WHEN PR.SSum > 0 THEN PR.SSum END),0) + nvl(SUM(CASE WHEN PR.SSum < 0 THEN PR.SSum END),0) debt
	FROM pdcl a
	LEFT JOIN pdcl PR
		ON PR.DDate< a.DDate
		AND PR.DEAL=a.DEAL    
	WHERE a.SSum > 0
	GROUP BY a.DDate, a.deal, a.SSum
	ORDER BY a.deal, a.DDate),
pd AS (
	SELECT t.DDate, t.next_date, t.deal,
				CASE WHEN debt < 0 THEN t.SSum+debt ELSE t.SSum END SSum
				,nvl(SUM(CASE WHEN NT.SSum < 0 and NT.DDate between t.DDate AND t.next_date-1 THEN NT.SSum END),0) cur_PAY
				,nvl(SUM(CASE WHEN NT.SSum > 0 THEN NT.SSum END),0) next_INST
				,nvl(SUM(CASE WHEN NT.SSum < 0 AND NT.DDate >= t.next_date THEN NT.SSum END),0) next_PAY
	FROM t
	LEFT JOIN pdcl NT
		ON NT.DDate> t.DDate
		AND NT.DEAL=t.DEAL
	GROUP BY t.DDate, t.next_date, t.deal, t.SSum, prev_date, prev_payment, debt
)      
SELECT DEAL,
	SSum + CUR_PAY+next_INST + next_PAY,
	max(DDate)keep(dense_rank first ORDER BY DDate) over (partition by deal) pd_dt
FROM pd
WHERE SSum + CUR_PAY > 0
ORDER BY DEAL, DDate
