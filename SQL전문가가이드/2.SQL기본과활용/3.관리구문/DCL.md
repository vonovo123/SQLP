# DCL 개요

테이블 생성과 조작에 관련된 명렁어 (DDL), 데이터를 조작하기 위한 명령어 (DML), 트랜잭션을 제어하기 위한 명령어 (TCL) 에 추가로 유저를 생성하고 권한을 제어할 수 있는 DCL 명령어가 있다.

---

# 유저와 권한

다른 부서 간에 또는 다른 회사 간에 데이터를 공유하기 위해 데이터베이스를 공개해야하는 경우가 발생한다.
이런 경우 새로운 유저를 생성하고, 생성한 유저에게 공유할 테이블이나 기타 오브젝트에 대한 접근 권한만을 부여하면 데이터 손실 우려를 해결할 수 있다.

대부분의 데이터베이스는 데이터 보호와 보안을 위해 유저와 권한을 관리하고 있다.

```sql
-- SCOTT : ORACLE 테스트용 샘플 계정
-- DEFAULT PASSWD : TIGER
-- SYS : 백업 및 복구 등 데이터베이스 상의 모든 관리 기능을 수행할 수 있는 최상위 관리자 계정
-- SYSTEM : 백업, 복구 등 일부 관리 기능을 제외한 모든 시스템 권한을 부여받은 DBA 계정(ORACLE 설치 시에 패스워드 설정)
```

ORACLE 은 유저를 통해 데이터베이스에 접속하는 형태이다. 아이디와 비밀번호 방식으로 인스턴스에 접속하고 그에 해당하는 스키마에 오브젝트 생성등의 권한을 부여받는다.

## 유저 생성과 시스탬 권한 부여

유저를 생성하고 데이터베이스에 접속한다. 하지만 데이터베이스에 접속했더라도 테이블, 뷰, 인덱스와 같은 오브젝트는 생성할 수 없다.
이를 위해선 사용자가 실행하는 모든 DDL문장에 대한 적절한 권한이 있어야한다.

이러한 시스템 권한은 약 100 종류가 존재한다. 일반적으로 시스템 권한을 일일이 유저에게 부여하지 않는다. 너무 복잡하고 관리가 어렵기 때문이다.

ROLE 을 이용해 간편하고 쉽게 권한을 부여한다.

```SQL
-- SCOTT 유저로 접속한 다음 SQLD 유저 (패스워드 : DB2019)를 생성해본다
CONN SCOTT/TIGER

CREATE USER SQLD IDENTIFIED BY DB2019;
--  ORA-01031: insufficient privileges
```

현재 SCOTT 유저는 유저를 생성할 권한을 부여받지 못했기 때문에 권한이 불충분하다는 오류가 발생한다. ORACLE의 DBA 권한을 갖고 있는 SYSTEM 유저로 접속하면 유저 생성 권한(CREATE USER)를 다르 유저에게 부여할 수 있다.

```sql
-- SCOTT 유저에게 유저생성 권한 (CREATE USER)을 부여한 후 다시 SQLD 유저를 생성한다.

GRANT CREATE USER TO SCOTT;

CONN SCOTT/TIGER

CREATE USER SQLD IDENTIFIEDD BY DB2019;

-- 생성된 SQLP 유저로 로그인하다.

CONN SQLD/DB2019; -- USER SQLD LACK CREATE SESSION PRIVILEGE; LOGON DENIED

```

SQLD 유저가 생성됐지만 아무런 권한도 부여받지 못했기 때문에 로그인을 하면 CREATE SESSION 권한이 없다는 오류가 발생한다. 로그인 하려면 CREATE SESSION 권한을 부여받아야 한다.

```sql
-- system 유저로 접속해 SQLD 유저가 로그인할 수 있도록 CREATAE SESSION 권한을 부여한다.

CONN SYSTEM/MANAGER;

GRANT CREATE SESSION TO SQLD;

CONN SQLD/DB2019;

-- SQLD 유저로 테이블을 생성한다.

SELECT * FROM USER_TABLES;

CREATE TABLE MENU (MENU_SEQ NUMBER NOT NULL, TITLE VARCHAR2(10)); -- 권한이 불충분합니다.

```

SQLD 유저는 로그인 권한만 부여됐기 때문에 테이블을 생성하려면 테이블 생성 권한(CREATE TABLE)이 불충분 하다는 오류가 발생한다.

```sql

--- SYSTEM 유저를 통해 SQLD 유저에게 CREATE TABLE 권한을 부여한 후 다시 테이블을 생성한다.

CONN SYSTEM/MANAGER;

GREATE GRANT TABLE TO SQLD;

CREATE TABLE MENU (MENU_SEQ NUMBER NOT NULL, TITLE VARCHAR2(10));
```

## OBJECT에 대한 권한 부여

오브젝트 권한은 특정 오브젝트인 테이블, 뷰 등에 대한 SELECT, INSERT, DELETE, UPDATE 작업 명령어를 의미한다.

## TABLE

ALTER, DELETE, EXECUTE, INDEX, INSERT, REFERENCES, SELECT , UPDATE

## VIEWS

DELETE, INSERT, SELECT, UPDATE

## SEQUENCE

ALTER, SELECT

## PROCEDURE

EXECUTE

모든 유저는 각자 자신이 생성한 테이블 이욍에 다른 유저의 테이블에 접근하려면 해당 테이블에 대한 오브젝트 권한을 소유자로부터 부여받아야 한다.

```sql

CONN SCOTT/TIGER;

SELECT * FROM SQLD.MENU -- 테이블 또는 뷰가 존재하지 않습니다.

```

SCOTT 유저는 SQLD 유저로부터 MENU TABLE 을 SELECT 할 수 있는 권한을 부여받지 못했기 때문에 MENU 테이블을 조회할 수 없다.

