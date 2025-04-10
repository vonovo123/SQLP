아래 SQL을 힌트 내용대로 실행할 때의 실행계획을 작성하시오.
(※ 아래 오퍼레이션 유형 활용)

[인덱스 구성]
계좌_PK : 계좌번호 
계좌_X1 : 개설일자 
고객변경이력_PK : 고객번호 + 변경일시

CREATE TABLE 계좌_217
( 계좌번호    VARCHAR2(6) 	NOT NULL
 ,계좌명     VARCHAR2(50) 	NOT NULL
 ,고객번호   VARCHAR2(9)    NOT NULL
 ,개설일자    VARCHAR2(8) 	NOT NULL
 ,계좌유형코드 VARCHAR2(2) 	NOT NULL
 ,CONSTRAINT PK_계좌_217 PRIMARY KEY (계좌번호)
) NOLOGGING
;

-- INSERT 상품테이블
INSERT /*+ APPEND */ INTO 계좌_217
SELECT /*+ PARALLEL(4) */
       'G'||LPAD(TO_CHAR(LEVEL),5,'0')        		                   계좌번호
	  ,'GD_NM_'||LPAD(TO_CHAR(LEVEL),8,'0')     	                   계좌명
	  ,'C'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1,1000000)),'FM00000009')  고객번호
	  , TO_CHAR(TRUNC(SYSDATE - DBMS_RANDOM.VALUE(1,365)), 'YYYYMMDD') 개설일자
	  ,LPAD(ROUND(DBMS_RANDOM.VALUE(1, 10)),2,'0')	                   계좌유형코드
FROM DUAL
CONNECT BY LEVEL <= 100000
ORDER BY DBMS_RANDOM.VALUE() -- RNADOM하고 인서트 대신 삽입 속도는 느림 
;

COMMIT;

CREATE INDEX X1_계좌_217 ON 계좌_217(개설일자);

CREATE TABLE 고객_217
( 고객번호    VARCHAR2(9) 	NOT NULL
 ,고객명      VARCHAR2(50) 	NOT NULL
 ,고객상태코드   VARCHAR2(3)    NOT NULL
 ,가입일자     VARCHAR2(8) 	NOT NULL
 ,CONSTRAINT PK_고객_217 PRIMARY KEY (고객번호)
) NOLOGGING
;

-- INSERT 고객_217
INSERT /*+ APPEND */ INTO 고객_217
SELECT /*+ PARALLEL(4) */
	   'C'||TO_CHAR(LEVEL,'FM00000009')  고객번호
      ,'C_'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,5000),-1), 'FM0009')
          ||TO_CHAR(ROWNUM, 'FM00000009')
          ||'_고객명'                                           고객명
	 ,'K'||TO_CHAR(DBMS_RANDOM.VALUE(20,30), 'FM09')   고객상태코드
	 , TO_CHAR(TRUNC(SYSDATE - DBMS_RANDOM.VALUE(1,365)), 'YYYYMMDD') 가입일자
FROM DUAL
CONNECT BY LEVEL <= 100000
ORDER BY DBMS_RANDOM.VALUE() -- RNADOM하고 인서트 대신 삽입 속도는 느림 
;

COMMIT;

CREATE TABLE 고객변경이력_217
( 고객번호    VARCHAR2(9) 	NOT NULL
 ,변경일시    DATE 	NOT NULL
 ,고객명      VARCHAR2(50) 	NOT NULL
 ,고객상태코드   VARCHAR2(3)    NOT NULL
 ,가입일자     VARCHAR2(8) 	NOT NULL
 ,CONSTRAINT PK_고객변경이력_217 PRIMARY KEY (고객번호, 변경일시)
) NOLOGGING
;

INSERT /*+ APPEND */ INTO 고객변경이력_217
SELECT /*+ PARALLEL(4) */
      고객번호	  
	  , SYSDATE - DBMS_RANDOM.VALUE(1,365)  변경일시
	  ,고객명
	  ,고객상태코드
	  ,가입일자
  FROM 고객_217
;

COMMIT;

-- INSERT 고객변경이력_217
-- 5번 수행 COMMIT

INSERT /*+ APPEND */ INTO 고객변경이력_217
SELECT /*+ PARALLEL(4) */
	   'C'||TO_CHAR(LEVEL,'FM00000009')  고객번호
	  , SYSDATE - DBMS_RANDOM.VALUE(1,365)  변경일시
      ,'C_'||TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,5000),-1), 'FM0009')
          ||TO_CHAR(ROWNUM, 'FM00000009')
          ||'_고객명'                                           고객명
	 ,'K'||TO_CHAR(DBMS_RANDOM.VALUE(20,30), 'FM09')   고객상태코드
	 , TO_CHAR(TRUNC(SYSDATE - DBMS_RANDOM.VALUE(1,365)), 'YYYYMMDD') 가입일자
FROM DUAL
CONNECT BY LEVEL <= 100000
ORDER BY DBMS_RANDOM.VALUE()  -- RNADOM하고 인서트 대신 삽입 속도는 느림 
;

-- ROLLBACK;

COMMIT;


[SQL]
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌_217 A, 고객변경이력_217 C 
 WHERE A.개설일자 = :OPEN_DT 
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ MAX(변경일시)
                       FROM 고객변경이력_217 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28');						

[오퍼레이션 유형]
NESTED LOOPS 
VIEW 
TABLE ACCESS (BY INDEX ROWID) OF '테이블명'
TABLE ACCESS (FULL) OF '테이블명'
INDEX (UNIQUE SCAN) OF '인덱스명'
INDEX (RANGE SCAN) OF '인덱스명'
SORT (AGGREGATE)
COUNT (STOPKEY)