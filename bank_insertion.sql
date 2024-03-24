use `bank_db`;

INSERT INTO `client` VALUES
 (1,'Марія', 'Лісова', '+38 066-884-33-09',  DEFAULT, 'maria-333', '$2a$12$CB.Lu7qEP.mCiqLJ4kciZOckijlOI5DeJ0PP0CmcCJq6DSnDTK9q6v'),
 (2,'Григорій', 'Маркович', '+38 073-111-44-55',  DEFAULT, 'grisha_1999', '$2a$12$QeBAjjIlRVj8Mr5wpCUR7.1Z/GkFT7FDBSGXcvPXGPqFThXCLkmWy'),
 (3,'Степан', 'Гіга', '+38 050-555-55-99', DEFAULT,'giga', '$2a$12$0kPahObm80L/85mcXKfqoe2bXSd4TAejhGE5XZVG73nb6yLFKv63S'),
 (4,'Лариса', 'Дмитренко', '+38 068-221-33-44', DEFAULT, 'larysa_dmytrenko','$2a$12$GxsuLa9ouAOLLUIpV9UClu/kUfFVGgwd8V/JZfJuW/IFAqKuFcJby' ),
 (5, 'Дмитро', 'Покотило', '+38 098-341-55-66', DEFAULT, 'dima_pokotilo', '$2a$12$gf7NuMr.9vCRUJcwL/swtu8bVsq9FMqHhRbulRWFzoVoEVStOJcR2');

 INSERT INTO `account` VALUES 
('33399559990022', 3250, 2),
('66677225559911', 2100.50, 1),
('88844220005577', 223230.38, 4),
('44466110005588', 21.0, 3);


