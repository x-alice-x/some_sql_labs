
-- 3.	Запросы
-- a.	Вывести абитуриентов, проживающих в Томске, имеющих медали, упорядочив результат по дате рождения.

select enrollee_name, enrollee_loc, medal 
	from enrollees
	where enrollee_loc = 'Томск' and medal not like 'нет'
	order by birth;


-- b.	Вывести список абитуриентов и название предметов, сданных более чем на 90 балов. 
-- Результат упорядочить по фамилиям абитуриентов

select enrollee_name, subject_name from enrollees enr 
	inner join exams ex 
		on ex.enrollee_id = enr.enrollee_id
	inner join subjects sub 
		on sub.subject_id = ex.subject_id
	where note >= 90
	order by enrollee_name;


-- c.	Найти средний проходной балл для каждого факультета.

select fac_name, trunc(avg(note)) from exams ex  
	inner join subjects sub 
		on sub.subject_id = ex.subject_id
	inner join spec_sub ss 
		on ss.subject_id = sub.subject_id
	inner join specials sp 
		on sp.spec_code = ss.spec_code
	group by sp.fac_name;


-- d.	Вывести абитуриентов, набравших максимальный балл (балл – сумма всех оценок абитуриента).

with sum_bal as(
	select enrollee_name, sum(note) as ball from exams ex 
		inner join enrollees enr 
			on enr.enrollee_id = ex.enrollee_id
		group by enr.enrollee_id, enrollee_name
)
select enrollee_name, ball from sum_bal 
	where ball = (select max(ball) from sum_bal);

--e.	Для каждого факультета определить количество абитуриентов, набравших проходной балл.

select fac_name, count(distinct enr.enrollee_id) from specials sp 
		inner join spec_sub ss 
			on ss.spec_code = sp.spec_code
		inner join subjects sub 
			on sub.subject_id = ss.subject_id
		inner join exams ex 
			on ex.subject_id = sub.subject_id
		inner join enrollees enr 
			on enr.enrollee_id = ex.enrollee_id
		group by fac_name, enr.enrollee_id, pass_score
		having count(*) = (select count(*) from specials sp1
								inner join spec_sub ss 
									on ss.spec_code = sp1.spec_code
								where sp.fac_name = sp1.fac_name
								group by fac_name)
		and sum(note) >= pass_score;

----------

--4.	Изменений данных 
--a.	Для всех абитуриентов из Томска сдвинуть дату экзамена по математике на одну неделю вперед.


update exams 
	set exam_date = exam_date + 7
	where enrollee_id in (select enr.enrollee_id from enrollees enr 
							inner join exams ex 
								on ex.enrollee_id = enr.enrollee_id
							inner join subjects sub 
								on sub.subject_id = ex.subject_id
							where enrollee_loc = 'Томск' and subject_name = 'Математика');

--b.	Удалить из базы абитуриентов, не сдававших экзамены.

delete from exams 
	where enrollee_id in (select enrollee_id from exams 
							group by enrollee_id
							having count(*) = (select count(*) from exams 
													where note < 50));

delete from enrollees 
	where enrollee_id in (select enrollee_id from exams
			where note is null);

--c.	Удалить из базы абитуриентов, не сдавших хотя бы один экзамен (т.е. оценка 50 балов).

delete from exams
	where enrollee_id in (select enrollee_id from exams
			where note < 50);

delete from enrollees
	where enrollee_id in (select enrollee_id from exams
			where note is null);

----------
-- 5.	Представления 
-- a.	Добавить в таблицу «Специальности» проходной бал, заполнить новое поле для всех специальностей. 
-- Для каждой специальности выдать список поступивших абитуриентов, результат оформить в виде представления.

alter table specials
	add pass_score number;

update specials
	set pass_score = 182
	where spec_code = 1;
update specials
	set pass_score = 207
	where spec_code = 2;
update specials
	set pass_score = 234
	where spec_code = 3;
update specials
	set pass_score = 203
	where spec_code = 4;
update specials
	set pass_score = 196
	where spec_code = 5;
update specials
	set pass_score = 170
	where spec_code = 6;

create or replace view entered_enrollees as
	select sp.fac_name, enr.enrollee_name, sum(note) as total_score, pass_score from specials sp 
		inner join spec_sub ss 
			on ss.spec_code = sp.spec_code
		inner join subjects sub 
			on sub.subject_id = ss.subject_id
		inner join exams ex 
			on ex.subject_id = sub.subject_id
		inner join enrollees enr 
			on enr.enrollee_id = ex.enrollee_id
		group by fac_name, enr.enrollee_name, pass_score
		having count(*) = (select count(*) from specials sp1
								inner join spec_sub ss 
									on ss.spec_code = sp1.spec_code
								where sp.fac_name = sp1.fac_name
								group by fac_name)
		and sum(note) >= pass_score;


-- b.	Для специальности «Прикладная математика и информатика» сформировать список поступивших абитуриентов, 
-- таких у которых сумма всех оценок выше проходного балла по специальности. 
-- Список оформить в виде представления, содержащего ФИО абитуриента, адрес и сумму оценок, результат отсортировать по убыванию суммы оценок.

