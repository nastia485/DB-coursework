use `bank_db`;

DROP VIEW IF EXISTS clients_transactions;
CREATE VIEW clients_transactions AS 
SELECT *
FROM `transaction` t 
INNER JOIN card d USING(card_number)
INNER JOIN account a USING (account_details)
INNER JOIN client cl USING(client_id); 

SELECT * FROM clients_transactions;

-- 1)	Вивести conterparty, який є клієнтом нашого банку(transactions) ????
SELECT t.transaction_id, t.conterparty_card_number, CONCAT(cl.name, ' ', cl.surname) AS client FROM `transaction` t 
	JOIN card c ON t.conterparty_card_number = c.card_number
    JOIN account a USING(account_details)
    JOIN client cl USING(client_id)
WHERE t.conterparty_card_number = c.card_number;

-- 2)	Дізнатися чия картка
SELECT c.card_number, CONCAT(cl.name, ' ', cl.surname) AS client FROM card c
	JOIN account a USING(account_details)
    JOIN client cl USING(client_id);

-- 3)	За якою адресою знаходиться банкомат combined

SELECT atm.atm_id, a.city, a.street, a.building_num FROM atm
		INNER JOIN branch USING(branch_id)
		INNER JOIN address a USING(address_id)
        INNER JOIN atm_type  ON atm.atm_type = atm_type.atm_type_id
        WHERE atm_type.name = 'combined'
        ORDER BY atm.atm_id;
        
-- 4)  кількість карток
DROP VIEW IF EXISTS cards_list;
CREATE VIEW cards_list AS 
SELECT  CONCAT(cl.name, ' ', cl.surname) AS client, COUNT(c.card_number) AS 'number of cards'
FROM card c
JOIN account a USING(account_details)
LEFT JOIN `client` cl USING (client_id)
GROUP BY client_id;

SELECT * FROM cards_list;
-- 5)адреса відділу, до якого належать люди, що робили транзакцію 

DROP VIEW IF EXISTS transactions_on_branch;
CREATE VIEW transactions_on_branch AS
SELECT DISTINCT (ct.transaction_id, CONCAT(ct.name, ' ', ct.surname) AS client, CONCAT(a.city, ' ', a.street,' ', a.building_num) AS 'branch address')
FROM clients_transactions ct
JOIN branch b USING (branch_id)
JOIN address a USING (address_id);

SELECT * FROM transactions_on_branch;
-- 21) за якою адресою обслуговується клієнт(адреса відділу)

DROP VIEW IF EXISTS client_branch;
CREATE VIEW client_branch AS
SELECT DISTINCT CONCAT(ct.name, ' ', ct.surname) AS client, CONCAT('м. ', a.city, ', вул. ', a.street, '  буд. №', a.building_num) AS 'branch address'
FROM clients_transactions ct
JOIN branch b USING (branch_id)
JOIN address a USING (address_id);

DROP PROCEDURE IF EXISTS display_address;
DELIMITER //
CREATE PROCEDURE display_address (IN name VARCHAR(50),
                        IN surname VARCHAR(50))
BEGIN
SELECT * FROM client_branch cb 
	WHERE cb.client = CONCAT(name, ' ', surname);
END //
DELIMITER ;

CALL display_address('Степан', 'Гіга');

-- 6)дізнатися підлеглих менеджера (по імені або номеру) та у якому відділенні працює(subordinate) --- (пари менеджер - підлеглий)
DROP VIEW IF EXISTS manager_subordinates;
CREATE VIEW manager_subordinates AS
SELECT CONCAT(em2.name, ' ', em2.surname) AS manager, CONCAT(em.name, ' ', em.surname) AS subordinate
FROM employee em
JOIN employee em2 ON em.chief_id = em2.employee_id;

SELECT * FROM manager_subordinates;
-- 7)баланс рахунку клієнта (карти+рахунок)
 
 SELECT cl.name, a.account_details, c.card_number, sum(c.card_balance) AS cards_balance, (a.account_balance) AS accounts_balance,
 sum(c.card_balance)+a.account_balance AS general_amount
 -- sum(c.balance) AS Balance
 FROM client cl
 JOIN `account` a USING(client_id)
 JOIN card c USING(account_details)
 GROUP BY client_id;
 
-- 8)дізнатися останню транзакцію клієнта

SELECT  CONCAT(name, ' ', surname) AS client, card_number, MAX(date) AS 'latest transaction date', amount, conterparty_card_number 
FROM clients_transactions 
GROUP BY client_id;
-- 9)згрупувати і порахувати транзакції клієнта 

