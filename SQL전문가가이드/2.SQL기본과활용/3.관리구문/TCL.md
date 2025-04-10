# 트랜잭션 개요

트랜잭션은 데이터베이스의 논리적 연산단위다. 트랜잭션이란 밀접히 관련돼 분리될 수 없는 한 개 이상의 데이터베이스 조작을 말한다.
하나의 트랜잭션에는 하나 이상의 SQL 문장이 포함된다. 트랜잭션은 분할할 수 없는 최소의 단위이다. 그러므로 전부 적용하거나 전부 취소한다.
계좌이체와 같은 하나의 논리적인 작업 단위를 구성하는 세부적인 연산의 집합을 트랜잭션이라고 한다. 이런 관점에서 데이터베이스 응용 프르로그램은 트랜잭션의 집합으로 정의할 수도 있다.

```sql
-- 트랜잭션의 특성
-- 원자성 : 트랜잭션에서 정의된 연산들은 모두 성공적으로 실행되던지 아니면 전혀 실행되지 않은 상태로 남아있어야한다.
-- 일관성 : 트랜잭션 실행전의 데이터베이스 내용이 잘못 돼 있지 않다면 트랜잭션 이후에도 내용에 잘못이 있으면 안된다.
-- 고립성 : 트랜잭션이 실행되는 도중에 다른 트랜잭션의 영향을 맏아 잘못된 결과를 만들어서는 안된다.
-- 지속성: 트랜잭션이 성공적으로 수행되면, 트랜잭션이 갱신한 데이터베이스의 내용은 영구적으로 저장된다.
```

트랜잭션의 원자성을 충족하기위해 데이터베이스는 다양한 레벨의 잠금기능을 제공한다. 잠금은 기본적으로 트랜잭션이 수행하는 동안 특정 데이터에 대해서 다른 트랜잭션이 동시에 접근하지 못하도록 제한하는 기법이다.

잠금이 걸린 데이터는 잠금을 실행한 트랜잭션만 독점적으로 접근할 수 있고, 다른 트랜잭션으로부터 간섭이나 방해를 받지 않는 것이 보장된다.잠금이 걸린 데이터는 잠금을 수행한 트랜잭션만 해제할 수 있다.

---

# COMMIT

입력, 수정, 삭제한 데이터에 대해 전혀 문제가 없다고 판단되면 COMMIT 명령어로 트랜잭션을 완료할 수 있다.

COMMIT이나 ROLLBACK 이전의 데이터 상태는 다음과 같다.

\- 데이터 변경을 취소해 이전 상태로 복구 가능하다.
\- 현재 사용자는 SELECT 문장으로 결과를 확인 가능하다.
\- 다른 사용자는 현재 사용자가 수행한 명령의 결과를 볼 수 없다.
\- 변경된 행은 잠금이 설정돼서 다른 사용자가 변경할 수 없다.

```sql
-- PLYAER 테이블에 데이터를 입력하고 COMMIT을 실행한다.
INSERT
 INTO PLAYER (PLAYER_ID, TEAM_ID, PLAYER_NAME, POSITION, HEIGHT, WEIGHT, BACK_NO)
 VALUE('1997035', 'K02', '이운재', 'GK', 182, 82 1);

 COMMIT;

-- PLAYER 테이블에 있는 데이터를 수정하고 COMMIT을 실행한다.
UPDATE PLAYER SET HEIGHT = 100;
COMMIT;

-- PLAYER 테이블에 잇는 데이터를 삭제하고 COMMIT을 실행한다.
DELETE FROM PLAYER;

COMMIT;
```

COMMIT 이후의 데이터 상태는 다음과 같다.

\- 데이터에 대한 변경 사항이 데이터베이스에 반영된다.
\- 이전 데이터는 영원히 잃어버리게된다.
\- 모든 사용자는 결과를 볼 수 있따.
\- 관련 행에 대한 잠금이 풀리고, 다른 사용자들이 행을 조작할 수 있게 된다.

---

# ROLLBACK

테이블 내 입력한 데이터나 수정한 데이터, 삭제한 데이터에 대해 COMMIT 이전에는 변경사항을 취소할 수 있다. 데이터베이스에서는 ROLLBACK 기능을 사용한다. 롤백은 데이터 변경이 취소돼 데이터가 이전 상태로 복구되며, 관련 행에 대한 잠금이 풀리고 다른 사용자들이 데이터 변경을 할 수 있게 된다.

```sql

-- PLAYER 테이블에 데이터를 입력하고 ROLLBACK을 실행한다.

INSERT
INTO PLAYER (PLAYER_ID, TEAM_ID, PLAYER_NAME, POSITION, HEIGHT, WEIGHT, BACK_NO)
VALUE('1997035', 'K02', '이운재', 'GK', 182, 82 1);

ROLLBACK;

 -- PLAYER 테이블에 있는 데이터를 수정하고 ROLLBACK 실행한다.
UPDATE PLAYER SET HEIGHT = 100;

ROLLBACK;

-- PLAYER 테이블에 잇는 데이터를 삭제하고 ROLLBACK 실행한다.
DELETE FROM PLAYER;

ROLLBACK;
```

ROLLBACK 후의 데이터 상태는 다음과 같다

\- 데이터에 대한 변경 사항은 취소된다.
\- 데이터가 트랜잭션 시작 이전의 상태로 되돌려진다.
\- 관련 행에 대한 잠금이 풀리고 다른 사용자들이 행을 조작할 수 있다.

