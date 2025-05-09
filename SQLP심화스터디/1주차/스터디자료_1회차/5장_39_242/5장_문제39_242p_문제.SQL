부분범위 처리가 가능한 상황에서 아래 SQL 을 최적화 하시오.
(쿼리를 그대로 둔 채 최적화 할 수 있다면 정확히 기술하고, 필요하다면 인덱스 재구성안도 제시할 것)

[테이블 구성]
-- 고객 테이블 
-- drop table 고객33 purge;

create table 고객39 nologging
as
select * from 고객27
;

-- 거래 테이블 1000,000건
-- drop table 거래39 purge;
create table 거래39
(
   고객번호 varchar2(9) not null
  ,거래일시 date not null
  ,거래금액 number(12) not null
)
nologging
;

[인덱스 구성]
고객_PK : 고객번호
고객_X1 : 가입일시
 
거래_PK : 고객번호 + 거래일시
거래_X1 : 거래일시
-- 거래_X2 : 고객번호 + 거래일시
-- select max(가입일시) from 고객39;

select c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select 고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-19), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;

--------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |     74 |00:00:00.09 |   13798 |       |       |          |
|   1 |  HASH GROUP BY      |      |      1 |     74 |00:00:00.09 |   13798 |   816K|   816K| 1368K (0)|
|*  2 |   HASH JOIN         |      |      1 |     74 |00:00:00.09 |   13798 |  1448K|  1448K| 1470K (0)|
|*  3 |    TABLE ACCESS FULL| 거래3|      1 |   5075 |00:00:00.03 |    3754 |       |       |          |
|*  4 |    TABLE ACCESS FULL| 고객3|      1 |  13793 |00:00:00.05 |   10044 |       |       |          |
--------------------------------------------------------------------------------------------------------