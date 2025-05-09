# 소프트파싱 vs 하드파싱

시스템 공유 메모리에서 SQL 과 실행계획이 캐싱되는 영역을 ORACLE에선 라이브러리 캐시라고 부른다.
사용자가 SQL을 실행하면 제일 먼저 SQL 파서가 SQL 문장에 문법적 오류가 있는지 검사한다. 문법적으로 오류가 없으면 의미상 오류가 없는지를 검사한다.
예를 들어 존재하지 않거나 권한이 없는 객체를 사용했는지, 또는 존재하지 않는 칼럼을 사용했는지 등을 검사한다.
이런 검사를 마치면 사용자가 발생한 SQL과 그 실행계획이 라이브러리 캐시에 캐싱됐는지를 확인한다. 만약 캐싱돼 있다면, 무거운 최적화 과정을 거치지 않고 곧바로 실행할 수 있다.

- 소프트 파싱 : SQL 실행계획을 캐시에서 찾아 곧바로 실행단계로 넘어가는 경우를 말한다.
- 하드 파싱 : SQL 실행계획을 캐시에서 찾지 못해 최적화 과정을 거치고 나서 실행단계로 넘어가는 경우를 말한다.

라이브러리 캐시는 해시구조로 관리되기 때문에 SQL 마다 hash 값에 따라 여러 해시 버킷으로 나누어 저장된다.
SQL을 찾을 때는 SQL 문장을 해시 함수에 입력해서 반환된 해시 값을 이용해 해당 해시버킷을 탐색한다.

---

## SQL 공유 및 재사용의 필요성

앞서 옵티마이저의 최적화 과정을 거치는 경우를 하드파싱이라고 표현했는데, 최적화 과정은 그만큼 무거운 작업을 수반한다. 예를 들어 5개의 테이블을 조인하려면 조인 순서만 고려해도 5!개의 실행계획을 평가해야한다.
120가지 실행계획에 포함된 각 조인 단계별 NL조인, 소트 머지 조인, 해시 조인 등 다양한 조인 방식까지 고려하면 경우의 수는 기하급수적으로 늘어난다. 여기에 각 테이블을 FULL SCAN 할지 인덱스를 사용할지,
인덱스를 사용한다면 어떤 인덱스를 어떤 방식으로 스캔할지까지 모두 고려해야 하므로 여간 무거운 작업이 아니다.

옵티마이저가 SQL 최적화 과정에 사용하는 정보는 다음과 같다.

\- 테이블, 칼럼, 인덱스 구조에 관한 기본 정보
\- 오브젝트 통계 : 테이블 통계, 인덱스 통계, 히스토그램을 포함한 칼럼 통계
\- 시스템 통계 : CPU 속도, SINGLE BLOCK I/O 속도, MULTIBLOCK I/O 속도
\- 옵티마이저 관련 파라미터

하나의 쿼리를 수행하는 데 있어 후보군이 될만한 무수히 많은 실행경로를 도출하고, 짧은 순간 딕셔너리와 통계정보를 읽어 각각에 대한 효율성을 판단하는 과정은 가벼울 수 없다.
어려운 작업을 거쳐 생성한 내부 프로시져를 한 번만 사용하고 버린다면 비효율적이다. 파싱과 최적화 과정을 거친 SQL 과 실행계획을 여러 사용자가 공유하면서 재사용할 수 있도록 공유 메모리에 캐싱해 두는 이유가 있다.

---

## 실행계획 공유 조건

SQL 수행 절차를 정리해 보면 다음과 같다.

- 문법적 오류와 의미상 오류가 없는지 검사한다.
- 해시 함수로부터 반환된 해시 값으로 라이브러리 캐시 내 해시버킷을 찾아간다.
- 찾아간 해시버킷에 체인으로 연결된 엔트리를 차례로 스캔하면서 같은 SQL 문장을 찾는다.
- SQL 문장을 찾으면 함께 저장된 실행계획을 가지고 바로 실행한다.
- 찾아간 해시버킷에서 SQL 문장을 찾지 못하면 최적화를 수행한다.
- 최적화를 거친 SQL 과 실행계획을 방금 탐색한 해시버킷 체인에 연결한다.
- 방금 최적화한 실행계획을 가지고 실행한다.

