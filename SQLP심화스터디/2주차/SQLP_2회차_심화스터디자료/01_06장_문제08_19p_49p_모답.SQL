select * from dbms_xplan.display_cursor(null,null,'allstats last -rows outline predicate alias');

-- 결제일자 not null 일 경우
select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 결제일자 = '20230701'
union all
select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 주문일자 = '20230701'
   and 결제일자 <> '20230701'
;

----------------------------------------------------------------------------
| Id  | Operation          | Name | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |    568 |00:00:00.01 |    1491 |
|   1 |  UNION-ALL         |      |      1 |    568 |00:00:00.01 |    1491 |
|*  2 |   TABLE ACCESS FULL| 결제0|      1 |    268 |00:00:00.01 |     745 |
|*  3 |   TABLE ACCESS FULL| 결제0|      1 |    300 |00:00:00.01 |     746 |
----------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SET$1
   2 - SEL$1 / 결제08@SEL$1
   3 - SEL$2 / 결제08@SEL$2
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SET$1")
      FULL(@"SEL$2" "결제08"@"SEL$2")
      FULL(@"SEL$1" "결제08"@"SEL$1")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("결제일자"='20230701')
   3 - filter(("주문일자"='20230701' AND "결제일자"<>'20230701'))

-- 결제일자 null 경우
select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 결제일자 = '20230701'
union all
select 결제번호, 결제수단코드, 주문번호, 결제금액, 결제일자, 주문일자
  from 결제08
 where 주문일자 = '20230701'
   and (결제일자 <> '20230701' or 결제일자 is not null)  -- 함수?
;
lnnvl(
----------------------------------------------------------------------------
| Id  | Operation          | Name | Starts | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |    568 |00:00:00.01 |    1491 |
|   1 |  UNION-ALL         |      |      1 |    568 |00:00:00.01 |    1491 |
|*  2 |   TABLE ACCESS FULL| 결제0|      1 |    268 |00:00:00.01 |     745 |
|*  3 |   TABLE ACCESS FULL| 결제0|      1 |    300 |00:00:00.01 |     746 |
----------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SET$1
   2 - SEL$1 / 결제08@SEL$1
   3 - SEL$2 / 결제08@SEL$2
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SET$1")
      FULL(@"SEL$2" "결제08"@"SEL$2")
      FULL(@"SEL$1" "결제08"@"SEL$1")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("결제일자"='20230701')
   3 - filter("주문일자"='20230701')