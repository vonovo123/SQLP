select /*+leading(p) use_nl(t) INDEX(p X01_PRODUCT33) INDEX(t)*/ 
      count(distinct p.PRODUCT_NO),
       sum(t.ORDER_PRICE),
	   sum(t.ORDER_AMOUNT),
	   round(avg(t.DISCOUNT_RATE),2)
  from PRODUCT33 p, ORDER33 t
 where t.PRODUCT_NO = p.PRODUCT_NO 
   and t.ORDER_DATE >= trunc(sysdate - 7)
   and exists (
       select /*+no_unnest push_subq*/1
	     from PRODUCT_DIV33 
	     where PRODUCT_TYPE_CD = p.PRODUCT_TYPE_CD 
          and PRODUCT_TYPE_CD = '01'
          --and 상위분류코드 = 'AK'  
       )
;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));


------------------------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	  | Starts | E-Rows | A-Rows |	 A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		  |	 1 |	    |	   1 |00:00:02.00 |    5541 |	    |	    |	       |
|   1 |  SORT GROUP BY	     |		  |	 1 |	  1 |	   1 |00:00:02.00 |    5541 |  5120 |  5120 | 4096  (0)|
|*  2 |   HASH JOIN	     |		  |	 1 |	824 |	 943 |00:00:01.99 |    5541 |  2078K|  2078K|	74M (0)|
|   3 |    NESTED LOOPS      |		  |	 1 |	 56 |	  56 |00:00:00.01 |	  8 |	    |	    |	       |
|*  4 |     INDEX UNIQUE SCAN| PK_GOOD_BR |	 1 |	  1 |	   1 |00:00:00.01 |	  1 |	    |	    |	       |
|*  5 |     TABLE ACCESS FULL| PRODUCT33  |	 1 |	 56 |	  56 |00:00:00.01 |	  7 |	    |	    |	       |
|*  6 |    TABLE ACCESS FULL | ORDER33	  |	 1 |  14733 |  17227 |00:00:01.44 |    5533 |	    |	    |	       |
------------------------------------------------------------------------------------------------------------------------

create index X01_PRODUCT33 on PRODUCT33(PRODUCT_TYPE_CD);
