/*  

테이블
   CONSULT_NO       NUMBER       -- 상담번호
   CONSULTANT_ID   VARCHAR2(4)    -- 상담자 아이디
   con_dt            VARCHAR2(8) -- 상담일자
   CON_TM           VARCHAR2(4) -- 상담시간
   RSLT_CD          VARCHAR2(4)  -- 상담처리 결과 0800(진행),  0900(완료)
   AFTRSLT_CD          VARCHAR2(2)  -- 사후처리 결과 11(보류), 21(부서이관)
   CUST_ID                       -- 고객ID
   
1) 아래 요건에 맞는 쿼리를 작성하세요.
   - 조건 : 상담자 아이디가 바인드변수로 제공
   - 상담자가 당월 1일 00시부터 현재일자 12시까지 상담한 정보를 조회하고자 한다.
     예) 오늘이 9월22일 일경우 => 2014.09.01 00:00 ~ 2014.09.22  12:00 
   - 조회 정보
          - 해당 상담자가 상담한 건수, 
          - 상담처리 결과가 완료된 건수, 
          - 사후처리가 부서이관된 건수(상담처리 결과는 완료된 건)
          - Unique한 상담 고객 수

2) 인덱스를 구성하세요.
  상담 테이블에서 상담일자로 월별 파티션이 되어 있다.  위 쿼리를 기준으로 가장 
  최적화된 인덱스를 구성하세요.  
  단,  테이블은 60개월분만 유지한다.  즉, 매달 1일 60개월 이전 데이터는 빠르게
  삭제 되어야 한다.
  
  - 인덱스 구성 칼럼? CONSULTANT_ID + COUNT_DT + CON_TM
  - 파티션 KEY 칼럼? COUNT_DT
  - LOCAL / GLOBAL 인덱스 선택 LOCAL
  - GLOBAL 인데스 일 경우 파티션 키 기준 (년, 월, 일 기타 등등)
 */

 SELECT COUNT(*), 
 NVL(SUM(CASE WHEN RSLT_CD = '0900' THEN 1 END), 0),
 NVL(SUM(CASE WHEN RSLT_CD = '0900' AND AFTRSLT_CD = '21' THEN 1 END), 0),
 COUNT(DISTINCT CUST_ID)
 FROM T_CONSULT55 A
 WHERE CONSULTANT_ID = 'T107';
 AND COUNT_DT BETWEEN TO_CHAR(SYSDATE,'YYYYMM') || '01' AND TO_CHAR(SYSDATE, 'YYYYMMDD')   
 AND  CON_DT || CON_TM <= TO_CHAR(SYSDATE, 'YYYYMMDD') || '1200' 



SELECT CON_DT, CON_TM
FROM T_CONSULT55 A
WHERE CONSULTANT_ID = 'T107'
AND CON_DT || CON_TM BETWEEN TO_CHAR(SYSDATE, 'YYYYMM') + '010000' AND TO_CHAR(SYSDATE, 'YYYYMMDD') + '1200'
 
T107

SELECT CONSULTANT_ID, COUNT(*)
FROM T_CONSULT55 A
WHERE CON_DT + CON_TM BETWEEN TO_CHAR(SYSDATE, 'YYYYMM') + '010000' AND TO_CHAR(SYSDATE, 'YYYYMMDD') + '1200'
GROUP BY CONSULTANT_ID;