# WHERE 조건절 개요

SELECT 절과 FROM 절만 사용해 SQL 문장을 구성한다면, 테이블에 있는 모든 자료가 결과로 출력돼 실제로 원하는 자료를 확인하기 어렵다. 검색자가 원하는 자료만을 검색하기 위해 WHERE 절을 이용해 자료를 제한할 수 있다.
WHERE 절에는 두 개 이상의 테이블에 대한 조인 조건을 기술하거나 결과를 제한하기 위해 조건을 기술할 수 있다.
현실의 데이터베이스는 많은 사용자나 프로그램들이 동시에 접속해 다량의 트랜잭션이 발생한다. WHERE 조건절을 사용하지 않는 요청은 데이터베이스가 설치된 서버의 시스템 자원을 과다하게 사용한다. 또한 많은 사용자로부터 오는 요청을 바로 처리해주지 못하게 되고 검색된 많은 자료가 네트워크를 통해 전달됨으로써 문제가 발생한다. 이런 문제점을 방지하기 위해 WHERE 조건절이 없는 Full Table Scan 문장은 SQL튜닝의 1차적인 검토 대상이 된다. WHERE 절은 조회하려는 데이터에 특정 조건을 부여할 목적으로 사용하기 때문에 FROM 절 뒤에 오게 된다.

```sql
SELECT [DISTINCT/ALL]
  칼럼명 [ALIAS 명]
FROM 테이블명
WHERE 조건식;
```

WHERE 절은 FROM 절 다음에 위치하며, 조건식은 아래 내용으로 구성된다.

- 칼럼명(보통 조건식의 좌측에 위치)
- 비교 연산자
- 문자, 숫자, 표현식
- 비교 칼럼명

---

# 연산자의 종류

```
케이리그 일부 선수의 이름과 포지션, 백넘버를 알고 싶다.
조건은 소속팀이 삼성블루윙즈이거나 전남드레곤즈에 소속된 선수들 중에
포지션이 미드필더 이면서 키는 170 cm 이상 , 180 이하여야 한다.
```

위의 요구 조건을 모두 만족하는 쿼리를 구성하기 위해서 다양한 연산자를 사용해야만 한다.
WHERE 절에 사용되는 연산자는 3가지 이다.

```sql

-- 비교 연산자
  -- = : 같다.
  -- > : 보다 크다.
  -- >= : 보다 크거나 같다.
  -- < : 보다 작다.
  -- <= : 보다 작거나 같다

-- SQL 연산자
  -- BETWEEN a AND b : a 와 b 값 사이의 값 (a,b 포함)
  -- IN (list) : 리스트에 있는 값 중 어느 하나라도 일치한다.
  -- LIKE '비교문자열' : 비교문자열과 형태가 일치(%,_사용)
  -- IS NULL : NULL 값을 갖는다.

-- 논리연산자

  -- AND : 앞에 있는 조건과 뒤에 오는 조건이 참이 되면 결과도 참이 된다.
  -- OR :  앞의 조건이 참이 되거나 뒤의 조건이 참이 되면 결과도 차미다.
  -- NOT : 뒤에 오는 조건에 반대되는 결과를 돌려준다.

-- 부정비교연산자

  -- != : 같지않다.
  -- ^= : 같지않다.
  -- <> : 같지않다.
  -- NOT 칼럼명 = : ~ 와 같지 않다.
  -- NOT 칼럼명 > : ~ 보다 크지 않다.

-- 부정 SQL 연산자

  -- NOT BETWEEN a AND b : a와 b 값 사이에 있지 않다.(a,b 값을 포함하지 않는다.)
  -- NOT IN (list) : list 값과 일치하지 않다.
  -- IS NOT NULL : NULL 값을 갖지 않는다.

-- 연산자 우선순위
-- 1 : 괄호()
-- 2 : 비교 연산자, SQL 연산자
-- 3 : NOT 연산자
-- 4 : AND
-- 5 : OR
```

연산자 우선순위를 살펴보면 다음과 같다.

\- 괄호로 묶은 연산이 제이 먼저 연산처리된다.
\- 연산자들 중에는 비교연산자, SQL 연산자가 먼저 처리된다.
\- 부정 연산자가 처리된다.
\- 논리 연산자 중에 AND,OR이 순서대로 처리된다.

실수하기 쉬운 비교 연산자와 논리 연산자의 경우 괄호를 사용해 우선순위를 표시하는 것이 좋다.

