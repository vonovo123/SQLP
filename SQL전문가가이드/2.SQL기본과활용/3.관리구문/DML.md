# INSERT

## 단일 행 INSERT 문

```sql
-- 단일 행 INSERT 문은 VALUES 절을 포함하며, 한 번에 한 행만 입력된다.
-- INTO 절의 칼럼명과 VALUES 절의 값을 서로 1:1 매핑해 기술한다. 칼럼명의 기술 순서는 테이블의 정의된 칼럼 순서와 동일할 필요는 없다.
-- INTO 절에 기술하지 않은 칼럼은 NULL 값이 입력된다. 단, PRIMARY KEY 제약 또는 NOT NULL 제약이 지정된 칼럼은 NULL 값을 입력을 허용하지않아 오류가 발생한다.
-- 해당 칼럼의 데이터 유형이 CHAR OR VARCHAR2 일경우 '' 와 함께 입력한다.
INSERT INTO 테이블명 (칼럼1, 칼럼2, ...) VALUES (value1, value2...);

INSERT
  INTO PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION, HEIGHT, WEIGHT, BACK_NO)
  VALUES ('2002007', 'PARKJISUNG', 'K07', 'MF', 178, 73, 7);

-- INTO 절의 칼럼명은 생략할 수 있지만 그 경우 VALUES 절의 존재하는 컬럼에 해당하는 값에 모든 값을 빠짐없이 기술해야한다.
INSERT
  INTO PLAYER
  VALUES ('2002007', 'PARKJISUNG', 'K07', '', 'BLUEDRAGON', '2002', 'MR' , '17', NULL, NULL, '1', 73, 7);

-- PLAYER 테이블에 데이터를 추가할때 현재 PLAYER_ID 의 값을 현재 사용중인 PLAYER_ID 에 1을 더한 값으로 넣고자 한다. 다음과 같이 VALUES 절에 서브 쿼리를 사용해 SQL 문을 작성할 수 있다.

INSERT
INTO PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID)
VALUES ((SELECT TO_CHAR(MAX(TO_NUMBER(PLAYER_ID)) + 1) FROM PLAYER), '홍길동', 'K06' )
```

---

## 서브 쿼리를 이용한 다중 행 INSERT 문

INSERT 문에 서브 쿼리를 사용하면 서브 쿼리의 결과를 테이블에 입력할 수 있다. 서브 쿼리의 결과가 다중 행이면, 한 번에 여러 건이 입력된다.

단, INTO 절의 컬럼 수가 서브쿼리의 SELECT 절 컬럼 수와 일치해야한다.

```sql
INSERT INTO TABLE (COLUMN1, COLUMN2...) SUBQUERY;

-- 서브 쿼리를 사용해 TEAM 테이블에 데이터를 입력한다.
INSERT INTO TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, ORIG_YYYY, STADIUM_ID)
SELECT REPLACE(TEAM_ID, 'K', 'A') AS TEAM_ID
      ,REGION_NAME, REGISON_NAME || 'ALL STAR' AT TEAM_NAME
      ,2019 AS ORIG_YYYY, STADIUM_ID
FROM TEAM
WHERE REGION_NAME IN ('성남', '인천');

-- 서브 쿼리를 사용해 PLAYER  테이블에 데이터를 입력한다.

INSERT INTO PLAYER(PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION)
SELECT 'A' || SUBSTR(PLAYER_ID, 2)AS PLAYER_ID, PLAYER_NAME , REPLACE(TEAM_ID, 'K', 'A') AS TEAM_ID, POSITION
FROM PLAYER
WHERE TEAM_ID IN ('K04', 'K08');
```

---

# UPDATE

데이터각 잘못 입력되거나 변경이 발생해 이미 입력된 데이터를 수정해야 하는 경우가 발생할 수 있다.
UPDATE 다음에 데이터를 수정할 대상 테이블명을 입력한다. SET 절에는 수정할 컬럼명과 해당 칼럼에 수정될 값을 기술하고,
WHERE 절에는 수정 대상이 될 행을 식별할 수 있도록 조건식을 기술한다. WHERE 절을 사용하지 않으면 테이블 전체 데이터가 수정된다.

