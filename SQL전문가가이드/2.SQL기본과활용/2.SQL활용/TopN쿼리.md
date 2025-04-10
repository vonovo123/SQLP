# ROWNUM PSEUDO 컬럼

ORACLE의 ROWNUM은 칼럼과 비슷한 성격의 PSEUDO COLUMN으로 SQL 처리 결과 집합의 각 행에 대해 임시로 부여되는 일련번호이다.
테이블이나 집합에서 원하는 만큼 행을 가져오고 싶을 때 WHERE 절에서 행의 개수를 제한하는 목적으로 사용한다.

```SQL
SELECT PLAYER_NAME FROM PLAYER WHERE ROWNUM <= N
```

ORACLE에서 순위가 높은 N개의 로우를 추출하기 위해 ORDER BY 절과 WHERE 절의 ROWNUM 조건을 같이 사용하는 경우가 있다.
이 두 조건으로는 원하는 결과를 얻을 수 없다. ORACLE의 경우 정렬이 완료된 후 데이터의 일부가 출력되는 것이 아니라, 데이터 일부를 먼저 추출한 후 정렬작업이 일어나기 때문이다.

```SQL
-- 사원 테이블에서 급여가 높은 3명만 내림차순으로 출력하고자 하는데, 잘못 된 SQL의 예이다.
-- 급여 순서 상관없이 무작위로 추출된 3명에 한해 급여를 내림차순으로 정렬한 결과이다.
SELECT EMPLOYEE_ID , SARARY
FROM HR.EMPLOYEES
WHERE ROWNUM < 4
ORDER BY SAL DESC;


-- 정렬 후 원하는 데이터를 얻기 위해서는 인라인 뷰에서 먼저 데이터를 정렬한 후 메인 퀴리에서 ROWNUM 조건을 사용해야한다.

SELECT EMPLOYEE_ID , SALARY
FROM (
SELECT EMPLOYEE_ID , SALARY
FROM HR.EMPLOYEES
ORDER BY SALARY DESC
)
WHERE ROWNUM < 4
```

---

# ROW LIMITING 절

ORACLE 12.1 버전 부터 ROW LIMITING 절로 TOP N 쿼리를 작성할 수 있다.

```SQL

-- OFFSET offset : 건너뛸 행의 개수를 지정한다.
-- FETCH : 반환할 행의 개수나 백분율을 지정한다.
-- ONLY : 지정된 행의 개수나 백분율만큼 행을 반환한다.
-- WITH TIES : 마지막 행에 대한 동순위를 포함해서 반환하다.

[OFFSET offset{ROW|ROWS}]
[FETCH {FIRST|NEXT}[{rowcount | percent PERCENT}]{ROW|ROWS}{ONLY | WITH TIES}]

-- ROW LIMITING 절을 사용한 TOP  쿼리다.

SELECT EMPLOYEE_ID, SALARY
FROM HR.EMPLOYEES
ORDER BY SALARY , EMPLOYEE_ID FETCH FIRST 5 ROWS ONLY;

-- OFFSET 만 기술하면 건너뛴 행 이후의 전체 행이 반환된다.
SELECT EMPLOYEE_ID, SALARY
FROM HR.EMPLOYEES
ORDER BY SALARY , EMPLOYEE_ID OFFSET 5 ROWS;

```
