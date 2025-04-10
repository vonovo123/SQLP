아래 SQL을 힌트 내용대로 실행할 때의 실행계획을 작성하시오.
(※ 아래 오퍼레이션 유형 활용)

[인덱스]
계좌_PK : 계좌번호 
계좌_X1 : 개설일자 
고객변경이력_PK : 고객번호 + 변경일시

[SQL]
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌_217 A, 고객변경이력_217 C 
 WHERE A.개설일자 = :OPEN_DT   -- 20230616
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ MAX(변경일시)
                       FROM 고객변경이력_217 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28');						

[오퍼레이션 유형]
NESTED LOOPS 
VIEW    
TABLE ACCESS (BY INDEX ROWID) OF '테이블명'
TABLE ACCESS (FULL) OF '테이블명'  
INDEX (UNIQUE SCAN) OF '인덱스명'
INDEX (RANGE SCAN) OF '인덱스명'
SORT (AGGREGATE)
COUNT (STOPKEY)  --> 필요없음

[오퍼레이션 유형의 문제를 푸는 방법]
1. 필요없는 오퍼레이션 유형을 골라낸다.
2. NL조인 메카니즘을 생각한다. 
   인덱스 -> 테이블을 읽는다.
3. SELECT MAX, MIN, SUM 의 실행계획을 생각한다.

NESTED LOOPS 
VIEW    --> 필요없음
TABLE ACCESS (BY INDEX ROWID) OF '테이블명'
TABLE ACCESS (FULL) OF '테이블명'  --> 필요없음
INDEX (UNIQUE SCAN) OF '인덱스명'
INDEX (RANGE SCAN) OF '인덱스명'
SORT (AGGREGATE)
COUNT (STOPKEY)  --> 필요없음

/* NL 전통 조인으로 실행계획을 작성
--------------------------------------------------------
NESTED LOOPS
 TABLE ACCESS (BY INDEX ROWID) OF '계좌_217'
  INDEX (RANGE SCAN) OF 'X1_계좌_217'
 TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력_217'
  INDEX (UNIQUE SCAN) OF 'PK_고객변경이력_217'      
   SORT (AGGREGATE)
    TABLE ACCESS (BY INDEX ROWID) OF '고객변경이력_217'
      INDEX (UNIQUE SCAN) OF 'PK_고객변경이력_217'
---------------------------------------------------------
*/

-- 테스트 1
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌_217 A, 고객변경이력_217 C 
 WHERE A.개설일자 = :OPEN_DT -- 20230616
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ MAX(변경일시)
                       FROM 고객변경이력_217 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28');
						
[실행계획]
----------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name          | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |               |      1 |     36 |00:00:00.01 |     986 |
|   1 |  NESTED LOOPS                           |               |      1 |     36 |00:00:00.01 |     986 |
|   2 |   NESTED LOOPS                          |               |      1 |     36 |00:00:00.01 |     950 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED  | 계좌_217      |      1 |    299 |00:00:00.01 |     245 |
|*  4 |     INDEX RANGE SCAN                    | X1_계좌_217   |      1 |    299 |00:00:00.01 |       2 |
|*  5 |    INDEX UNIQUE SCAN                    | PK_고객변경이 |    299 |     36 |00:00:00.01 |     705 |
|   6 |     SORT AGGREGATE                      |               |    299 |    299 |00:00:00.01 |     632 |
|*  7 |      TABLE ACCESS BY INDEX ROWID BATCHED| 고객변경이력_2|    299 |    255 |00:00:00.01 |     632 |
|*  8 |       INDEX RANGE SCAN                  | PK_고객변경이 |    299 |    288 |00:00:00.01 |     344 |
|   9 |   TABLE ACCESS BY INDEX ROWID           | 고객변경이력_2|     36 |     36 |00:00:00.01 |      36 |
----------------------------------------------------------------------------------------------------------						

-- 테스트2                   
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) NO_NLJ_PREFETCH(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌_217 A, 고객변경이력_217 C 
 WHERE A.개설일자 = :OPEN_DT -- 20230616
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ MAX(변경일시)
                       FROM 고객변경이력_217 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28');
[실행계획]
----------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name          | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |               |      0 |      0 |00:00:00.01 |       0 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED    | 고객변경이력_2|      1 |     36 |00:00:00.01 |     986 |
|   2 |   NESTED LOOPS                          |               |      1 |     36 |00:00:00.01 |     950 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED  | 계좌_217      |      1 |    299 |00:00:00.01 |     245 |
|*  4 |     INDEX RANGE SCAN                    | X1_계좌_217   |      1 |    299 |00:00:00.01 |       2 |
|*  5 |    INDEX UNIQUE SCAN                    | PK_고객변경이 |    299 |     36 |00:00:00.01 |     705 |
|   6 |     SORT AGGREGATE                      |               |    299 |    299 |00:00:00.01 |     632 |
|*  7 |      TABLE ACCESS BY INDEX ROWID BATCHED| 고객변경이력_2|    299 |    255 |00:00:00.01 |     632 |
|*  8 |       INDEX RANGE SCAN                  | PK_고객변경이 |    299 |    288 |00:00:00.01 |     344 |
----------------------------------------------------------------------------------------------------------

 /* OPTIMIZER_FEATURES_ENABLE('12.2.0.1') */

-- 테스트3
-- 옵티마이저 모드를 변경해서 아래의 쿼리를 전통 NL 조인으로 만들어 본다.

ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE = '9.2.0';

SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌_217 A, 고객변경이력_217 C 
 WHERE A.개설일자 = :OPEN_DT -- 20230616
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ MAX(변경일시)
                       FROM 고객변경이력_217 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28');

[실행계획]
--------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Starts | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |      1 |     36 |00:00:00.01 |     986 |
|   1 |  NESTED LOOPS                   |               |      1 |     36 |00:00:00.01 |     986 |
|   2 |   TABLE ACCESS BY INDEX ROWID   | 계좌_217      |      1 |    299 |00:00:00.01 |     245 |
|*  3 |    INDEX RANGE SCAN             | X1_계좌_217   |      1 |    299 |00:00:00.01 |       2 |
|   4 |   TABLE ACCESS BY INDEX ROWID   | 고객변경이력_2|    299 |     36 |00:00:00.01 |     741 |
|*  5 |    INDEX UNIQUE SCAN            | PK_고객변경이 |    299 |     36 |00:00:00.01 |     705 |
|   6 |     SORT AGGREGATE              |               |    299 |    299 |00:00:00.01 |     632 |
|*  7 |      TABLE ACCESS BY INDEX ROWID| 고객변경이력_2|    299 |    255 |00:00:00.01 |     632 |
|*  8 |       INDEX RANGE SCAN          | PK_고객변경이 |    299 |    288 |00:00:00.01 |     344 |
--------------------------------------------------------------------------------------------------						
						
-- 현재 옵티마이저 모드로 변경 한다.
ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE = '12.2.0.1';	