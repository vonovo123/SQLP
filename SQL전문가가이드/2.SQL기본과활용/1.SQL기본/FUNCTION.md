# 내장 함수 개요

함수는 다양한 기준으로 분류할 수 있는데, 벤더에서 제공하는 함수인 내장 함수와 사용자가 정의할 수 있는 함수로 나눌 수 있다.
내장 함수는 SQL을 더욱 강력하게 해주고 데이터 값을 간편하게 조작하는 데 사용된다. 내장 함수는 다시 함수 입력 값이 단일행 값이 입력되는 단일행 함수와 여러 행의 값이 입력되는 다중행 함수로 나눌 수 있다.

다중행 함수는 다시 집계함수, 그룹함수, 윈도우함수로 나눌 수 있다.

함수는 입력되는 값이 아무리 많아도 출력은 하나만 되는 M:1 관계라는 중요한 특징을 갖고 있다. 단일행 함수의 경우 단일행 내에 있는 하나의 값
또는 여러 값이 입력 인수로 표현될 수 있다. 다중행 함수의 경우 여러 레코드의 값들을 입력 인수로 사용한다.

단일행 함수는 처리하는 데이터의 형식에 따라 문자형, 숫자형, 날짜형, 변화녕, Null 관련 함수로 나눌 수 있다.

단일행 함수의 중요한 특징은 다음과 같다.

\- SELECT, WHERE, ORDER BY 절에 사용 가능하다.
\- 각 행들에 대해 개별적으로 작용해 데이터 값을 조작하고, 각각의 행에 대한 조작 결과를 리턴한다.
\- 여러 인자를 입력해도 단 하나의 결과만 리턴한다.
\- 함수의 인자로 상수,변수,표현식이 사용 가능하고, 하나의 인수를 가지는 경우도 있지만 여러 개의 인수를 가질 수 있다.
\- 특별한 경우가 아니면 함수의 인자로 함수를 사용하는 함수의 중첩이 가능하다.

---

## 문자형 함수

문자형 함수는 문자 데이터를 매개 변수로 받아들여서 문자나 숫자 값의 결과를 돌려주는 함수다. 몇몇 문자형 함수는 결과를 숫자로 리턴하기도 한다.

```sql
-- LOWER(문자열) : 문자열의 알파벳 문자를 소문자로 바꾸어 준다.
-- 'sql expert'
LOWER('SQL Expert')

-- UPPER(문자열) : 문자열의 알파벳 문자를 대문자로 바꾸어 준다.
-- 'SQL EXPERT'
UPPER('SQL Expert')

-- ASCII(문자열) : 문자나 숫자를 ASCII 코드 번호로 바꾸어 준다.
-- 65
ASCII('A')

-- CHR/CHAR(ASCCI번호) : ASCII 코드 번호를 문자나 숫자로 바꾸어 준다.
-- 'A'

CHAR(65)

-- CONCAT(문자열1, 문자열2) : 문자열1과 문자열2를 연결한다.
-- 'RDBMS SQL'

CONCAT('RDBMS', ' SQL')

-- SUBSTR/SUBSTRING(문자열, m, [,n]) : 문자열 중 m위치에서 n개의 문자길이에 해당하는 문자르 돌려준다.
-- 'Exp'

SUBSTR('SQL Expert', 5, 3)

-- LENGTH/LEN(문자열) : 문자열의 개수를 숫자값으로 돌려준다.
-- 10

SELECT LENGTH('SQL Expert') AS LEN
FROM DUAL;

-- LTRIM (문자열, [,지정문자]) / LTRIM(문자열) : 문자열의 첫 문자부터 확인해서 지정 문자가 나나타면 해당 문자를 제거한다. (지정문자가 없으면 공백이 디폴트)
-- 'YYZZxYZ'
LTRIM('xxxYYZZxYZ', 'x')

-- RTRIM (문자열, [,지정문자]) / RTRIM(문자열) : 문자열의 마지막 문자부터 확인해서 지정 문자가 나타나는 동안 해당 문자를 제거한다. (지정문자가 없으면 공백이 디폴트)

-- 'XXYYzzXY'
RTRIM('XXYYzzXYzz', 'z')
-- 'XXYYZZXYZ'
RTRIM('XXYYZZXYZ    ')

-- TRIM([leading|trailing|both] 지정문자 FROM 문자열) : 문자열에서 머리말(leading), 꼬리말(trailing) 또는 양쪽(both) 에 있는 지정 문자를 제거한다.(Default : both)
-- 'YYZZxYZ'
TRIM('x' FROM 'xxYYZZxYZxx')

```

