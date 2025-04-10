create table 결제08
(
  결제번호 varchar2(10) not null,
  결제수단코드 varchar(2) not null,
  주문번호 varchar2(10) not null,
  결제금액 number(10) not null,
  결제일자 varchar2(8) not null,
  주문일자 varchar2(8) not null
) nologging;

insert /*+ append */ into 결제08
select dbms_random.string('U', 2)||to_char(dbms_random.value(1,99999999),'FM00000009') 결제번호
      ,'P'||to_char(dbms_random.value(1,9),'FM9') 결제수단코드
	  ,dbms_random.string('U', 2)||to_char(dbms_random.value(1,99999999),'FM00000009') 결제번호
	  ,round(dbms_random.value(10,100000),-2) 결제금액
	  ,to_char(sysdate - dbms_random.value(1,365),'yyyymmdd') 결제일자 
	  ,to_char(sysdate - dbms_random.value(1,365),'yyyymmdd') 주문일자        
  from dual 
connect by level <= 100000
;

select * from 결제08;

alter table 결제08 add constraints pk_결제08 primary key(결제번호);
create index x1_결제08 on 결제08(주문번호, 결제수단코드);
create index x2_결제08 on 결제08(결제일자);
create index x3_결제08 on 결제08(주문일자);