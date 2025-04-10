# 집계함수

여러 행들의 그룹이 모여 그룹당 단 하나의 결과를 돌려주는 다중행 함수 중 집계함수의 특성은 다음과 같다.

\- GROUP BY 절은 행들을 소그룹화 한다.
\- SELECT 절, HAVING 절, ORDER BY 절에 사용할 수 있다.

```sql
집계함수명 ([ DISTINCT | ALL ] 칼럼이나 표현식)

- ALL : Defatul 옵션이므로 생략 가능하다.
- DISTINCT : 같은 값을 하나의 데이터로 간주할 때 사용하는 옵션이다.
```

자주 사용되는 주요 집계함수들은 다음과 같다. 집계함수는 그룹에 대한 정보를 제공하므로 주로 숫자 유형에 사용되지만, MAX,MIN,COUNT 함수는 문자,날짜 유형에도 적용 가능한 함수다.

```sql
-- COUNT(*) : NULL 값을 포하만 행의 수를 출력한다.
-- COUNT(표현식) : 표현식의 값이 NULL 인 것을 제외한 행수를 출력한다.
-- SUM([DISTINCT | ALL] 표현식) : 표현식의 NULL 값을 제외한 합계를 출력한다.
-- AVG([DISTINCT | ALL] 표현식) : 표현식의 NULL 값을 제외한 평균를 출력한다.
-- MAX([DISTINCT | ALL] 표현식) : 표현식의 최댓값을 출력한다.
-- MIN([DISTINCT | ALL] 표현식) : 표현식의 최소값을 출력한다.
-- STDDEV([DISTINCT | ALL] 표현식) : 표현식의 표준 편차를 출력한다.
-- VARIANCE([DISTINCT | ALL] 표현식) : 표현식의 분산을 출력한다.

-- 일반적으로 집계함수는 GROUP BY 절과 같이 사용되지만 아래와 같이 테이블 전체가 하나의 그룹이 되는 경우에는 GROUP BY 절 없이 단독으로 사용 가능하다.

SELECT COUNT(*) AS 전체행수, COUNT(HEIGHT) AS 키건수, MAX(HEIGHT) AS 최대키, MIN(HEIGHT) AS 최소키, ROUND(AVG(HEIGHT), 2) AS 평균키
FROM PLAYER;
```

COUNT 함수에 사용된 와일드 카드는 전체 칼럼을 뜻한다. 전체 칼럼이 NULL인 행은 존재할 수 없으므로 결국 COUNT는 전체 행의 개수를 출력한 것이고, COUNT(HEIGHT)는 HEIGHT 칼럼 값이 NULL 인 33건은 제외된 건수의 합이다.

---

# GROUP BY 절

WHERE 절을 통해 조건에 맞는 데이터를 조회했지만 테이블에 1차적으로 존재하는 데이터 이외의 정보, 예를 들어 팀별로 선수가 몇명인지, 팀별로 선수들의 평균 신장과 몸무게가 얼마나 되는지, 또는 각 팀에서 가장 큰 키의 선수가 누구인지 등 2차 가공 정보도 필요하다.
GROUP BY 절은 SQL 문에서 FROM 과 WHERE 절 뒤에 오며, 데이터들을 작은 그룹으로 분류해 소그룹에 대한 항목별 통계 정보를 얻을 때 추가로 사용한다.

```sql
SELECT [DISTINCT] 칼럼명 [ALIAS명]
FROM 테이블명
[WHERE 조건식]
[GROUP BY 컬럼 또는 표현식]
[HAVING 그룹조건식];
```

GROUP BY 절과 HAVING 절은 다음과 같은 특성을 가진다.

