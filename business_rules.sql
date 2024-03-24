use `bank_db`;

/* Транзакції
1) За одну транзакцію не можна переводити більше ніж 100 тис.грн. + не може бути негативною
2) Не можна перевести більше грошей,ніж є на рахунку(карті) якщо це не кредитна карта 
3) `conterparty_account_details` не може бути рівним поточним реквізитам
*/

ALTER TABLE `transaction` 
ADD CONSTRAINT `transaction_range` CHECK(amount BETWEEN 0 AND 100000);

ALTER TABLE `transaction` 
ADD CONSTRAINT `conterparty_constraint` CHECK(`conterparty_card_number` != `card_number`); 

-- INSERT INTO `transaction` VALUE
-- (1, '3241 8785 5678 1535', '2022-06-15', '23:12:45', 150000.50, 'На благодійність', '2124 6655 2389 8111');
-- INSERT INTO `transaction` VALUE
-- (2, '3241 8785 5678 1535', '2022-06-15', '23:12:45', 150000.50, 'На благодійність', '3241 8785 5678 1535');

DROP FUNCTION IF EXISTS getBalance;

 DELIMITER $$
CREATE FUNCTION getBalance(
	card_details VARCHAR(19)
) 
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE c_balance DECIMAL(8,2);
    SELECT 
		card_balance
	INTO c_balance
    FROM card
    WHERE 
		card_number = card_details; 
	RETURN (c_balance);
END$$
DELIMITER ; 

-- SELECT getBalance('3241 8785 5678 1535');

 DELIMITER $$
CREATE FUNCTION getCardType(
	card_details VARCHAR(19)
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE card_type VARCHAR(20);
    SELECT 
		card_type_name
	INTO card_type
    FROM card c 
    JOIN card_type ct USING (card_type_id)
    WHERE 
		c.card_number = card_details; 
	RETURN (card_type);
END$$
DELIMITER ; 

-- SELECT getCardType('3241 8785 5678 1535');

DELIMITER //
CREATE PROCEDURE check_amount(IN amount DECIMAL(8, 2),
                        IN card_num VARCHAR(19))
BEGIN
IF ((amount > getBalance(card_num)) AND ((getCardType(card_num))!='credit'))
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Кількість грошей на картці недостатня для проведення операції';
END IF;
END //
DELIMITER ;

-- CALL check_amount(15000, '5647 3322 9438 1240');

DELIMITER $$
CREATE TRIGGER amount_check_insert
BEFORE INSERT ON `transaction` 
FOR EACH ROW
BEGIN
CALL check_amount(NEW.amount, NEW.card_number);
END$$
DELIMITER ; 

-- INSERT INTO `transaction` VALUE
-- (8, '3241 8785 5678 1535', '2022-06-15', '23:12:45', 35000.50, 'На благодійність', '2124 6655 2389 8111');

DELIMITER $$
CREATE TRIGGER amount_check_update
BEFORE UPDATE ON `transaction` 
FOR EACH ROW
BEGIN
CALL check_amount(NEW.amount, NEW.card_number);
END$$
DELIMITER ;

-- INSERT INTO `transaction` VALUE
-- (7, '5647 3322 9438 1240', '2022-06-15', '23:12:45', 40000.50, 'На благодійність', '2124 6655 2389 8111');
/*
Картки

6)`expiry_date` не може бути раніше сьогоднішньої дати
7) `balance` може бути < 0 тільки якщо card_type = credit(тобто всі інші > 0) 
*/
-- ALTER TABLE `card` 
DROP TRIGGER IF EXISTS balance_check_insert;
DROP TRIGGER IF EXISTS balance_check_upd;

DELIMITER $$
CREATE TRIGGER balance_check_insert
BEFORE INSERT ON card
FOR EACH ROW
BEGIN
CALL check_balance(NEW.card_balance, NEW.card_type_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER balance_check_upd
BEFORE UPDATE ON card
FOR EACH ROW
BEGIN
CALL check_balance(NEW.card_balance, NEW.card_type_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS check_balance;
DELIMITER //
CREATE PROCEDURE check_balance(IN card_balance DECIMAL(8, 2),
                        IN card_type_num INT)
BEGIN
IF card_balance < 0 AND card_type_num != 2 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Не кредитна карта не може мати негативний баланс!';
END IF;
END //
DELIMITER ;

-- INSERT INTO card value ('3208 8785 5678 1535', '66677225559911', 1, 32250.45, '2023-06-28');
-- UPDATE card SET card_balance= '-10.00' WHERE card_number='3208 8785 5678 1535';

DROP TRIGGER IF EXISTS expiry_date_check_insert;
DROP TRIGGER IF EXISTS expiry_date_check_upd;

DELIMITER $$
CREATE TRIGGER expiry_date_check_insert
BEFORE INSERT ON card
FOR EACH ROW
BEGIN
CALL expiry_date_check(NEW.expiry_date);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER expiry_date_check_upd
BEFORE UPDATE ON card
FOR EACH ROW
BEGIN
CALL expiry_date_check(NEW.expiry_date);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS expiry_date_check;
DELIMITER //
CREATE PROCEDURE expiry_date_check(IN exp_date DATE)
BEGIN
IF exp_date <= CURDATE() THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата закінчення терміну картки має бути не раніше сьогодні!';
END IF;
END //
DELIMITER ;

-- INSERT INTO card VALUE ('3200 8785 5678 1536', '66677225559911', 1, 32250.45, '2021-06-28');
-- UPDATE card SET expiry_date='2016-07-06' WHERE card_number='3200 8785 5678 1536';

/*Робітники
8) 'employee+branch_id' UNIQUE
11) працівник не можу бути керівніком(менеджером) саого себе
12) post in consultant, manager, accountant
*/
ALTER TABLE `employee` ADD CONSTRAINT `employee_in_single_branch` UNIQUE(employee_id, branch_id);
ALTER TABLE `employee` ADD CONSTRAINT `post_options` CHECK(`post` IN ('менеджер', 'консультант', 'бухгалтер')); 

DROP TRIGGER IF EXISTS chief_constraint;
DELIMITER $$
CREATE TRIGGER chief_constraint
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
IF NEW.employee_id = NEW.chief_id THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Робітник не може бути своїм начальником';
END IF;
END$$
DELIMITER ;

-- INSERT INTO employee VALUE 
-- (10, 'Софія', 'Мирошниченко', 'менеджер', 10, 1, 'sof_myr', '$2a$12$dvTenMZUQRVvhYC85CXd.Osh6axgpw4kokBPC2wewU0CFBGRLInoW');

/*
Займи
9) Дата займу не пізніше сьогодні
*/
DROP TRIGGER IF EXISTS `loan_date_check`;

DELIMITER $$
CREATE TRIGGER loan_date_check
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
IF NEW.loan_date > CURDATE() THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата взяття кредиту не може бути пізніше сьогодні';
END IF;
END$$
DELIMITER ;


-- INSERT INTO loan VALUE (2, '5647 3322 9438 1240', 3000.00,  '2017-10-10', 4.2, '12 місяців');
-- UPDATE loan SET loan_date='2026-02-02' WHERE loan_id = 2;

/*
Депозити
10) Ставка між 8 та 17 відсотками
*/

ALTER TABLE deposit ADD CONSTRAINT `rate_range` CHECK (rate BETWEEN 8 AND 17);















