-- 1. Список домов по улице Дзержинского.
select street, house_number 
	from locations where street = 'Дзержинского';
	
-- 2. Список домов по улице Дзержинского и  Елизаровых в формате: улица, дом.
select street, house_number 
	from locations where street = 'Дзержинского' or street = 'Елизаровых';
	
-- 3. Cписок всех острых вегетарианских пицц.
select product_name 
	from products where hot = 1 and vegetarian = 1;
	
-- 4. Список всех острых пицц стоимостью до 500.
select product_name 
	from products where price 
	between 0 and 500;
	
-- 5. Список всех не острых и не вегетарианских пицц стоимостью до 490.
select product_name 
	from products where price 
	between 0 and 490 and hot = 0 and vegetarian = 0;

-- 6. Список домов по улице Белинского, исключая проезд Белинского, в формате: улица, дом.
select street, house_number 
	from locations where street 
	like '%Белинского' and street <> 'проез Белинского';
	
-- 7. Список полных имен, в которых есть две “е” и нет “c”.
select customer_name 
	from customers where customer_name 
	like '%е%е%' and customer_name not like '%с%';

-- 8. Список все улиц, на которых есть дома номер 1, 15, 16.
select street, house_number 
	from locations where house_number in ('1', '15', '16');
	
-- 9. Список все улиц, на которых есть дома номер с 1 по 17. 
select street, house_number 
	from locations where house_number between 1 and 17;

-- 10. Список все улиц, на которых нет домов номер с 10 по 30, и название которых начинается с “М” или “C”.
select street, house_number 
	from locations where (street like ('м%') or street 
	like ('с%')) and (house_number between '10' and '30');

-- 11. Список всех улиц, на которых есть дома не принадлежащие ни одному району.
select street 
	from locations where area_id is null; 

-- 12. Список заказов, которые были доставлены  в сентябре 2017-го. Список должен быть отсортирован.
select order_id, order_date 
	from orders where extract (month from order_date) = 9 and extract (year from order_date) = 2017 
	order by order_date asc;

-- 13. Список заказов, которые были доставлены  за последние 3 месяца. Список должен быть отсортирован. 
select order_id, order_date from orders
    where abs(months_between(order_date, current_date)) <= 3;

-- 14. Список заказов, которые были доставлены с 1 по 10 любого месяца. Список должен быть отсортирован.
select order_id, order_date from orders
    where extract (day from order_date) between 1 and 10;

-- 15. Список всех продуктов с их типами.
select pr.product_name, categories_name from products pr
    inner join categories ca
    on ca.category_id = pr.category_id;

-- 16. Все дома в Кировском районе.
select street, house_number, areas_name
     from locations lc
     inner join areas
     on areas.area_id = lc.area_id
     where areas_name = 'Кировский';

-- 17. Все дома в Кировском районе или не принадлежащие ни одному району. 
select street, house_number, areas_name
   from locations lc
   inner join areas a
   on a.area_id = lc.area_id
   where areas_name = 'Кировский' or areas_name is null;

-- 18. Все дома в Кировском районе или не принадлежащие ни одному району. 
-- Для домов, не принадлежащих ни одному району, в советующем столбце должно стоять  ‘нет’.
select lc.street, lc.house_number, nvl(a.areas_name, 'нет')
	from locations lc 
	inner join areas a
        on lc.area_id = a.area_id 
        where a.areas_name = 'Кировский' or a.area_id is null;

-- 19. Список имён всех страдников и с указанием имени начальника. 
-- Для начальников в соотв. столбце выводить – ‘шеф’.
select em.employee_name, nvl(ch.employee_name, 'шеф')
   from employees em
   left join employees ch
   on ch.employee_id = em.chief_id;

-- 20. Список всех заказов доставленных в советский район.
select o.order_id, ar.areas_name
	from orders o
	inner join locations loc 
	on o.location_id = loc.location_id
	inner join areas ar 
	on loc.area_id = ar.area_id and ar.areas_name = 'Советский';