- GROUP BY 절을 통해 소그룹별 기준을 정한 후, SELECT 절에 집계함수를 사용한다.
- 집계함수의 통계 정보는 NULL 값을 가진 행을 제외하고 수행한다.
- GROUP BY 절에서는 SELECT 절과 달리 ALIAS를 사용할 수 없다.
- 집계함수는 WHERE 절에는 올 수 없다. (집계함수를 사용할 수 있는 GROUP BY 절보다 WHERE 절이 먼저 수행된다)
- WHERE 절은 전체 데이터를 GROUP으로 나누기 전에 행들을 미리 제거한다.
- HAVING 절은 GROUP BY 절의 기준 항목이나 소그룹 집계함수를 이용한 조건을 표시할 수 있다.
- GROUP BY 절에 의한 소그룹별로 만들어진 집계 데이터 중, HAVING 절에서 제한 조건을 두어 조건을 만족하는 내용만 출력한다.
- HAVING 절은 일반적으로 GROUP BY 절 뒤에 위치한다.

관계형 데이터베이스 환경에서는 뒤에 언급할 ORDER BY 절을 명시해야 데이터 정렬이 수행된다.

```sql
-- GROUP BY 절을 사용하지 않고 집계함수를 사용했을 때 어떤 결과를 보이는지 포지션별 평균키를 구해본다.
SELECT POSITION AS 포지션, AVG(HEIGHT) AS 평균키
FROM PLAYER;
-- ORA-00937 : 단일 그룹의 그룹 함수가 아닙니다.

-- GROUP BY 절에서 그룹 단위를 표시해 주어야 SELECT 절에서 그룹 단위의 칼럼과 집계함수를 사용할 수 있다.
-- GROUP BY절에서 POSITION 의 alias는 사용할 수 없다.
SELECT POSITION AS 포지션, AVG(HEIGHT) AS 평균키
FROM PLAYER
GROUP BY POSITION;

-- 포지션별 최대키, 최소키, 평균키를 출력한다.

SELECT POSITION AS 포지션, COUNT(*) AS 인원수, COUNT(HEIGT) AS 측정대상
, MAX(HEIGHT) AS 최대키, MIN(HEIGHT) AS 최소키
, ROUND(AVG(HEIGHT),2) AS 평균키
FROM PLAYER
GROUP BY POSITION;

-- ORDER BY 절이 없기때문에 포지션 별로 정렬은 되지않는다.
-- 추가로 포지션과 키 정보가 없는 선수가 3명이라는 정보를 얻을 수 있으며, 포지션이 DF인 172명 중 30명은 키에 대한 정보가 없는 ㄱㅅ도 알 수 이싸.
-- 키 값이 NULL 인 경우는 계산 대상에서 제외된다.
```

---

# HAVING 절

```sql
 -- 케이리그 선수들의 포지션별 평균키를 구하는데 평균키가 180 cm 이상인 포지션의 정보만 표시하라는 요구 사항을 WHERE 절과 GROUP BY 절을 사용해 나타낸다.

 SELECT POSITION AS 포지션, AVG(HEIGHT) AS 평균키
 FROM PLAYER
 GROUP BY POSITION;
 HAVING AVG(HEIGHT) >= 180;
```

GROUP BY 절과 HAVING 절의 순서를 바꾸어서 수행하더라도 문법 에러도 없고 결과물도 동일하다. 그렇지만 SQL 내용을 보면, 포지션이란 소그룹으로 그룹핑돼 통계 정보가 만들어지고
이후 적용된 결과 값에 대한 HAVING 절의 제한 조건에 맞는 데이터만 출력하는 것이므로 논리적으로 GROUPBY 절과 HAVING 절의 순서를 지키는 것이 좋다.

