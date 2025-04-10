alter session set statistics_level = all;

alter table emp add constraint pk_emp primary key (empno);

/*
drop index EMP_X1;
drop index EMP_X01;
drop index EMP_X02;
drop index EMP_X03;
drop index EMP_ENAME_SAL_IDX;
*/

EMP_PK : EMPHO
EMP_X1 : JOB + DEPTNO
EMP_X2 : MGR + JOB 

create index emp_x1 on emp(job, deptno);
create index emp_x2 on emp(mgr, job);

-- 문제 
SELECT *
  FROM EMP E, DEPT D
 WHERE (E.DEPTNO = D.DEPTNO AND E.JOB = 'CLERK' AND D.LOC = 'DALLAS')
    OR 
       (E.DEPTNO = D.DEPTNO AND E.JOB = 'CLERK' AND E.MGR = 7782)
;

-- 모범답안
select /*+ leading(e) use_nl(d) */
       *
  from emp e, dept d
 where e.deptno = d.deptno 
   and e.job='CLERK'
   and (d.loc = 'DALLAS' or e.mgr = 7782)
;

--------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name    | Starts | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |         |      1 |      3 |00:00:00.01 |       8 |
|   1 |  NESTED LOOPS                         |         |      1 |      3 |00:00:00.01 |       8 |
|   2 |   NESTED LOOPS                        |         |      1 |      4 |00:00:00.01 |       4 |
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMP     |      1 |      4 |00:00:00.01 |       2 |
|*  4 |     INDEX RANGE SCAN                  | EMP_X1  |      1 |      4 |00:00:00.01 |       1 |
|*  5 |    INDEX UNIQUE SCAN                  | PK_DEPT |      4 |      4 |00:00:00.01 |       2 |
|*  6 |   TABLE ACCESS BY INDEX ROWID         | DEPT    |      4 |      3 |00:00:00.01 |       4 |
--------------------------------------------------------------------------------------------------

-- 
select /*+ use_concat */
       *
  from emp e, dept d
 where e.deptno = d.deptno 
   and e.job='CLERK'
   and (d.loc = 'DALLAS' or e.mgr=7782)
;
 
select * from dbms_xplan.display_cursor(null,null, 'allstats last -rows outline predicate alias');

----------------------------------------------------------------------------------------------------
| Id  | Operation                              | Name     | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                       |          |      1 |      3 |00:00:00.01 |       8 |
|   1 |  CONCATENATION                         |          |      1 |      3 |00:00:00.01 |       8 |
|   2 |   NESTED LOOPS                         |          |      1 |      1 |00:00:00.01 |       4 |
|   3 |    NESTED LOOPS                        |          |      1 |      1 |00:00:00.01 |       3 |
|*  4 |     TABLE ACCESS BY INDEX ROWID BATCHED| EMP      |      1 |      1 |00:00:00.01 |       2 |
|*  5 |      INDEX RANGE SCAN                  | EMP_X2   |      1 |      1 |00:00:00.01 |       1 |
|*  6 |     INDEX UNIQUE SCAN                  | DEPT_PK  |      1 |      1 |00:00:00.01 |       1 |
|   7 |    TABLE ACCESS BY INDEX ROWID         | DEPT     |      1 |      1 |00:00:00.01 |       1 |
|   8 |   NESTED LOOPS                         |          |      1 |      2 |00:00:00.01 |       4 |
|   9 |    NESTED LOOPS                        |          |      1 |      2 |00:00:00.01 |       3 |
|  10 |     TABLE ACCESS BY INDEX ROWID BATCHED| DEPT     |      1 |      1 |00:00:00.01 |       2 |
|* 11 |      INDEX SKIP SCAN                   | DEPT_X03 |      1 |      1 |00:00:00.01 |       1 |
|* 12 |     INDEX RANGE SCAN                   | EMP_X1   |      1 |      2 |00:00:00.01 |       1 |
|* 13 |    TABLE ACCESS BY INDEX ROWID         | EMP      |      2 |      2 |00:00:00.01 |       1 |
----------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$1  
   4 - SEL$1_1 / E@SEL$1
   5 - SEL$1_1 / E@SEL$1
   6 - SEL$1_1 / D@SEL$1
   7 - SEL$1_1 / D@SEL$1
  10 - SEL$1_2 / D@SEL$1_2
  11 - SEL$1_2 / D@SEL$1_2
  12 - SEL$1_2 / E@SEL$1_2
  13 - SEL$1_2 / E@SEL$1_2
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"SEL$1_1")
      USE_CONCAT(@"SEL$1" 8 OR_PREDICATES(4) PREDICATE_REORDERS((3 2) (4 3) (5 4) (6 5) (2 6)))
      OUTLINE_LEAF(@"SEL$1_2")
      OUTLINE(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1_1" "E"@"SEL$1" ("EMP"."MGR" "EMP"."JOB"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1_1" "E"@"SEL$1")
      INDEX(@"SEL$1_1" "D"@"SEL$1" ("DEPT"."DEPTNO"))
      INDEX_SS(@"SEL$1_2" "D"@"SEL$1_2" ("DEPT"."DEPTNO" "DEPT"."LOC"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1_2" "D"@"SEL$1_2")
      INDEX(@"SEL$1_2" "E"@"SEL$1_2" ("EMP"."JOB" "EMP"."DEPTNO"))
      LEADING(@"SEL$1_1" "E"@"SEL$1" "D"@"SEL$1")
      LEADING(@"SEL$1_2" "D"@"SEL$1_2" "E"@"SEL$1_2")
      USE_NL(@"SEL$1_1" "D"@"SEL$1")
      NLJ_BATCHING(@"SEL$1_1" "D"@"SEL$1")
      USE_NL(@"SEL$1_2" "E"@"SEL$1_2")
      NLJ_BATCHING(@"SEL$1_2" "E"@"SEL$1_2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter("E"."DEPTNO" IS NOT NULL)
   5 - access("E"."MGR"=7782 AND "E"."JOB"='CLERK')
   6 - access("E"."DEPTNO"="D"."DEPTNO")
  11 - access("D"."LOC"='DALLAS')
       filter("D"."LOC"='DALLAS')
  12 - access("E"."JOB"='CLERK' AND "E"."DEPTNO"="D"."DEPTNO")
       filter("E"."DEPTNO" IS NOT NULL)
  13 - filter(LNNVL("E"."MGR"=7782))