방금 설명한 SQL 수행 절차에서 중요한 사실 하나를 발견할 수 있다. 하드 파싱을 반복하지 않고 캐시오딘 버전을 찾아 재사용하려면 캐시에서 SQL을 먼저 찾아야 하는데, 캐시에서 SQL을 찾기 위해 사용되는 키 값이 SQL 문장 그 자체라는 사실이다.
SQL 문을 구성하는 전체 문자열이 이름 역할을 한다. 이는 SQL 파싱 부하 해소 원리를 이해하는 데 있어 매우 중요하다. 문장에 공백문자 하나만 추가되더라도 DBMS는 서로 다른 SQL 문장으로 인식하기 때문에 캐싱된 버전을 상요하지 못하게 된다.

- 공백문자
- 대소문자 구분
- 주석
- 테이블 OWNER 명시
- 옵티마이져 힌트 사용
- 조건절 비교값 변경

옵티마이져 힌트 사용을 제외하고 나머지 것들은 실행계획이 모두 같다. 그럼에도 문자열을 조금 다르게 기술하는 바람에 서로 다른 SQL로 인식돼 각각 하드파싱을 일으키고 서로 다른 메모리 공간을 차지하게 된다.
이를 방지하기 위해 개발 초기에 SQL 작성 표준을 정해 이를 준수해야한다.

캐시 효율과 직접 관련있는 패턴은 조건절 비교값 변경이다. 사용자가 입력값 을 조건절에 문자열로 붙여가며 매번 다른 SQL 을 실행하는 경우다. 만약 하루 1000만 번 로그인일 발생하는 애플리케이션에서 사용자 로그인을 조건절 값에 따라 매번 새로운 SQL 문이 되도록 한다면 피크 시간대에 큰 부하가 발생할 수 있다.

---

# 바인드 변수 사용

## 바인드 변수의 중요성

사용자 로그인을 처리하는 프로그램에 SQL을 조건절의 비교값이 변경되는 식으로 작성하면 프로시저가 로그인 사용자마다 하나씩 만들어지게 된다. 이를 프로시저로 만들어 주는 역할을 옵티마이저가 담당한다.

```SQL
PROCEDURE LOGIN_TOMMY() {...}
PROCEDURE LOGIN_KARAJAN() {...}
PROCEDURE LOGIN_JAVAKING() {...}
PROCEDURE LOGIN_ORAKING() {...}

```

모든 프로시저의 처리 루틴이 같다면 여러 개를 생성하기보다 아래처럼 로그인 ID를 파라미터로 받아 하나의 프로시저로 처리하도록 하는 것이 마땅하다.

```sql
procedure login(login_id in varchar2) {...}

-- 이처럼 파라미터 디리븐 방식으로 SQL을 작성하는 방법이 제공되는데, 그것이 곧 바인드 변수이다.
-- 바인드 변수를 사용하면 하나의 프로시저를 공유하면서 반복 재사용할 수 있게 된다.

SELECT * FROM CUSTOMER WHERE LOGIN_ID = :LOGIN_ID;
```

위와같이 바인드 변수를 사용하면 이를 처음 수행한 세션이 하드파싱을 통해 실행계획을 생성한다.
실행계획을 한번 사용하고 버리는 것이 아니라 라이브러리에 캐싱해 둠으로써 같은 SQL을 수행하는 다른 세션들이 반복 재사용할 수 있도록한다.
즉, 이후 세션들은 캐시에서 실행계획을 얻어 입력 값만 새로 바인딩해 실행하게 된다.

바인드 변수를 사용했을 때의 효과는 아주 분명하다. SQL과 실행계획을 여러 개 캐싱하지 않고 하나를 반복 재사용하므로 파싱 소요시간과 메모리 사용량을 줄여준다.
궁극적으로 시스템 전반의 CPU와 메모리 사용률을 낮춰 데이터베이스 성능과 확장성을 높인다.

다음와 같은 경우에는 바인드 변수를 쓰지 않아도 된다.

\- 배치프로그램이나 DW, OLAP 등 정보계 시스템에서 사용되는 lONG RUNNING 쿼리

이들 쿼리는 파싱 소요시간이 쿼리 총 소요시간에서 차지하는 비중이 매우 낮고, 수행빈도도 낮아 하드파싱에 의한 라이브러리 캐시 부하를 유발할 가능성이 낮다. 그러므로 바인드 변수 대신 상수 조건절을 사용함으로써
옵티마이저가 칼럼 히스토리를 활용할 수 있도록 하는 것이 유리하다.

\- 조건절 칼럼의 값 종류가 소수일 때

