# 블록 단위 I/O

ORACLE을 포함한 모든 DBMS에서 I/O는 블록 단위로 이뤄진다. 즉 하나의 레코드로 읽더라도 레코드가 속한 블록 전체를 읽는다.
SQL 성능을 좌우하는 가장 중요한 성능지표는 엑세스하는 블록의 수이며, 옵티마이저의 판단에 가장 큰 영향을 준다.
블록 단위 I/O 는 버퍼 캐시와 데이터 FILE I/O 모두에 적용된다.

\- 데이터 파일에서 DB 버퍼 캐시로 블록을 적재할 때
\- 데이터 파일에서 블록을 직접 읽고 쓸때
\- 버퍼 캐시에서 블록을 읽고 쓸 때
\- 버퍼 케시에서 변경된 블록을 다시 데이터 파일을 쓸 때

---

# 메모리 I/O vs 디스크 I/O

## I/O 효율화 튜닝의 중요성

디스크를 경유한 데이터 입출력은 디스크의 엑세스 암이 움직이면서 헤드를 통해 데이터를 읽고 쓰기 때문에 느린 반면, 메모리를 통한 입출력은 전기적 신호에 불과하기 때문에 속도가 빠르다.
모든 DBMS는 읽고자 하는 블록을 먼저 버퍼 캐시에서 찾아보고, 없을 경우에만 디스크에서 읽어 버퍼 캐시에 적재한 후 읽기/쓰기 작업을 수행한다.

물리적 디스트의 I/O가 필요할 때면 서버 프로세스는 시스템 I/O CALL을 하고 잠시 대기 상태에 빠진다. 디스크 I/O 경합이 심할수록 대기 시간도 길어진다.
디스크 I/O를 최소화하고 버퍼 캐시 효율을 높이는 것이 데이터베이스 I/O 튜닝의 목표가 된다.

## 버퍼 캐시 히트율

전체 읽은 블록 중에서 매모리 버퍼 캐시에서 찾은 비율을 나타낸다. 즉 버퍼 캐시 히트율은 물리적 디스크 읽기를 수반하지 않고 곧바로 메모리에서 블록을 찾은 비율을 말한다.

DIRECT PATH READ 방식 이외의 모든 블록 읽기는 버퍼 캐시를 통해 이뤄진다. 읽고자 하는 블록을 먼저 버퍼 캐시에서 찾아보고, 없을 때만 디스크로부터 버퍼 캐시에 적재한 후 읽어 들인다.

```sql
-- BCHR = (버퍼 캐시에서 곧바로 찾은 블록 수 / 총 읽은 블록 수 ) * 100
```

BCHR은 주로 시스템 전체적인 관점에서 측정하지만, 개별 sql 측면에서 구해볼 수도 있는데 이 비율이 낮은 것이 sql 성능을 떨어뜨리는 주원인이 된다.

모든 블록 읽기는 버퍼 캐시를 경우하며, 디스크 I/O가 수반되더라도 먼저 버퍼 캐시에 적재한 후 읽는다고 했다.
총 읽은 블록 수가 디스크로부터 읽은 블록 수를 이미 포함한다.
논리적인 블록 요청 횟수를 줄이고, 물리적으로 디스크에서 읽어야 할 블록 수르 줄이는 것이 i/O 효율화 튜닝의 핵심 원리이다.

같은 블록을 반복적으로 액세스 하는 형태의 SQL은 논리적인 I/O 요청이 비효울적으로 많이 발생함에도 BCHR은 매우 높다. 이는 BCHR이 성능지표로 갖는 한계점이라고 할 수 있다.

작은 테이블을 반복적으로 엑세스하면 모든 블록이 메모리에서 찾아져 BCHR는 높겠지만 일략이 작지 않고, 블록을 찾는 과정에서 lach 경합과 버퍼 LOCK 경합이 발생하면 메모리 IO 비용이 디스트 iO 비용보다 커질 수 있다.

따라서 논리적으로 읽어야 할 블록수의 절대량이 많다면 반드시 튜닝을 통해 논리적인 블록 읽기를 최소화 해야한다.