-- 21. Список всех пицц, которые были доставлены в этом месяце.
select pr.product_name
	from products pr
	inner join categories ca 
	on ca.category_id = pr.category_id and ca.categories_name = 'Пицца'
	inner join order_details od 
	on pr.product_id = od.product_id
	inner join orders o 
	on od.order_id = o.order_id and extract(month from order_date) = extract(month from current_date);

-- 22. Список всех заказчиков, делавших заказ в октябрьском районе по улице Алтайской.
select c.customer_name, loc.street
	from customers c
	inner join orders o 
	on o.customer_id = c.customer_id
	inner join locations loc 
	on o.location_id = loc.location_id and loc.street = 'Алтайская'
	inner join areas ar 
	on loc.area_id = ar.area_id and ar.areas_name = 'Октябрьский';

-- 23. Список всех пицц, которые были доставлены под руководствам Козлова (или им самим). 
-- В списке также должны отображаться имя курьера и район (‘нет’ – если район не известен). 

    select pr.product_name, emp.employee_name, nvl(a.areas_name, 'нет')
	from orders o
	inner join employees emp
		on emp.employee_id = o.employee_id
        inner join order_details od
		on o.order_id = od.order_id
	inner join products pr
		on pr.product_id = od.product_id
	inner join categories ca
		on ca.category_id = pr.category_id
	inner join locations lc
		on o.location_id = lc.location_id
	left join areas a
		on lc.area_id = a.area_id 
	left join employees ch
  		on ch.employee_id = emp.chief_id
	where ca.categories_name = 'Пицца' and (emp.employee_name like '%Козлов' or ch.employee_name like '%Козлов');

-- --24.Список продуктов с типом, которые заказывали вместe с острыми или вегетарианскими пиццами в этом месяце.  

	select pr2.product_name, cat2.categories_name 
from order_details od 
inner join products pr 
		on od.product_id = pr.product_id 
inner join categories cat 
		on cat.category_id = pr.category_id 
inner join orders o 
		on o.order_id = od.order_id 
inner join order_details od2 
		on o.order_id = od2.order_id 
inner join products pr2 
		on od2.product_id = pr2.product_id 
inner join categories cat2 
		on cat2.category_id = pr2.category_id 
where extract (month from current_date)-1 = extract(month from o.end_date) 
and pr.hot = '1' or pr.vegetarian = '1' 
order by cat2.categories_name;

-- --25.Найти среднюю стоимость пиццы с точность до второго знака.  
	select trunc(avg(price), 2) from products;

-- --26. Для каждого заказа посчитать общее количество товаров в заказе, и количество позиций в заказе. 
-- Столбцы: номер заказа, общее количество, количество позиций.
	select order_id, sum(quantity), count(order_id)
	from order_details	
	group by order_id; 

-- --27. Для каждого заказа посчитать сумму заказа.
	select order_id, sum(pr.price * od.quantity)
	from order_details od
	inner join products pr
		on pr.product_id = od.product_id
	group by order_id;

-- --28. Для каждой пиццы найти общую сумму заказов.
	select product_name, sum(pr.price * od.quantity)
	from products pr
	inner join order_details od
		on od.product_id = pr.product_id
	inner join categories ca
		on ca.category_id = pr.category_id
	where ca.categories_name = 'Пицца'
	group by pr.product_id, pr.product_name;

-- --29. Составьте отчёт по суммам заказов за последние три  месяца
	select o.order_date, sum(pr.price * od.quantity), od.order_id
	from order_details od
	inner join orders o
		on o.order_id = od.order_id
	inner join products pr
		on pr.product_id = od.product_id
	where abs(months_between (o.order_date, current_date)) <= 3
	group by od.order_id, o.order_date;


-- --30. Найти всех заказчиков, которые сделали заказ одного  товара на сумму не менее 3000. 
--Отчёт должен содержать имя заказчика, номер заказа и стоимость.
	select cm.customer_name, o.order_id, sum(price * quantity)
	from customers cm 
	inner join orders o 
	on o.customer_id = cm.customer_id
	inner join order_details od 
	on od.order_id = o.order_id
	inner join products pr 
	on pr.product_id = od.product_id
	group by cm.customer_name, o.order_id
	having sum(price * quantity) >= 3000;