create or replace view enterned_fpmk as
	select enrollee_name, enrollee_loc, sum(note) as total_score from specials sp 
		inner join spec_sub ss 
			on ss.spec_code = sp.spec_code
		inner join subjects sub 
			on sub.subject_id = ss.subject_id
		inner join exams ex 
			on ex.subject_id = sub.subject_id
		inner join enrollees enr 
			on enr.enrollee_id = ex.enrollee_id
		where fac_name = 'ФПМК'
		group by fac_name, enr.enrollee_name, enrollee_loc, pass_score
		having count(*) = (select count(*) from specials sp1
								inner join spec_sub ss 
									on ss.spec_code = sp1.spec_code
								where sp.fac_name = sp1.fac_name
								group by fac_name)
		and sum(note) >= pass_score
		order by sum(note) desc;



--6.	Создать индекс для таблицы “специальность_предмет ” содержащий 2 поля.

create index index_spec_sub on spec_sub
	(subject_id, spec_code);

-- 7.	Создать пакет, состоящий из процедуры и функций, включить обработчики исключительных ситуаций. 

create or replace package enrollees_pack
	as
	function exams_medals (med in varchar2) return number;
	function enrol_fac (fac in varchar2) return varchar2;
	procedure rez_exams;
end enrollees_pack;
/

create or replace package body enrollees_pack
	as

-- a.	Функция возвращает число абитуриентов, имеющих медали и сдавших все экзамены на «отлично»
-- (Наличие_медали (золотая, серебряная, любая) – параметр функции).	
	function exams_medals (med in varchar2)
		return number
	as 
		my_excp_med exception;
		countEnrol number;	
	begin 
		countEnrol := 0;
		if (med = 'любая') then 
			with m_any as
			(select count(enr.enrollee_id) as total_any 
				from enrollees enr 
					inner join exams ex 
						on ex.enrollee_id = enr.enrollee_id
					where (medal = 'золотая' or medal = 'серебряная')
					group by ex.enrollee_id
					having  sum(ex.note) = count(ex.note) * 100
				)
			select total_any into countEnrol 
				from m_any; 
		end if;
		if (med = 'серебряная') then
			with m_silver as
			(select count(enr.enrollee_id) as total_sil 
				from enrollees enr 
					inner join exams ex 
						on ex.enrollee_id = enr.enrollee_id
					where medal = 'серебряная' 
					group by ex.enrollee_id
					having  sum(ex.note) = count(ex.note) * 100
				)
			select total_sil into countEnrol
				from m_silver;
		end if; 
		if (med = 'золотая') then
			with m_gold as
			(select count(enr.enrollee_id) as total_gold 
				from enrollees enr 
					inner join exams ex 
						on ex.enrollee_id = enr.enrollee_id
					where medal = 'золотая'
					group by ex.enrollee_id
					having  sum(ex.note) = count(ex.note) * 100
				)
			select total_gold into countEnrol
				from m_gold; 
		end if;

		if (countEnrol = 0) then
		 	raise my_excp_med;
		end if;
	
	if countEnrol is null then 
		dbms_output.put_line('List is empty');
	end if;

	return countEnrol;

	exception
		when my_excp_med then
			dbms_output.put_line('Некорректные данные');

	end exams_medals;
-- begin 
-- 	dbms_output.put_line(exams_medals('золотая'));
-- end;
-- select exams_medals('любая') from dual;

--b.	Функция возвращает список абитуриентов поступавших на определённый факультет (Аргументы название факультета) 
--Формат вывода: ФИО абитуриента (сумма балов): названия предмета предметов через зяпятую.
	function enrol_fac (fac in varchar2)  --сделать норм вывод
		return varchar2
	as
		cursor c1 is select enrollee_name, sum(note) 
						from specials sp 
						inner join spec_sub ss 
							on ss.spec_code = sp.spec_code
						inner join subjects sub 
							on sub.subject_id = ss.subject_id
						inner join exams ex 
							on ex.subject_id = sub.subject_id
						inner join enrollees enr 
							on enr.enrollee_id = ex.enrollee_id
						where fac_name = fac 
						group by fac_name, enr.enrollee_name, enrollee_loc, pass_score
						having count(*) = (select count(*) from specials sp1
												inner join spec_sub ss 
													on ss.spec_code = sp1.spec_code
												where sp.fac_name = sp1.fac_name
												group by fac_name);
		cursor c2 is select subject_name from subjects sub 
						inner join spec_sub ss 
							on ss.subject_id = sub.subject_id
						inner join specials sp 
							on sp.spec_code = ss.spec_code
						where fac_name = fac;
		rezult varchar2(1000);
		rez1 varchar2(1000);
		enrolname enrollees.enrollee_name%type;
		total exams.note%type;
		subname subjects.subject_name%type;
	begin 
		open c1;
		fetch c1 into enrolname, total;
		open c2;
		fetch c2 into subname;
		if (c1%notfound or c2%notfound) then 
			dbms_output.put_line('List is empty');
		else                                                        
			loop 
				exit when c1%notfound;
				loop
					exit when c2%notfound;
					rez1 := rez1||subname||', ';
					fetch c2 into subname;
					
				end loop;
				rezult := rezult||enrolname||' ('||total||') '||': '||rez1||'; ';
				fetch c1 into enrolname, total;
				
			end loop;
		end if;
		close c1;
		close c2;
	return rezult;
	end enrol_fac;

	-- begin
	-- 	dbms_output.put_line(enrol_fac('ФПМК'));
	-- end;
	-- select enrol_fac('ФПМК') from dual;



