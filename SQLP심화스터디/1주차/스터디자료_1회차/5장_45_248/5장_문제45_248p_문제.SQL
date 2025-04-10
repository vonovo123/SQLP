쿼리 변환 기능이 약한 DBMS 버전을 사용한다고 가정하고, 아래와 같은 오라클 실행계획이 나타나도록
SQL을 변환하시오.

[인덱스 구성]
DEPT_PK : DEPTNO
DEPT_X1 : LOC

EMP_PK : EMPHO
EMP_X1 : JOB + DEPTNO
EMP_X2 : MGR + JOB 

-- 문제 1 case I
SELECT *
  FROM EMP E, DEPT D
 WHERE (E.DEPTNO = D.DEPTNO AND E.JOB = 'CLERK' AND D.LOC = 'DALLAS')
    OR 
       (E.DEPTNO = D.DEPTNO AND E.JOB = 'CLERK' AND E.MGR = 7782)
;
--------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name    | Starts | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |         |      1 |      3 |00:00:00.01 |       8 |
|   1 |  NESTED LOOPS                         |         |      1 |      3 |00:00:00.01 |       8 |
|   2 |   NESTED LOOPS                        |         |      1 |      4 |00:00:00.01 |       4 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |      1 |      4 |00:00:00.01 |       2 |
|*  4 |     INDEX RANGE SCAN                  | EMP_X1  |      1 |      4 |00:00:00.01 |       1 |
|*  5 |    INDEX UNIQUE SCAN                  | DEPT_PK |      4 |      4 |00:00:00.01 |       2 |
|*  6 |   TABLE ACCESS BY INDEX ROWID         | DEPT    |      4 |      3 |00:00:00.01 |       4 |
--------------------------------------------------------------------------------------------------