```sql
UPDATE TABLENAME
SET COLUMN1=VALUE1
[, COLUMN2=VALUE2]
[, COLUMN3=VALUE3]
[WHERE CONDITION];

-- 선수 테이블의 백넘버를 일괄적으로 99로 수정한다.
UPDATE PLAYER
SET BACK_NO = 99;

-- 선수 테이블에서 포지션이 NULL인 선수들의 포지션을 MF 로 수정한다.
UPDATE PLAYER
SET POSITION = 'MF'
WHERE POSITION IS NUL;

-- UPDATE 문의 SET 절에 서브 쿼리를 사용하면, 서브 쿼리의 결과로 값이 수정된다.

-- 팀 테이블에서 창단년도가 2000년 이후인 팀의 주소를 홈팀 경기장의 주소로 수정한다.
UPDATE TEAM A
SET A.ADDRESS = (
  SELECT X.ADDRESS
  FROM STADIUM X
  FROM X.HOMETEAM_ID = A.HOMETEAM_ID
)
WHERE A.ORIG_YYYY > 2000;

-- 모든 경기장의 지역번호와 전화번호를 홈팀의 지역번호와 전화번호로 수정한다
UPDATE STADIUM A
SET ( A.DDD , A.TEL ) = (
  SELECT X.DDD, X.TEL
  FROM TEAM X
  FROM X.HOMETEAM_ID = A.HOMETEAM_ID
);

-- UPDATE 문의 WHERE 절에 서브 쿼리를 이용해 수정될 행을 식별할 수도 있다.

-- 홈팀의 정보가 존재하는 경기장의 지역번호와 전화번호를 홈팀의 지역번호와 전화번호로 수정한다.
UPDATE STADIUM A
SET(A.DDD , A.TEL) = (
  SELECT X.DDD, X.TEL
  FROM TEAM X
  FROM X.HOMETEAM_ID = A.HOMETEAM_ID
)
WHERE EXISTS (SELECT 1
  FROM TEAM X
  WHERE X.TEAM_ID = A.HOMETEAM_ID
)

-- 앞 UPDATE 문은 TEAM 테이블을 2번 조회하는 비효율이 있다. MERGE 문을 사용하면 TEAM 테이블을 1번만 조회하여 데이터를 수정할 수 있다.

MERGE
  INTO STADIUM T
USING TEAM S
  ON (T.TEAM_ID = S.HOMETEAM_ID)
WHERE MATCHED THEN
UPDATE
  SET T.DDD = S.DD
  , T.TEL = S.TEL;
```

---

# DELETE

테이블에 저장된 데이터가 더이상 필요 없게 됐을 경우 데이터 삭제를 수행한다.

```sql
DELETE [FROM] TABLENAME
[WHERE CONDITION];

-- 선수 테이블의 데이터 전부를 삭제한다.
DELETE FROM PLAYER;

-- 선수 테이블에서 포지션이 DF이고 입단년도가 2010년 이전인 선수의 데이터를 삭제한다.
DELETE PLAYER
WHERE POSITION = 'DF'
AND JOIN_YYYY < 2010;

-- 선수 테이블에서 창단년도가 1980년 이전인 팀에 소속된 선수 데이터를 삭제한다.
DELETE PLAYER A
WHERE EXISTS (
  SELECT 1
  FROM TEAM X
  WHERE X.TEAM_ID = A.TEAM_ID
  AND X.ORIG_YYYY < 1980
);

-- 선수 테이블에서 소속 선수가 10명 이하인 팀에 소속된 선수의 데이터를 삭제한다.

DELETE PLAYER A
WHERE IN (
  SELECT TEAM_ID
  FROM PLAYER
  GROUP BY TEAM_ID
  HAVING COUNT(*) <= 10
);


```

# MERGE

MERGE 문을 사용하면 새로운 행을 입력하거나, 기존 행을 수정하는 작업을 한 번에 할 수 있다.