## 네트워크, 파일시스템 캐시가 IO 효율에 미치는 영향

대용량 데이터를 읽고 쓰는 데 다양한 네크워크 기술(DB 서버와 스토리지 간에 NAS OR SAN을 사용)이 사용됨에 따라 네트워크 속도도 SQL 성능에 큰 영향을 미친다.
네트워크 전송량이 많을 수밖에 없도록 SQL을 작성한다면 좋은 성능을 기대할 수 없다.
SQL을 작성할 때는 다양한 I/O 튜닝 기법을 사용해 네트워크 전송량을 줄이려고 노력하는 것이 중요하다.

RAC 같은 클러스터링 데이터베이스 환경에선 인스턴스 간 캐시된 블록을 공유하므로 메모리 I/O 성능에도 네트워크 속도가 지대한 영향을 미친다.
같은 양의 DISK I/O 가 발생하더라도, I/O 대기 시간이 크게 차이날 때가 있다. 디스크 경합 때문일 수도있고, OS에서 지원하는 파일 시스템 버퍼 캐시와 SAN 캐시때문일 수도 있다.
SAN 캐시는 크다고 문제될 것이 없지만, 파일 시스템 버퍼캐시는 최소화 해야한다. 데이터베이스 자체적으로 캐시 영역을 갖고 잇으므로 이를 위한 공간을 크게 할당하는 것이 더 효과적이다.
네트워크 문제이든 파일 시스템 문제이든 I/O 성능에 관한 가장 확실하고 근본적인 해결책은 논리적 블록 요청 횟수를 최소화하는 것이다.

---

# SEQUENTIAL I/O VS RANDOM I/O

SEQUENTIAL I/O는 레코드간 논리적 또는 물리적인 순서를 따라 차례대로 읽어 나가는 방식이다. 인덱스 리프블록에 위치한 모든 레코드는 포인터를 따라 논리적으로 연결돼 있고, 이 포인터를 따라 스캔하는것이 SEQUENTIAL I/O 방식이다.

RANDOM I/O 는 레코드간 논리적, 물리적인 순서를 따르지 않고, 한 건을 읽기 위해 한 블록씩 접근하는 방식을 말한다.

블록 단위 I/O를 하더라도 한번 엑세스할때 시퀀셜 방식으로 모든 레코트를 읽는다면 비효율은 없다. 반면 하나의 레코드를 읽으려고 한 블록씩 랜덤 엑세스를 한다면 매우 비효울적이라 할 수 있다.
여기서 I/O 튜닝의 핵심 원리 두 가지를 발견할 수 있다.

- 시퀀셜 액세스에 의한 선택 비중을 높인다.
- 렌덤 엑세스 발생량을 줄ㅇ니다.

## 시퀀셜 엑세스에 의한 선택 비중 높이기

시퀄셜 엑세스 효율성을 높이려면, 읽은 총 건수 주에서 결과 집합으로 선택되는 비중을 높여야 한다. 즉 같은 결과를 얻기 위해 얼마나 적은 레코드를 읽느냐로 효율성을 판단할 수 있따.

