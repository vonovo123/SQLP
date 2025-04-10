DROP TABLE 고객27 PURGE;

CREATE TABLE 고객27
(
  고객번호 VARCHAR2(9),
  고객명 VARCHAR2(30),
  가입일시 DATE,
  관리사원번호 VARCHAR2(4),
  전화번호 VARCHAR2(11),
  고객구분코드 VARCHAR2(2),
  최종주문금액 NUMBER(12),
  CONSTRAINT CUSTOMER27_PK PRIMARY KEY(고객번호)
) NOLOGGING
;

INSERT /*+ APPEND */ INTO 고객27
SELECT 
    'C'||TO_CHAR(ROWNUM, 'FM00000009') 고객번호,
    'C_'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,5000),-1), 'FM0009')
        ||TO_CHAR(ROWNUM, 'FM00000009')
        ||'_고객명'                                           고객명,
    TO_CHAR(SYSDATE - DBMS_RANDOM.VALUE(0,365*10),'YYYYMMDDHH24MISS') 가입일시,
    TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1,9999),-2),'FM0009')     관리사원번호,
    '010'||
    TO_CHAR(DBMS_RANDOM.VALUE(1,9999),'FM0009')||
    TO_CHAR(DBMS_RANDOM.VALUE(1,9999),'FM0009')               전화번호,
	TO_CHAR(DBMS_RANDOM.VALUE(1,5),'FM09')                    고객구분코드,       -- 01 개인 02 법인 03 사업자 04 영리단체 05 비영리단체 
    ROUND(DBMS_RANDOM.VALUE(5000, 1000000), -3)               최종주문금액
  FROM DUAL
CONNECT BY LEVEL <= 1000000
;

COMMIT;

select * from 고객27;

EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, '고객27');

CREATE TABLE 거래27
(
  고객번호 VARCHAR2(9) NOT NULL,
  거래일시 DATE NOT NULL,
  거래일자 VARCHAR2(8) NOT NULL,
  상품번호 VARCHAR2(9) NOT NULL,
  거래담당자ID VARCHAR2(5) NOT NULL,
  거래지점ID VARCHAR2(4) NOT NULL
  -- CONSTRAINT ORDER27_PK PRIMARY KEY (고객번호, 거래일시)
) NOLOGGING
;

DECLARE
  V_DAY        NUMBER DEFAULT 1;        -- 데이터 생성일수 
  V_EXE_CNT    NUMBER DEFAULT 13700;    -- 일자별 로우수 
  V_DAYS_LIMIT NUMBER DEFAULT 365 * 2;  -- 총 발생 일수 
BEGIN
  -- 복제 단위 
  LOOP
  
     INSERT /*+ APPEND */ INTO 거래27
	 SELECT 
             'C'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1,1000000)),'FM00000009') 고객번호
	        , SYSDATE - DBMS_RANDOM.VALUE(V_DAY, V_DAY+1)         거래일시
			, TO_CHAR(TRUNC(SYSDATE - V_DAY), 'YYYYMMDD')         거래일자
	        , 'G'||LPAD(ROUND(DBMS_RANDOM.VALUE(1,999),0),5,'0')  상품번호
	        , 'D'||LPAD(ROUND(DBMS_RANDOM.VALUE(1,1500),0),4,'0') 거래담당자ID
	        , 'B'||LPAD(ROUND(DBMS_RANDOM.VALUE(1,1000),0),3,'0') 거래지점ID
	   FROM DUAL
     CONNECT BY LEVEL <= V_EXE_CNT
	 ;
     
     V_DAY := V_DAY + 1;
    
     COMMIT;

     EXIT WHEN V_DAY > V_DAYS_LIMIT;  -- 총 발생일수 까지	 
			
  END LOOP;
  
END;

ALTER TABLE 거래27 ADD CONSTRAINT ORDER27_PK PRIMARY KEY (고객번호, 거래일시);