```sql
MERGE
-- 입력/수정돼야할 타겟 테이블
INTO TARGET_TABLE_NAME
-- 입력/수정에 사용할 소스 테이블
USING SOURCE_CONDITION
-- 타깃 테이블과 소스 테이블 간의 조인 조건식
ON (JOIN_CONDITION)
-- 조인에 성공한 행들에 대한 UPDATE
WHEN MATCHED THEN
UPDATE
SET COLUMN1 = VALUE1
[, COLUMN2 = VALUE2, ...]
-- 조인에 실패한 행들에 대한 INSERT
WHEN NOT MATCHED THEN
INSERT (COLUMN1, COLUMN2)
VALUE (VALUE1, VALUE2)

-- MERGE TEST를 위한 임시 테이블 생성
CREATE TABLE TEAM_TMP AS
SELECT NVL(B.TEAM_ID, 'K' || ROW_NUMBER() OVER (ORDER BY B.TEAM_ID, A.STADIUM_ID)) AS TEAM_ID
, SUBSTR(A.STADIUM_NAME , 1, 2) AS REGION_NAME
, SUBSTR(A.STADIUM_NAME, 1, 2) || NVL2(B.TEAM_NAME, 'FC', '시티즌') AS TEAM_NAME
, A.STADIUM_ID
, A.DDD
, A.TEL
FROM STADIUM A, TEAM B
WHERE B.STADIUM_ID(+) = A.STADIUM_ID;

-- TEAM_TMP 테이블을 이용해 TEAM 테이블에 데이터 입력, 수정 한다.
MERGE
INTO TEAM T
USING TEAM_TMP S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN MATCHED THEN
UPDATE
SET T.REGION_NAME = S.REGISON_NAME
, T.TEAM_NAME = S.TEAM_NAME
, T.DDD = S.DDD
, T.TEL = S.TEL
WHEN NOT MATCHED THEN
INSERT (T.TEAM_ID, T.REGION_NAME, T.TEAM_NAME, T.STADIUM_ID, T.DDD, T.TEL)
VALUES (S.TEAM_ID, S.REGISON_NAME, S.TEAM_NAME, S.STADUM_ID, S.DDD. S.TEL)

-- MERGE 문의 USING 절에 소스 테이블 대신 서브 쿼리를 사용해 입력, 수정할 수도 있다.
MERGE
INTO TEAM T
USING(SELECT * FROM TEAM_TMP WHERE REGION_NAME IN ('성남', '부산', '대구', '전주')) S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN MATCHED THEN
UPDATE
SET T.REGION_NAME = S.REGION_NAME
, T.TEAM_NAME = S.TEAN_NAME
,T.DDD = S.DDD
,T.TEL = S.TEL
WHEN NOT MATCHED THEN
INSERT (T.TEAM_ID, T.REGION_NAME, T.TEAM_NAME, T.STADIUM_ID, T.DDD, T.TEL)
VALUES (S.TEAM_ID, S.REGISON_NAME, S.TEAM_NAME, S.STADUM_ID, S.DDD. S.TEL);

-- TEAM_TMP 테이블을 이용해 TEAM 테이블의 기존 데이터를 수정한다.
MERGE
INTO TEAM T
USING TEAM_TMP S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN MATCHED THEN
UPDATE
SET T.REGION_NAME = S.REGISON_NAME
, T.TEAM_NAME = S.TEAM_NAME
, T.DDD = S.DDD
, T.TEL = S.TEL;

-- TEAM_TMP 테이블을 이용해 TEAM 테이블에 없는 데이터를 입력한다.
MERGE
INTO TEAM T
USING TEAM_TMP S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN NOT MATCHED THEN
INSERT (T.TEAM_ID, T.REGION_NAME, T.TEAM_NAME, T.STADIUM_ID, T.DDD, T.TEL)
VALUES (S.TEAM_ID, S.REGISON_NAME, S.TEAM_NAME, S.STADUM_ID, S.DDD. S.TEL
```

DML은 명령어 사용 시 데이터의 변경 사항을 테이블에 영구적으로 저장하기 위해선 COMMIT 명령어를 수행해 TRANSACTION 을 종료해야 한다.
테이블 전체 데이터를 삭제하는 경우 시스템 활용측면에서 데이터를 로그로 저장하는 DELETE TABLE 보다는 TRUNCATE TABLE의 사용을 권고한다.
단, TRUNCATE TABLE 은 ROLLBACK 이 불가하다.