```SQL
-- 테스트용 테이블 생성
CREATE TABLE T
AS
SELECT * FROM ALL_OBJECTS
ORDER BY DBMS_RANDOM.VALUE

-- 테스트용 테이블 데이터 건수 : 49.906
SELECT COUNT(*) FROM T;

-- 24,613 개의 레코드를 선택하기 위해 49,906 개의 레코드를 읽었으므로 49%가 선택됐다. TABLE FULL SCAN 에서 이정도면 나쁘지 않다.
-- 읽은 블록 수는 691개 이다.
SELECT COUNT(*) FROM T
WHERE OWNER LIKE 'SYS%'

--  1 개의 레코드를 선택하기 위해 49.906 개의 레코드를 선택했다. 선택비중이  0.002% 밖에 되지 않으므로 TABLE FULL SCAN 비효율이 높다.
-- 여기서 읽은 블록 수도 똑같이 691개이다.
SELECT COUNT(*) FROM T
WHERE OWNER LIKE 'SYS%'
AND OBJECT_NAME = 'ALL_OBJECTS';

-- 이처럼 테입을 스캔하면서 읽은 레코드 중 대부분이 필터링 되고 일부만 선택된다면 아래처럼 인덱스를 이용하는게 효과적이다.
-- 참조하는 칼럼이 모두 인덱스에 있으므로 인덱스만 스캔하고 결과를 구할 수 있다.
-- 하지만 1개의 레코드를 읽기 위해 76개의 블록을 읽어야 한다.
-- 테이블뿐만 아니라 인덱스를 시퀀셜 엑세스 방식으로 스캔할 때도 비효울이 나타날 수 있다.
-- 조건절에서 사용된 칼럼과 연산자 형태, 인덱스 구성에 의해 효율성이 결정된다.

create index t_inx on t(owner, object_name);
select /*+ index(t t_idx) */ count(*) from t;
WHERE OWNER LIKE 'SYS%'
AND OBJECT_NAME = 'ALL_OBJECTS';

-- 다음은 인덱스 구성 칼럼의 순서를 변경한 후에 테스트한 결과다.
-- 루트와 리프, 단 2개의 인덱스 블록만 읽었다. 한 건을 얻으려고 읽는 건수도 한 건일 것이므로 가장 효율적인 방식으로 시퀀셜 엑세스를 수행했다.
DROP INDEX T_IDX;
CRAETE INDEX T_IDX ON T(OBJECT_NAME, OWNER);

SELECT /*+INDEX(T T_IDX*/ COUNT(*) FROM T
WHERE OWNER LIKE 'SYS%'
AND OBJECT_NAME = 'ALL_OBJECTS'
```

---

## 렌덤 엑세스 발생량 줄이기

렌덤 엑세스 발생량을 낮추는 방법을 살펴보자. 인덱스에 속하지 않는 칼럼을 참조하도록 퀴리를 변경함으로써 테이블 액세스가 발생하도록 한다.

```SQL
-- 인덱스로부터 조건을 만족하는 22,934건을 읽어 그 횟수만큼 테이블을 랜덤 엑세스 했다. 최종적으로 한 건이 선택된 것에 비해 너무 많은 랜덤 엑세스가 발생했다.
DROP INDEX T_IDX;
CREATE INDEX T_INDX ON T(OWNER);

SELECT OBJECT_ID FROM T
WHERE OWNER = 'SYS'
AND OBJECT_NAME = 'ALL_OBJECTS';

-- 인덱스를 변경해 테이블 랜덤 액세스 발생량을 줄인 결과다.
-- 인덱스 구성이 바뀌자 테이블 랜덤 액세스가 대폭 감소했다.
DROP INDEX T_IDX;
CREATE INDEX T_INDX ON T(OWNER, OBJECT_NAME);

SELECT OBJECT_ID FROM T
WHERE OWNER = 'SYS'
AND OBJECT_NAME = 'ALL_OBJECTS';

```

---

# SINGLE BLOCK I/O VS MULTIBLOCK I/O

SINGLE BLOCK I/O 는 한 번의 입출력 CALL에 하나의 데이터 블록만 읽어 메모리에 적재하는 방식이다.
인덱스를 통해 테이블을 엑세스할 때는, 기본적으로 인덱스와 테이블 블록 모두 이 방식을 사용한다.

MULTIBLOCK I/O 은 입출력 콜이 필요한 시점에, 인접한 블록들을 같이 읽어 메모리에 적재하는 방식이다. TABLE FULL SCAN 처럼 물리적으로 저장된 순서에 따라 읽을 때는 인접한 블록들을 같이 읽는 것이 유리하다.
인접한 블록이란, 한 익스텐트내에 속한 블록을 말한다. 달리 말하면 MULTIBLOCK I/O 방식으로 읽더라도 익스텐트 범위를 넘어서까지 읽지는 않는다.

