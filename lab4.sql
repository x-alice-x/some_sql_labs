-- 1. Написать триггер, активизирующийся при изменении  содержимого таблицы «Orders» и проверяющий, 
-- чтобы срок доставки был больше текущего времени  не менее чем на 30 минут. 
-- Если время заказа не указано автоматически должно проставляться текущее время, 
-- если срок доставки не указан, то он автоматически должен ставиться на час позже времени заказа. 

create view o_view as select * from orders;

create or replace trigger CheckDelivery
  before insert or update on orders
  for each row
  begin
    :new.order_date := nvl(:new.order_date, current_date); 
    :new.delivery_date := nvl(:new.delivery_date, :new.order_date + 1 / 24);
    if (:new.delivery_date - :new.order_date) < 30/24/60 then
      raise_application_error(-20001, 'Срок доставки должен быть больше текущего времени на 30 минут');
    end if;
  end CheckDelivery;


insert into orders(order_id, employee_id, location_id, delivery_date, order_date) values (767, 13, 3, null--to_date('2017.12.13 16:15','YYYY.MM.DD HH24:MI')
	,null);--to_date('2017.12.13 16:00', 'YYYY.MM.DD HH24:MI'));
select order_id, to_char(order_date, 'DD.MM.YY HH24:MI') as order_date, to_char(delivery_date, 'DD.MM.YY HH24:MI') as delivery_date 
from orders where order_id = 767; 


-- 2. Написать триггер, сохраняющий статистику изменений таблицы «EMPLOYEES» в таблице (таблицу создать), 
-- в которой хранятся номер сотрудника  дата изменения, тип изменения (insert, update, delete). 
-- Триггер также выводит на экран сообщение с указанием количества дней прошедших со дня последнего изменения.

drop table EmployStat;	
create table EmployStat(
	empl_id number,
	change_time date,
	change_type varchar2(10)
);

create or replace trigger EmployStatistic
	after delete or insert or update on employees 
	for each row
declare
	dat date;
	rezdate number;
begin
	if inserting then
		insert into EmployStat(empl_id, change_time, change_type) values(:new.employee_id, current_date, 'insert');
	elsif deleting then
		insert into EmployStat(empl_id, change_time, change_type) values(:new.employee_id, current_date, 'delete');
	elsif updating then
		insert into EmployStat(empl_id, change_time, change_type) values(:new.employee_id, current_date, 'update');
	end if;

	select max(change_time) into dat from EmployStat;
	rezdate := to_number(months_between(current_date, dat)*31);
	dbms_output.put_line('last change '||rezdate||' days ago');
end EmployStatistic;

begin 
	update employees
	set employee_id = 301 where employee_id = 2;
end;
insert into employees(employee_id) values(34);
select * from EmployStat;



-- 3. Добавить к таблице “ Orders ” не обязательное поле “ cipher”, которое должно заполняться автоматически согласно шаблону:  
-- <YYYYMMDD>- <номер район> - < номер заказа в рамках месяца>.  Номера не обязательно должны соответствовать дате заказа, 
-- если район не известен, то “ номер района” равен 0. 


alter table orders
  add cipher varchar2(16);

create or replace trigger ClmCipher
  after insert or update on orders
  for each row
  declare
    cph orders.cipher%type;
    ord_id orders.order_id%type;
  begin
    select rank() over(partition by extract(month from :new.order_date) order by order_date) into ord_id from orders;
    cph = concat(concat(concat(to_char(:new.order_date, '<YYYYMMDD>-'), nvl(:new.location_id, '0')), '-',) ord_id);
    update orders
    set cipher = cph
    where order_id = :new.order_id;
  end ClmCipher;


begin
	update orders
	set order_id = 750, order_date = to_date('13.12.2017'), location_id = 3 where order_id = 729;
end;
insert into orders(order_id, employee_id, order_date, location_id) values(753, 6, to_date('13.12.2017'), 3);

select cipher from orders where cipher is not null;