예제 및 실행 결과를 보면 함수에 대한 결과 값을 마치 테이블에서 값을 조회했을 때와 비슷하게 표현한다.
Oracle은 SELECT 절과 FROM 절 두 개의 절을 SELECT 문장의 필수 절로 지정했으므로, 사용자 테이블이 필요없는 SQL 문장의 경우에도 필수적으로 DUAL 이라는 테이블을 FROM 절에 지정한다.

DUAL 테이블의 특성은 다음과 같다.

\- 사용자 SYS가 소유하며 모든 사용자가 엑세스 가능하다.
\- SELECT ~ FROM ~ 의 형식을 갖추기 위한 일종의 DUMMY 테이블이다.
\- DUMMY라는 문자열 유형의 칼럼에 'X' 라는 값이 들어 있는 행 1건을 포함한다.

```sql
-- 선수 테이블에서 CONCAT 문자형 함수를 이용해 축구선수란 문구를 추가한다.
SELECT CONCAT (PLAYER_NAME, ' 축구선수') AS 선수명
FROM PLAYER;
```

실행 결과를 보면 실제적으로 함수가 모든 행에 대해 적용되어 '~축구선수' 라는 각각의 결과로 출력됐다.

특별한 제약조건이 없다면 함수는 여러 개 중첩해 사용할 수 있다. 함수 내부에 다른 함수를 사용하면 안쪽에 위치한 함수부터 실행되어, 그 결과 값이 바깥쪽 함수의 인자로 사용된다.

```sql
함수3 (함수2( 함수1 (칼럼이나 표현식 [, Arg1]), [, Arg2]), [, Arg3])

-- 경기장의 지역번호와 전화번호를 합친 번호의 길이를 구하시오. 연결연산자의 결과가 LENGTH 함수의 인수가 된다.

SELECT STADIUM_ID, DDD || ')' || TEL AS TEL, LENGTH( CONCAT( DDD, '-' , TEL) ) AS T_LEN
FROM STADIUM;
```

---

## 숫자형 함수

숫자형 함수는 숫자 데이터를 입력받아 처리하고 숫자를 리턴하는 함수이다.

```sql

-- ABS(숫자) : 숫자의 절대값을 돌려준다.
-- SIGN(숫자) : 숫자가 양수인지, 임수인지 0인지를 구별한다.
-- MOD(숫자1, 숫자2) : 숫자 1을 숫자 2로 나누어 나머지 값을 리턴한다.
-- CEIL(숫자) : 숫자보다 크거나 같은 최소 정수를 리턴한다.
-- FLOOR(숫자) : 숫자보다 작거나 같은 최대 정수를 리턴한다.
-- ROUND(숫자 [, m]) : 숫자를 소수점 m 자리에서 반올림해 리턴한다.
-- TRUNC(숫자, [, m]) : 숫자를 소수 m 자리에서 잘라버린다.
-- SIN, COS, TAN : 숫자의 삼각함수를 리턴한다.
-- EXP(숫자) : 숫자의 지수 값을 리턴한다.
-- POWER(숫자1, 숫자2) : 숫자의 거듭제곱 값을 리터난다.
-- SQRT(숫자) : 숫자의 제곱근 값을 리턴한다.
-- LOG(숫자1, 숫자2) : 숫자1을 밑수로 하는 숫자2의 로그갑을 리턴한다.
-- LN(숫자) : 숫자의 자연 로그 값을 리턴한다.


-- 반올림 및 내림해 소수점 이하 한 자리 까지 출력한다.

SELECT ENAME, ROUND( SAL /12 , 1 ) AS SAL_ROUND, TRUNC(SAL / 12, 1) AS SAL_TRUNC
FROM EMP;

-- 반올림 및 올림해 정수 기준으로 출력한다.
SELECT ENAME, ROUND(SAL/12) AS SAL_ROUND, CEIL(SAL / 12) AS SAL_CEIL
FROM EMP;

```

---

## 날짜형 함수

날짜형 함수는 DATE 타입의 값을 연산하는 함수다.

