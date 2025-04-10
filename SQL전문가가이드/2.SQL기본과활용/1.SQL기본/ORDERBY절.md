# ORDER BY 정렬

SQL 문장으로 조회한 데이터들을 다양한 목적에 맞게 특정 컬럼을 기준으로 정렬, 출력하는데 사용한다.
컬럼명 대신에 SELECT 절에서 사용함 ALIAS 명이나 칼럼 순서를 나타내는 정수도 사용 가능하다. 별도로 지정하지 않으면 기본적으로 오름차순이 적용되며, SQL 문장의 제일 마지막에 위치한다.

```sql
SELECT 칼럼명 [ALIAS명]
FROM 테이블명
[WHERE CONDITION]
[GROUP BY COLUMN OR EXP]
[HAVING GROUP CONDITION]
[ORDER BY COLUMN OR EXP [ASC OR DESC]]
```

ORDER BY 절은 2가지 정렬 방식이 있다.

\- ASC : 조회한 데이터를 오름차순으로 정렬한다.
\- DESC : 조회한 데이터를 내림차순으로 정렬한다.

```sql

-- ORDER BY 절의 예로 선수 테이블에서 선수들의 이름, 포지션, 백넘버를 출력하는데 사람 이름을 내림차순으로 정렬해 출력한다.

SELECT PLAYER_NAME, POSITION, BACK_NO
FROM PLAYER
ORDER BY PLAYER_NAME DESC;

-- ORDER BY 절의 예로 선수 테이블에서 선수들의 이름,포지션,백넘버를 출력하는데 선수들의 포지션 내림차순으로 출력한다. 칼럼명이 아닌 ALIAS를 이용한다.

SELECT PLAYER_NAME, POSITION AS 포지션, BACK_NO
FROM PLAYER
ORDER BY 포지션 DESC;

```

내림차순으로 정렬시 포지션에 아무 것도 없는 값들이 상위에 출력된다. 이는 Oracle이 NULL 값을 가장 큰 값으로 취급했음을 의미한다.

ORDER BY 절의 특징은 다음과 같다.

\- 기본적인 정렬 순서는 오른차순이다.
\- 숫자형 데이터 타입은 오름차순으로 정렬했을 경우에 가장 작은 값부터 출력된다.
\- 날짜형 데이터 값은 오름차순으로 정렬했을 경우 날짜 값이 가장 빠른 값이 먼저 출력된다.
\- Oracle에서는 NULL 값을 가장 큰 값으로 간주해 오름차순으로 정렬했을 경우에는 가장 마지막에, 내림차순으로 정렬했을 경우에는 가장 먼저 위치한다.

```sql
-- 한 개의 칼럼이 아닌 여러 가지 칼럼을 기준으로 정렬한다. 먼저 키가 큰 순서대로, 키가 같은 경우 백넘버 순을 ORDER BY 절을 적용해 SQL 문장을 작성한다. 키가 NULL 인 데이터는 제외한다.
SELECT PLAYER_NAME, POSITION AS 포지션, BACK_NO, HEIGHT
FROM PLAYER
WHERE HEIGHT IS NOT NULL
ORDER BY HEIGHT DESC, BACK_NO;
```

칼럼명이나 ALIAS명을 대신해 SELECT 절의 칼럼 순서를 정수로 매핑해 사용할 수도 있다. 단 유지보수성이나 가독성이 떨어지므로 가능한 칼럼명이나 ALIAS 명을 권고한다.

```sql
-- ORDER BY 절의 예로 선수 테이블에서 선수들의 이름, 포지션, 백넘버를 출력하는데 백넘버 내림차순, 백넘버가 같은 경우 포지션, 포지션까지 같은 경우 선수명 순서로 출력한다. BACK_NO가 NULL 인 경우는 제외하고, 칼럼명이나 ALIAS가 아닌 칼럼 순서를 매핑한다.
SELECT PLAYER_NAME AS 선수명, POSITION, BACK_NO
FROM PLAYER
WHERE BACK_NO IS NOT NULL
ORDER BY 3 DESC, 2, 1;

-- DEPT 테이블 정보를 부서명, 지역, 부서번호 내림차순으로 정렬해서 출력한다. 아래의 Sql 문장은 출력되는 칼럼 레이블은 다를 수 있지만 결과는 모두 같다.
-- CASE 1. 컬럼명 사용 ORDER BY 절 사용
SELECT DNAME, LOC, DEPTNO
FROM DEPT
ORDER BY DNAME, LOC, DEPTNO DESC;

-- CASE 2. 컬럼명 + ALIAS 명 사용 ORDER BY 절 사용
SELECT DNAME AS DEPT, LOC AS AREA, DEPTNO
FROM DEPT
ORDER BY DNAME, AREA, DEPTNO DESC;

-- CASE 3. 칼럼 순서번호 + ALIAS 명 사용 ORDER BY 절 사용
SELECT DNAME AS DEPT, LOC AS AREA, DEPTNO
FROM DEPT
ORDER BY 1, AREA, 3 DESC;
```

---

# SELECT 문장 실행 순서

GROUP BY 절과 ORDER BY가 같이 사용될때 SELECT 문장은 6개의 절로 구성되고, SELECT 문장의 수행 단계는 아래와 같다.

