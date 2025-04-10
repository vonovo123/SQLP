# 구조적, 집합적, 선언적 질의 언어

SQL은 기본적으로 구조적이고 집합적이고 선언적인 질의 언어이다.
원하는 결과 집합을 구조적, 집합적으로 선언하지, 그 결과 집합을 만드는 과정은 절차적일 수밖에 없다. 즉 프로시저가 필요한데, 그런 프로시저를 만들어 내는 DBMS 내부 엔진이 바로 sql 옵티마이저다.

---

# SQL 처리 과정

```sql
-- PARSER : SQL 문장을 이루는 개별 구성요소를 분석하고 파싱해서 파싱 트리를 만든다. 이 과정에서 사용자 SQL에 문법적인 오류가 없는지, 의미상 오류가 없는지 확인한다.

-- OPTIMIZER
  -- QUERY TRANSFORMER : 파싱된 SQL을 좀 더 일반적이고 표준적인 형태로 변환한다.
  -- ESTIMATOR : 오브젝트 및 시스템 통계정보를 이용해 쿼리 수행 각 단계의 선택도, 카디널리티, 비용을 계산하고 실행계획 전체의 총 비용을 계산해 낸다.
  -- PLAN GENERATOR : 하나의 쿼리를 수행할 때, 후보군이 될 만한 실행 계획을 생성해 낸다.

-- ROW-SOURCE GENERATOR : 옵티마이저가 생성한 실행 계획을 SQL 엔진이 실제 실행할 수 있는 코드 형태로 포맷팅 한다.
-- SQL ENGINE : SQL을 실행한다.
```

---

# SQL 옵티마이저

사용자가 원하는 작업을 가장 효율적으로 수행할 수 있는 최적의 데이터 액세스 경로를 선택해주는 핵심 엔진이다.
최적화 단계를 요약하면 다음과 같다.

- 사용자로부터 전달받은 쿼리를 수행하는 데 후보군이 될만한 실행계획을 찾아낸다.
- 데이터 딕셔너리에 수집해 둔 오브젝트 통계및 시스템 통계정보를 이용해 각 실행계획의 예상비용을 산정한다.
- 최저 비용을 나타내는 실행계획을 선택한다.

---

# 실행계획과 비용

SQL 옵티마이져가 생성한 처리절차를 사용자가 확인할 수 있도록 다음과 같이 트리 구조로 표현한 것인 실행 계획이다.

```SQL

-- 옵티마이저가 특정 실행 계획을 선택하는 근거는 무엇일까?
-- 이르 설명하기 위해 다음과 같이 테스트용 테이블을 생성한다.

CREATE TABLE t
AS
SELECT D.NO, E.*
FROM SCOTT.EMP E
, (SELECT ROWNUM NO FROM DUAL CONNECT BY LEVEL <= 1000) D;

-- 다음과 같이 인덱스도 생성한다.
CREATE INDEX t_x01 ON t(deptno, no);
CREATE INDEX t_x02 ON t(deptno, job, no);

-- 아래 명령어는 방금 생성한 T 테이블에 통계정보를 수집하는 ORACLE 명령어이다.

SQL> EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'T');

-- PL/SQL procedure successfully completed.

-- 실행계획을 작성한다.
SQL> SET AUTOTRACE TRACEONLY EXP;

SQL> SELECT * FROM T
  2  WHERE DEPTNO = 10
  3  AND NO = 1;

-- 옵티마이저가 T_X01 인덱스를 선택했다. T_X02 인덱스를 선택할 수 있고 테이블 FULL SCAN 할 수도 있다.
-- T_X01 인덱스를 선택한 근거는 무엇일까?
-- 위 실행계획에서 맨 우측 COST 가 2로 표시돼있다.
Execution Plan
----------------------------------------------------------
Plan hash value: 481254278

--------------------------------------------------------------------------------
-----

| Id  | Operation		    | Name  | Rows  | Bytes | Cost (%CPU)| Time
    |

--------------------------------------------------------------------------------
-----

|   0 | SELECT STATEMENT	    |	    |	  5 |	210 |	  2   (0)| 00:00
:01 |

|   1 |  TABLE ACCESS BY INDEX ROWID| T     |	  5 |	210 |	  2   (0)| 00:00
:01 |

|*  2 |   INDEX RANGE SCAN	    | T_X01 |	  5 |	    |	  1   (0)| 00:00
:01 |

--------------------------------------------------------------------------------
-----

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("DEPTNO"=10 AND "NO"=1)

-- T_X02 인덱스를 사용하도록 INDEX 힌트를 지정하고 실행계획을 확인해 보면 COST 가 19로 표시된다.

SQL> SELECT /*+INDEX(T T_X02)*/ * FROM T
  2  WHERE DEPTNO = 10
  3  AND NO = 1;

Execution Plan
----------------------------------------------------------
Plan hash value: 3077781317

--------------------------------------------------------------------------------
-----

| Id  | Operation		    | Name  | Rows  | Bytes | Cost (%CPU)| Time
    |

--------------------------------------------------------------------------------
-----

|   0 | SELECT STATEMENT	    |	    |	  5 |	210 |	  7   (0)| 00:00
:01 |

|   1 |  TABLE ACCESS BY INDEX ROWID| T     |	  5 |	210 |	  7   (0)| 00:00
:01 |

|*  2 |   INDEX SKIP SCAN	    | T_X02 |	  5 |	    |	  6   (0)| 00:00
:01 |

--------------------------------------------------------------------------------
-----


Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("DEPTNO"=10 AND "NO"=1)
       filter("NO"=1)
-- TABLE FULL SACN 하도록 FULL 힌트를 지정하고 실행계획을 확인해 보면, COST가 다음과 같이 29로 표시된다.
SQL> SELECT /*+FULL(T)*/ * FROM T
  2  WHERE DEPTNO = 10
  3  AND NO = 1;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation	  | Name | Rows  | Bytes | Cost (%CPU)| Time	 |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	 |     5 |   210 |    30   (4)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| T	 |     5 |   210 |    30   (4)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("NO"=1 AND "DEPTNO"=10)

```