```sql
-- SYSDATE : 현재 날짜와 시각을 출력한다.
-- EXTRACT(YEAR|MONTH|DAY from d) : 날짜 데이터에서 연월일 데이터를출력할 수 있다.
-- TO_NUMBER(TO_CHAR(d, 'YYYY')) : 날짜데이터에서 년도를 숫자로 출력
-- TO_NUMBER(TO_CHAR(d, 'MM')) : 날짜데이터에서 월을 숫자로 출력
-- TO_NUMBER(TO_CHAR(d, 'DD')) : 날짜데이터에서 일을 숫자로 출력
```

DATE 변수가 데이터베이스에 어떻게 저장되는지 살펴보면, 데이터베이스는 날짜를 저장할 때 내부적으로 세기, 연, 월, 이, 시, 분 ,초 와 같은 숫자 형식으로 변환해 저장한다.
날짜는 여러 가지 형식으로 출력되고 날짜 계산에도 사용되기 때문에 그 편리성을 위해 숫자형으로 지정한다.
데이터베이스는 날짜를 숫자로 저장하기 때문에 덧셈, 뻴셈 같은 산술 연산자로도 계산이 가능하다. 즉 날짜에 숫자 상수를 더하거나 뺄 수 있다.

```sql
-- 날짜 + 숫자 = 날짜 : 숫자만큼의 날수를 날짜에 더한다.
-- 날짜 - 숫자 = 날짜 : 숫자만큼의 날수를 날짜만큼 뺀다.
-- 날짜1 - 날짜2 = 숫자 : 다른 하나의 날짜에서 하나의 날짜를 빼 일수를 구한다.
-- 날짜 + 숫자/24 = 날짜 : 시간을 날짜에 더한다.

-- Oracle 의 SYSDATE 함수를 이용해 데이터베이스에서 사용하는 현재의 날짜데이터를 확인한다. 날짜 데이터는 시스템 구성에 따라 다양하게 표현될 수 이다.

SELECT SYSDATE
FROM DUAL;

-- 사원(EMP) 테이블의 입사일자에서 년, 월, 일 데이터를 각각 출력한다.
SELECT ENAME AS 사원명, HIREDATE AS 입사일자
, EXTRACT (YEAR FROM HIREDATE) AS 입사년도
, EXTRACT (MONTH FROM HIREDATE) AS 입사월
, EXTRACT (DAY FROM HIREDATE) AS 입사일
FROM EMP;

SELECT ENAME AS 사원명, HIREDATE AS 입사일자
, TO_NUMBER (TO_CHAR(HIREDATE,'YYYY')) AS 입사년도
, TO_NUMBER (TO_CHAR(HIREDATE,'MM')) AS 입사월
, TO_NUMBER (TO_CHAR(HIREDATE,'DD')) AS 입사일
FROM EMP;

SELECT ENAME AS 사원명, HIREDATE AS 입사일자
, YEAR(HIREDATE,'YYYY') AS 입사년도
, MONTH(HIREDATE) AS 입사월
, DAY(HIREDATE) AS 입사일
FROM EMP;
```

---

## 변환형 함수

변환형 함수는 특정 데이터 타입을 다양한 형식으로 출력하고 싶을 경우 사용한다. 변환형 함수는 크게 두 가지 방식이 있다.

- 명시적 데이터 유형 변환

데이터 변환형 함수를 사용해 데이터 유형을 변환하도록 명시해 주는 경우

- 암시적 데이터 유형 변환

데이터베이스가 자동으로 데이터 유형을 변환해 계산하는 경우

암시적 데이터 유형 변환의 경우 성능 저하가 발생할 수 있다. 자동으로 데이터베이스가 알아서 계산하지 않는 경우가 있어 에러가 발생할 수 있으므로 명시적인 데이터 유형 변환 방법을 사용하는 것이 바람직하다.
명시적 데이터 유형 변환에 사용되는 대표적 변환형 함수는 다음과 같다.