```sql
SELECT COLUMN --- 5. 데이터 값을 출력,계산한다.
FROM TABLE_NAME --- 1. 발췌 대상 테이블을 참조한다.
WHERE CONDITION --- 2. 발췌 대상 데이터가 아닌 것은 제거한다.
GROUP BY COLUMN --- 3. 행들을 소그룹화한다.
HAVING GROUP_CONDITION --- 4. 그룹핑된 값의 조건에 맞는 것만을 출력한다.
ORDER BY COLUME --- 6. 데이터를 정렬한다
```

위 순서는 옵티마이저가 SQL 문장의 SYNTAX,SEMANTIC 에러를 점검하는 순서이기도 하다. 예를들어 FROM 절에 정의되지 않은 테이블 칼럼을 WHERE절, GROUP BY 절, HAVING 절, SELECT 절, ORDER BY 절에서 사용하면 에러가 발생한다.
그러나 ORDER BY 절에는 SELECT 목록에 나타나지 않은 문자형 항목이 포함될 수 있다. 단 SELECT DISTINCT를 지정하거나 SQL 문장에 GROUP BY 절이 있거나, SELECT 문에 UNION 연산자가 있으면 열 정의가 SELECT 목록에 표시돼야한다.
이 부분은 관계형 데이터베이스가 데이터를 메모리에 올릴 때 행 단위로 모든 칼럼을 가져오게 되므로, SELECT 절에서 일부 칼럼만 삭제하더라도 ORDER BY 절에서 메모리에 올라와 있는 다른 칼럼의 데이터를 사용할 수 있다.
SQL 문장 실행 순서는 오라클 옵티마이저가 SQL 문장을 해석하는 논리적 순서이므로, SQL 문장이 실제로 실행되는 무리적 순서가 아님에 유의해야한다. SQL 문장이 실제 수행되는 무리적 순서는 실행계획에 의해 정해진다.

```sql
-- SELECT 절에 없는 MGR 칼럼을 ORDER BY 절에 사용한다.
-- 예제를 통해 ORDER BY 절에 SELECT 절에 정의하지 않은 칼럼을 사용할 수 있음을 확인할 수 있다.
SELECT EMPNO, ENAME
FROM EMP
ORDER BY MGR;

-- 인라인 뷰에 정의된 SELECT 칼럼을 메인 쿼리에서 사용한다.
SELECT EMPNO
FROM (
  SELECT EMPNO, ENAME
  FROM EMP
  ORDER BY MGR;
)

-- 인라인 뷰에 미정의된 칼럼을 메인 쿼리에서 사용해 본다.
-- 부적합한 식별자
SELECT MGR
FROM (
  SELECT EMPNO, ENAME
  FROM EMP
  ORDER BY MGR;
)
```

서브 쿼리의 SELECT 절에서 선택되지 않은 칼럼들은 계속 유지되는 것이 아니라 서브 쿼리 범위를 벗어나면 더이상 사용할 수 없게 된다.

GROUP BY 절에서 그룹핑 기준을 정의하게 되면 데이터베이스는 일반적으로 SELECT 문장처럼 FROM 절에 정의된 테이블 구조를 그대로 갖고 가는 것이 아니다. GROUP BY 절의 그룹핑 기준에 사용된 칼럼과 집계함수에 사용될 수 있는 숫자형 데이터 칼럼들의 집합을 새로 만든다.

GROUP BY 절을 사용하게 되면 그룹핑 기준에 사용된 칼럼과 집계함수에 사용될 수 있는 숫자형 데이터 컬럼들의 집합을 새로 만드는데, 개별 데이터는 필요없으므로 저장하지 않는다. GROUP BY 이후 수행 절인 SELECT 절이나 ORDER BY 절에서 개별데이터를 사용하는 경우 에러가 발생한다.

결과적으로 SELECT 절에서는 그룹핑 기준과 숫자 형식 칼럼의 집계함수를 사용할 수 있지만, 그룹핑 기준외의 문자형식 칼럼은 정할 수 업다.

```sql
-- GROUP BY 절 사용시 SELECT 절에 일반 칼럼을 사용해 본다.
-- GROUP BY 표현식이 아닙니다.
SELECT JOB, SAL
FROM EMP
GROUP BY JOB
HAVING COUNT (*) > 0
ORDER BY SAL;

-- GROUP BY 절 사용시 ORDER BY 절에 일반 칼럼을 사용해 본다.
-- GROUP BY 표현식이 아닙니다.

SELECT JOB
FROM EMP
GROUP BY JOB
HAVING COUNT (*) > 0
ORDER BY SAL;

-- GROUP BY 절 사용시 ORDER BY 절에 집계 칼럼을 사용해 본다.
-- 위의 예제를 통해 SELECT SQL에서 GROUP BY 절이 사용됐기 때문이 SELECT 절에 정의하지 않는 MAX, SUM, COUNT 집계함수도 ORDER BY 절에서 사용할 수 있음을 확인할 수 있다.

SELECT JOB, SUM(SAL) AS SALARY_SUM
FROM EMP
GROUP BY JOB
HAVING SUM(SAL) > 5000
ORDER BY SUM(SAL);
```
