-- 1. Написать функцию,  возвращающую общую стоимость заказов сделанных заданным заказчиком за выбранный период.  
-- Если заказчик не указан или  не заданы, граница периода выводить сообщение об ошибке. 
-- Параметры функции: промежуток времени и номер заказчика.

create or replace function price_order (cust_id in number, date1 in date, date2 in date)
	return number
as
	my_excp_cust exception;
	my_excp_date exception;
	t number;
begin
	if cust_id is null then 
		raise my_excp_cust;
	end if;
	if date1 is null or date2 is null then
		raise my_excp_date;
	end if;

	with tot_price as
	(
		select customer_name, sum(pr.price * od.quantity) as total
		from customers cs
		inner join orders o
			on o.customer_id = cs.customer_id
		inner join order_details od 
			on od.order_id = o.order_id
		inner join products pr 
			on pr.product_id = od.product_id
		where (cs.customer_id = cust_id) and (o.order_date between date1 and date2)
		group by customer_name, od.order_id
	)
	select sum(total) into t
	from tot_price;

	dbms_output.put_line('Общая стоимость заказов = '|| t);

return t;

exception
		when my_excp_cust then
			dbms_output.put_line('Error: Customer_id is null');
		when my_excp_date then
			dbms_output.put_line('Error: Date is null');
end price_order;
/
begin
	dbms_output.put_line(price_order(1, to_date('04.04.2017'), to_date ('04.10.2017')));
end;

-- 2. Написать процедуру выводящую маршрут курьера в указанный день. 
-- Формат вывода: ФИО курьера и список адресов доставки в формате: “hh:MM  - адрес “ через  точку с запятой. 

create or replace procedure empl_trip (empl_id in number, day in date)
as
	cursor c1 is select end_date, lc.street, lc.house_number
					from orders o 
					inner join employees em 
						on em.employee_id = o.employee_id
					inner join locations lc 
						on lc.location_id = o.location_id
					where em.employee_id = empl_id and extract(day from end_date) = extract(day from day)
					and  extract(month from end_date) = extract(month from day) 
					and  extract(year from end_date) = extract(year from day)
					order by o.end_date;
	emplname employees.employee_name%type;
	emplstreet locations.street%type;
	emplhouse number;
	day1 date;
begin
	select employee_name into emplname from employees
		where employee_id = empl_id;
	dbms_output.put_line(emplname||': ');
	open c1;
	fetch c1 into day1, emplstreet, emplhouse;
	if c1%notfound 
		then dbms_output.put_line('Trip is empty');
	else
		loop 
			exit when c1%notfound;
			dbms_output.put_line(to_char(day1, 'HH24:MI')||' - '||emplstreet||', '|| emplhouse||'; ');
			fetch c1 into day1, emplstreet, emplhouse;
		end loop;
	end if;
	close c1;
end empl_trip;
/

begin
	empl_trip(1, to_date('18.07.2017'));
end;


-- 3. Написать процедуру формирующую список скидок по итогам заданного месяца (месяц считает от введенной даты). 
-- Условия:  скидка 10%  на самую часто заказываемую пиццу , скидка 5% на пиццу, которую заказали на самую большую сумму, 
-- 15% на пиццу, которые заказывали с  наибольшим числом напитков. 
-- Формат вывода: наименование – новая цена, процент скидки.   

create or replace procedure sale_month (mon in date)
as
	price10 number;
	price5 number;
	price15 number;
	prname10 products.product_name%type;
	prname5 products.product_name%type;
	prname15 products.product_name%type;

begin

	with prod10 as
	(
		select product_name, price, count(pr.product_id) as cnt 
		from order_details od 
		inner join products pr 
				on pr.product_id = od.product_id
		inner join orders o 
			on o.order_id = od.order_id
		where category_id = '1' and extract(month from order_date) = extract(month from mon)
		group by product_name, price, pr.product_id 
	)
	select product_name, price into prname10, price10 
	from prod10
	where cnt = (select max(cnt) from prod10);

	with prod5 as
	(
		select product_name, price, sum(pr.price * quantity) as prc 
		from order_details od 
		inner join products pr 
				on pr.product_id = od.product_id
		inner join orders o 
			on o.order_id = od.order_id
		where category_id = '1' and extract(month from order_date) = extract(month from mon)
		group by product_name, price, pr.product_id 
	)
	select product_name, price into prname5, price5 
	from prod5
	where prc = (select max(prc) from prod5);	

	with prod15 as
	(
		select pr.product_name, pr.price, count(pr2.product_id) as cnt 
		from order_details od 
		inner join products pr 
				on pr.product_id = od.product_id
		inner join orders o 
			on o.order_id = od.order_id
		inner join order_details od2
			on od2.order_id = od.order_id
		inner join products pr2
			on pr2.product_id = od2.product_id
		where pr.category_id = 1 and extract(month from order_date) = extract(month from mon)
		and pr2.category_id = 2
		group by pr.product_name, pr.price, pr2.product_id 
	)
	select product_name, price into prname15, price15 
	from prod15
	where cnt = (select max(cnt) from prod15);

	dbms_output.put_line(prname5||' - '||(price5*95/100)||'|5%');
	dbms_output.put_line(prname10||' - '||(price10*90/100)||'|10%');
	dbms_output.put_line(prname15||' - '||(price15*85/100)||'|15%');
end sale_month;
/

begin 
	sale_month(to_date('18.07.2017'));
end;