```sql

-- 선수들 중 K02 와 K09의 인원수는 얼마인가? WHERE 절과 GROUP BY 절을 사용한 SQL 과  GROUP BY 절을 사용한 SQL 과 GROUP BY 절과 HAVING 정을 사용한 SQL 을 모두 작성한다.

select TEAM_ID, COUNT(*)
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K09')
GROUP BY TEAM_ID;

select TEAM_ID, COUNT(*)
FROM PLAYER
GROUP BY TEAM_ID
HAVING TEAM_ID IN ('K02', 'K09');

-- 같은 실행 결과를 얻는 두 가지 방법 중 HAVING 절에서 TEAM_ID 같은 GROUP BY 기준 칼럼에 대한 조건을 추가할 수도 있으나, 가능하면 WHERE 절에서 조건절을 적용해 GROUP BY 의 계산 대상 자체를 줄이는 것이 효율적이다.

-- 포지션별 평균키만을 출력하는데, 최대키가 190cm 이상인 선수를 갖고 있는 표지션의 정보만 출력한다.

SELECT TEAM_ID, AVG(HEIGHT)
FROM PLAYER
GROUP BY TEAM_ID
HAVING MAX(HEIGHT) >= 190

-- MAX 집계함수를 HAVING 절에서 조건절로 사용한 사례다. 즉 HAVING 절은 GROUP BY 절의 기준 항목이나 소그룹의 집계함수를 이용한 조건을 표시할 수 있다.
-- 주의할 점은 WHERE 절의 조건 변경은 대상 데이터의 개수가 변경되므로 결과 데이터 값이 변경될 수 있지만 HAVING 저의 조건 변경은 결과 데이터 변경은 없고 출력되는 레코드 개수만 변경될 수 있다.
```

---

# CASE 표현을 활용한 월별 데이터 집계

'집계함수(CASE()) ~ GROUP BY' 기능은 모델링의 제1정규화로 인해 반복되는 칼럼의 경우 구분 칼럼을 두고 여러 개의 레코드로 만들어진 집합을 정해진 칼럼 수 만큼 확장해 집계 보고서를 만드는 유용한 기법이다.
부서별로 월별 입사자 평균 급여를 알고 싶다는 고객의 요구사항이 있다. 입사 후 1년마다 급여인상이나 보너스 지급과 같은 일정이 정기적으로 잡힌다면 업무적으로 중요한 정보가 될 수 있다.

```sql
-- 부서별로 월별 입사자 평균 급여를 알고 싶다
-- STEP 1. 개별 데이터 확인
-- 먼저 개별 입사정보에서 월별 데이터를 추출하는 작업을 진행한다.

SELECT FIRST_NAME, DEPARTMENT_ID, EXTRACT (MONTH FROM HIRE_DATE) AS "입사월", SALARY
FROM HR.EMPLOYEES;

-- STEP2. 월별 구분
-- 추출된 MONTH 데이터를 Simple Cae Expression 을 이용해 12개의 월별 컬럼으로 구분한다.
SELECT FIRST_NAME, DEPARTMENT_ID
, CASE MONTH WHEN 1 THEN SAL END AS M01
, CASE MONTH WHEN 2 THEN SAL END AS M02
, CASE MONTH WHEN 3 THEN SAL END AS M03
, CASE MONTH WHEN 4 THEN SAL END AS M04
, CASE MONTH WHEN 5 THEN SAL END AS M05
, CASE MONTH WHEN 6 THEN SAL END AS M06
, CASE MONTH WHEN 7 THEN SAL END AS M07
, CASE MONTH WHEN 8 THEN SAL END AS M08
, CASE MONTH WHEN 9 THEN SAL END AS M09
, CASE MONTH WHEN 10 THEN SAL END AS M10
, CASE MONTH WHEN 11 THEN SAL END AS M11
, CASE MONTH WHEN 12 THEN SAL END AS M12
FROM
(
	SELECT FIRST_NAME, DEPARTMENT_ID, EXTRACT (MONTH FROM HIRE_DATE) AS MONTH, SALARY AS SAL
	FROM HR.EMPLOYEES
);

-- STEP3. 부서별 데이터 집계
-- 최종적으로 보여주는 리포트는 부서별로 월별 입사자의 평균 급여을 알고싶다는 요구 사항이므로 부서별 평균값을 구하기 위해 GROUP BY 절과 AVG 집게 함수를 사용한다.
-- 직원 개인에 대한 정보는 더이상 필요 없으므로 제외한다.
-- ORDER BY 절을 사용하지 않기 때문에 부서번호별로 정렬되지않는다.

SELECT DEPARTMENT_ID
, AVG(CASE MONTH WHEN 1 THEN SAL END) AS M01
, AVG(CASE MONTH WHEN 2 THEN SAL END) AS M02
, AVG(CASE MONTH WHEN 3 THEN SAL END) AS M03
, AVG(CASE MONTH WHEN 4 THEN SAL END) AS M04
, AVG(CASE MONTH WHEN 5 THEN SAL END) AS M05
, AVG(CASE MONTH WHEN 6 THEN SAL END) AS M06
, AVG(CASE MONTH WHEN 7 THEN SAL END) AS M07
, AVG(CASE MONTH WHEN 8 THEN SAL END) AS M08
, AVG(CASE MONTH WHEN 9 THEN SAL END) AS M09
, AVG(CASE MONTH WHEN 10 THEN SAL END) AS M10
, AVG(CASE MONTH WHEN 11 THEN SAL END) AS M11
, AVG(CASE MONTH WHEN 12 THEN SAL END) AS M12
FROM
(
	SELECT FIRST_NAME, DEPARTMENT_ID, EXTRACT (MONTH FROM HIRE_DATE) AS MONTH, SALARY AS SAL
	FROM HR.EMPLOYEES
)
GROUP BY DEPARTMENT_ID
```

