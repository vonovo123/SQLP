[테이블 구성]
-- 고객 테이블 
-- drop table CUST39 purge;

DROP TABLE CUST39 PURGE;

CREATE TABLE CUST39
(
  CUST_NO VARCHAR2(9),
  CUST_NM VARCHAR2(30),
  REG_DT DATE,
  MGTN_NO VARCHAR2(4),
  TEL_NO VARCHAR2(11),
  CUST_DV_CD VARCHAR2(2),
  TOTAL_AMOUNT NUMBER(12)
  -- CONSTRAINT CUSTOMER39_PK PRIMARY KEY(CUST_NO)
) NOLOGGING
;

INSERT /*+ APPEND */ INTO CUST39
SELECT 
    'C'||TO_CHAR(ROWNUM, 'FM00000009') CUST_NO,
    'C_'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,5000),-1), 'FM0009')
        ||TO_CHAR(ROWNUM, 'FM00000009')
        ||'_CUST_NM'                                           CUST_NM,
    SYSDATE - DBMS_RANDOM.VALUE(0,365*10) REG_DT,
    TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1,9999),-2),'FM0009')     MGTN_NO,
    '010'||
    TO_CHAR(DBMS_RANDOM.VALUE(1,9999),'FM0009')||
    TO_CHAR(DBMS_RANDOM.VALUE(1,9999),'FM0009')               TEL_NO,
	TO_CHAR(DBMS_RANDOM.VALUE(1,5),'FM09')                    CUST_DV_CD,       -- 01 개인 02 법인 03 사업자 04 영리단체 05 비영리단체 
    ROUND(DBMS_RANDOM.VALUE(5000, 1000000), -3)               TOTAL_AMOUNT
  FROM DUAL
CONNECT BY LEVEL <= 100000
;

COMMIT;

select COUNT(*) from CUST39;

EXEC DBMS_STATS.GATHER_TABLE_STATS('SYSTEM', 'CUST39');

-- 거래 테이블 1,000,000건
-- drop table TRAN39 purge;
create table TRAN39
(
   CUST_NO varchar2(9) not null
  ,TRAN_DT date not null
  ,TRAN_AMOUNT number(12) not null
)
nologging
;

insert /*+ append */ into TRAN39
select /*+ parallel(4) */
        'C'||to_char(dbms_random.value(1,1000000),'FM00000009') CUST_NO,
        sysdate - dbms_random.value(1,730) TRAN_DT,
		round(dbms_random.value(1000,100000),-2) TRAN_AMOUNT       
  from dual
connect by level <= 1000000
;

commit;

exec dbms_stats.gather_table_stats('SYSTEM', 'TRAN39', cascade=>true);

[인덱스 구성]
고객_PK : CUST_NO
고객_X1 : REG_DT
 
거래_PK : CUST_NO + TRAN_DT
거래_X1 : TRAN_DT
-- 거래_X2 : CUST_NO + TRAN_DT


alter table CUST39 add constraints PK_CUST primary key (CUST_NO);

alter table TRAN39 add constraints PK_TRAN primary key (CUST_NO, TRAN_DT);

create index X1_CUST on CUST39(REG_DT);
create index X1_TRAN on TRAN39(TRAN_DT);

-- select max(REG_DT) from CUST39;

--부분범위 처리가 가능한 상황에서 아래 SQL 을 최적화 하시오. 
--(쿼리를 그대로 둔 체 최적화할 수 있다면 힌트를 정확히 기술하고, 
--필요하다면 인덱스 재구성한도 제시할 것)

select /*+index(c)*/
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));


--------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |     74 |00:00:00.09 |   13798 |       |       |          |
|   1 |  HASH GROUP BY      |      |      1 |     74 |00:00:00.09 |   13798 |   816K|   816K| 1368K (0)|
|*  2 |   HASH JOIN         |      |      1 |     74 |00:00:00.09 |   13798 |  1448K|  1448K| 1470K (0)|
|*  3 |    TABLE ACCESS FULL| 거래3|      1 |   5075 |00:00:00.03 |    3754 |       |       |          |
|*  4 |    TABLE ACCESS FULL| 고객3|      1 |  13793 |00:00:00.05 |   10044 |       |       |          |
--------------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$1
   2 - SEL$2 / T@SEL$1
   3 - SEL$2
   4 - SEL$2 / TRAN39@SEL$2
   5 - SEL$1 / C@SEL$1
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      NO_ACCESS(@"SEL$1" "T"@"SEL$1")
      FULL(@"SEL$1" "C"@"SEL$1")
      LEADING(@"SEL$1" "T"@"SEL$1" "C"@"SEL$1")
      USE_HASH(@"SEL$1" "C"@"SEL$1")
      FULL(@"SEL$2" "TRAN39"@"SEL$2")
      USE_HASH_AGGREGATION(@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("T"."CUST_NO"="C"."CUST_NO")
   4 - filter("TRAN_DT">=TRUNC(SYSDATE@!,'fmmm'))
   5 - filter("C"."REG_DT">=TRUNC(ADD_MONTHS(SYSDATE@!,-19),'fmmm'))



SELECT A.TABLE_NAME
     , A.CONSTRAINT_NAME
     , B.COLUMN_NAME     
     , B.POSITION
FROM ALL_CONSTRAINTS  A
     , ALL_CONS_COLUMNS B
WHERE A.TABLE_NAME      = 'TRAN39'
   AND A.CONSTRAINT_TYPE = 'P' 
   AND A.OWNER           = B.OWNER
   AND A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
 ORDER BY B.POSITION

ALTER TABLE TRAN39 DROP PRIMARY KEY DROP INDEX;