# CREATE TABLE

테이블은 데이터베이스의 가장 기본적인 객체로, 행과 열의 구조로 데이터를 저장한다. 테이블 생성을 위해서는 해당 테이블에 입력될 데이터를 정의하고, 정의한 데이터를 어떠한 데이터 유형으로 선언할 것인지를 결정해야한다.

## 테이블과 칼럼 정의

테이블에 존재하는 모든 데이터를 고유하게 식별할 수 있으면서 반드시 값이 존재하는 단일 칼럼이나 칼럼의 조합중 하나를 선정해 기본키 칼럼으로 지정한다. 기본키는 단일 칼럼이 아닌 여러 개의 칼럼으로 구성될 수도 있다.

테이블과 테이블 간의 관계는 기본키와 외부키를 활용해 설정한다.

선수 테이블에 선수 소속팀의 정보가 같이 존재한다고 가정하면, 특정 팀의 이름이 변경됐을 경우 그 팀에 소속된 선수 데이터를 일일이 찾아서 수정하거나, 팀이 해체됐을 경우 선수 정보까지 삭제되는 수정,삭제 이상 현상이 발생할 수 있다. 이런 이상 현상을 방지하기 위해 팀 정보를 관리하는 팀 테이블을 별도로 분리해 팀 ID와 팀 이름을 저장하고, 선수 테이블에서는 팀 ID를 외부키로 참조한다.

## CREATE TABLE

테이블을 생성하는 구문 형식은 다음과 같다.

```sql
CREATE TABLE TABLE_NAME (
  COLUMN1 DATATYPE [DEFAULT VALUE] [NOTNULL]
  ,COLUMN2 DATATYPE [DEFAULT VALUE] [NOTNULL]
  ,COLUMN3 DATATYPE [DEFAULT VALUE] [NOTNULL]
)
```

테이블 생성시 주의사항은 다음과 같다.