하나의 데이터에 여러 번 CASE 표현을 사용하고 집계함수가 적용되므로 SQL 처리 성능 측면에서 나쁘다고 생각할 수 있다. 하지만 같은 기능을 하는 리포트를 작성하기 위해 장문의 프로그램을 코딩하는 것에 비해
하나의 SQL 문으로 처리가능하므로 훨씬 효율적이다. 데이터 건수가 많아질 수록 처리 속도 차이는 더 나 수 있다. 개발자들은 가능한 하나의 SQL 문장으로 비즈니스적인 요구 사항을 처리할 수 있도록 노력해야한다.

```sql
-- Simple Case Expression 으로 표현된 위의 SQL 과 같은 내용으로 Oracle DECODE 함수를 사용한 SQL 문장을 작성한다.
SELECT DEPARTMENT_ID
, AVG(DECODE(MONTH, 1, SAL)) AS M01
, AVG(DECODE(MONTH, 2, SAL)) AS M02
, AVG(DECODE(MONTH, 3, SAL)) AS M03
, AVG(DECODE(MONTH, 4, SAL)) AS M04
, AVG(DECODE(MONTH, 5, SAL)) AS M05
, AVG(DECODE(MONTH, 6, SAL)) AS M06
, AVG(DECODE(MONTH, 7, SAL)) AS M07
, AVG(DECODE(MONTH, 8, SAL)) AS M08
, AVG(DECODE(MONTH, 9, SAL)) AS M09
, AVG(DECODE(MONTH, 10, SAL)) AS M010
, AVG(DECODE(MONTH, 11, SAL)) AS M011
, AVG(DECODE(MONTH, 12, SAL)) AS M012
FROM
(
	SELECT FIRST_NAME, DEPARTMENT_ID, EXTRACT (MONTH FROM HIRE_DATE) AS MONTH, SALARY AS SAL
	FROM HR.EMPLOYEES
)
GROUP BY DEPARTMENT_ID
```

# 집계함수와 NULL 처리

리포트 빈칸을 NULL이 아닌 ZERO로 표현하기 위해 NVL 함수를 사용하는 경우가 많다. 다중 행 함수를 사용하는 경우 불필요한 부하가 발생하므로 굳이 사용할 필요가 없다.
다중 행 함수는 입력 값으로 전체 건수가 NULL 값인 경우만 함수의 결과가 NULL이 나오고 전체 건수 중에서 일부만 NULL인 경우는 NULL 인 행을 다중 행 함수의 대상에서 제외한다.