---

# 비교 연산자

비교 연산자는 소속팀, 포지션, 키와 같은 칼럼들을 특정한 값들과 조건을 비교하는데 사용된다.

```sql

-- 첫 번째 요구 사항인 소속팀이 삼성블루윙즈라는 조건을 WHERE 절로 옮겨서 SQL 문장을 완성한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = "K02";

-- 세 번째 요구 사항인 포지션이 미드필더인 조건을 WHERE 조건절로 옮겨서 SQL 문장을 완성해 실행한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = "MF";
```

추가로 문자 유형간 비교 조건이 발생하는 경우 다음과 같이 처리한다.

```sql
-- 비교 연산자의 양쪽이 모두 CHAR 타입인 경우
  -- 길이가 서로 다르면 작은 쪽에 스페이스를 추가해 길이를 같게 한 후 비교한다.
  -- 서로 다른 문자가 나올 때 까지 비교한다.
  -- 달라진 첫 번째 문자의 값에 따라 크기를 결정한다.
  -- 문자 끝 블랭크 수만 다르다면 서로 같은 값으로 결정한다.

-- 비교 연산자의 어느 한 쪽이 VARCHAR 타입인 경우
  -- 서로 다른 문자가 나올때 까지 비교한다.
  -- 길이가 다르면 짧은 것이 끝날 때 까지만 비교한후 기리가 긴 것이 크다고 판단한다.
  -- 길이가 같고 다른 것이 없다면 같다고 판단한다.
  -- 문자 끝 블랭크도 문자로 취급하기때문에 문자가 같더라도 블랭크 수가 다르면 다른 값이다

-- 상수값과 비교할 경우
  -- 상수 쪽을 변수 타입과 동일하게 바꾸고 비교한다.
  -- 변수 쪽이 CHAR 타입이면 위의 CHAR 유형 타임의 경우를 적용한다.
  -- 변수 쪽이 VARCHAR 타입이면 위의 VARCHAR 유형 타임의 경우를 적용한다.

-- 네 번째 요구 사항인 '키 170 센티미터 이상' 인 조건도 WHERE 절로 옮겨서 SQL 문장을 완성해 실행한다.
-- WHERE HEIGHT >= '170' 이라고 기술하더라도 HEIGTH 칼럼의 유형이 숫자이므로 내부적으로 "170"을 170으로 바꿔 처리한다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID >= 170;


```

---

# SQL 연산자

SQL 연산자는 SQL 문장에서 사용하도록 기본적으로 예약돼있는 연산자로서 모든 데이터 타입에 대해 가능한 4가지 종류가 있다.

## IN (list) 연산자

```sql

-- 소속팀 코드에 관련된 IN () 형태의 SQL 연산자를 사용해 WHERE 절에 사용한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07');

-- 사원 테이블에서 JOB이 MANAGER 이면서 20번 부서에 속하거나, JOB이 CLERK 이면서 30번 부서에 속하는 사원의 정보를 IN 연산자의 다중 리스트를 이용해 출력하라.
SELECT ENAME, JOB, DEPTNO
FROM EMP
WHERE (JOB, DEPTNO) IN (('MANAGER', 20), ('CLERK', 30))
```

사용자들이 잘 모르고 있는 다중 리스트를 이용한 IN 연산자는 SQL 문장을 짧게 만들어 주면서도 성능 면에서 장점을 가질 수 있는 매우 유용한 존재다. 사용이 적극 권장된다.
다만 아래 SQL 문장과는 다른 결과가 나타나게 되므로 용도를 구분해야한다.

```sql
SELECT ENAME, JOB, DEPTNO
FROM EMP
WHERE JOB IN ('MANAER', 'CLERK') AND DEPTNO IN (20, 30);
```

## LIKE 연산자

```sql
-- 요구 사항의 두 번째 조건에 대해서 LIKE 연산자를 WHERE 절에 적용해서 실행한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION LIKE 'MF';
```

LIKE 연산자에서는 와일드카드를 사용할 수 있다.와일드카드란 한 개 혹은 0개 이상의 문자를 대신해 사용하기 위한 특수 문자를 의미한다.

```sql
-- % : 0개 이상의 어떤 문자를 의미한다.
-- _ : 1개인 단일 문자를 의미한다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION LIKE '장%';

-- 세글자 이름을 가진 선수 중 '장'씨 성을 갖고 끝 글자가 '호'인 선수들의 정보를 조회하는 WHERE 절을 작성한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION LIKE '장_호';
```