```sql
CONN SQLD/DB2019;

INSERT INTO MENU VALUESS ( 1, 'TEMP');

COMMIT;

GRANT SELECT ON MENU TO SCOTT;

```

다시 한 번 SCOTT 유저로 접속해 SQLD.MENU 테이블을 조회한다. 이제 SQLD.MENU 테이블을 SELECT 하면ㄴ 테이블 자료를 불 수 있다.
SCOTT 유전는 SQLD.MENU 테이블을 SESLECT 하는 권한만 부여 받았기 때문에 UPDATE, INSERT, DELETE 와 같은 다른 작업을 할 수 없다. 오브젝트 권한은 SELECT, INSERT, DELETE, UPDATE 등의 권한ㄴ을 따로 관리한다.

```sql
CONN SCOTT/TIGER;


SELECT * FROM SQLD.MENU;

UPDATE SQLD.MENU
SET TITLE = 'KOREA'
WHERE MENU_SEQ = 1; -- 권한이 불충분합니다.

```

권한이 부족해 UPDATE 할 수 없다는 오류가 나타난다. SQLD 유저에게 UPDATE 권한을 부여한 후 다시 시도하면 업데이트가 가능하다.

---

## ROLE을 이용한 권한 부여

유저를 생성하면 기본적으로 CREATE SESSION, CREATE TABLE, CREATE PROCEDURE 등 많은 권한을 부여해야 한다.

데이터베이스 관리자는 유저가 생성될 때마다 각각의 권한들을 유저에게 부여하는 작업을 수행해야 하며, 간혹 권한을 빠뜨릴 수도 있으므로 유저별로 어떤 권한이 부여됐는지를 관리해야 한다.

하지만 관리해야 할 유저가 점점 늘어나고 자주 변경되는 상황에서는 매우 번거로운 작업이 될 것이다. 이와 같은 문제를 줄이기 위해 많은 데이터베이스에서 유저들과 권한들 사이에서 중개 역할을 하는 ROLE을 제공한다.

데이터베이스 관리자는 ROLE을 생성하고 ROLE에 각종 권한들을 부여한 후, ROLE 을 다른 ROLE 이나 유저에게 부여할 수 있다. 또한 ROLE 에 포함된 권한들이 필요한 유저에게는 해당 ROLE 만을 부여함으로써 빠르고 정확하게 필요한 권한을 부여할 수 있다.

ROLE에는 시스템 권한과 오브젝트 권한을 모두 부여할 수 있다. ROLE은 유저에게 직접 부여될 수도 있고, 다른 ROLE에 포함해 유저에게 부여될 수 있다.

```sql
-- SQLD 유저에게 CREATE SESSION과 CREATE TABLE 권한을 가진 ROLE 을 생성한ㄴ 후 ROLE 을 이용해 다시 권한을 할당한다.
-- 권한을 취소할 때는 REVOKE를 사용한다.


CONN SYSTEM/MANAGER;

-- 권한 취소
REVOKE CREATE SESSION, CREATE TABLE FROM SQLD;


CONN SQLD/DB2019; -- USER SQLD LACKS CREATE SESSION PRIVILEGE; LOGIN DENIED;

-- LOGIN_TABLE 이라는 ROLE을 만들고, 이 ROLE을 이용해 SQLD 유저에게 권한을 부여한다.

CONN SYSTEM/MANAGER;

CREATE TABLE LOGIN_TABLE;


GRANT CREATE SESSION, CREATE TABLE TO LOGIN_TABLE; -- 권한 부여

GRANT LOGIN_TABLE TO SQLD; -- 권ㄴ한 부여

CONN SQLD/DB2019;

CREATE TABLE MENU (MENU_SEQ NUMBER NOT NULL, TITLE VARCHAR2(10));

```

이와 같이 ROLE을 만들어 사용한는 것이 권한을 직접 부여하는 것보다 빠르고 안전하게 유저를 관리할 수 있는 방법이다.

ORACLE 에서는 기본적으로 몇 가지 ROLE을 제공하다. 그중 가장 많이 사용하는 ROLE은 CONNECT 와 RESOURCE 다. CONNECT 는 CREATE SESSION 과 같은 로그인 권한이 포함돼 있고, RESOURCE 는 CREATE TABLE 과 같은 오브젝트 생성 권한이 포함돼 있다. 일반적으로 유저를 생성할 때 CONNECT 와 RESOURCE ROLE 을 사용해 기본 권한을 부여한다.

### CONNECT

CREATE SESSION

### RESOURCE

CREATE CLUSTER
CREATE INDEXTYPE
CREATE OPERATOR
CREATE PROCEDURE
CREATE SEQUENCE
CREATE TABLE
CREATE TRIGGER
CREATE TYPE

유저를 삭제하는 명령어는 DROP USER이고, CASCADE 옵션을 주면 해당 유저가 생성한 오브젝트를 먼저 삭제한 후 유저를 삭제한다.

```sql
-- 앞에서 MENU라는 테이블을 생성했기 때문에 CASCADE 옵션을 사용해 SQLD 유저를 삭제한 후, 유저 재생성 및 기본적인 ROLE을 부여한다.

CONN SYSTEM/MANAGER;

DROP USER SQLD CASCADE;

```

유저가 삭제되면서 SQLD 유저가 만든 MENU TABLE도 같이 삭제됐다.

```sql
CREATE USER SQLD IDENTIFIED BY DB2019;

GRANT CONNECT, RESOURCE TO SQLD;

CONN SQLD/DB2019;

CREATE TABLE MENU(MENU_SEQ NUMBER NOT NULL. TITLE VARCHAR2(10));
```