옵티마이저가 T_X01 인덱스를 선택한 근거는 비용이다. 비용은 쿼리가 수행하는 동안 발생할 것으로 예상하는 I/O 횟수 또는 예상 소요시간을 표현한 값이다.
실행경로를 선택하기 위해 옵티마이저가 여러 통계정보를 활용해 계산해 낸 값이다. 실측치가 아니므로 실제 수행할 때 발생하는 I/O 또는 시간과 많은 차이가 날 수 있다.

---

## 옵티마이저 힌트

통계정보가 정확하지 않거나 기타 다른 이유로 옵티마이저가 잘못된 판단을 할 수 있다. 그럴 때 프로그램이나 데이터 특성 정보를 정확히 알고 있는 개발자가 직접 인덱스를 지정하거나 조인방식을 변경함으로써 더 좋은 실행 계획으로 유도하는 메커니즘이 필요한데, 옵티마저 힌트가 바로 그것이다.

### ORACLE 힌트

```SQL
-- ORACLE 에서 힌트를 기술하는 방법은 다음과 같다.
SELECT  /*+ LEADING(E2 E1) USE_NL(E1) INDEX(E1 EMP_EMP_ID_PK)
			USE_MERGE(J) FULL(J	*/
E1.FIRST_NAME, E2.LAST_NAME, J.JOB_ID, SUM(E2.SALARY) TOTAL_SAL
FROM EMPLOYEES E1, EMPLOYEES E2, JOB_HISTORY J
WHERE E1.EMPLOYEE_ID = E2.MANAGER_ID
AND E1.EMPLOYEE_ID = J.EMPLOYEE_ID
AND E1.HIRE_DATE = J.START_DATE
GROUP BY E1.FIRST_NAME, E1.LAST_NAME, J.JOB_ID
ORDER BY TOTAL_SAL;

-- index 힌트에는 인덱스명 대신 다음과 같이 컬럼명을 지정할 수 있다.
SELECT /*+ LEADING(E2 E1) USE_NL(E1) INDEX(E1 (EMPLOYEE_ID))

-- 다음과 같은 경우에 ORACLE 옵티마이저는 힌트를 무시하고 최적화를 진행한다.
-- 문법적으로 안 맞게 힌트를 기술
-- 의미적으로 안 맞게 힌트를 기술
-- 잘못된 참조 사용
-- 논리적으로 불가능한 액세스 경로

-- 버그
-- 무시되는 경우에 해당하지 않는 한 옵티마이저는 힌트를 우선적으로 따른다.
-- 힌트를 잘못 기술하거나 잘못된 참조를 사용하더라도 에러가 발생하지 않는다.
-- 힌트가 변경되어도 동작상 에러나 경고가 발생하지않아 성능이 저하된 것을 발견하지 못할 수 있다.

-- 힌트 종류
-- 최소한 아래 나열된 힌트는 그 용도와 사용법을 숙지할 필요가 있다.

-- 최적화 목표
/*+all_rows*/
/*+first_rows(n)*/

-- 엑세스 경로

/*+full*/
/*+cluster*/
/*+hash*/
/*+index, no_index*/
/*+index_asc, index_desc*/
/*+index_combine*/
/*+index_join*/
/*+index_ffs, no_index_ffs*/
/*+index_ss, no_index_ss*/
/*+index_ss_asc, index_ss_desc*/

-- 쿼리 변환

/*+no_query_transformation*/
/*+use_concat*/
/*+no_expand*/
/*+rewrite, no_rewrite*/
/*+merge, no_merge*/
/*+star_transformation, no_star_transformation*/
/*+fact, no_fact*/
/*+unnest, no_unnest*/

-- 조인 순서

/*+ordered*/
/*+leading*/

-- 조인 방식
/*+use_nl, no_use_nl*/
/*+use_nl_with_index*/
/*+use_merge, no_use_merge*/
/*+use_hash, no_use_hash*/

-- 병렬 처리
/*+parallel, no_parallel*/
/*+pq_distribute*/
/*+parallel_index, no_parallel_index*/

-- 기타
/*+append, noappend*/
/*+cache, nocache*/
/*+push_pred, no_push_pred*/
/*+push_subq, no_push_subq*/
/*+qb_name*/
/*+cursor_sharing_exact*/
/*+driving_site*/
/*+dynamic_sampling*/
/*+model_min_anlysis*/
```
