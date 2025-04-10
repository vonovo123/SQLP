exec dbms_stats.gather_table_stats(user,'고객27', cascade=>true);
exec dbms_stats.gather_table_stats(user,'거래27', cascade=>true);

select * 
  from dbms_xplan.display_cursor(null,null,'allstats last -rows outline alias predicate');
   
select /*+ gather_plan_statistics opt_param('_optimizer_adaptive_plans','false') full(c) */
       count(*)
from   고객27 c
where  c.가입일시 < trunc(add_months(sysdate,-1))
and    not exists (
         select /*+ unnest hash_aj index_ffs(거래27 ORDER27_PK) */
                'x'
		 from   거래27
		 where 고객번호 = c.고객번호
		 --and    rownum <= 1
       )
;

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation              | Name       | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |            |      1 |      1 |00:00:01.13 |   49200 |       |       |          |
|   1 |  SORT AGGREGATE        |            |      1 |      1 |00:00:01.13 |   49200 |       |       |          |
|*  2 |   HASH JOIN ANTI       |            |      1 |     63 |00:00:01.13 |   49200 |    53M|  9891K|   55M (0)|
|*  3 |    TABLE ACCESS FULL   | 고객27     |      1 |   1000K|00:00:00.05 |   10011 |       |       |          |
|   4 |    INDEX FAST FULL SCAN| ORDER27_PK |      1 |     10M|00:00:05.52 |   39189 |       |       |          |
-----------------------------------------------------------------------------------------------------------------
 
Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------
 
   1 - SEL$5DA710D3
   3 - SEL$5DA710D3 / C@SEL$1
   4 - SEL$5DA710D3 / 거래27@SEL$2
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.2.0.1')
      DB_VERSION('12.2.0.1')
      OPT_PARAM('_px_adaptive_dist_method' 'off')
      OPT_PARAM('_optimizer_strans_adaptive_pruning' 'false')
      OPT_PARAM('_optimizer_nlj_hj_adaptive_join' 'false')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$5DA710D3")
      UNNEST(@"SEL$2")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      FULL(@"SEL$5DA710D3" "C"@"SEL$1")
      INDEX_FFS(@"SEL$5DA710D3" "거래27"@"SEL$2" ("거래27"."고객번호" "거래27"."거래일시"))
      LEADING(@"SEL$5DA710D3" "C"@"SEL$1" "거래27"@"SEL$2")
      USE_HASH(@"SEL$5DA710D3" "거래27"@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("고객번호"="C"."고객번호")
   3 - filter("C"."가입일시"<TRUNC(ADD_MONTHS(SYSDATE@!,-1)))
   
   
-- 본인이 작성한 쿼리도 테스트하고, 아래의 쿼리도 테스트 해보세요
-- 아래는 안돌아감 확인해 보세요
select count(*)
from   고객27 c
where  c.가입일시 < trunc(add_months(sysdate,-1))
and    not exists (
         select /*+ full(거래27) */
                'x'
		 from   거래27
		 where 고객번호 = c.고객번호
		 and    rownum <= 1
       )
;


select /*+ gather_plan_statistics opt_param('_optimizer_adaptive_plans','false') full(c) */
       count(*)
from   고객27 c
where  c.가입일시 < trunc(add_months(sysdate,-1))
and    not exists (
         select /*+ unnest hash_aj index_ffs(거래27 ORDER27_PK) */
                'x'
		 from   거래27
		 where 고객번호 = c.고객번호
		 and    rownum <= 1
       )
;    