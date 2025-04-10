select 
c.CUST_NO, c.CUST_NM, t.AVG_T, t.MIN_T, t.MAX_T
from CUST39 c,
       (select 
       CUST_NO, avg(TRAN_AMOUNT) AVG_T, min(TRAN_AMOUNT) MIN_T, max(TRAN_AMOUNT) MAX_T 
       from TRAN39
       where TRAN_DT >= trunc(sysdate, 'mm')
       group by CUST_NO) t
 where c.REG_DT >= trunc(add_months(sysdate,-19), 'mm')  -- 1개월 데이터
   and t.CUST_NO = c.CUST_NO
;

--------------------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |	      |      1 |	|    141 |00:00:02.04 |    4711 |	|	|	   |
|*  1 |  HASH JOIN	     |	      |      1 |   8644 |    141 |00:00:02.04 |    4711 |  1601K|  1601K|   77M (0)|
|   2 |   VIEW		     |	      |      1 |   8644 |   8589 |00:00:00.42 |    3725 |	|	|	   |
|   3 |    HASH GROUP BY     |	      |      1 |   8644 |   8589 |00:00:00.23 |    3725 |  1547K|  1547K|   16M (0)|
|*  4 |     TABLE ACCESS FULL| TRAN39 |      1 |   8666 |   8625 |00:00:00.09 |    3725 |	|	|	   |
|*  5 |   TABLE ACCESS FULL  | CUST39 |      1 |  17000 |  16112 |00:00:00.19 |     986 |	|	|	   |
--------------------------------------------------------------------------------------------------------------------


SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));


select /*+LEADING(c) USE_NL(t) index(c X1_CUST)*/
c.CUST_NO, c.CUST_NM, t.AVG_T, t.MIN_T, t.MAX_T
from CUST39 c,
       (select /*+no_merge push_pred*/ 
       CUST_NO, avg(TRAN_AMOUNT) AVG_T, min(TRAN_AMOUNT) MIN_T, max(TRAN_AMOUNT) MAX_T 
       from TRAN39
       where TRAN_DT >= trunc(sysdate, 'mm')
       group by CUST_NO) t
 where c.REG_DT >= trunc(add_months(sysdate,-1), 'mm')  -- 1개월 데이터
   and t.CUST_NO = c.CUST_NO
;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));


select /*+leading(c) use_nl(t) push_pred(t) index(c X1_CUST)*/
c.CUST_NO, c.CUST_NM, t.AVG_T, t.MIN_T, t.MAX_T
from CUST39 c,
       (select /*+no_merge push_pred*/ 
       CUST_NO, avg(TRAN_AMOUNT) AVG_T, min(TRAN_AMOUNT) MIN_T, max(TRAN_AMOUNT) MAX_T 
       from TRAN39
       where TRAN_DT >= trunc(sysdate, 'mm')
       group by CUST_NO) t
 where c.REG_DT >= trunc(add_months(sysdate,-19), 'mm')  -- 1개월 데이터
   and t.CUST_NO = c.CUST_NO
;