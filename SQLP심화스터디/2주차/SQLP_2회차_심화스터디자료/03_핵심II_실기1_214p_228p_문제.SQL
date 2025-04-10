아래 SQL을 힌트 내용대로 실행할 때의 실행계획을 작성하시오.
(※ 아래 오퍼레이션 유형 활용 - 1개 이상 중복하여 사용 가능)

[인덱스 구성]
계좌_PK : 계좌번호 
계좌_X1 : 개설일자 
고객변경이력_PK : 고객번호 + 변경일시

[SQL]
SELECT /*+ ORDERED USE_NL(C) INDEX(A) INDEX(C) */
       A.계좌번호, A.계좌명, A.고객번호, C.고객명, C.고객상태코드, C.변경일시 
  FROM 계좌 A, 고객변경이력 C 
 WHERE A.개설일자 = :OPEN_DT 
   AND C.고객번호 = A.고객번호 
   AND C.변경일시 = (SELECT /*+ NO_UNNEST PUSH_SUBQ */ 
                            MAX(변경일시)
                       FROM 고객변경이력 H 
					  WHERE H.고객번호 = A.고객번호 
                        AND H.고객상태코드 <> 'K28')

[오퍼레이션 유형]
NESTED LOOPS 
VIEW 
TABLE ACCESS (BY INDEX ROWID) OF '테이블명'
TABLE ACCESS (FULL) OF '테이블명'
INDEX (UNIQUE SCAN) OF '인덱스명'
INDEX (RANGE SCAN) OF '인덱스명'
SORT (AGGREGATE)
COUNT (STOPKEY)