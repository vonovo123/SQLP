[인덱스 구성]
상품분류_PK : PRODUCT_TYPE_CD
상품_PK : PRODUCT_NO
주문_PK : CUST_NO + PRODUCT_NO + ORDER_DATE
주문_X1 : PRODUCT_NO + ORDER_DATE

select count(distinct p.PRODUCT_NO),
       sum(t.ORDER_PRICE),
	   sum(t.ORDER_AMOUNT),
	   round(avg(t.DISCOUNT_RATE),2)
  from PRODUCT33 p, ORDER33 t
 where t.PRODUCT_NO = p.PRODUCT_NO 
   and t.ORDER_DATE >= trunc(sysdate - 7)
   and exists (
       select 1
	     from PRODUCT_DIV33 
	    where PRODUCT_TYPE_CD = p.PRODUCT_TYPE_CD 
          and PRODUCT_TYPE_CD = '01'
          --and 상위분류코드 = 'AK'  
       )
;


-- 환경구성
-- DROP TABLE PRODUCT33 PURGE;
CREATE TABLE PRODUCT33
( PRODUCT_NO    VARCHAR2(6) 	NOT NULL
 ,PRODUCT_NAME     VARCHAR2(50) 	NOT NULL
 ,PRODUCT_PRICE    NUMBER(9) 	NOT NULL
 ,PRODUCT_TYPE_CD VARCHAR2(2) 	NOT NULL
) NOLOGGING
;

-- INSERT 상품테이블
INSERT /*+ APPEND */ INTO PRODUCT33
SELECT 
       'G'||LPAD(TO_CHAR(LEVEL),5,'0')        		PRODUCT_NO
	  ,'GD_NM_'||LPAD(TO_CHAR(LEVEL),8,'0')     	PRODUCT_NAME
	  ,ROUND(DBMS_RANDOM.VALUE(1000, 100000),-3) 	PRODUCT_PRICE
	  ,LPAD(ROUND(DBMS_RANDOM.VALUE(1, 10)),2,'0')	PRODUCT_TYPE_CD
FROM DUAL
CONNECT BY LEVEL <= 1000
;

COMMIT;

alter table PRODUCT33 add constraint pk_good primary key(PRODUCT_NO);

create table PRODUCT_DIV33 nologging
as
select distinct PRODUCT_TYPE_CD
      ,PRODUCT_TYPE_CD||'_명' 상품유형명
  from PRODUCT33 
;

alter table PRODUCT_DIV33 add constraint pk_good_br primary key(PRODUCT_TYPE_CD);

create table ORDER33
(
  CUST_NO varchar2(6) not null,
  PRODUCT_NO varchar2(6) not null,
  ORDER_DATE varchar2(13) not null,
  ORDER_PRICE number(12) not null,
  ORDER_AMOUNT number(9) not null,
  DISCOUNT_RATE number(4,2) not null
) nologging
;

insert /*+ append */ into ORDER33
select 'C'||to_char(round(dbms_random.value(1,1000)),'FM00009') CUST_NO
      ,'G'||to_char(round(dbms_random.value(1,1000)),'FM00009') PRODUCT_NO
	  ,sysdate - dbms_random.value(1,365) ORDER_DATE
	  ,round(dbms_random.value(1000,1000000),-2) ORDER_PRICE
	  ,round(dbms_random.value(1,100)) ORDER_AMOUNT
	  ,round(dbms_random.value(1,99),2) DISCOUNT_RATE
  from dual 
connect by level <= 1000000
;

-- 중복제거 (1번 이상 수행할 수도 있음)
delete from ORDER33
where rowid in (
select max(rowid)
  from ORDER33
group by CUST_NO, PRODUCT_NO, ORDER_DATE 
having count(*) > 1
)
;

commit;

alter table ORDER33 add constraint pk_ord33 primary key(CUST_NO, PRODUCT_NO, ORDER_DATE);
create index x01_ord33 on ORDER33(PRODUCT_NO, ORDER_DATE);

-- 아래 쿼리를 실행했을 경우 아래와 같이 실행계획이 표시 됩니다.
select count(distinct p.PRODUCT_NO),
       sum(t.ORDER_PRICE),
	   sum(t.ORDER_AMOUNT),
	   round(avg(t.DISCOUNT_RATE),2)
  from PRODUCT33 p, ORDER33 t
 where t.PRODUCT_NO = p.PRODUCT_NO 
   and t.ORDER_DATE >= trunc(sysdate - 7)
   and exists (
       select 1
	     from PRODUCT_DIV33 
	    where PRODUCT_TYPE_CD = p.PRODUCT_TYPE_CD 
          and PRODUCT_TYPE_CD = '01'
          --and 상위분류코드 = 'AK'  
       )
;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));


---------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name       | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |            |      1 |      1 |00:00:00.34 |    5732 |       |       |          |
|   1 |  SORT GROUP BY       |            |      1 |      1 |00:00:00.34 |    5732 |  4096 |  4096 | 4096  (0)|
|*  2 |   HASH JOIN          |            |      1 |   1218 |00:00:00.34 |    5732 |  2078K|  2078K| 1588K (0)|
|   3 |    NESTED LOOPS      |            |      1 |     68 |00:00:00.01 |      14 |       |       |          |
|*  4 |     INDEX UNIQUE SCAN| PK_GOOD_BR |      1 |      1 |00:00:00.01 |       1 |       |       |          |
|*  5 |     TABLE ACCESS FULL| PRODUCT33     |      1 |     68 |00:00:00.01 |      13 |       |       |          |
|*  6 |    TABLE ACCESS FULL | ORDER33     |      1 |  18819 |00:00:00.33 |    5718 |       |       |          |
---------------------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$5DA710D3
   4 - SEL$5DA710D3 / PRODUCT_DIV33@SEL$2
   5 - SEL$5DA710D3 / P@SEL$1
   6 - SEL$5DA710D3 / T@SEL$1
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$5DA710D3")
      UNNEST(@"SEL$2")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      INDEX(@"SEL$5DA710D3" "PRODUCT_DIV33"@"SEL$2" ("PRODUCT_DIV33"."PRODUCT_TYPE_CD"))
      FULL(@"SEL$5DA710D3" "P"@"SEL$1")
      FULL(@"SEL$5DA710D3" "T"@"SEL$1")
      LEADING(@"SEL$5DA710D3" "PRODUCT_DIV33"@"SEL$2" "P"@"SEL$1" "T"@"SEL$1")
      USE_NL(@"SEL$5DA710D3" "P"@"SEL$1")
      USE_HASH(@"SEL$5DA710D3" "T"@"SEL$1")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("T"."PRODUCT_NO"="P"."PRODUCT_NO")
   4 - access("PRODUCT_TYPE_CD"='01')
   5 - filter("P"."PRODUCT_TYPE_CD"='01')
   6 - filter(INTERNAL_FUNCTION("T"."ORDER_DATE")>=TRUNC(SYSDATE@!-7))