COMMNT & ROLLBACK 을 통해 다음과 같은 효과를 볼 수 있다.

- 데이터 무결성 보장
- 영구적인 변경을 하기 전에 데이터의 변경 사항 확인 가능
- 논리적으로 연관된 작업을 그룹핑해 처리

---

## SAVEPOINT

SAVEPOINT를 정의하면 ROLLBAK 할 때 트랜잭션에 포함된 전체 작업을 롤백하는 것이 아니라, 현 시점에서 SAVEPOINT까지 트랜잭션의 일부만 롤백할 수 있다.
따라서 대규모 트랜잭션에서 에러가 발생했을 때 SAVEPOINT 까지의 트랜잭션만 롤백하고 실패한 부분에 대해서만 다시 실행할 수 있다.

복수의 저장점을 지정할 수 있으며, 동일이름으로 여러 개의 저장점을 저장했을 때는 마지막에 정의한 저장점만 유효하다.

```sql
SAVEPOINT SVPT1;

-- 저장점까지 롤백할 때는 ROLLBACK 뒤에 저장점 명을 지정한다.
-- 저장점 설정 이후에 있었던 데이터 변경에 대해서만 원래 데이터 상태로 되돌아가게 한다.
ROLLBACK TO SVPT1;

-- SAVEPOINT를 지정하고, PLAYER 테이블에 데이터를 입력한 다음 롤백을 이전에 설정한 저장점까지 실행한다.
SAVEPOINT SVPT1;

INSERT
INTO PLAYER (PLAYER_ID, TEAM_ID, PLAYER_NAME, POSITION, HEIGHT, WEIGHT, BACK_NO)
VALUE('1997035', 'K02', '이운재', 'GK', 182, 82 1);

ROLLBACK TO SVPT1;

-- SAVEPOINT를 지정하고 PLAYER 테이블에 있는 데이터를 수정한 다음 롤백을 이전에 설정한 지점까지 실행한다.
SAVEPOINT SVPT2;

UPDATE PLAYER SET HEIGHT = 100;

ROLLBACK TO SVPT2;

-- SAVEPOINT를 지정하고 PLAYER 테이블에 있는 데이터를 삭제한 다음 롤백을 이전에 설정한 지점까지 실행한다.
SAVEPOINT SVPT3;

DELETE FROM PLAYER;

ROLLBACK TO SVPT3;

-- 새로운 트랜잭션을 시작하기 전에 PLAYER 테이블의 데이터 건수와 몸무게가 100인 선수의 데이터 건수를 확인한다.

SELECT COUNT (*) AS CNT FROM PLAYER;
--480

SELECT COUNT (*) AS CNT FROM PLAYER WHERE WEIGHT = 100;
-- 0

/*새로운 트랜잭션 시작*/

INSERT
INTO PLAYER (PLAYER_ID, TEAM_ID, PLAYER_NAME, POSITION, HEIGHT, WEIGHT, BACK_NO)
VALUE('1997035', 'K02', '이운재', 'GK', 182, 82 1);

SAVEPOINT SVPT_A;

UPDATE PLAYER SET WEIGHT = 100

SAVEPOINT SVPT_B;

DELETE FROM PLAYER;

-- CASE1. SAVEPOINT B 저장점까지 롤백을 수행하고 롤백 전후 데이터를 확인해본다.

SELECT COUNT (*) AS CNT FROM PLAYER; -- 0

ROLLBACK TO SVPT_B;

SELECT COUNT (*) AS CNT FROM PLAYER; -- 481

-- CASE2. SAVEPOINT A 저장점까지 롤백을 수행하고 롤백 전후 데이터를 확인해본다.

ROLLBACK TO SVPT_A;

SELECT COUNT (*) AS CNT FROM PLAYER WHERE WEIGHT = 100; -- 0

-- CASE3. 트랜잭션 최초 시점까지 롤백을 수행하고 롤백 전후 데이터를 확인해본다.

ROLLBACK;

SELECT COUNT (*) AS CNT FROM PLAYER; -- 480
```

해당 테이블에 데이터의 변경을 발생시키는 입력, 수정, 삭제 명령어 수행 시 변경되는 데이터의 무결성을 보장하는 것이 커밋과 롤백의 목적이다.

커밋은 '변경된 데이터를 테이블이 영구적으로 반영해라' 라는 의미를 갖는 것이고, 롤백은 변경된 데이터가 문제가 있으니 변경사항을 취소하고 이전의 데이터로 복구하라는 것이다.

SAVEPOINT/SAVE TANSACTION 은 데이터 변경을 사전이 지정한 저장점까지만 롤백하라는 의미다.

ORACLE의 트랜잭션은 트랜잭션의 대상이 되는 SQL 문장을 실행하면 자동으로 시작되고, COMMIT 또는 롤백을 실행한 시점에서 종료된다.

단, 다음의 경우에는 COMMIT과 ROLLBACK을 실행하지 않아도 자동으로 트랜잭션이 종료된다.

\- CREATE, ALTER, DROP, RENAME, TRUNCATE TABLE 등 DDL 문장을 실행하면, 그 전후 시점에 자동으로 커밋이 수행된다.

\- DML 문장 이후 명시적인 커밋이 없더라도 DDL 문장이 실행되면 데이터의 변경 사항이 자동으로 커밋된다.

\- 데이터베이스를 정상적으로 접속 종료하면 자동으로 트랜잭션이 커밋된다.

\- 애플리케이션의 이상 종료로 데이터베이스와의 접속이 단절되면 트랜잭션이 자동으로 롤백된다.
