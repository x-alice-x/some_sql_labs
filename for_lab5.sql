-- 1.	Написать команды создания таблиц заданной схемы с указанием необходимых ключей и ограничений. 
-- Все ограничения должны быть именованными (для первичных ключей имена должны начинаться с префикса «PK_», 
-- для вторичного ключа – «FK_», проверки  - «CH_»). 
-- Ограничения: оценка должна лежать в границе 0-100.


drop table spec_sub;
drop table specials;
drop table exams;
drop table subjects;
drop table enrollees;

create table enrollees(
	enrollee_id number not null,
	enrollee_name varchar2(100) not null,
	enrollee_loc varchar2(50),
	birth date not null,
	medal varchar2(50),
	constraint PK_enrollees primary key(enrollee_id)
);


create table subjects(
	subject_id number not null,
	subject_name varchar2(50) not null,
	constraint PK_subject primary key(subject_id)
);


create table exams(
	exam_id number not null,
	note number not null,
	exam_date date not null,
	enrollee_id number,
	subject_id number,
	constraint PK_exam primary key(exam_id),
	constraint FK_enrollees foreign key (enrollee_id)
		references enrollees(enrollee_id),
	constraint FK_subject foreign key(subject_id)
		references subjects,
	constraint CH_note check (note between 0 and 100)
);

create table specials(
	spec_code number not null,
	fac_name varchar2(50) not null,
	phone varchar2(50),
	constraint PK_spec_code primary key(spec_code)
);

create table spec_sub(
	subject_id number not null,
	spec_code number not null,
	constraint PK_spec_code_sub primary key(spec_code, subject_id),
	constraint FK_subject_spec foreign key(subject_id)
		references subjects,
	constraint FK_spec_code foreign key(spec_code)
		references specials
);
------------------------------------------------------------------



insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(1, 'Елизавета Николаевна Чернышова', 'Виннипег', to_date('25.11.1998', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(2, 'Антон Валерьевич Атрошенко', 'Тайга', to_date('12.04.1996', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(3, 'Максим Александрович Дёмин', 'Томск', to_date('23.08.1997', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(4, 'Валерия Дмитриевна Ермина', 'Петрозаводск', to_date('19.10.1997', 'DD.MM.YYYY'), 'золотая');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(5, 'Анастасия Александровна Бородина', 'Санкт-Петербург', to_date('23.09.1997', 'DD.MM.YYYY'), 'серебряная');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(6, 'Алесандра Евгеньевна Скурлатова', 'Томск', to_date('16.06.1997', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(7, 'Юлия Петровна Жукова', 'Москва', to_date('08.06.1997', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(8, 'Ксения Анатольевна Кожевникова', 'Ярославль', to_date('25.01.1998', 'DD.MM.YYYY'), 'нет');
insert into enrollees(enrollee_id, enrollee_name, enrollee_loc, birth, medal)
		values(9, 'Александр Александрович Батраков', 'Томск', to_date('30.03.1997', 'DD.MM.YYYY'), 'золотая');
------------------------------------------------------
insert into subjects(subject_id, subject_name) 
	values (1, 'Математика');
insert into subjects(subject_id, subject_name) 
	values (2, 'Русский');
insert into subjects(subject_id, subject_name) 
	values (3, 'Информатика');
insert into subjects(subject_id, subject_name) 
	values (4, 'Литература');
insert into subjects(subject_id, subject_name) 
	values (5, 'История');
insert into subjects(subject_id, subject_name) 
	values (6, 'Обществознание');
insert into subjects(subject_id, subject_name) 
	values (7, 'Биология');	
insert into subjects(subject_id, subject_name) 
	values (8, 'Ин. язык');
insert into subjects(subject_id, subject_name) 
	values (9, 'Химия');
-------------------------------------------------------
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(1, 60, to_date('27.05.2015', 'DD.MM.YYYY'), 1, 1);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(2, 89, to_date('03.06.2015', 'DD.MM.YYYY'), 1, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(3, 77, to_date('10.06.2015', 'DD.MM.YYYY'), 1, 3);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(4, 57, to_date('27.05.2015', 'DD.MM.YYYY'), 2, 1);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(5, 77, to_date('03.06.2015', 'DD.MM.YYYY'), 2, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(6, 90, to_date('16.06.2015', 'DD.MM.YYYY'), 2, 7);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(7, 46, to_date('23.06.2015', 'DD.MM.YYYY'), 3, 1);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(8, 79, to_date('22.06.2015', 'DD.MM.YYYY'), 3, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(9, 70, to_date('29.05.2015', 'DD.MM.YYYY'), 3, 9);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(10, 59, to_date('24.05.2015', 'DD.MM.YYYY'), 4, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(11, 93, to_date('15.06.2015', 'DD.MM.YYYY'), 4, 5);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(12, 89, to_date('14.06.2015', 'DD.MM.YYYY'), 4, 6);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(13, 90, to_date('27.05.2015', 'DD.MM.YYYY'), 5, 5);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(14, 100, to_date('10.06.2015', 'DD.MM.YYYY'), 5, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(15, 96, to_date('17.06.2015', 'DD.MM.YYYY'), 5, 8);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(16, 76, to_date('30.05.2015', 'DD.MM.YYYY'), 6, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(17, 79, to_date('13.06.2015', 'DD.MM.YYYY'), 6, 8);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(18, 86, to_date('23.06.2015', 'DD.MM.YYYY'), 6, 4);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(19, 60, to_date('27.05.2015', 'DD.MM.YYYY'), 7, 1);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(20, 78, to_date('24.05.2015', 'DD.MM.YYYY'), 7, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(21, 73, to_date('30.05.2015', 'DD.MM.YYYY'), 7, 3);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(22, 97, to_date('12.05.2015', 'DD.MM.YYYY'), 8, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(23, 89, to_date('23.05.2015', 'DD.MM.YYYY'), 8, 5);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(24, 79, to_date('20.06.2015', 'DD.MM.YYYY'), 9, 2);
insert into exams(exam_id, note, exam_date, enrollee_id, subject_id)
	values(25, 83, to_date('16.06.2015', 'DD.MM.YYYY'), 9, 4);
----------------------------------------------------------------------
insert into specials(spec_code, fac_name, phone)
	values(1, 'ФПМК', '35-78-23');
insert into specials(spec_code, fac_name, phone)
	values(2, 'ФИЯ', '79-35-75');
insert into specials(spec_code, fac_name, phone)
	values(3, 'МО', '34-57-36');
insert into specials(spec_code, fac_name, phone)
	values(4, 'ФЖ', '67-46-84');
insert into specials(spec_code, fac_name, phone)
	values(5, 'ХИМ', '67-23-75');
insert into specials(spec_code, fac_name, phone)
	values(6, 'ГГФ', '57-35-58');
-------------------------------------------------------------------------
insert into spec_sub(spec_code, subject_id)
	values(1, 1);
insert into spec_sub(spec_code, subject_id)
	values(1, 2);
insert into spec_sub(spec_code, subject_id)
	values(1, 3);
insert into spec_sub(spec_code, subject_id)
	values(2, 2);
insert into spec_sub(spec_code, subject_id)
	values(2, 5);
insert into spec_sub(spec_code, subject_id)
	values(2, 8);
insert into spec_sub(spec_code, subject_id)
	values(3, 2);
insert into spec_sub(spec_code, subject_id)
	values(3, 5);
insert into spec_sub(spec_code, subject_id)
	values(3, 8);
insert into spec_sub(spec_code, subject_id)
	values(4, 2);
insert into spec_sub(spec_code, subject_id)
	values(4, 4);
insert into spec_sub(spec_code, subject_id)
	values(5, 2);
insert into spec_sub(spec_code, subject_id)
	values(5, 7);
insert into spec_sub(spec_code, subject_id)
	values(5, 9);
insert into spec_sub(spec_code, subject_id)
	values(6, 2);
insert into spec_sub(spec_code, subject_id)
	values(6, 7);
-------------------------------------------------------------------------