리터럴 SQL 위주로 애플리케이션을 개발하면 라이브러리 캐시 경합 때문에 시서템 정상 가동이 어려운 상황에 직면할 수 있다. 이에 대비해 각 DBMS는 조건절 비교 값이 리터럴 상수일 때 이를 자동으로 변수화해주는 기능을 제공한다.
리터럴 쿼리에 의한 파싱부하가 극심한 상황에서 이 기능이 시스템 부하를 줄이는데 도움이 되는 것은 사실이다 하지만 이 옵션을 적용하는 순간 실행계획이 갑자기 바뀌어 기존에 잘 수행되던 쿼리가 갑자기 느려질 수 있다. 사용자가 의도적으로 사용한 상수까지 변수화가 되면서 문제를 일으키기도 한다.

\- 바인드 변수 사용시 주의사항

바인드 변수를 사용하면 SQL이 최초 수행될 때 최적화를 거친 실행계획을 캐시에 저장하고, 실행시점에는 그것을 그대로 가져와 값만 다르게 바인딩하면서 반복 재사용한다.
변수를 바인딩하는 시점이 최적화 이후다. 즉 나중에 반복 수행될 때 어떤 값이 입력될지 알 수 없기 때문에 옵티마이저는 조건절 칼럼의 데이터 분포가 균일하다는 가정을 세우고 최적화를 수행한다.
칼럼에 대한 히스토그램 정보가 딕셔너리에 저장돼 있어도 이를 활용하지 못하는 것이ㅏㄷ.
칼럼 분포가 균일할때는 이렇게 처리해도 나쁘지 않지만, 그렇지 않을 때는 실행 시점에 바인딩되는 값에 따라 쿼리 성능이 다르게 나타날 수 있다. 이럴 때는 바인드 변수를 사용하는 것 보다 상수 값을 사용하는 것이 나을 수 있다.
그 값에 대한 칼럼 히스토그램 정보를 이용해 좀 더 최적의 실행계획을 수립할 가능성이 높기 때문이다.

---

## 바인드 변수 부작용을 극복하기 위한 노력

바인드 변수 사용에 따른 부작용을 극복하기위해 바인드 변수 PEEKING 기능이 도입됐다. SQL이 첫 번째 수행될 때의 바인드 변수 값을 참고하여 그 값에 대한 칼럼 분포를 이용해 실행계획을 결정하는 기능이다.
그러나 이것은 매우 위함한 기능이다. 처음 실행될 때 입력된 값과 전혀 다른 분포를 갖는 값이 나중에 입력되면 쿼리 성능이 갑자기 느려지는 현상이 발생할 수 있기 때문이다.

쿼리 수행 전에 확인하는 실행계획은 바인드 변수 PEEKING 기능이 적용되지 않은 실행계획이라는 사실도 기역해야한다.
사용자가 쿼리 수행 전에 실행계획을 확인할 때는 변수에 값을 바인딩하지 않으므로 옵티마이저는 값을 PEEKING 할 수 없다. 따라서 사용자는 평균 분포에 의한 실행계획을 확인하고 프로그램을 배포하지만
실제 SQL이 실행될 때는 바인드 변수 PEEKING 을 일으켜 다른 방식으로 수행될 수 있다.

```sql
-- 바인드 변수 Peeking qlghkftjdghk
alter system set "_optim_peek_user_binds" = FALSE;

-- 아래 쿼리로 아파트 매물 테이블을 읽을 때, 서울시와 경기도처럼 선택도가 높은 값이 입력될때는 FULL TABLE SCAN이 유리하고, 강원도나 제주도처럼 선택도가 낮은 값이 입력될 때는 인덱스를 경유해 테이블을 액세스하는 것이 유리하다.
SELECT * FROM 아파트매물 WHERE 도시 = :CITY;

-- 그럴 때 위 쿼리에서 바인딩 되는 값에 따라 실행계획을 다음과 같이 분리하는 방안을 고려할 수 있다.
SELECT /*+FULL(a)*/ *
FROM 아파트매물 a
WHERE :CITY IN ('서울시', '경기도')
AND 도시 = :CITY
UNION ALL
SELECT /*+INDEX(a IDX01)*/ *
FROM 아파트매물 a
WHERE :CITY not IN ('서울시', '경기도')
AND 도시 = :CITY
```

---

# 에플리케이션 커서 캐싱

