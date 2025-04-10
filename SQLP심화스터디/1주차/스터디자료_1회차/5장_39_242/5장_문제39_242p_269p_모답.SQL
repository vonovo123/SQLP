부분범위 처리가 가능한 상황에서 아래 SQL 을 최적화 하시오.
(쿼리를 그대로 둔 채 최적화 할 수 있다면 정확히 기술하고, 필요하다면 인덱스 재구성안도 제시할 것)

부분범위 처리가 가능한 상황에서 아래 SQL 을 최적화 하시오. 
(쿼리를 그대로 둔 체 최적화할 수 있다면 힌트를 정확히 기술하고, 
필요하다면 인덱스 재구성한도 제시할 것)

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

insert /*+ append */ into 거래39
select /*+ parallel(4) */
        'C'||to_char(dbms_random.value(1,1000000),'FM00000009') 고객번호,
        sysdate - dbms_random.value(1,730) 거래일시,
		round(dbms_random.value(1000,100000),-2) 거래금액       
  from dual
connect by level <= 1000000
;

commit;

exec dbms_stats.gather_table_stats(user, '거래39', cascade=>true);

[인덱스 구성]
고객_PK : 고객번호
고객_X1 : 가입일시
 
거래_PK : 고객번호 + 거래일시
거래_X1 : 거래일시
-- 거래_X2 : 고객번호 + 거래일시

exec dbms_stats.gather_table_stats(user, '거래39', cascade=>true);

alter table 고객39 add constraints PK_고객 primary key (고객번호);
alter table 거래39 add constraints PK_거래 primary key (고객번호, 거래일시);

create index X1_고객 on 고객39(가입일시);
create index X1_거래 on 거래39(거래일시);

-- select max(가입일시) from 고객39;


select c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select 고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-18), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;

--------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |     32 |00:00:00.08 |   13798 |       |       |          |
|   1 |  HASH GROUP BY      |      |      1 |     32 |00:00:00.08 |   13798 |   816K|   816K| 1361K (0)|
|*  2 |   HASH JOIN         |      |      1 |     32 |00:00:00.08 |   13798 |  1448K|  1448K| 1524K (0)|
|*  3 |    TABLE ACCESS FULL| 거래3|      1 |   5075 |00:00:00.03 |    3754 |       |       |          |
|*  4 |    TABLE ACCESS FULL| 고객3|      1 |   5247 |00:00:00.04 |   10044 |       |       |          |
--------------------------------------------------------------------------------------------------------

-- 모답
select /*+ leading(c) use_nl(t) push_pred(t) index(c (가입일시)) */
       c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select /*+ no_merge */
	           고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-18), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;

----------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name    | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |         |      1 |     32 |00:00:00.03 |   15729 |
|   1 |  NESTED LOOPS                           |         |      1 |     32 |00:00:00.03 |   15729 |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED   | 고객39  |      1 |   5247 |00:00:00.01 |    5188 |
|*  3 |    INDEX RANGE SCAN                     | X1_고객3|      1 |   5247 |00:00:00.01 |      17 |
|   4 |   VIEW PUSHED PREDICATE                 |         |   5247 |     32 |00:00:00.02 |   10541 |
|*  5 |    FILTER                               |         |   5247 |     32 |00:00:00.02 |   10541 |
|   6 |     SORT AGGREGATE                      |         |   5247 |   5247 |00:00:00.02 |   10541 |
|   7 |      TABLE ACCESS BY INDEX ROWID BATCHED| 거래39  |   5247 |     32 |00:00:00.01 |   10541 |
|*  8 |       INDEX RANGE SCAN                  | PK_거래 |   5247 |     32 |00:00:00.01 |   10509 |
----------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$1       
   2 - SEL$1        / C@SEL$1
   3 - SEL$1        / C@SEL$1
   4 - SEL$639F1A6F / T@SEL$1
   5 - SEL$639F1A6F
   7 - SEL$639F1A6F / 거래39@SEL$2
   8 - SEL$639F1A6F / 거래39@SEL$2
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$639F1A6F")
      PUSH_PRED(@"SEL$1" "T"@"SEL$1" 2)
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE(@"SEL$2")
      OUTLINE(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1" "C"@"SEL$1" ("고객39"."가입일시"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1" "C"@"SEL$1")
      NO_ACCESS(@"SEL$1" "T"@"SEL$1")
      LEADING(@"SEL$1" "C"@"SEL$1" "T"@"SEL$1")
      USE_NL(@"SEL$1" "T"@"SEL$1")
      INDEX_RS_ASC(@"SEL$639F1A6F" "거래39"@"SEL$2" ("거래39"."고객번호" "거래39"."거래일시"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$639F1A6F" "거래39"@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("C"."가입일시">=TRUNC(ADD_MONTHS(SYSDATE@!,-18),'fmmm'))
   5 - filter(COUNT(*)>0)
   8 - access("고객번호"="C"."고객번호" AND "거래일시">=TRUNC(SYSDATE@!,'fmmm'))
   
-- 테스트 1 
select /*+ leading(c) use_nl(t) push_pred(t) index(c (가입일시)) */
       c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select 
	           고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-18), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;

-- 테스트 2
select /*+ leading(c) use_nl(t) index(c (가입일시)) */
       c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select /*+ merge */
	           고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-18), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;

-- 테스트 3
select /*+ leading(t) use_nl(c)  */
       c.고객번호, c.고객명, t.평균거래, t.최소거래, t.최대거래
  from 고객39 c,
       (select /*+ no_merge */
	           고객번호, avg(거래금액) 평균거래, min(거래금액) 최소거래, max(거래금액) 최대거래 
         from 거래39
         where 거래일시 >= trunc(sysdate, 'mm')
        group by 고객번호) t
 where c.가입일시 >= trunc(add_months(sysdate,-18), 'mm')  -- 1개월 데이터
   and t.고객번호 = c.고객번호
;