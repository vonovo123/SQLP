문제> 부분범위 처리를 가능하도록 튜닝하시오.

create table 결제08
(
  결제번호 varchar2(10) not null,
  결제수단코드 varchar(2) not null,
  주문번호 varchar2(10) not null,
  결제금액 number(10) not null,
  결제일자 varchar2(8) not null,
  주문일자 varchar2(8) not null
) nologging;

alter table 결제08 add constraints pk_결제08 primary key(결제번호);

create index x1_결제08 on 결제08(주문번호, 결제수단코드);
create index x2_결제08 on 결제08(결제일자);
create index x3_결제08 on 결제08(주문일자);


select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 결제일자 = '20230701'
union
select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 주문일자 = '20230701'
;

--------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |      |      1 |    568 |00:00:00.01 |    1480 |       |       |          |
|   1 |  SORT UNIQUE        |      |      1 |    568 |00:00:00.01 |    1480 | 61440 | 61440 |55296  (0)|
|   2 |   UNION-ALL         |      |      1 |    568 |00:00:00.01 |    1480 |       |       |          |
|*  3 |    TABLE ACCESS FULL| 결제0|      1 |    268 |00:00:00.01 |     740 |       |       |          |
|*  4 |    TABLE ACCESS FULL| 결제0|      1 |    300 |00:00:00.01 |     740 |       |       |          |
--------------------------------------------------------------------------------------------------------