\- 테이블명은 객체를 의미할 수 있는 적절한 이름을 사용한다.
\- 테이블 명은 다른 테이블의 이름과 중복되지 않아야 한다.
\- 한 테이블 내에서는 칼럼명이 중복되게 지정될 수 없다.
\- 테이블 이름을 지정하고 각 칼럼들은 괄호로 묶어 지정한다.
\- 각 칼럼들은 콤마로 구분되고 테이블 생성문의 끝은 항상 세미콜론으로 끝난다.
\- 칼럼에 대해서는 다른 테이블까지 고려해 데이터베이스 내에서 일관성 있게 사용하는 것이 좋다.
\- 데이터 유형은 반드시 지정돼야한다.
\- 테이블명과 칼럼명은 반드시 문자로 시작해야 하고, 벤더별로 길이에 대한 한계가 있다.
\- 벤터에서 사전에 정의한 예약어는 쓸 수 없다.
\- [A-ZA-Z0-9_$#] 문자만 혀용한다.

한 테이블 안에서 칼럼 이름은 고유해야 하지만, 다른 테이블의 칼럼 이름과는 같을 수 있다. 같은 이름을 가진 칼럼들은 기본키와 와래키의 관계를 갖는 경우가 많으며, 향후 테이블 간의 조인 조건으로 사용되는 연결고리 역할을 하기도한다.

```sql
-- 테이블 명세
-- 테이블 명 : TEAM
-- 케이리그 선수들의 소속팀에 대한 정보를 갖고 있는 테이블
-- 칼럼명
-- TEAM_ID     문자 고정 자릿수 3자리,
-- REGION_NAME 문자 가변 자릿수 8자리,
-- TEAM_NAME   문자 가변 자릿수 40자리,
-- E_TEAM_NAME 문자 가변 자릿수 50자리,
-- ORIG_YYYY   문자 고정 자릿수 4자리,
-- STADIUM_ID  문자 고정 자릿수 3자리,
-- ZIP_CODE1   문자 고정 자릿수 3자리,
-- ZIP_CODE2   문자 고정 자릿수 3자리,
-- ADDRESS     문자 가변 자릿수 80자리,
-- DDD         문자 가변 자릿수 3자리,
-- TEL         문자 가변 자릿수 10자리,
-- FAX         문자 가변 자릿수 10자리,
-- HOMEPAGE    문자 가변 자릿수 50자리,
-- OWNER       문자 가변 자릿수 10자리,
-- 제약조건
-- PRIMARY KEY (제약조건명 TEAM_ID_PK) -> TEAM_ID
-- NOT NULL(제약조건 미적용) -> REGION_NAME, TEAM_NAME, STADIUM_ID

CREATE TABLE TEAM(
  TEAM_ID     CHAR(3) NOT NULL
,REGION_NAME  VARCHAR2(8) NOT NULL
,TEAM_NAME    VARCHAR2(40) NOT NULL
,E_TEAM_NAME  VARCHAR2(50)
,ORIG_YYYY    CHAR(4)
,STADIUM_ID   CHAR(3)
,ZIP_CODE1    CHAR(3)
,ZIP_CODE2    CHAR(3)
,ADDRESS      VARCHAR2(80)
,DDD          VARCHAR2(3)
,TEL          VARCHAR2(10)
,FAX          VARCHAR2(10)
,HOMEPAGE     VARCHAR2(50)
,OWNER        VARCHAR2(10)
,CONSTRAINT TEAM_PK PRIMARY KEY (TEAM_ID)
);

-- 테이블 명세
-- 테이블 명 : PLAYER
-- 케이리그 선수들의 정보를 갖고있는 테이블
-- 칼럼명
-- PLAYER_ID     문자 고정 자릿수 7자리,
-- PLAYER_NAME   문자 가변 자릿수 20자리,
-- TEAM_ID       문자 고정 자릿수 3자리,
-- E_PLAYER_NAME 문자 가변 자릿수 40자리,
-- NICKNAME      문자 가변 자릿수 30자리,
-- JOIN_YYYY     문자 고정 자릿수 4자리,
-- POSITION      문자 가변 자릿수 10자리,
-- BACK_NO       숫자 2자리
-- NATION        문자 가변 자릿수 20자리,
-- BIRTH_DATE    날짜
-- SOLAR         문자 고정 자릿수 1자리,
-- HEIGHT        숫자 3자리
-- WEIGHT        숫자 3자리
-- 제약조건
-- PRIMARY KEY (제약조건명 PLAYER_ID_PK) -> PLAYER_ID
-- FOREIGN KEY (제약조건명 PLAYER_FK) -> TEAM_ID(TEAM.TEAM_ID)
-- NOT NULL(제약조건 미적용) -> PLAYER_NAME, TEAM_ID

CREATE TABLE PLAYER(
PLAYER_ID       CHAR(7)
,PLAYER_NAME    VARCHAR2(20)
,TEAM_ID        CHAR(3)
,E_PLAYER_NAME  VARCHAR2(40)
,NICKNAME       VARCHAR2(30)
,JOIN_YYYY      CHAR(4)
,POSITION       VARCHAR2(10)
,BACK_NO        NUMBER(2)
,NATION         VARCHAR2(20)
,BIRTH_DATE     DATE
,SOLAR          CHAR(1)
,HEIGHT         NUMBER(3)
,WEIGHT         NUMBER(3)
,CONSTRAINT PLAYER_PK PRIMARY KEY (PLAYER_ID)
,CONSTRAINT PLAYER_FK FOREIGN KEY(TEAM_ID) REPERENCES TEAM( TEAM_ID)
);
```

테이블 생성 예제에서 추가적인 주의 사항 몇 가지를 확인하면 다음과 같다.

- 테이블 생성시 대소문자는 구분하지 않는다.
- 기본적으로 테이블이나 칼럼명은 대문자로 만들어진다.
- DATETIME 데이터 유형에는 별도로 크기를 지정하지 않는다.
- 문자 데이터 유형은 반드시 가질 수 있는 최대 길이를 표시해야한다.
- 칼럼과 칼럼의 구분은 콤마로 하되, 마지막 칼럼은 컴마를 찍지않는다.
- 칼럼에 대한 제약조건은 CONSTRAINT를 이용해 추가한다.

제약조건은 각 칼럼의 데이터 유형 뒤에 기술하는 칼럼 LEVEL 정의방식(PLAYER_NAME VARCHAR(20) NOT NULL)과
테이블 정의 마지막에 모든 제약조건을 기술하는 테이블 LEVEL 정의방식 (CONSTRAINT PLAYER_PB PRIMARY KEY(PLAYER_ID)) 이 있다.

---

## 제약조건

CONSTRAINT(제약조건)이란 사용자가 원하는 조건의 데이터만 유지하기 위한, 즉 데이터의 무결성을 유지하기 위한 방법으로, 테이블의 특정 칼럼에 설정하는 제약이다.
테이블을 생성할 때 제약조건을 반드시 기술할 필요는 없지만 ALTER TABLE을 이용해 추가, 수정하는 경우 처리가 쉽지않으므로 초기 테이블 생성 시점부터 적합한 제약조건에 대한 검토가 필요하다.

\- PRIMARY KEY

테이블에 저장된 행 데이터를 고유하게 식별하기 위한 기본키를 정의한다. 하나의 테이블에 하나의 기본키 제약만 정의할 수 있다.
기본키 제약 정의시 DBMS는 자동으로 UNIQUE 인덱스를 생성하며, 기본키를 구성하는 컬럼에는 NULL 값을 입력할 수 없다.
결국 기본키 제약은 '고유키 제약 + NOT NULL 제약' 이다.

\- UNIQUE

테이블에 저장된 행 데이터를 고유하게 식별하기 위한 고유키를 정의한다.
NULL은 고유키 제약의 대상이 아니므로 NULL을 가진 행이 여러 개가 있더라도 고유키 제약 위반이 되지않는다.

\- NOT NULL

NULL 값의 입력을 금지한다. 디폴트 상태에서는 모든 칼럼에 NULL을 허가하지만, 이 제약ㅇ르 지정함으로써 해당 칼럼은 입력 필수 칼럼이 된다.

\- CHECK

입력할 수 있는 값의 번위를 제한한다. TRUE/FALSE로 평가할 수 있는 논리식을 지정해야한다.

\- FOREIGN KEY

관계형 데이터베이스에서 테이블 간의 관계를 정의하기 위해 기본키를 다른 테이블의 외래키로 복사하는 경우 외래키가 생성된다.
외래키 지정시 참조 무결성 제약 옵션을 선택할 수 있다.

---

## 생성된 테이블 구조 확인

테이블을 생성한 후 테이블 구조가 제대로 만들어졌는지 확인할 필요가 있다.

```sql
-- sqlplus, sql developer에서는 다음과 같이 스키마를 확인 가능
DESCRIBE PLAYER;
-- 테이블 스키마 조회
SELECT * FROM user_tab_columns WHERE table_name='PLAYER';
```

---

## SELECT 문장으로 테이블 생성 사례

SELECT 문장을 활용해서 테이블을 생성할 수 있다. 기존 테이블을 이용한 CTAS 방법을 사용하면 칼럼별로 데이터 유형을 다시 정의하지않아도 되는 장점이있다.
주의할 점은 CTAS (CREATE TABLE ~ AS SELECT ~) 기법 사용시 기존 테이블의 제약조건 중 NOT NULL 제약만 신규 테이블에 적용되고 기본, 고유키, 외래키, CHECK 등의 제약조건은 없어진다는 점이다. 제약조건을 적용하기 위해서는 뒤에 나오는 ALTER TABLE 기능을 사용해야 한다.

```sql
-- 선수 테이블과 같은 내용으로 TEAM_TEMP 복사 테이블을 만든다.

CREATE TABLE TEAM_TEMP AS SELECT * FROM TEAM;

SELECT * FROM user_tab_columns WHERE table_name='TEAM_TEMP';

```

---

# ALTER TABLE

한 번 생성된 테이블은 특별히 사용자가 구조를 변경하기 전까지 생성 당시의 구조를 유지한다. 생성 당시의 테이블 구조를 그대로 유지하는 것이 최선이지만, 운영상 변경해야 할 일들이 발생할 수도 있다.
이 경우 주로 칼럼을 추가 삭제하거나 제약조건을 추가/삭제 하는 일을 진행한다.

## ADD COLUMN

다음은 기존 테이블에 필요한 칼럼을 추가하는 명령이다.

```SQL
ALTER TABLE 테이블명
ADD (
  COLUMN DATATYPE [DEFAULT VALUE] [NOT NULL]
[,COLUMN DATATYPE [DEFAULT VALUE] [NOT NULL]...]);

-- PLAYER TABLE 에 ADDRESS(VARCHAR2 LENGTH 80) 칼럼을 추가한다.
ALTER TABLE PLAYER
ADD (
  ADDRESS VARCHAR2(80);
)
```

---

## DROP COLUMN

테이블에서 필요없는 칼럼을 삭제한다. 데이터가 유무에 상관없이 삭제가 가능하다. 단, 칼럼 삭제후 테이블에 최소 하나 이상의 칼럼이 존재해야한다. 한 번 삭제된 칼럼은 복구할 수 없다.

```sql
ALTER TABLE TABLENAME DROP (COLUMN1 [, COLUMN2,...])

-- PLAYER TABLE 에서 ADDRESS 칼럼을 삭제한다.
ALTER TABLE PLYAER DROP (ADDRESS)
```

---

## MODIFY COLUMN

테이블에 존재하는 칼럼에 대해 ALTER TABLE 명령을 이용해 칼럼의 데이터 유형, 디폴트, NOT NULL 제약조건을 변경할 수 있다.

```sql
ALTER TABLE TABLENAME
MODIFY (
  COLUMN1 DATATYPE [DEFAULT] [NOT NULL]
  [, COLUMN1 DATATYPE [DEFAULT] [NOT NULL]
  , ...
  ]
)

-- 다음과 같은 사항을 고려해야한다.
-- 해당 칼럼의 크기를 늘릴 수 있지만 테이블에 데이터가 존재한다면 칼럼의 크기를 줄이는데는 제약이 있다.
-- 해당 칼럼이 NULL 값만 갖고 있거나 테이블에 아무 행도 없으면 칼럼의 크기를 줄일 수 있다.
-- 해당 칼럼이 NULL 값만 있으면 데이터의 유형을 변경할 수 있따.
-- 해당 칼럼이 DEFAULT 값을 바꾸면 변경 작업 이후 발생하는 행 삽입에만 영향을 미친다.
-- 해당 칼럼이 NULL 값이 없을 경우에만 NOT NULL 제약 조건을 추가할 수 있다.

-- TEAM 테이블의 ORIG_YYYY 칼럼의 데이터 유형을 VARCHAR2로 변경하고, 향후 입력되는 데이터의 DEFAULT 값으로 '20020129'를 적용하다.
-- 모든 행의 ORIG_YYYY 컬럼에 NULL 이 없으므로 제약조건을 NULL => NOT NULL 로 변경한다.

ALTER TABLE TEAM_TEMP MODIFY (ORIG_YYYY VARCHAR2(8) DEFAULT '2002019' NOT NULL);
```

---

## RENAME COLUMN

다음은 테이블을 생성하면서 만들었던 칼럼명을 변경해야하는 경우 RENAME COLUMN 을 이용한다.

```sql
ALTER TABLE TABLE_NAME RENAME COLUMN PREV COLUMN TO NEW COLUMN;

-- RENAME COLUMN 으로 칼럼명이 변경되면, 해당 칼럼과 고나계된 제약 조건에 대해서도 자동으로 변경되는 장점이 있다. ORACLE 등 일부 DBMS에서만 지원한다.

ALTER TABLE PLAYER RENAME COLUMN PLAYER_IT TO TEMP_ID;
```

---

## DROP CONSTRAINT

테이블 생성 시 부여했던 제약조건을 삭제하는 명령어는 다음과 같다

```sql
ALTER TABLE TABLE NAME DROP CONSTRAINT CONSTRAINT_NAME;

-- PLAYER 테이블의 외래키 제약조건을 삭제한다.
ALTER TABLE PLYAER DROP CONSTRAINT PLAYER_FK;
```

---

## ADD CONSTRAINT

테이블 생성 시 제약 조건을 적용하지 않았다면 생성이후 추가할 수 있다.

```sql
ALTER TABLE TABLE_NAME ADD CONSTRAINT 제약조건명 제약조건 (칼럼명);

-- PLAYER 테이블에 TEAM 테이블과의 외래키 제약조건을 추가한다. 제약조건명은 PLAYER_FK로 하고, PLAYER 테이블의 TEAM_ID 칼럼이 TEAM 테이블의 TEAM_ID를 참조하는 조건이다.

ALTER TABLE PLAYER ADD CONSTRAINT PLAYER_FK FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID);

-- PLYAER 테이블이 참조하는 TEAM 테이블을 제거한다.
-- 외래 키에 의해 참조되는 고유/기본 키가 테이블에 있습니다.

DROP TABLE TEAM;

-- TEAM TABLE, PLAYER TABLE에 각각 데이터를 1건씩 입력한다.
INSERT
INTO TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID)
VALUES ('K10', '대전', '시티즌', 'D02')

INSERT
  INTO PLAYER (PLAYER_ID, TEAM_ID, PLAYER_NAME, POSITION, HEIGHT, WEIGHT, BACK_NO)
VALUES ('200003', 'K10', '유동우', 'DF', 177, 70, 40);

COMMIT;

-- PLAYER 테이블이 참조하는 TEAM 테이블의 데이터를 삭제해 본다.
-- 무결성 제약조건(U_DDL.PLAYER_FK)이 위배됐습니다 - 자식 레코드가 발견됐습니다.
-- 외부키를 설정함으로써 실수에 의한 테이블 삭제나 필요한 데이터의 의도하지 않은 삭제와 같은 불상사를 방지할 수 있다.

DELETE TEAM WHERE TEAM_ID = 'K10';

```

---

# RENAME TABLE

```SQL
RENAME AS_IS_TABLE_NAME TO TO_BE_TABLE_NAME;

-- RENAME 문장을 이용해 TEAM 테이블 이름을 다른 것으로 변경하고, 다시 TEAM 테이블로 변경한다.
RENAME TEAM TO TEAM_BACKUP;
RENAME TEAM_BACKUP TO TEAM;
```

---

# DROP TABLE

테이블을 잘못 만들었거나 테이블이 더이상 필요 없을 경우 해당 테이블을 삭제한다.

```sql
-- 테이블의 모든 데이터 및 구조를 삭제한다.
-- CASCADE CONSTRAINT 옵션은 해당 테이블과 관계가 있었던 참조되는 제약조건에 대해서도 삭제함을 의미한다.

DROP TABLE TABLE_NAME [CASCADE CONSTRAINT]

```

---

# TRUNCATE TABLE

테이블 자체를 삭제하는것이 아니고, 해당 테이블에 들어 있던 모든 행을 제거해 저장 공간을 재사용 가능하도록 해제한다.

```sql
TRUNCATE TABLE 테이블명;
```

DROP TABLE의 경우는 테이블 자체가 없어지기 때문에 테이블 구조를 확인할 수 없다.
반면 TRUNCATE TABLE의 경우는 테이블 구조는 그대로 유지한 채 데이터만 전부 삭제하는 기능이ㅏㄷ.
테이블을 삭제하는 명령어는 TRUNCATE TABLE 명령어 이외에도 DELETE 명령어가 있다.
TRUNCATE TABLE 과 DELETE 는 처리하는 방식자체가 다르다. 테이블 전체 데이터를 삭제하는 경우, 시스템 활용 측면에서는 DELETE 보다 부하가 적은 TRUNCATE TABLE의 사용이 권장된다.
단, TRUNCATE TABLE는 정상적인 복구가 불가능하다.