인덱스 스캔 시에는 SINGLE BLOCK I/O 방식이 효율적이다. 인덱스 블록간 논리적 순서는 데이터 파일에 저장된 물리적인 순서와 다르기 때문이다. 물리적으로 한 익스텐트에 속한 블록들은 입출력 콜 시점에 같이 메모리에 올렸는데, 그 블록들이 논리적 순서로는 한참 뒤쪽에 위치할 수 있다. 그러면 그 블록들은 실제 사용되지 못한 채 버퍼 상에서 밀려나는 일이 발생한다. 하나의 블록을 캐싱하려면 다른 블록을 밀어내야 하는데, 이런 현상이 자주 발생하면 버퍼 캐시 효율이 떨어진다.

대량의 데이터를 MULTIBLOCK I/O 방식으로 읽을 때 SINGLE BLOCK I/O 보다 성능상 유리한 이유는 입출력 콜 발생 횟수를 줄여주기 때문이다.

```sql
create table t
as
select * from all_objects;

alter table t add
constraint t_pk primary key(object_id);

select /*+ index(t) */ count (*)
from t where object_id > 0

-- 디스크 I/O가 발생하도록 버퍼 캐시 FLUSHING
alter system flush buffer_cache;

-- MULTIBLOCK I/O 방식으로 인덱스 스캔
SELECT /*+ INDEX_FFS(T) */ COUNT(*) FROM T WHERE OBJECT_ID > 0;
```

똑같이 64 개의 블록을 디스크에서 읽었늗데, 입출력 촐이 9번에 그쳤다.
참고로 위 테스트는 ORACLE 9i 에서 수행한 것이다. ORACLE 10G 부터는 INDEX RANGE SCAN OR INDEX FULL SCAN일 때도 MULTIBLOCK I/O 방식으로 읽는 경우가 있다.
위 처럼 테이블 엑세스 없이 인덱스만 읽고 처리할 때가 그렇다.
SINGLE BLOCK I/O 방식으로 읽은 블록들은 LRU 리스트 상 MRU 쪽에 위치하므로 한 번 적재되면 버퍼 캐시에 비교적 오래 머문다. 반대로 MULTIBLOCK I/O 방식으로 읽은 블록은 LRU 리스트 상 LRU 쪽으로 연결되므로 적재된지 얼마 지나지 않아 1순위 버퍼캐시에서 밀려난다.

---

# I/O 효율화 원리

논리적인 I/O 요청 횟수를 최소화하는 것이 튜닝의 핵심 원리이다. I/O 때문에 시스템 성능이 낮게 측정될 때 하드웨어적인 방법을 통해 향상 시킬 수도 있다. 하지만 SQL 튜닝을 통해 I/O 발생 횟수 자체를 줄이는 것이 더 근본적이고 확실한 해결 방안이다.

- 필요한 최소 블록만 읽도록 SQL 작성
- 최적의 옵티마이징 팩터 제공
- 필요하다면, 옵티마이저 힌트를 사용해 최적의 액세스 경로로 유도