같은 SQL을 반복해서 여러 번 수행해야 할 때, 첫 번째는 하드파싱이 일어나겠지만 이후 부터는 라이브러리 캐시에 공유된 버전을 찾아 가볍게 실행할 수 있다.
그렇다더라도 SQL 문장의 문법적, 의미적 어류가 없는지 확인하고 해시함수로부터 반환된 해시 값을 이용해 캐시에서 실행계획을 찾고, 수행에 필요한 메모리 공간을 할당하는 등의 작업을 반복하는 것은 비효율적이다.
이런 과정을 생략하고 빠르게 SQL을 수행하는 방법이 '애플리케이션 커서 캐싱' 이다.

일반적인 방식으로 같은 SQL을 반복 수행할 때는 PARSE CALL 횟수가 EXECUTE CALL 횟수와 같게 나타난다. 반면 애플리케이션 캐싱한 트레이스 결과에선 PARSE CALL이 한 번만 발생했고 이후에는 발생하지 않았다.
자바에서 이 기능을 구현하려면 다음과 같이 묵시적 캐싱 옵션을 사용하면 된다.

```java
public static void CursorCaching(Connection conn, int count) throws Exception {

  // 케시 사이즈를 1로 지정
  ((OracleConnection) conn).setStatementCacheSize(1);
  // 묵시적 캐싱 기능 활성화
  ((OracleConnection) conn).setImplicitCachingEnabled(true);

  for(int i = 1; i <= count; i ++){
    PreparedStatement stmt = conn.prepareStatement(
      "SELECT ?, ?, ?, a.* from emp a where a.ename like 'W%'"
    )
    stmt.setInt(1, i);
    stmt.setInt(2, i);
    stmt.setString(3, "test");
    ResultSet rs = stmt.executeQuery();
    rs.close()
    // 커서를 닫더라도 묵시적 캐싱 기능을 활성화 했으므로 닫지 않고 캐시에 보관
    stmt.close();
  }
}

// 아래 처럼 Statement를 닫지 않고 재사용해도 같은 효과를 얻을 수 있다.
public static void CursorHolding(Connection conn, int count) throws Exception {

 PreparedStatement stmt = conn.prepareStatement(
      "SELECT ?, ?, ?, a.* from emp a where a.ename like 'W%'"
);
ResultSet rs;

for(int i = 1; i <= count; i ++){
    stmt.setInt(1, i);
    stmt.setInt(2, i);
    stmt.setString(3, "test");
    rs = stmt.executeQuery();
    rs.close()
  }
  // 루프를 빠져 나왔을 때 커서를 닫는다.
  stmt.close();
}
```

PL/SQL 에서는 위와 같은 옵션을 별도로 적용하지 않더라도 자동적으로 커서를 캐싱한다. 단 STATIC SQL을 사용할 때만 그렇다. DYNAMIC SQL을 사용하거나 CURSOR VARIABLE을 사용할 때는 커서를 자동으로 캐싱하는 효과가 사라진다.

---

# Static SQL VS DYNAMIC SQL

## STATIC SQL

string형 변수에 담지 않고 코드 사지에 직접 기술한 SQL 문을 말한다.

## DYNAMIC SQL

STRING 형 변수에 담아서 기술하는 SQL 문을 말한다. STRING 변수를 사용하므로 조건에 따라 문을 동적으로 바꿀 수 있고, 또는 런타임 시에 사용자로부터 SQL문 일부 또는 전부를 입력 받아서 실행할 수도 있다.
따라서 PRECOMPILE 시 SYSTAX, SEMANTICS 체크가 불가능하므로 그대로 DBMS로 전달된다.

---

## 바인드 변수의 중요성

지금까지 설명한 STATIC, DYNAMIC SQL은 애플리케이션 개발 측면에서의 구분일 뿐이며 데이터 베이스 입장에서는 차이가 없다. 성능에 영향을 주지 않는다.
따라서 라이브러리 캐시 효율을 논할 때 STATIC이나 DYNAMIC 이냐의 차이보다는 바인드 변수 사용 여부에 초첨을 맞춰야 한다.
바인드 변수만 잘 사용했다면 라이브러리 캐시 효율을 떨어뜨리지 않는다. 바인드 변수를 사용하지 않고 LITERAL 값을 SQL 문자열에 결합하는 방식으로 개발했을 때, 반복적인 하드 파싱으로 성능이 크게 저하되고 그로 인해 라이브러리 캐시에 심한 경합이 발생하다.