```sql
-- TO_NUMBER(문자열) : 숫자로 변환 가능한 문자열을 숫자로 변환한다.
-- TO_CHAR(숫자|날짜 [, FORMAT]) : 숫자나 날짜를 주어진 FORMAT 형태인 문자열 타입으로 변환한다.
-- TO_DATE(문자열, [, FORMAT]) : 문자열을 주어진 FORMAT 형태인 날짜 타입으로 변환한다.

SELECT TO_CHAR(SYSDATE, 'YYYY/MM/DD') AS 날짜
      ,TO_CHAR(SYSDATE, 'YYYY. MON, DAY') AS 문자형
FROM DUAL;

-- 팀 테이블의 ZIP코드1과 ZIP코드2를 숫자로 변환한 후 두 항목을 더한 숫자를 출력한다.

SELECT TEAM_ID AS 팀ID
, TO_NUMBER(ZIP_CODE1, '999') + TO_NUMBER(ZIP_CODE2, '999') AS 우편번호합
FROM TEAM;

```

---

## CASE 표현

CASE 표현은 IF-THEN-ELSE 논리와 유사한 방식으로 표현식을 작서애 SQL의 비교 연산 기능을 보완하는 역할을 한다. ORACLE의 Decode 함수와 같은 기능을 하므로 단일행 내장 함수에서 같이 설명한다.

```sql
-- PL/SQL
IF SAL > 2000
  THEN REVISED_SALARY=SAL
  ELSE REVISED_SALARY = 2000
END IF

-- CASE로 표현
SELECT ENAME
, CASE
    WHEN SAL > 2000 THEN SAL
    ELSE 2000
  END AS REVISED_SALARY
FROM EMP;

```

CASE Expression 은 Simple Case Expression 과 Searched Case Expresison 두 가지 표현법 중 하나를 선택해서 사용하게 된다.

```sql
CASE
  SIMPLE_CASE_EXPRESSION 조건 or SEARCHED_CASE_EXPRESSION 조건
  [ELSE 디폴트값]
END
```

SIMPLE_CASE_EXPRESSION 은 CASE 바로 다음 조건에 사용되는 칼럼이나 표현식이다. 다음 WHEN 절에서 앞에 정의한 칼럼이나 표현식과 같은지 다른지 판단하는 문장으로 EQUI 조건만 사용한다면
SEARCHED_CASE_EXPRESSION 보다 간단하게 사용할 수 있는 장점이 있다.

```sql
-- 부서 정보에서 부서 위치를 미국의 동부, 중부, 서부로 구분하라.
SELECT LOC
, CASE LOC
    WHEN 'NEW YORK' THEN 'EAST'
    WHEN 'BOSTON' THEN 'EAST'
    WHEN 'CHICAGO' THEN 'CNETER'
    WHEN 'DALLAS' THEN 'CNETER'
    ELSE 'ETC'
  END as AREA
FROM DEPT;
```

SEARCHED_CASE_EXPRESSION 은 CASE 다음에는 칼럼이나 표현식을 표시하지 않고, 다음 WHEN 절에 EQUI 조건 포함 여러 조건을 이용한 조건절을 사용할 수 있다.
SIMPLE_CASE_EXPRESSION 보다 훨씬 다양한 조건을 적용할 수 있는 장점이 있다.

```sql
CASE
  WHEN CONDITION THEN RETURN_EXPR
  ELSE DEFAULT_EXPR
END

-- 사원 정보에서 급여가 3000 이상이면 상등급, 1000 이상이면 중등급, 1000 미만이면 하등급으로 분류하라

SELECT ENAME
      , CASE
        WHEN SAL >= 3000 THEN 'HIGH'
        WHEN SAL >= 1000 THEN 'MID'
        ELSE 'LOW'
      END AS SALARY_GRADE
FROM EMP;

-- CASE 표현은 함수의 성질을 갖고 있으므로 중첩 함수로 사용할 수도 있다.
-- 사원 정보에서 급여가 2000 이상이면 보너스를 1000으로, 1000 이상이면 500 을 1000 미만이면 으로 계산한다.

SELECT ENAME, SAL
  , CASE
      WHEN SAL >= 2000 THEN 1000
      ELSE(
        CASE
          SAL >= 1000 THEN 500
          ELSE 0
      END )
  END AS BONUS
FROM EMP;
```

---

# NULL 관련 함수

## NVL/ISNULL 함수

- NULL 값은 정의되지 않은 값으로 0 또는 공백과 다르다. 0은 숫자고, 공백은 하나의 문자다.
- 테이블을 생성할 때 NOT NULL 또는 PRIMARY KEY로 정의되지 않은 모든 속성은 NULL 값을 가질 수 있다.
- NULL 값을 포함하는 연산의 경우 결과 값도 NULL이다. 모르는 데이터에 숫자를 더하거나 빼도 결과는 마찬가지로 모르는 데이터인 것과 같다.

