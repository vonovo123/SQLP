/* 아래 SQL은 OLTP 에서 자주 사용되는구문이다. trace를 보고 튜닝을 하시오. (인덱스 변경 가능)
테이블 정보
 - T_ORDER53   : 0.1 억 건 (20090101 이후 200,000건)
 - T_PRODUCT53 : 10,000건
 - T_MANUF53   : 50건
인덱스 
  PRODUCT53 : PK_T_PRODUCT53(PROD_ID);
  T_MANUF53 : PK_T_MANUF53(M_CODE);  
*/
SELECT /*+ ORDERED USE_NL(B C) */
       DISTINCT B.M_CODE, C.M_NM
FROM T_ORDER53 A, 
     T_PRODUCT53 B, 
     T_MANUF53 C
WHERE A.ORDER_DT >= '20090101'
AND A.PROD_ID    = B.PROD_ID
AND B.M_CODE     = C.M_CODE;
/*
---------------------------------------------------------------------------------------
| Id  | Operation                       | Name            | A-Rows | Buffers | Reads  |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |                 |     50 |   40579 |  40161 |
|   1 |  HASH UNIQUE                    |                 |     50 |   40579 |  40161 |
|   2 |   NESTED LOOPS                  |                 |    200 |   40579 |  40161 |
|   3 |    NESTED LOOPS                 |                 |    200 |   40379 |  40161 |
|   4 |     NESTED LOOPS                |                 |    200 |   40375 |  40161 |
|   5 |      VIEW                       | VW_DTP_377C5901 |    200 |   40166 |  40161 |
|   6 |       HASH UNIQUE               |                 |    200 |   40166 |  40161 |
|*  7 |        TABLE  ACCESS FULL        | T_ORDER53       |    200K|   40166 |  40161 |
|   8 |      TABLE ACCESS BY INDEX ROWID| T_PRODUCT53     |    200 |     209 |      0 |
|*  9 |       INDEX UNIQUE SCAN         | PK_T_PRODUCT53  |    200 |       9 |      0 |
|* 10 |     INDEX UNIQUE SCAN           | PK_T_MANUF53    |    200 |       4 |      0 |
|  11 |    TABLE ACCESS BY INDEX ROWID  | T_MANUF53       |    200 |     200 |      0 |
---------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   7 - filter("A"."ORDER_DT">='20090101')
   9 - access("ITEM_1"="B"."PROD_ID")
  10 - access("B"."M_CODE"="C"."M_CODE")
*/

SELECT COUNT(*) FROM T_ORDER53 A WHERE ORDER_DT >= '20090101';

-- DISTINCT 튜닝으로 HASH UNIQUE 없에기
SELECT /*+ ORDERED USE_NL(B C) */
DISTINCT B.M_CODE, C.M_NM
FROM T_ORDER53 A, 
     T_PRODUCT53 B, 
     T_MANUF53 C
WHERE A.ORDER_DT >= '20090101'
AND A.PROD_ID    = B.PROD_ID
AND B.M_CODE     = C.M_CODE;

SELECT B.M_CODE M_CODE , C.M_NM M_NM 
FROM T_PRODUCT53 B, T_MANUF53 C
WHERE B.M_CODE = C.M_CODE

SELECT /*+ INDEX(C PK_T_MANUF53)*/
C.M_CODE, C.M_NM
FROM T_MANUF53 C
WHERE EXISTS (
  SELECT 1 
    FROM T_PRODUCT53 B
    WHERE M_CODE = C.M_CODE
    AND EXISTS (
      SELECT 1 
      FROM T_ORDER53
      WHERE PROD_ID = B.PROD_ID
      AND ORDER_DT >= '20090101'
    )
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));

DROP INDEX IDX_T_PRODUCT53
CREATE INDEX IDX_T_PRODUCT53 ON T_PRODUCT53(M_CODE, PROD_ID);

DROP INDEX IDX_T_ORDER53;
CREATE INDEX IDX_T_ORDER53 ON T_ORDER53(ORDER_DT, PROD_ID);



ALTER SESSION SET STATISTICS_LEVEL=ALL;


SELECT count(*)
FROM T_ORDER53
WHERE ORDER_DT >= '20090101';

SELECT 1
FROM T_PRODUCT53 B
WHERE EXISTS (
  SELECT 1 /*+INDEX(IDX_T_ORDER53)*/
  FROM T_ORDER53
  WHERE PROD_ID = B.PROD_ID
  AND ORDER_DT >= '20090101'
)


SELECT 
*
FROM T_MANUF53 C
WHERE EXISTS (
  SELECT 1 
  FROM T_PRODUCT53 B
  WHERE M_CODE = C.M_CODE 
)


SELECT
*
FROM T_PRODUCT53 B
WHERE EXISTS (
  SELECT 1 
  FROM T_MANUF53 
  WHERE M_CODE = B.M_CODE 
)




SELECT /*+ ORDERED USE_NL(B C) */
       DISTINCT B.M_CODE, A.M_NM
FROM T_MANUF53   A,
     T_PRODUCT53 B, 
     T_ORDER53   C
WHERE B.M_CODE     = A.M_CODE;
AND C.PROD_ID    = B.PROD_ID
AND C.ORDER_DT >= '20090101'

DROP INDEX IDX_T_PRODUCT53;
CREATE INDEX IDX_T_PRODUCT53 ON T_PRODUCT53(M_CODE, PROD_ID);

DROP INDEX IDX_T_ORDER53;
CREATE INDEX IDX_T_ORDER53 ON T_ORDER53(ORDER_DT, PROD_ID);

DROP INDEX IDX_T_ORDER53;
CREATE INDEX IDX_T_ORDER53 ON T_ORDER53(PROD_ID, ORDER_DT);



select * FROM
T_MANUF53   A,
T_PRODUCT53 B
WHERE B.M_CODE     = A.M_CODE;

select count(*) FROM
T_PRODUCT53   B,
T_ORDER53 C
WHERE C.PROD_ID    = B.PROD_ID
AND C.ORDER_DT >= '20090101';


SELECT /*+ LEADING(B A C) USE_HASH(B A) INDEX(C PK_T_MANUF53)*/
       DISTINCT B.M_CODE, C.M_NM
FROM T_ORDER53 A, 
     T_PRODUCT53 B, 
     T_MANUF53 C
WHERE A.PROD_ID    = B.PROD_ID
AND  A.ORDER_DT >= '20090101'
AND B.M_CODE     = C.M_CODE
ORDER BY B.M_CODE;
USE_NL(C) SWAP_JOIN_INPUTS(B) NO_SWAP_JOIN_INPUTS(A)

SELECT /*+FULL(A) HASH_SJ(P@RROD) HASH_SJ(O@ORD)*/
A.M_CODE, A.M_NM
FROM T_MANUF53 A
WHERE EXISTS (
  SELECT /*+UNNEST QB_NAME(PROD)*/
  1 
    FROM T_PRODUCT53 P
    WHERE M_CODE = A.M_CODE
    AND EXISTS (
      SELECT /*+UNNEST QB_NAME(ORD)*/
      1 
      FROM T_ORDER53 O
      WHERE PROD_ID = P.PROD_ID
      AND ORDER_DT >= '20090101'
    )
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));