INSERT INTO `card_type` VALUES
(1, 'debit','Related to the account, gives access only to money placed on account.'),
(2, 'credit', 'Gives access not only to account money, but to the bank`s money, which
               are being paid back with interest within a specified period.'),
(3, 'overdraft', 'Stores the money on account and can work as credit');
                
INSERT INTO `card` VALUES 
('3241 8785 5678 1535', '66677225559911', 2, 32250.45, '2026-06-28'),
('3241 7576 3331 9988', '33399559990022', 2, 30.25, '2024-09-11'),
('5647 3322 9438 1240',  '44466110005588', 1, 12325.65, '2023-03-08'),
('3543 9078 4441 1616', '88844220005577', 3, 4040.00, '2025-12-05'),
('6543 8123 4451 1416', '33399559990022', 1, 40567.00, '2023-01-30');

INSERT INTO `transaction` VALUES
(1, '3241 8785 5678 1535', '2022-06-15', '23:12:45', 350.50, 'На благодійність', '2124 6655 2389 8111'),
(2, '3543 9078 4441 1616', '2022-11-02', '11:15:53', 1209.40, DEFAULT, '4491 4536 4411 9701'),
(3, '3543 9078 4441 1616', '2022-12-15', '14:13:30', 30.0, 'Оплата замовлення №323', '3241 8785 5678 1535'),
(4, '5647 3322 9438 1240', '2022-10-09', '18:15:12', 2278.00, DEFAULT, '4563 8273 4563 4671'),
(5, '3241 8785 5678 1535', '2022-12-12', '12:11:57', 200.00, DEFAULT, '5647 3322 9438 1240'),
(6, '5647 3322 9438 1240', '2022-12-12', '14:34:15', 700.00, DEFAULT, '3114 5672 9984 0102');

INSERT INTO `address` VALUES 
(1, 'Херсон', 'Шевченка', '3a' ),
(2, 'Київ', 'Леонтовича', '174'),
(3, 'Харків', 'Лисенка', '10/1'),
(4, 'Львів', 'Вишні', '17');

INSERT INTO `branch` VALUES
(1, 4, DEFAULT),
(2, 3, DEFAULT),
(3, 1, DEFAULT),
(4, 2, DEFAULT);

INSERT INTO `atm_type` VALUES (1, 'cash_in', 'Designed for depositing cash, it is also called a terminal'),
								   (2, 'cash_out', 'Designed to withdraw cash'),
                                   (3, 'combined', 'Cash in together with cash out'),
                                   (4, 'nfc', 'ATM with contactless interaction function');

INSERT INTO `atm` VALUES
(1, 3, 2),
(2, 2, 3),
(3, 4, 2),
(4, 3, 1), 
(5, 1, 4);
                                   
-- 2 5 6

UPDATE client SET branch_id = 3 WHERE client_id = 1;
UPDATE client SET branch_id = 2 WHERE client_id = 2;
UPDATE client SET branch_id = 1 WHERE client_id = 3;
UPDATE client SET branch_id = 4 WHERE client_id = 4;

INSERT INTO `loan` VALUES 
(1, '3241 8785 5678 1535', 3000.00,  '2021-10-10', 4.2, '12 місяців');

INSERT INTO `deposit` VALUES
(3, '5647 3322 9438 1240', 12000.00, 8.4, '2023-08-23');
                                   
INSERT INTO `employee` VALUES
(1, 'Анастасія', 'Сергієнко', 'бухгалтер', DEFAULT, 2, 'a_sergiyenko', '$2a$12$M5m8MZfQszL4o6jvmV5Wf.g.Q/Flk..qkmF9yDWJhd.JVZvQJDodO' ), 
(2, 'Дмитро', 'Павленко', 'менеджер', DEFAULT, 1, 'dm_pavl', '$2a$12$z9nB83Ui.0b8tYaYeuXPTOstEnlkwyIbiudoeYebwZEPeZ5DOW/kC'),
(3, 'Петро', 'Дмитренко', 'консультант',DEFAULT , 1, 'petro-1', '$2a$12$G7PiTKHmdzfH5KATz3NcEeEtmcVCP9I5ozqCAkAfbwJfj7Zwiqjsy'),
(4, 'Олександр', 'Городецький', 'бухгалтер', DEFAULT, 3, 'oleks_gorodeckyi', '$2a$12$DlO/QoibuE2W220XrK0lJeGdOwAN1HGrPiTySJ7rcN.J6c3TQtPNm'),
(5, 'Володимир', 'Шевчук', 'менеджер', DEFAULT, 2, 'shevchuk02', '$2a$12$evFcyWMA052Cfo6lSwQt/eU4r5P28DPtjZ2pWiTD6phNPCk8/sCBG'),
(6, 'Марина', 'Кліщук', 'менеджер', DEFAULT, 3, 'mklishchuk', '$2a$12$Uthp7eYXn4dKKMjgbuqpTOEMaqsG1ixuM27z9.9od/2wjlpLQzwrC'),
(7, 'Василь', 'Олександров', 'бухгалтер', DEFAULT, 1, 'v_oleksandrov', '$2a$12$22IzN5TmIV9tK2nbVK9uW.NdvUmqWyrewz2sKy8EDeqDZwr0nBwJy'),
(8, 'Оксана', 'Немиренко','консультант', DEFAULT, 2, 'oks-nem', '$2a$12$97lWA8SpC3NZSS5xSyottex9jXtL74ddcxPaAB/YEIQnoNdcFoTBq'),
(9, 'Степан', 'Григорович', 'консультант', DEFAULT, 3, 'stepan_grygorovych', '$2a$12$h4v4qzGjUVCkX/qh/yTGgekyqByqbAEdAO8TEbpQn3.yxlg1Mus1q'),
(10, 'Максим', 'Степаненко', 'консультант', DEFAULT, 4, 'max-step', '$2a$12$QpLIgv7gJtWm4TtpXLQco.mpnSaF2g8DREfidt8pv3G3gPQfq0UX6'),
(11, 'Григорій', 'Леонтович', 'менеджер', DEFAULT, 4, 'g.leontovych', '$2a$12$rVnU15vQP9CSeTq4hIXUcugDARqAorK.xXfJEI3cPNqCqNGrD.U7q');

UPDATE employee SET chief_id = 5 WHERE employee_id = 1;
UPDATE employee SET chief_id = 2 WHERE employee_id = 3;
UPDATE employee SET chief_id = 6 WHERE employee_id = 4;
UPDATE employee SET chief_id = 2 WHERE employee_id = 7;
UPDATE employee SET chief_id = 5 WHERE employee_id = 8;
UPDATE employee SET chief_id = 6 WHERE employee_id = 9;
UPDATE employee SET chief_id = 11 WHERE employee_id = 10;

UPDATE branch SET head = 2 WHERE branch_id = 1;
UPDATE branch SET head = 5 WHERE branch_id = 2;
UPDATE branch SET head = 6 WHERE branch_id = 3;



