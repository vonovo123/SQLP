Deterministic 키워드는, 함수의 입력 값이 같다면 출력 값도 항상 같음을 선언하려는 데에 목적이 있다.

하지만 테이블의 컬럼 값이 갱신될 수 있다면 함수의 입력값이 같을때 출력 값이 항상 동일함을 보장할 수 없다.

Deterministic 함수로 선언했는데 실제 내용이 Deterministic이 아니라면 문제가 생길 수 있다.

테이블의 특정 컬럼 값이 바뀐다면 위 함수를 사용하는 쿼리들이, 시점에 따라 서로 다른 값을 출력하게 될 뿐 아니라

쿼리 결과를 FETCH 하는 도중에도 다른 값을 출력하게 된다.

이 같은 현상은 함수를 사용하는 한 Deterministic 키워드를 쓰든 안쓰든 상관없이 나타난다.,

Deterministic 을 쓰더라도 캐싱효과는 Fetch Call 내에서만 유효하므로 새로운 Fetch Call 시점에 다시 쿼리하면서

이런 현상이 발생하게 된다.

함수를 스칼라 서브쿼리에 덧입히더라도 읽기 일관성을 완전히 보장받을 수 없다.

스칼라 서브쿼리의 캐싱효과는 Fetch Call을 넘어서 커서거 닫힐때까지 유효하지만,

첫 번째 호출이 일어나 캐싱될 때까지의 시간차 때문에 완벽한 문장수준 읽기 일관성을 보장하기 어렵다.

```sql
create or replace function lookup(l_input number) return varchar2l
DETEMINISTIC
as
  l_output LookupTable.value%TYPE;
  begin
    select value into l_output from LookupTable where key = l_input;
    return l_output;
  end;
/

create table LookupTable (key number, value varchar2(100));

insert into LookupTable (key, value) values(1,'YAMAHA');
insert into LookupTable (key, value) values(2,'YAMAHA');
```

아래는 loopup 함수를 호출하는 쿼리로 쿼리에 사용된 big_table에는 no = 1인 레코드가 1000개, no=2인 레코드가 1000개 있다.

함수 호출이 no 값 순서대로 일어나도록 하려고 no 컬럼이 선두에 위치한 인덱스를 이용한다.

그러면 캐싱에는 최초 (1, 'YAMAHA') 가 캐싱된다.

```sql
select /*+index(t t_no_idx)*/ (select lookup(t.no) from dual)
from big_table t
where t.no > 0;
```

아직 no = 2인 첫 번째 레코드에 도달하지 않은 상태에서 다른 세션에서 아래 쿼리를 수행하면 이 순간 부터 lookup 함수의 출력 값은 'YAMAHA2'로 바뀐다.

```sql
update LookupTable set value = 'YAMAHA2'
commit;
```

이제 위 쿼리가 no=2 인 첫 번째 레코드에 도달하는순간 lookup 함수가 수행되면서 캐시에는 두 개의 엔트리가 저장된다

```sql
{(1,'YAMAHA', 'YAMAHA2')}
```

이제 Query Execution Cache는 일관성 없는 상태에 놓이게 됐다.

쿼리 시작 시점을 기준으로 하면 아래와 같은 값들이 캐싱돼야한다,

```sql
{(1,'YAMAHA',)(2 'YAMAHA2')}
```

만약 쿼리가 진행중인 Current 기준이라면 다음과 같은 값이 캐싱돼야한다.

```sql
{(1,'YAMAHA2',)(2 'YAMAHA2')}
```

이런 일관성 없는 읽기는 사용자 정의 함수를 쓰는 한 완전히 피할 수 없는 현상이며 join 문 또는 스칼라서브쿼리를 써야만 해결된다.

```sql
select l.value
from big_table t, LookupTable l
where l.key(+) = t.no;

select (select value from LookupTable where key = t.no)
from big_table t
```

스칼라 서브쿼리는 별도의 SQL이 수행되는 것처럼 느껴지지만 스칼라서브쿼리는 조인의 또다른 형태로 메인 쿼리가 시작되는 시점을 기준으로

블록을 읽기 때문에 읽기 일관성을 보장한다.

DETERMINISTIC 키워드는 함수가 일관성 없는 데이터를 출력해 그 인덱스를 사용한 쿼리가 잘못된 결과를 내는 일이 발생하더라도 오라클의 책임이 아님을 도장찍는것과 다름없다.

실무적으로 사용되는 사용자정의 함수 대부분은 쿼리문을 포함하는 형ㅇ태이므로 오라클 읽기 일관성 모델 특성상 Deterministic 함수 일 수 없다.

update 문으로 반정규화 컬럼을 갱신하거나 insert 문으로 가공 테이블에 레코드를 삽입할 때도 중간에 값이 변경되면 일관성 없는 상태로 값들이 영구 저장될 수 있다.

따라서 캐싱 효과를 얻으려고 함부로 사용해선 아노디다.