CASE 표현 사용 시 ELSE 절을 생략하면 Default 값이 NULL 이다. NULL 은 연산의 대상이 아닌 반면, SUM(CASE MONTH WHEN 1 THEN SAL ELSE 0 END) 처럼 ELSE 절에 0을 지정하면 불필요하게 0이 SUM 연산에 사용되어 자원 사용이 많아진다.
같은 결과를 얻을 수 있다면, 가능한 ELSE 절에 상수값을 지정하지 않거나 ELSE 절을 작성하지 않도록 한다. 같은 이유로 ORACLE DECODE 함수는 4번째 인자를 지정하지 않으면 NULL이 Default로 할당된다.

가장 많이 실수하는 것 중 하나가 SUM(NVL(SAL,0)) 연산이다. 개별 데이터의 급여가 NULL 인 경우 NULL의 특성으로 자동으로 SUM 연산에서 빠지는데, 불필요하게 0으로 변한해 데이터 건수 만큼 연산이 일어나게 할 필요가 없다.
리포트 출력 때 NULL이 아닌 0을 표시하고 싶은 경우 전체 SUM의 결과가 NULL 인 경우에만 한 번 NVL 함수를 사용한다.

```sql
-- 팀별 포지션별 FW, MF, DF, GK 포지션의 인원수와 팀별 전체 인원수를 구하는 SQL을 작성한다. 데이터가없는 경우 0으로 표시한다.
SELECT TEAM_ID
, NVL(SUM(CASE POSITION WHEN 'FW' THEN 1 ELSE 0 END),0) AS FW
, NVL(SUM(CASE POSITION WHEN 'MF' THEN 1 ELSE 0 END),0) AS MF
, NVL(SUM(CASE POSITION WHEN 'DF' THEN 1 ELSE 0 END),0) AS DF
, NVL(SUM(CASE POSITION WHEN 'GK' THEN 1 ELSE 0 END),0) AS GK
, COUNT(*) AS SUM
FROM PLAYER
GROUP BY TEAM_ID;

-- ELSE 0, ELSE NULL 문구는 생략 가능하므로 다음과 같이 좀더 짧게 구성할 수 있다.

-- SIMPLE_CASE_EXPRESIION
SELECT TEAM_ID
, NVL(SUM(CASE POSITION WHEN 'FW' THEN 1  END),0) AS FW
, NVL(SUM(CASE POSITION WHEN 'MF' THEN 1  END),0) AS MF
, NVL(SUM(CASE POSITION WHEN 'DF' THEN 1  END),0) AS DF
, NVL(SUM(CASE POSITION WHEN 'GK' THEN 1  END),0) AS GK
, COUNT(*) AS SUM
FROM PLAYER
GROUP BY TEAM_ID;

-- SEARCHED_CASE_EXPRESIION
SELECT TEAM_ID
, NVL(SUM(CASE WHEN POSITION = 'FW' THEN 1 END),0) AS FW
, NVL(SUM(CASE WHEN POSITION = 'MF' THEN 1 END),0) AS MF
, NVL(SUM(CASE WHEN POSITION = 'DF' THEN 1 END),0) AS DF
, NVL(SUM(CASE WHEN POSITION = 'GK' THEN 1 END),0) AS GK
, COUNT(*) AS SUM
FROM PLAYER
GROUP BY TEAM_ID;

-- GROUP BY 절 없이 전체 선수들의 포지션별 평균키 및 전체 평균키를 출력할 수 있다.
SELECT TEAM_ID
, ROUND(AVG(CASE WHEN POSITION = 'FW' THEN HEIGHT END),2) AS FW
, ROUND(AVG(CASE WHEN POSITION = 'MF' THEN HEIGHT END),2) AS MF
, ROUND(AVG(CASE WHEN POSITION = 'DF' THEN HEIGHT END),2) AS DF
, ROUND(AVG(CASE WHEN POSITION = 'GK' THEN HEIGHT END),2) AS GK
, ROUND(AVG(HEIGT), 2) AS 전체평균키
FROM PLAYER
```