## BETWEEN a AND b

```sql
-- 세 번째로 키가 170 센티미터 이상 180 센티미터 이하인 선수들의 정보를 BETWEEN a AND b 연산자를 사용해 WHERE 절을 완성한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE HEIGHT BETWEEN 170 AND 180;
```

## IS NULL 연산자

NULL 은 값이 존재하지 않는 것이로, 확정되지 않은 값을 표현할때 사용한다. 따라서 비교 자체가 불가능하다.

\- NULL 값과의 수치연산은 NULL 값을 리턴한다.
\- NULL 값과의 비교연산은 거짓을 리턱한다.
\- 어떤 값과도 비교할 수 없으며, 특정 값과의 대/소 비교를 할 수 없다.

NULL 값의 비교 연산은 IS NULL, IS NOT NULL 이라는 정해진 문구를 사용해야 제대로 된 결과를 얻을 수 있다.

```sql

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION = NULL;

-- 선택된 레코드가 없습니다. 라는 메세지를 출력한다.
-- 문법적 에러는 나지 않았지만 WHERE 절의 조건이 False로 판명되어 WHERE절의 조건으 만족하는 데이터를 한 건도 얻지 못하게 된다.

-- POSITION 칼럼 값이 NULL인지를 판단하기 위해서는 IS NULL을 사용해야한다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION IS NULL;

```

---

# 논리 연산자

논리 연산자는 비교 연산자나 SQL 연산자들로 이우러진 여러 개의 조건을 논리저으로 연결시키기 위해서 사용되는 연산자이다.

- AND
- OR
- NOT

```sql
-- 소속이 삼성블루윙즈인 조건과 키가 170 cm 이상인 조건을 연결해 WHERE 절을 완성한다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
AND HEIGHT > 170;

-- 소속이 K02 이거나 K03인 조건을 SQL 연산자로, 포지션이 미드필더인 조건을 비교 연산자로 비교한 결과를 논리 연산자로 묶어서 처리한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07') and POSITION = 'MF';

-- 요구 사항을 논리 연산자를 사용해 DBMS 가 이해할 수 있는 SQL 형식으로 변경한다.

-- 소속이 K02 이거나 K03 이고
-- 포지션이 미드필더이고
-- 키는 170 cm 이상 180 이하여야한다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
OR  TEAM_ID = 'K07'
AND POSITION = 'MF';
AND HEIGHT >= 170
AND HEIGHT <= 180
```

실행 결과를 보면 포지션이 'MF' 가 아닌 선수들의 명단이 출력됐다.
그 이유는 AND 연산자가 OR 연산자보다 우선순위가 높아 먼저 실행됐기 때문이다.
논리 연산자들이 여러 개 같이 사용됐을때 처리 우선 순위는 (), NOT, AND, OR 순이다.

```sql
-- 괄호를 사용해 다시 적용한다.
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE
(
  TEAM_ID = 'K02'
  OR
  TEAM_ID = 'K07'
)
AND POSITION = 'MF';
AND HEIGHT >= 170
AND HEIGHT <= 180

-- IN 와 BETWEEN a AND b 연산자를 활용해 같은 결과를 출력하는 SQL 문장을 작성한다. 두 개의 SQL 문장은 DBMS 내부적으로 같은 프로세스를 거쳐 수행된다.

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07')
AND POSITION = 'MF';
AND HEIGHT BETWEEN 170 AND 180;
```

## 부정 연산자

비교 연산자, SQL 연산자에 대한 부정 표현을 부정 논리 연산자, 부정 SQL 연산자로 구분할 수 있다.

```sql
-- !=
-- ^=
-- <>
-- NOT 칼럼명 =
-- NOT 컬럼명 >
-- NOT BETWEEN a AND b
-- NOT IN (list)
-- IS NOT NULL

-- K02 소속인 선수 중에 포지션이 미드필더가 아니고, 키가 175 cm 이상 185 cm 이하가 아닌 선수를 검색

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
AND POSITION != 'MF'
AND HEIGHT NOT BETWEEN 175 AND 185;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
AND POSITION <> 'MF'
AND HEIGHT NOT BETWEEN 175 AND 185;

-- 국적이 NULL 이 아닌 선수를 검색
SELECT PLAYER_NAME AS 선수명, NATION AS 국적
FROM PLAYER
WHERE NATION IS NOT NULL;
```
