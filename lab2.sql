--1.	Создать представления по описанию. 
--1.1.	Данные о сотрудниках: имя, должность, адрес (одной строкой), телефон, срок работы в месяцах.

create view employee_data as
select em.employee_name, nvl2(ch.employee_name, 'Курьер', 'Шеф') as post, 
concat( concat(concat(em.street, ', '), concat(em.house_number, ', кв. ')), em.apartment) as address,
trunc(abs(months_between(current_date, em.start_date)), 1) as term
from employees em
left join employees ch
	on ch.employee_id = em.chief_id;

	
--1.2.	Данные о заказах: номер заказа, номер заказчика, номер курьера, срок доставки общая стоимость заказа.

create view order_data as
select o.order_id, cs.customer_id, em.employee_id, o.end_date, sum(pr.price * od.quantity) as Price
from orders o 
inner join order_details od 
	on od.order_id = o.order_id
inner join products pr 
	on pr.product_id = od.product_id
inner join customers cs 
	on cs.customer_id = o.customer_id
inner join employees em 
	on em.employee_id = o.employee_id
group by o.order_id, cs.customer_id, em.employee_id, o.end_date
order by o.order_id;
	
--1.3.	Расширенные данные о заказе: номер заказа, имя курьера, имя заказчика, обща стоимость заказа, 
--строк доставки, отметка о том был ли заказа доставлен вовремя.

create view full_order_data as
select o.order_id, em.employee_name, cs.customer_name, sum(pr.price * od.quantity) as price, o.end_date,
case when o.delivery_date < o.end_date
	then 'Опоздал' else 'Вовремя'
end as delivery
from orders o
inner join employees em 
	on em.employee_id = o.employee_id
inner join customers cs 
	on cs.customer_id = o.customer_id
inner join order_details od 
	on od.order_id = o.order_id
inner join products pr 
	on pr.product_id = od.product_id 
group by o.order_id, em.employee_name, cs.customer_name, o.end_date, o.delivery_date
order by o.order_id;


-- 1.4.	Представление, позволяющее получить маршрут курьера.

create view trip as 
select em.employee_id, em.employee_name, o.end_date, a.areas_name, lc.street, lc.house_number --добавить дату
from orders o 
inner join employees em 
	on em.employee_id = o.employee_id
inner join locations lc 
	on lc.location_id = o.location_id
inner join areas a 
	on a.area_id = lc.area_id
group by em.employee_id, em.employee_name, o.end_date, a.areas_name, lc.street, lc.house_number
order by em.employee_id, o.end_date;

-- 2.	Создать ограничения по требованиям. 
-- 2.1.	Ни один заказ не может включать не известные продукты, доставляться не известным сотрудником, по не известному адресу.

alter table orders
add foreign key (employee_id) references employees(employee_id);
alter table orders 
add foreign key (location_id) references locations(location_id);
alter table order_details
add foreign key (product_id) references products(product_id);

-- 2.2.	Начальником может быть только реально существующий сотрудник.

alter table employees
add foreign key (chief_id) references employees(employee_id);

-- 2.3.	Цена товара не может быть отрицательной или нулевой.

alter table products
add constraint chk_prod_price check (price > 0);

-- 2.4.	Наименования категории, наименования продуктов,  имена сотрудников, 
--имена заказчиков, названия районов, названия улиц, номера домов не могут быть пустыми.

alter table products
modify (product_name varchar2(256) not null);
alter table categories
modify (categories_name varchar2(50) not null);
alter table employees
modify (employee_name varchar2(1000) not null);
alter table customers
modify (customer_name varchar2(200) not null);
alter table areas 
modify (areas_name varchar2(30) not null);
alter table locations
modify (street varchar2(100) not null, house_number varchar2(10) not null);

-- 2.5.	Поля “острая” и “вегетарианская” могут принимать только значения 1 или 0.

alter table products
add constraint chk_hv check ((hot in (0,1)) and vegetarian in (0,1));

-- 2.6.	Количество любого продукта в заказе не может быть отрицательным или превышать 100. 

alter table order_details
add constraint chk_quant check (quantity between 0 and 100);

-- 2.7.	Срок, к которому надо доставить заказ,  не может превышать дату и время заказа, 
-- заказ не может быть доставлен  до того как его сделали.

alter table orders
add constraint chk_del_time check (delivery_date>order_date);

-- 2.8.	Принимаются заказы только на 10 дней вперёд.

alter table orders 
add constraint chk_10_days check ((delivery_date - order_date)<=10*24);

-- 3.	Модифицировать схему базы данных согласно схеме stud_2. 
-- Для каждого сотрудника может быть указано несколько адресов.	

drop table contacts;
create table contacts( 
	contact_id number,
	location_id number,
	employee_id number,
	phone varchar2(1000),
	apartment number,
	primary key (contact_id),
	foreign key (employee_id)
		references employees(employee_id),
	foreign key (location_id)
		references locations(location_id));
insert into contacts(contact_id, employee_id, phone, apartment, location_id) 
	select distinct rank() over(order by em.employee_id) as contact_id, em.employee_id, em.phone, em.apartment, 
	min(lc.location_id) over(partition by employee_id) as location_id from employees em 
	inner join locations lc 
	on ((em.street = lc.street) and (em.house_number = lc.house_number))
	where (em.street = lc.street) and (em.house_number = lc.house_number);



