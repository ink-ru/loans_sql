-- Oracle
-- https://www.orafaq.com/wiki/Oracle_Row_Generator_Techniques
select * FROM (
    SELECT ROWNUM, TRUNC(SYSDATE,'Y')-ROWNUM-1 thedate, CREATED, round(dbms_random.value() * 8) + 1
    FROM ALL_OBJECTS
    order by dbms_random.value
    )
where rownum <= 4\\