```sql
-- 필요한 최소 블록만 읽도록 SQL 작성
-- 데이터베이스의 성능은 입출력 효율에 달렸다. 이를 달성하려면 동일한 데이터를 중복 엑세스 하지않고 필요한 최소 블록만 읽도록 SQL을 작성한다.
-- 최소 일령을 요구하는 형태로 논리적인 집합을 정의하고, 효율적인 처리가 가능하도록 작성하는 것이 무엇보다 중요하다.
-- 아래는 비효율적인 중복 엑세스를 없애고 필요한 최소 블록만 액세스하도록 튜닝한 사례다.

-- 위 SQL은 어제 거래가 있었던 카드에 대한 전일, 주간, 전월, 연중 거래 실적을 집계하고 있다.
-- 논리적인 전체 집합은 과거 1년치 인데, 전일, 주간, 전월 데이터를 각각 액세스한 후 조인한 것을 볼 쑤 있다. 전일데이터는 총 4번 엑세스 됐다.
SELECT A.CARD_NUM
, A.T_AMOUNT
, B.T_AMOUNT
, C.T_AMOUNT
, D.T_AMOUNT
FROM (
  SELECT CARD_NUM, T_AMOUNT
  FROM DAILY
  WHERE T_DATE = TO_CHAR(SYSDATE -1, 'YYYYMMDD')
) A
,(
  SELECT CARD_NUM, SUM(T_AMOUNT)
  FROM DAILY
  WHERE T_DATE = BETWEEN TO_CHAR(SYSDATE - 7, 'YYYYMMDD') AND TO_CHAR(SYSDATE -1, 'YYYYMMDD')
  GROUP BY CARD_NUM
) B
,(
  SELECT CARD_NUM, SUM(T_AMOUNT)
  FROM DAILY
  WHERE T_DATE = BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMMDD') || '01' AND TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE, -1)), 'YYYYMMDD')
  GROUP BY CARD_NUM
) C
,(
  SELECT CARD_NUM, SUM(T_AMOUNT)
  FROM DAILY
  WHERE T_DATE = BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD') || '01' AND TO_CHAR(SYSDATE -1, 'YYYYMMDD')
  GROUP BY CARD_NUM
) D

-- SQL을 다음과 같이 작성하면 과거 1년치 데이터를 한 번만 읽고 전일, 주간, 전월 결과를 구할 수 있다. 즉 논리적인 집합 재구성을 통해 엑세스 해야할 데이터 양을 최소화 할 수 있다.

SELECT CARD_NUM
, SUM( CASE WHEN T_DATE = TO_CHAR(SYSDATE -1 , 'YYYYDDMM') THEN T_AMOUNT  END )
, SUM( CASE WHEN T_DATE BETWEEN TO_CHAR(SYSDATE -7 , 'YYYYMMDD') AND TO_CHAR(SYSDATE -1 , 'YYYYMMDD') THEN T_AMOUNT END )
, SUM( CASE WHEN BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMMDD') || '01' AND TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE, -1)), 'YYYYMMDD') END)
FROM T_LIST
WHERE T_DATE = BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -12), 'YYYYMMDD') || '01' AND TO_CHAR(SYSDATE -1, 'YYYYMMDD')
GROUP BY CARD_NUM
HAVING SUM(CASE WHEN T_DATE = TO_CHAR(SYSDATE -1, 'YYYYMMDD') THEN T_AMOUNT END)

-- 최적의 옵티마이징 팩터 제공
-- 옵티마이저가 블록 엑세스를 최소화하면서 효율적으로 처리할 수 있도록 하려면 최적의 옵티마이징 팩터를 제공해 주어야한다.

-- 전략적 인덱스 구성
-- DMBS가 제공하는 기능 활용
-- 인덱스 외에도 dbms 가 제공하는 다양한 기능을 적극적으로 활용한다. 인덱스, 파티션, 클러스터, 윈도우 함수 등을 적극 활용해 옵티마이저가 최적으로 선택할 수 있도록 한다.
-- 옵티마이저 모드 설정
-- 전체 처리속도 최적화, 최초 응답속도 최적화 와 그 외 옵티마이저 행동에 영향을 미치는 일부 파라미터를 변경해주는 것이 도움이 된다.
-- 통계정보
-- 옵티마이저에게 저확한 정보를 제공한다.

-- 필요하다면 옵티마이저 힌트를 사용해 최적 액세스 경로 유도

SELECT /*+LEADING(D) USE_NL(E) INDEX(D DEPT_LOC_IDX)*/
*
FROM EMP E, DEPT D
WHERE E.DPETNO = D.DEPTNO
AND D.LOC = 'CHICAGO'
```

옵티마이저 힌트를 사용할 때는 의도한 실행계획으로 수행되는 지 반드시 확인해야한다.
데이터베이스 애플리케이션 개발자라면 인덱스, 조인, 옵티마이저의 기본 원리를 이해하고, 그것을 바탕으로 최적의 엑세스 경로로 유도할 수 있는 능력을 필수적으로 갖춰야한다.