-- --31. Найти всех заказчиков, которые делали заказы во всех районах.
	select cm.customer_name
	from customers cm
	inner join orders o 
	on o.customer_id = cm.customer_id
	inner join locations lc 
	on lc.location_id = o.location_id
	inner join areas a 
	on a.area_id = lc.area_id
	group by cm.customer_name
	having count(distinct a.area_id) = (select count(*) from areas);
	
--32. Вывести все “чеки” (номер заказа, курьер, заказчик, стоимость заказа) для всех заказов, 
--сделанных в кировском районе и содержащих хотя бы 1 острую пиццу. 

select o.order_id, em.employee_name, cs.customer_name, sum(pr2.price * od.quantity)
	from orders o 
    inner join Order_Details od 
    	on o.order_id = od.order_id
    inner join products pr
    	on od.product_id = pr.product_id
    inner join employees em
    	on em.employee_id = o.employee_id
    inner join customers cs
    	on cs.customer_id = o.customer_id
    	inner join locations lc 
    	on o.location_id = lc.location_id
    inner join areas a 
    	on a.area_id = lc.area_id 
    inner join order_details od2 
		on od.order_id = od2.order_id 
	inner join products pr2 
		on od2.product_id = pr2.product_id 
    where pr.hot = '1' and lc.area_id = '1'
    group by o.order_id, em.employee_name, cs.customer_name;

-- 33. Для каждого заказа, в котором есть хотя бы 1 острая пицца  посчитать стоимость напитков.
	select o.order_id, sum(pr2.price) 
	from orders o 
	inner join order_details od 
		on o.order_id = od.order_id 
	inner join products pr 
		on od.product_id = pr.product_id 
	inner join order_details od2 
		on od.order_id = od2.order_id 
	inner join products pr2 
		on od2.product_id = pr2.product_id 
	where pr.hot = '1' and pr2.category_id = 2 
	group by o.order_id
	order by o.order_id;

-- 34. Найти сумму всех заказов сделанных по адресам, не относящимся ни к одному району. Использовать вариант решения с подзапросом.
  	select od.order_id, sum(pr.price * od.quantity)
  	from order_details od 
  	inner join products pr 
  		on pr.product_id = od.product_id
  	inner join orders o 
  		on o.order_id = od.order_id
  	where o.location_id in 
  		(
			select location_id from locations
			where area_id is null
        )
    group by od.order_id;

-- 35. Вывести номера и имена сотрудников ни разу не задержавших доставку более чем на полтора часа. 
-- Использовать вариант решения без групповых операций и DISTINCT
 	 select employee_id, employee_name
       from employees 
       where employee_id not in (
          select em.employee_id 
                 from employees em
                 inner join orders o 
                 on o.employee_id = em.employee_id
          where (o.end_date - o.delivery_date) <= 90*1/24/60 
       );


-- 36. Найти курьера выполнившего наибольшее число заказов.

with empl as
 ( 
	select employee_name, count(em.employee_id) as cnt
	from  employees em 
	inner join orders o 
		on o.employee_id = em.employee_id
	group by employee_name, em.employee_id
 )
select employee_name, cnt 
from empl
where cnt = (select max(cnt) from empl);	

-- 37. Найти курьера с наименьшим процентов заказов выполненных с задержкой
	
	with proz as 
	(
	select employee_name, (del/tot*100) as prozent
	from orders o 
	inner join employees em 
		on em.employee_id = o.employee_id
	inner join (
		select employee_id, count(order_id) as del  
		from orders 	
		where end_date>delivery_date
		group by employee_id) delay
			on delay.employee_id = em.employee_id
	inner join (
		select employee_id, count(order_id) as tot
		from orders
		group by employee_id) total
			on total.employee_id = em.employee_id
	group by employee_name, del, tot)
	select employee_name, prozent
	from proz
	where prozent = (select min(prozent) from proz);