--c.	Процедура выдает информацию по результатам всех экзаменов, сданных абитуриентами на «хорошо» и «отлично», 
--при условии, что оценок «хорошо» не более двух. 
--Формат вывода: ФИО абитуриента и список предметов и оценок, им сданных.

procedure rez_exams
as
	cursor cname is select enr.enrollee_id, enrollee_name, subject_id from enrollees enr 
						inner join exams ex 
							on ex.enrollee_id = enr.enrollee_id 
						order by enr.enrollee_id;
	cursor csub is select enrollee_id, subject_name, note from exams ex 
						inner join subjects sub 
							on sub.subject_id = ex.subject_id
						order by enrollee_id;
	cursor c4 is select count(*) from exams 
						where note between 70 and 99
						group by enrollee_id
						order by enrollee_id;
	cursor c5 is select enrollee_id, count(*) from exams 
						where note = 100
						group by enrollee_id
						order by enrollee_id;
	count4 number;
	count5 number;
	enrolname enrollees.enrollee_name%type;
	enrolid1 number;
	enrolid2 number;
	subid number;
	enrolid3 number;
	subname subjects.subject_name%type;
	pnote exams.note%type;
begin 
	open cname;
	open csub;
	open c4;
	open c5;
	fetch cname into enrolid1, enrolname, subid;
	fetch csub into enrolid3, subname, pnote;
	fetch c4 into count4;
	fetch c5 into enrolid2, count5;
	if (cname%notfound or csub%notfound or c4%notfound or c5%notfound) then
		dbms_output.put_line('List is empty');
	else 
		loop
			exit when (c4%notfound or c5%notfound or csub%notfound or cname%notfound);
			loop 
				exit when (count4 = 2 and count5 > 0) or (c4%notfound or c5%notfound);
				fetch c4 into count4;
				fetch c5 into enrolid2, count5;
			end loop;
			if c5%notfound then 
				dbms_output.put_line('List is empty');
			else 
				loop 
					if (enrolid1 = enrolid2) then 
						dbms_output.put_line(enrolname);
						loop
							if (enrolid1 = enrolid3) then
								dbms_output.put_line(subname||' ('||pnote||'), ');
							end if;
							exit when csub%notfound;
							fetch csub into enrolid3, subname, pnote;
						end loop;
					end if;
					exit when (cname%notfound) or (enrolid1 = enrolid2);
					fetch cname into enrolid1, enrolname, subid;
				end loop;
			end if;
		end loop;
	end if;
	close cname;
	close csub;
	close c4;
	close c5;
end rez_exams;

-- begin
-- 	rez_exams;
-- end;

-- select rez_exams from dual;

end enrollees_pack;

-----------
-- 8.	Создать триггеры, включить обработчики исключительных ситуаций. 
-- a.	Триггер, активизирующийся при изменении содержимого таблицы «Абитуриенты» и проверяющий корректность даты рождения и 
--корректность данных в поле Наличие_медали, допустимые значения: золотая, серебряная или нет.

create or replace trigger medals_trig
	before insert or update on enrollees
	for each row
begin
	if (:new.medal = 'золотая' or :new.medal = 'серебряная' or :new.medal = 'нет') then
		:new.medal := :new.medal;
	else 
		raise_application_error(-20001, 'Некорректные данные');
	end if;
end medals_trig;


update enrollees
	set medal = 'jgrd'
	where enrollee_id = 1;



-- b.	Триггер, сохраняющий статистику изменений таблицы «Экзамены» в таблице «Экзамены_Статистика», 
-- в которой хранится дата изменения, тип изменения (insert, update, delete). Триггер также выводит на экран сообщение с 
-- указанием количества дней прошедших со дня последнего изменения. 

create table ex_statistic(
	change_date date,
	change_type varchar2(20)
);

create or replace trigger ex_stat
after delete or insert or update on exams
	for each row
declare
	dat date;
	rezdate number;
begin
	if inserting then
		insert into ex_statistic(change_date, change_type) values(current_date, 'insert');
	elsif deleting then
		insert into ex_statistic(change_date, change_type) values(current_date, 'delete');
	elsif updating then
		insert into ex_statistic(change_date, change_type) values(current_date, 'update');
	end if;
	select max(change_date) into dat from ex_statistic;
	rezdate := to_number(months_between(current_date, dat)*31);
	dbms_output.put_line('last change '||trunc(rezdate)||' days ago');
end ex_stat;

update exams 
	set exam_id = 303 where exam_id = 302;
insert into exams(exam_id, note, exam_date) values(44, 68, to_date('22.07.2015', 'DD.MM.YYYY'));