SELECT CONCAT(name, ' ', surname) AS client, COUNT(transaction_id) AS 'number of transactions'
FROM clients_transactions
GROUP BY client_id;
-- 10)місце роботи робітника за номером або ім'ям
SELECT CONCAT(e.name, ' ', e.surname) AS 'employee name' , CONCAT('м. ', a.city, ', вул. ', a.street, '  буд. №', a.building_num) AS 'place of work' 
FROM employee e 
JOIN branch b USING(branch_id) 
JOIN address a USING(address_id);
-- 11) адреса + номер відділення + банкомат + тип банкомату у форматі : за адресою () на якій знаходить відділ № () є банкомат () типу ()
SELECT at.name AS type, b.branch_id AS 'branch number', CONCAT('м. ', a.city, ', вул. ', a.street, '  буд. №', a.building_num) AS 'address'
FROM atm 
JOIN atm_type at ON at.atm_type_id = atm.atm_type
JOIN branch b USING(branch_id)
JOIN address a USING(address_id);

-- 12) хто зробив кредит і скільки
SELECT l.loan_id, CONCAT(cl.name, ' ', cl.surname) AS client, l.amount FROM loan l 
JOIN card c USING(card_number) 
JOIN account a USING(account_details)
JOIN client cl USING(client_id) ;

-- 14) згрупувати amount робітників за відділеннями
SELECT b.branch_id , COUNT(employee_id) AS employees_number FROM employee e 
JOIN branch b USING(branch_id)
GROUP BY branch_id
ORDER BY branch_id;

-- 15) вивести картки, у яких срок дії закінчується менше ніж через 2 місяці (щоб попередити клієнта) і ім'я клієнта
SELECT CONCAT(cl.name, ' ', cl.surname) AS client, c.card_number, c.expiry_date FROM card c
JOIN account a USING(account_details)
JOIN client cl USING(client_id)
WHERE c.expiry_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 MONTH);
-- 16) вивести ім'я людей, у яких на картці(або рахунку) більше 200 тис грн для того, що запропонувати депозит
SELECT CONCAT(cl.name, ' ', cl.surname) AS client, acc.account_balance FROM client cl
JOIN account acc USING (client_id)
WHERE acc.account_balance >= 200000;

-- 17) клієнти яких обслуговує конкретний консультант 
SELECT CONCAT(cl.name, ' ', cl.surname) AS client, b.branch_id AS 'branch number', CONCAT(e.name, ' ', e.surname) AS consultant FROM client cl
RIGHT JOIN branch b USING(branch_id)
LEFT JOIN employee e USING(branch_id)
WHERE e.post = 'консультант';

-- 18) номери карток, які обслуговує бухгалтер: работники - бранч - клиенты - счета - карточки
SELECT CONCAT(e.name, ' ', e.surname) AS accountant, c.card_number AS 'card number' FROM employee e
LEFT JOIN branch b USING(branch_id) 
LEFT JOIN client cl USING(branch_id)
LEFT JOIN account a USING(client_id)
LEFT JOIN card c USING(account_details)
WHERE e.post='бухгалтер';

-- 19) порахувати скільки клієнт заробив(заробить) протягом 1го року депозиту
-- SELECT CONCAT(cl.name, ' ', cl.surname) AS client, d.date_to_withdraw
SELECT CONCAT(cl.name, ' ', cl.surname) AS client, d.amount, d.rate, CAST((d.amount*d.rate/100.0) as DECIMAL(8,2)) AS outcome 
FROM deposit d
LEFT JOIN card c USING(card_number) 
JOIN account a USING(account_details)
JOIN client cl USING(client_id);

-- 20) виписка - транзакції конкретної людини

DROP PROCEDURE IF EXISTS display_transactions;
DELIMITER //
CREATE PROCEDURE display_transactions (IN name VARCHAR(50),
                        IN surname VARCHAR(50))
BEGIN
SELECT * FROM client_transaction ct 
	WHERE ct.name = name AND ct.surname = surname;
END //
DELIMITER ;

CREATE VIEW client_transaction AS
SELECT cl.name, cl.surname, t.card_number, t.date, t.time , t.amount, t.purpose
FROM `transaction` t
JOIN card c ON t.card_number = c.card_number
JOIN account a ON c.account_details = a.account_details
JOIN `client` cl ON a.client_id = cl.client_id;

CALL display_transactions('Степан', 'Гіга');
        
