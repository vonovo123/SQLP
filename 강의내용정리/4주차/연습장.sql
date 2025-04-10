페이징 처리 SQL을 튜닝하시오. (인덱스 생성 가능/불필요한 인덱스는 감점요소임)
 1) T_USR60 (사용자)
    - 1만건
 2) T_BBM60 (게시판)
    - 100만건
    - BBM_TYPE = 'NOR' AND DEL_YN = 'N' 조건 40건
    - 동일 사용자가 게시한 글이 거의 없다는 전제
*/
SELECT BBM_NO, BBM_TITL, BBM_CONT, REG_NM, REG_DTM
FROM  (SELECT BBM_NO, BBM_TITL, BBM_CONT, REG_NM, REG_DTM, ROWNUM RNUM
       FROM (SELECT BBM_NO, BBM_TITL, BBM_CONT, FN_GETREGNM(REG_NO) REG_NM, REG_DTM
             FROM T_BBM60
             WHERE BBM_TYP = 'NOR'
               AND DEL_YN  = 'N'
             ORDER BY REG_DTM DESC
            )
       )      
WHERE RNUM BETWEEN 11 AND 20
ORDER BY RNUM
;

-- FN_GETREGNM
SELECT A.USRNM  INTO RESULT
FROM T_USR60 A
WHERE A.USRNO = V_ID;
    

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));




CREATE INDEX IDX_T_BBM60 ON T_BBM60(BBM_TYP, DEL_YN);


-- IDX_T_BBM60 (BBM_TYP, DEL_YN, REG_DTM)

SELECT BBM_NO, BBM_TITL, BBM_CONT,
 (
  SELECT USRNM  
  FROM T_USR60 
  WHERE USRNO = A.REG_NO
 ) REG_NM, REG_DTM
FROM (
  SELECT BBM_NO, BBM_TITL, BBM_CONT, REG_NO, REG_DTM, ROWNUM RNUM
    FROM (
      SELECT BBM_NO, BBM_TITL, BBM_CONT, REG_NO, REG_DTM
      FROM T_BBM60
      WHERE BBM_TYP = 'NOR'
      AND DEL_YN  = 'N'
      ORDER BY REG_DTM DESC
  ) 
  WHERE ROWNUM <= 20
) A
WHERE RNUM >= 11;  

------------------------------------------------------------------------------------------------------------------
| Id  | Operation			| Name	      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT		|	      |      1 |	|     10 |00:00:00.01 |      24 |      2 |
|   1 |  TABLE ACCESS BY INDEX ROWID	| T_USR60     |     10 |      1 |     10 |00:00:00.01 |      22 |      0 |
|*  2 |   INDEX UNIQUE SCAN		| PK_T_USR60  |     10 |      1 |     10 |00:00:00.01 |      12 |      0 |
|*  3 |  VIEW				|	      |      1 |     20 |     10 |00:00:00.01 |      24 |      2 |
|*  4 |   COUNT STOPKEY 		|	      |      1 |	|     20 |00:00:00.01 |      24 |      2 |
|   5 |    VIEW 			|	      |      1 |     20 |     20 |00:00:00.01 |      24 |      2 |
|   6 |     TABLE ACCESS BY INDEX ROWID | T_BBM60     |      1 |    501 |     20 |00:00:00.01 |      24 |      2 |
|*  7 |      INDEX RANGE SCAN DESCENDING| IDX_T_BBM60 |      1 |     20 |     20 |00:00:00.01 |       4 |      2 |
------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("USRNO"=:B1)
   3 - filter("RNUM">=11)
   4 - filter(ROWNUM<=20)
   7 - access("BBM_TYP"='NOR' AND "DEL_YN"='N')