결과 값을 NULL이 아닌 다른 값으로 얻고자 할 때 NVL/ISNULL 함수를 사용한다. NULL 값의 대상이 숫자 유형 데이터인 경우는 주로 0으로, 문자 유형 데이터인 경우는 블랭크보다는 'x' 와 같이 해당 시스템에서 의미 없는 문자로 바꾸는 경우가 많다.

NVL/ISNULL 함수를 유용하게 사용하는 예는 산술적인 계산에서 데이터 값이 NULL일 경우다. 칼럼 간 계산을 하는 경우 NULL이 존재하면 해당 연산 결과가 항상 NULL이 되므로 원하는 결과를 얻을 수 없는 경우가 많다.
이런 경우는 NVL 함수를 사용해 0으로 변환한 후 계산하면 원하는 데이터를 얻는다.

관계형 데이터베이스의 중요한 데이터인 NULL을 처리하는 주요 함수는 다음과 같다.

```sql
-- NVL(NULL 판단 대상, 'NULL 일 때 대체값')

SELECT NVL (NULL, 'NVL-OK') AS NVL_TEST
FROM DUAL;

SELECT NVL ('NOT-NULL', 'NVL-OK') AS NVL_TEST
FROM DUAL;

-- 선수 테이블에서 성남 일화천마 소속 선수의 이름과 포지션을 출력하는데, 포지션이 없는 경우 '없음'으로 표시한다.

SELECT PLAYER_NAME AS 선수명, POSITIN AS 포지션, NVL(POSITION, '없음') AS NL 포지션
FROM PLAYER
WHERE TEAM_ID='K08';

-- NVL 함수와 ISNULL 함수를 사용한 SQL 문장은 벤더 공통으로 CASE 문장으로 표현할 수 있다.

SELECT PLAYER_NAME 선수명, POSITION AS 포지션
, CASE
    WHEN POSITION IS NULL THEN '없음'
    ELSE POSITION
  END AS NV포지션;
FROM PLAYER
WHERE TEAM_ID='K08';

-- 급여와 커미션을 포함한 연봉을 계산하면서 NVL 함수의 필요성을 알아본다.

SELECT ENAME AS 사원명, SAL AS 월급, COMM AS 커미션
, (SAL * 12) + COMM AS 연봉 A, (SAL * 12) + NVL(COMM,0) AS 연봉 B
```

실행 결과에서 월급에 커미션을 더해서 연봉을 계산하는 산술식이 있을 때, 커미션에 NULL 값이 있는 경우 커미션 값에 NVL() 함수를 사용하지 않으면, 연봉 A의 계산 결과가 NULL이 돼서 잘못된 결과가 도출된다.
그러나 NVL 함수를 다중행 함수의 인자로 사용하는 경우 오히려 불필요한 부하가 발생할 수 있으므로 굳이 함수를 사용할 필요가 없다. 다중행 함수는 입력 값으로 전체 건수가 NULL인 경우만 함수의 결과가 NULL이 나오고,
전체 건수 중에서 일부만 NULL 인 경우는 다중행 함수의 대상에서 제외된다.

예를 들어 100명 중 10명의 성적이 NULL 일때 평균을 구하는 다중행 함수 AVG를 사용하면 NULL 값이 아닌 90명의 성적에 대해서만 평균값을 구한다.

---

# NULL 과 공집합

## 일반적인 NVL/ISNULL 함수 사용

```sql

-- 1. 정상적으로 매니저 정보를 갖고 있는 SCOTT 매니저를 출력한다.

SELECT MGR
FROM EMP
WHERE ENAME = 'SCOTT';

-- 2. 매니저에 NULL 이 들어있는 KING의 매니저를 출력한다.

SELECT MGR
FROM EMP
WHERE ENAME = 'KING';

-- 3. 매니저가 NULL 인 경우 빈칸이 아닌 9999로 출력하기 위해 NVL/ISNULL 함수를 사용한다.
SELECT NVL(MGR, 9999) AS MGR
FROM EMP
WHERE ENAME = 'KING';
```

## 공집합일때 NVL/ISNULL 함수 사용

