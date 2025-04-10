아래 SQL을 튜닝하되, 원하는 방식으로 실행되도록(=절대 다른방식으로 실행되지 못하도록) 힌트를
정확히 기술하고, 필요시 인덱스 구성 방안도 제시하시오.

[인덱스 구성]
상품분류_PK : 상품유형코드
상품_PK : 상품번호
주문_PK : 고객번호 + 상품번호 + 주문일시
주문_X1 : 상품번호 + 주문일시

select count(distinct p.상품번호),
       sum(t.주문금액),
	   sum(t.주문수량),
	   round(avg(t.할인율),2)
  from 상품33 p, 주문33 t
 where t.상품번호 = p.상품번호 
   and t.주문일시 >= trunc(sysdate - 7)
   and exists (
       select 1
	     from 상품분류33 
	     where 상품유형코드 = p.상품유형코드 
          and 상품유형코드 = '01'
       )
;

create table 상품33 nologging
as
select *
  from 상품_12
;

alter table 상품33 add constraint pk_good primary key(상품번호);

drop table 상품분류33 purge;

create table 상품분류33 nologging
as
select distinct 상품유형코드
      ,상품유형코드||'_명' 상품유형명
  from 상품33 
;

alter table 상품분류33 add constraint pk_good_br primary key(상품유형코드);

create table 주문33
(
  고객번호 varchar2(6) not null,
  상품번호 varchar2(6) not null,
  주문일시 varchar2(13) not null,
  주문금액 number(12) not null,
  주문수량 number(9) not null,
  할인율 number(4,2) not null
) nologging
;

insert /*+ append */ into 주문33
select 'C'||to_char(round(dbms_random.value(1,1000)),'FM00009') 고객번호
      ,'G'||to_char(round(dbms_random.value(1,1000)),'FM00009') 상품번호
	  ,sysdate - dbms_random.value(1,365) 주문일시
	  ,round(dbms_random.value(1000,1000000),-2) 주문금액
	  ,round(dbms_random.value(1,100)) 주문수량
	  ,round(dbms_random.value(1,99),2) 할인율
  from dual 
connect by level <= 1000000
;

-- 중복제거 (1번 이상 수행할 수도 있음)
delete from 주문33
where rowid in (
select max(rowid)
  from 주문33
group by 고객번호, 상품번호, 주문일시 
having count(*) > 1
)
;

commit;

alter table 주문33 add constraint pk_ord33 primary key(고객번호, 상품번호, 주문일시);
create index x01_ord33 on 주문33(상품번호, 주문일시);

-- 아래 쿼리를 실행했을 경우 아래와 같이 실행계획이 표시 됩니다.
select count(distinct p.상품번호),
       sum(t.주문금액),
	   sum(t.주문수량),
	   round(avg(t.할인율),2)
  from 상품33 p, 주문33 t
 where t.상품번호 = p.상품번호 
   and t.주문일시 >= trunc(sysdate - 7)
   and exists (
       select 1
	     from 상품분류33 
	    where 상품유형코드 = p.상품유형코드 
          and 상품유형코드 = '01'
          --and 상위분류코드 = 'AK'  
       )
;

---------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name       | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |            |      1 |      1 |00:00:00.34 |    5732 |       |       |          |
|   1 |  SORT GROUP BY       |            |      1 |      1 |00:00:00.34 |    5732 |  4096 |  4096 | 4096  (0)|
|*  2 |   HASH JOIN          |            |      1 |   1218 |00:00:00.34 |    5732 |  2078K|  2078K| 1588K (0)|
|   3 |    NESTED LOOPS      |            |      1 |     68 |00:00:00.01 |      14 |       |       |          |
|*  4 |     INDEX UNIQUE SCAN| PK_GOOD_BR |      1 |      1 |00:00:00.01 |       1 |       |       |          |
|*  5 |     TABLE ACCESS FULL| 상품33     |      1 |     68 |00:00:00.01 |      13 |       |       |          |
|*  6 |    TABLE ACCESS FULL | 주문33     |      1 |  18819 |00:00:00.33 |    5718 |       |       |          |
---------------------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$5DA710D3
   4 - SEL$5DA710D3 / 상품분류33@SEL$2
   5 - SEL$5DA710D3 / P@SEL$1
   6 - SEL$5DA710D3 / T@SEL$1
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$5DA710D3")
      UNNEST(@"SEL$2")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      INDEX(@"SEL$5DA710D3" "상품분류33"@"SEL$2" ("상품분류33"."상품유형코드"))
      FULL(@"SEL$5DA710D3" "P"@"SEL$1")
      FULL(@"SEL$5DA710D3" "T"@"SEL$1")
      LEADING(@"SEL$5DA710D3" "상품분류33"@"SEL$2" "P"@"SEL$1" "T"@"SEL$1")
      USE_NL(@"SEL$5DA710D3" "P"@"SEL$1")
      USE_HASH(@"SEL$5DA710D3" "T"@"SEL$1")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("T"."상품번호"="P"."상품번호")
   4 - access("상품유형코드"='01')
   5 - filter("P"."상품유형코드"='01')
   6 - filter(INTERNAL_FUNCTION("T"."주문일시")>=TRUNC(SYSDATE@!-7))

주문
주문_01
주문_02
주문_04
주문_199
주문_200
주문_69
주문_70
주문_72
주문_P1
주문_PT2
주문상세_01
주문상세_PT2
주문상품110
주문상품52
주문상품_02
주문상품_52  