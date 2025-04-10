# 메커니즘

```sql

-- 중첩 루프문과 같은 수행 구조를 사용하는 NL 조인이 실제 어떤 순서로 데이터를 엑세스하는지 아래 PL/SQL 문이 잘 설명해준다

begin
  for outer in (select deptno, empno, rpad(ename, 10) ename from emp)
  loop -- outer loop
    for inner in (select dname from dept where deptno = outer.deptno)
    loop -- inner loop
      dbms_output.put_line(outer.empno || ':' || outer.ename || ':' || inner.dname);
    end loop;
  end lool;
end

-- 위 PL/SQL 문은 아래 쿼리와 100% 같은 순서로 데이터를 엑세스하고 데이터 출력 순서도 같다. 내부적으로 재귀적 쿼리를 반복 수행하지 않는다는 점만 다르다.

select /*+ordered use_nl(d)*/ e.empno, e.ename, d.dname
from scott.emp e, scott.dept d
where d.deptno = e.deptno

select /*+leading(e) use_nl(d)*/ e.empno, e.ename, d.dname
from scott.emp e, scott.dept d
where d.deptno = e.deptno
```

뒤에서 설명할 소트 머지 조인과 해시 조인도 각각 소트영역과 해시영역에 가공해 둔 데이터를 이용한다는 점만 다를 뿐 조인 프로세싱은 다르지 않다.

---

# NL 조인 수행 과정 분석

```sql
select /*+ordered use_nl(d)*/ e.empno, e.ename, d.dname, e.job, e.sal
from scott.emp e, scott.dept d
where d.deptno = e.deptno --- 1
and d.loc = 'SEOUL' --- 2
AND d.gb = '2' --- 3
and e.sal >= 1500 --- 4
order by sal desc

-- 인덱스 상황은 다음과 같다.
-- pk_dept : dept.deptno
-- dept_loc_idx : dept.loc
-- pk_emp : emp.empno
-- emp_deptno_idx : emp.deptno
-- emp_sal_idx : emp.sal

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT
1 0 SORT ORDER BY
2 1   NESTED LOOPS
3 2     TABLE ACCESS BY INDEX ROWID DEPT
4 3       INDEX RANGE SCAN DEPT_LOC_IDX
5 2     TABLE ACCESS BY INDEX ROWID EMP
6 5       INDEX RANGE SCAN EMP_DEPTNO_IDX

-- 사용되는 인덱스는 DEPT_LOC_IDX, EMP_DEPTNO_IDX 인 것을 실행계획을 통해 알 수 있다.
-- 조건 비교 순서는 2 -> 3 -> 1 -> 4 순이다
-- 일반적으로 실행계획을 해석할 때 형제 노드간에는 위에서 아래로, 부모자식은 안쪽에서 바깥쪽으로 즉, 자식 노드 부터 읽는다.
-- 이 규칙에 따라 실행계획을 해석하면 다음과 같다.
-- 1. DEPT_LOC_IDX 인덱스 범위 스캔
-- 2. INDEX ROWID로 DEPT 테이블 액세스
-- 3. EMP_DEPTNO_IDX 인덱스 범위 스캔
-- 4. INDEX ROWID 로 EMP 테이블 엑셋스
-- 5. sal 기준으로 내림차순 정렬
```

SQL 실행 순서를 이런 규칙에 따라 해석하는 방식이 NL 조인에서는 비교적 자연스럽고 실행 과정을 이해하는데 도움을 준다.

1. d.loc = 'SEOUL' 조건을 만족하는 레코드를 찾으려고 DEPT_LOC_IDX 인덱스 범위 스캔을 한다.
2. dept_loc_idx 인덱스에서 읽은 ROWID 를 가지고 Dept 테이블을 액세스해 DEPT.GB = 2 필터 조건을 만족하는 레코드를 찾는다.
3. dept 테이블에서 읽은 deptno 값을 가지고 조인 조건을 만족하는 EMP 쪽 레코드를 찾기위해 EMP_DEPTNO_IDX 인덱스 범위 스캔한다.
4. EMP_DEPTNO_IDX 인덱스에서 읽은 rowid 를 가지고 EMP 테이블을 액세스 해 sal > 1500 필터 조건을 만족하는 레코드를 찾는다.
5. 위 과정을 통과한 레코드를 sal 칼럼 기준 내림차순으로 정렬할 후 결과를 리턴한다.

dept_loc_idx 인덱스를 스캔하는 야에 따라 전체 일량이 좌우된다. 여기서는 단일 칼럼 인덱스를 = 조건으로 스캔했으므로 비효율 없이 6건을 읽었고, 그만큼 테이블 랜덤 엑세스가 발생했다. 우선 이 부분이 NL 조인ㄴ의 첫 번재 부하 지점이다.

만약 dept 테이블로 많은 양의 랜덤 엑세스가 있었는데 gb='2' 조건에 의해 필터링 되는 비율이 높다면 어떻게 해야할까?
DEPT_LOC_IDX에 gb 칼럼을 추가하는 방안을 고려해야 한다.

두 번째 부하지점은 EMP_DEPTNO_IDX 인덱스를 탐색하는 부분이다. OUTER 테이블인 DEPT를 읽고나서 조인 액세스가 열마나 발생하느냐애 따라 일양이 결정된다.
이역시 랜덤 엑세스에 해당한다.