-- 	38. Для каждого курьера найти число заказов, доставленных с задержкой, как процент от числа выполненных им заказов и  процент от общего числа заказов. 
-- Отчёт должен содержать имя курьера, количество заказов, количество и процент выполненных без задержки 

	 select employee_name, count(order_id) as count, (del/tot*100) as prozent, (del/(select count(*) from orders)*100) as total_prozent
	 from orders o 
	 inner join employees em 
	 	on em.employee_id = o.employee_id
	 inner join (
	 	select employee_id, count(order_id) as del  
	 	from orders 	
	 	where end_date>delivery_date
	 	group by employee_id) delay
	 		on delay.employee_id = em.employee_id
	 inner join (
	 	select employee_id, count(order_id) as tot
		from orders
	 	group by employee_id) total
	 		on total.employee_id = em.employee_id
	 group by employee_name, del, tot;


-- 39.	Для клиента найти дату и номер самого дорогого заказа.

	 with ord as
	 (
	 	select customer_name, o.order_id, order_date, sum(price * quantity) as total
	 	from orders o 
	 	inner join customers cs 
	 		on cs.customer_id = o.customer_id
	 	inner join order_details od 
	 		on od.order_id = o.order_id
	 	inner join products pr 
	 		on pr.product_id = od.product_id
	 	group by customer_name, order_date, o.order_id
	 )
	 select customer_name, order_id, order_date, total
	 from ord 
	 where total >= all(select total from ord ord1
	 						where ord.customer_name = ord1.customer_name)
	 order by customer_name;
-- 40. Для каждого старшего группы найти стоимость всех заказов, выполненных им самим или его подчинёнными.

	select chief_id, chief_name, sum(total_order_price) from ( 
        select em.employee_id as employee_id, em.chief_id as chief_id, em1.employee_name as chief_name, total_order_price
        from Employees em
        left join Employees em1 
        	on em.chief_id = em1.employee_id
        inner join Orders o
        	on o.employee_id = em1.employee_id
        inner join (
        	select o.employee_id as employee_id, sum(price * quantity) as total_order_price 
        	from Order_Details od
        	inner join Orders o 
        		on o.order_id = od.order_id
            inner join Products pr
            	on pr.product_id = od.product_id
            group by o.employee_id
                         ) ord 
        	on ord.employee_id = em.employee_id
) group by chief_id, chief_name
order by chief_id asc; 




	-- 	count_enrol := 1;
	-- 	if med = 'любая' then 
	-- 		open c_any;
	-- 		fetch c_any into x;
	-- 		if c_any%notfound then 
	-- 			dbms_output.put_line('List is empty');
	-- 		else 
	-- 			loop 
	-- 				exit when c_any%notfound;
	-- 				count_enrol := count_enrol + 1;
	-- 				fetch c_any into x;
	-- 			end loop;
	-- 		end if;
	-- 	end if;
	-- 	if med = 'серебряная' then 
	-- 		open c_silver;
	-- 		fetch c_silver into x;
	-- 		if c_silver%notfound then 
	-- 			dbms_output.put_line('List is empty');
	-- 		else 
	-- 			loop 
	-- 				exit when c_silver%notfound;
	-- 				count_enrol := count_enrol + 1;
	-- 				fetch c_silver into x;
	-- 			end loop;
	-- 		end if;
	-- 	end if;
	-- 	if med = 'золотая' then 
	-- 		open c_gold;
	-- 		fetch c_gold into x;
	-- 		if c_gold%notfound then 
	-- 			dbms_output.put_line('List is empty');
	-- 		else 
	-- 			loop 
	-- 				exit when c_gold%notfound;
	-- 				count_enrol := count_enrol + 1;
	-- 				fetch c_gold into x;
	-- 			end loop;
	-- 		end if;
	-- 	end if;
	-- 	return count_enrol;
	-- end;