조건에 맞는 데이터가 한 건도 없는 경우를 공집합이라고 한다.
'SELECT 1 FROM DUAL WHERE 1 = 2;' 와 같은 조건이 대표적인 공집합을 발생시키는 쿼리다. 공집합은 NULL 데이터와는 또 다른 개념이다.

```sql
-- 공집합을 발생시키기 위해 사원 테이블에 존재하지 않는 'JSC'라는 이름으로 데이터를 검색한다.
-- 선택된 레코드가 없습니다.
SELECT MGR
FROM EMP
WHERE ENAME = 'JSC';

-- EMP 테이블에 ENAME이 'JSC' 란 사람은 없으므로 공집합이 발생한다.

-- NVL/ISNULL 함수를 이용해 공집합을 9999로 바꾸고자 시도한다.
-- 선택된 레코드가 없습니다.
SELECT NVL (MGR, 9999) AS MGR
FROM EMP
WHERE ENAME = 'JSC';

-- 공집합인 경우 NVL/ISNULL을 사용해도 역시 공집합이 출력된다. NVL/ISNULL 함수는 NULL 값을 다른 값으로 바꾸는 역할을 하는 함수이지 공집합을 대상으로 하지 않는다.

-- 적절합 집계함수를 찾아 NVL 함수 대신 적용한다
-- 1개의 행이 선택됐습니다.( NUULL로 변경)
-- 다른 함수와 달리 집계합수나 Scalar Subquery인 경우 인수의 결과 값이 공집합인 경우에도 NULL로 출력한다.
SELECT MAX(MGR) AS MGR
FROM EMP
WHERE ENAME = 'JSC';



-- 집계함수를 인수로 한 NVL/ISNULL 함수를 이용해서 공집합인 경우에도 빈칸이 아닌 9999로 출력하게 한다.

SELECT NVL ( MAX(MGR), 9999) AS MGR
FROM EMP
WHERE ENAME = 'JSC';
```

공집합의 경우는 NVL 함수를 사용해도 공집합이 출력되므로, 그룹함수와 NVL 함수를 같이 사용해서 처리한다. 예제는 그룹 함수를 NVL 함수의 인자로 사용해서 인수 값이 공집합인 경우에도 원하는 9999 라는 값으로 변환한 사례이다.
개발자는 NVL/ISNULL 함수를 사용해야 하는 경우와, 집계함수를 포함한 NVL/ISNULL 함수를 사용해야 하는 경우, 그리고 NVL/ISNULL 함수를 포함한 집계함수를 사용하지 않아야 될 경우까지 잘 이해해서 NVL/ISNULL 함수를 정확히 사용해야한다.

---

## NULLIF

EXPR1이 EXPR2와 같으면 NULL을, 같지않으면 EXPR1을 리턴한다. 특정 값을 NULL로 대체하는 경우 유용하다.

```sql
NULLIF (EXPR1, EXPR2)

-- 사원테이블에서 MGR와 7689이 같으면 NULL 을 표시하고, 같지않으면 MGR을 표시한다
SELECT ENAME, EMPNO, MGR, NULLIF(MGR, 7698) AS NUIF
FROM EMP;

-- CASE 문장으로도 표현할 수 있다.
SELECT ENAME, EMPNO, MGR
, CASE
    WHEN MGR = 7698 THEN NULL
    ELSE MGR
END AS NUIF
FROM EMP;
```

---

## 기타 NULL 관련 함수(COALESCE)

COALESCE 함수는 인수의 숫자가 한정돼 있지 않으며, 임의의 개수 EXPR에서 NULL이 아닌 최초의 EXPR을 나타낸다. 모든 EXPR이 NULL 이면 NULL을 리턴한다.

```sql
COALESCE (EXPR1, EXPR2, ....);

-- 사원 테이블에서 커미션을 1차 선택 값으로, 급여를 2차 선택 값을 선택하디, 두 컬럼 모두 NULL 인 경우는 NULL로 표시한다.
SELECT ENAME, COMM, COALESECE(COMM, SAL) AS COAL
FROM EMP;

-- 두 개의 중첩된 CASE 문장으로 표현할 수 있다.
SELECT ENAME, COMM, SAL,
, CASE
  WHEN COMM IS NOT NULL THEN COMM
  ELSE (
    CASE SAL IS NOT NULL THEN SAL
    ELSE NULL
    END
  )
  END AS COAL
FROM EMP;
```