'GB=2' 필터 조건에 해당하는 3건 만큼의 조인시도가 발생한다. 만약 EMP_DEPTNO_IDX의 높이가 3이면 건마다 그만큼의 블록 I/O가 발생하고 리프 블록을 스캔하며서 추가적인 I/O가 더해진다.

세 번째 부하지점은 EMP_DEPTNO_IDX를 읽고 나서 Emp 테이블을 엑세스하는 부분이다. 여기서도 sal >= 1500 조건에 의해 필터링 되는 비율이 높다면 SAL 칼럼을 인덱스에 추가하는 방안을 고려해야한다.

OLTP 시스템에서 조인을 튜닝할 때는 일차적으로 NL 조인부터 고려하는 것이 올바른 순서다. 우선 NL 조인 메커니즘을 따라 각 단계의 수행 일량을 분석해 과도한 랜덤 액세스가 발생하는 지점을 파악한다. 조인 순서를 변경해 랜덤 액세스 발생량을 줄일 수 있는 경우가 있지만, 그렇지 못할 때는 인덱스 칼럼 구성을 변경하거나 다른 인덱스의 사용을 고려해야한다.

여러가지 방안을 검토한 결과 NL 조인이 효과적이지 못하다고 판단될 때 해시 조인이나 소트머지 조인을 검토한다.

---

# NL 조인의 특징

대부분의 DBMS가 블록 단위로 I/O를 수행한다. 하나의 레코드를 읽으려고 블록을 통째로 읽는 랜덤 액세스 방식은 비효율이 존재한다.
그런데 NL 조인의 첫 번째 특징이 랜덤 엑세스 위주의 조인 방식이라느 점이다. 따라서 인덱스 구성이 아무리 완벽하더라도 대량을 데이터를 조인할 때 매우 비효율적이다.

두 버째 특징은 조인을 한 레코드씩 순차적으로 진행한다는 점이다. 첫 번째 특징 때문에 대용량 데이터 처리시 매우 치명적인 한계를 드러내지만, 반대로 이 두 번째 특징 때문에 아무리 대용량 집합이라도 매우 극적인 응답속도를 낼 수 있다. 부분범위처리가 가능한 상황에서 그렇다. 그래고 순차적으로 진행하는 특징 때문에 먼저 액세스되는 테이블의 처리 범위에 의해 전체 일량이 결정된다.

다른 조인방식과 비교했을 때, 인덱스 구성 전략이 특히 중요하다는 것도 NL 조인의 특징이다. 조인 칼럼에 대한 인덱스가 있느냐 없느냐, 있다면 칼럼이 어떻게 구성됐느냐에 따라 조인 효율이 크게 달라진다.
이런 여러 가지 특징을 종합할 때, NL 조인은 소량의 데이터를 주로 처리하거나 부분범위처리가 가능한 온라인 트랜잭션 환경에 적합한 조인 방식이라 할 수 있다.

---

# NL 조인 확장 메커니즘

PREFETCH 는 인덱스를 이용해 테이블을 액세스하다가 디스크 I/O 가 필요해지면, 이어서 곧 읽게 될 블록까지 미리 읽어서 버퍼캐시에 적재하는 기능이다.
'배치 I/O'는 디스트 I/O Call을 미뤘다가 읽을 블록이 일정량 쌓이면 한꺼번에 처리하는 기능이다.
두 기능 모두 읽는 블록마다 건건이 I/O CALL을 발생시키는 비효율을 줄이기 위해 고안했다.

```sql

--- 전통적인 실행계획
NESTED LOOPS
  TABLE ACCESS BY INDEX ROWID OF EMP
    INDEX RANGE SCAN OF EMP_X1
  TABLE ACCESS BY INDEX ROWID OF CUS
    INDEX RANGE SCAN OF CUS_X1

--- TABLE PREFECTH EXECUTEPLAN
-- INNER TABLE(EMP) 에 대한 디스크 I/O 과정에서 테이블 PREFATCH 기능이 작동할 수 있음을 표시하기 위함이다.
-- nlj_prefetch, no_nlj_prefetch 힌트를 이용해 이 실행계획이 나오게 할 수도 있고, 안 나오게 할 수도 있다.
TABLE ACCESS BY INDEX ROWID OF CUS
  NESTED LOOP
    TABLE ACCESS BY INDEX ROWID OF EMP
      INDEX RANGE SCAN OF EMP_X1
    INDEX RANGE SCAN OF CUS_X1

-- BATCH I/O EXECUTEPLAN
-- INNER TABLE에 대한 디스크 I/O 과정에 배치 I/O 기능이 작동할 수 있음을 표시하기 위함이다.
-- nlj_batching, no_nlj_batching 힌트로 이 실행계획이 나오게 할 수도 있고, 안 나오게 할 수도 있다.
NESTED LOOPS
  NESTED LOOPS
    TABLE ACCESS BY INDEX ROWID OF EMP
      INDEX RANGE SCAN OF EMP_X1
    INDEX RANGE SCAN OF CUS_X1
  TABLE ACCESS BY INDEX ROWID OF CUS
```

오라클 11g 이후 세 가지 실행계획이 모두 나타나는데 INNER 쪽 테이블 블록을 모두 버커패시에서 읽는다면 어떤 방식이든 성능의 차이가 없다.
다만 일부를 디스크에서 일ㄹ게되면 성능에 차이가 나타날 수 있고, 배치 I/O 실행계획이 나타날 때는 결과 집합의 정렬 순서도 다를 수 있다.
