create table if not exists unc_guadcore.employee
(
    employee_id serial
        constraint employee_pk
            primary key,
    full_name   varchar(80) not null,
    manager_id  integer
        constraint employee_employee_employee_id_fk
            references unc_guadcore.employee
);


INSERT INTO employee (employee_id, full_name, manager_id) VALUES (1, 'Michael North', null);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (2, 'Megan Berry', 1);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (3, 'Sarah Berry', 1);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (4, 'Zoe Black', 1);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (5, 'Tim James', 1);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (6, 'Bella Tucker', 2);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (7, 'Ryan Metcalfe', 2);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (8, 'Max Mills', 2);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (9, 'Benjamin Glover', 2);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (10, 'Carolyn Henderson', 3);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (11, 'Nicola Kelly', 3);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (12, 'Alexandra Climo', 3);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (13, 'Dominic King', 3);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (14, 'Leonard Gray', 4);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (15, 'Eric Rampling', 4);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (16, 'Piers Paige', 7);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (17, 'Ryan Henderson', 7);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (18, 'Frank Tucker', 8);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (19, 'Nathan Ferguson', 8);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (20, 'Kevin Rampling', 8);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (21, 'Person 1', null);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (22, 'Person 2', 21);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (23, 'Person 3', 22);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (24, 'Person 4', 22);
INSERT INTO employee (employee_id, full_name, manager_id) VALUES (25, 'Person 5', 22);
