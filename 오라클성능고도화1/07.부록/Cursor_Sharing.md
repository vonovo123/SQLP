바인드 변수의 사용원칙을 지키지 않으면 시스템정상 가동이 어렵다.

라이브러리 캐시 경합을 일시적으로 해결하기 위해 cursor_sharing 파라미터를 변경하는 것을 고려해 볼 수 있다.

```sql
create table emp
as
select * from scott.emp;

create index emp_empno_idx on emp(empno);

analyze table emp compute statistics
for table for all indexs for columns empno size 1;

show parameter cursor_sharing

alter session set cursor_sharing = FORCE;

alter system flush shared_pool;

declare
  l_condition varchar2(20);
  l_ename emp.ename%type;
  begin
    for c in (select empno from emp)
    loop
      l_condition := 'empno = ' || c.empno;
    execute immediate
      'select ename ' || 'from emp where ' || l_condition
    into l_ename;

    dbms_output.put_line(l_condition || ':' || l_ename)
    end loop;
  end
```

바인드 변수를 사용했을 때처럼 하나의 공유 커서가 반복 사용됐다.

세션 레벨에서 cursor_sharing 파라미터를 FORCE로 바꿨기 때문이다.

이 파라미터의 기본값은 EXACT 이고 이때는 SQL 문이 100% 같을때만 커서를 공유할 수 있다.

FORCE로 바꾸면, 어떤 값으로 실행하든 항상 같은 실행계획을 사용한다.

EXACT 일 때보다 라이브러리 캐시 부하는 상당히 줄겠지만 칼럼 히스토리를 사용하지 못하기 때문에 성능이 더 나빠질 가능성이 있다.

이는 바인드 변수를 사용할 때 나타나는 부작용이기도 하다.

단점을 회피할 목적으로 값을 SIMILAR로 설정할 수 있는데, 실행되는 Literal 값에 따라 별도의 커서를 생성함으로써 다른 실행게획을 사용할 수 있게 된다.

```sql
alter system flush shared_pool;

ater session set cursor_sharing = SIMILAR;

declare
  l_condition varchar2(20);
  ...
  end;
/
```

empno 컬럼에 대한 히스토그램이 없기 때문에 Similar로 설정해도 Force 일 때와 같은 방식으로 작동한다.
.

값 분포가 균등하지 않은 컬럼에 대해서는 히스토그램을 만들어 옵티마이저가 좋은 실행계획을 만들도록 돕는다면 유용하다.

라이브러리 캐시 효율에는 도움이 되지 않는다.

Similar일 때, 히스토그램을 생성해 둔 컬럼에 값의 종류가 아주 많으면 수행시간이 증가한다.

```sql
analyze table t computer statistics
for table for all indexes for all columns size 100;

alter system flush shared_pool;

declare
  l_cnt number;
begin
  for i in 1..10000
  loop
    execute immediate
        'select /* similar*/ count(*) from t where no = ' || i
    into l_cnt;
  end loop;
end
```

히스토그램을 생성했으므로 각 입력값별로 Child 커서를 만들어야 했고, 이것은 아래처럼 매번 하드파싱할 때보다 더 나쁜 겨로가를 초래한다.

```sql
alter session set cursor_sharing = EXACT;

begin
  for i in 1..10000
  loop
    execute immediate
        'select /* similar*/ count(*) from t where no = ' || i
    into l_cnt;
  end loop;
end

```

정상적으로 바인드 변수를 상ㅇ하면 최적으로 수행된다.

```sql
declare
  l_cnt number;
begin
  for i in 1..10000
  loop
    execute immediate
        'select /* bind*/ count(*) from t where no = :no'
    into l_cnt
    using i;
  end loop;
end

```

Similar 방식은 과도한 Share pool과 라이브러리 캐시 래치 경합이 발생하여 정상적인 서비스가 어려울때 임시로 사용할 수 있는방식이다.

이 옵션을 사용하면 기존 실행계획이 틀어져 이전보다 더 느리게 수행되는 쿼리들이 속출하게될 가능성이 높다.
