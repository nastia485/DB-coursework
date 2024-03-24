DROP DATABASE IF EXISTS `bank_db`;
CREATE DATABASE `bank_db`; 
USE `bank_db`;
 
SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;
 
CREATE TABLE `client` (
  `client_id` int ,
  `name` varchar(20) NOT NULL,
  `surname` varchar(20) NOT NULL,
  `phone` varchar(18) NOT NULL,
   `branch_id` INT DEFAULT NULL,
  `login` varchar(40) UNIQUE,
  `password` varchar(100),
  PRIMARY KEY (`client_id`)
);

CREATE TABLE `account`(
-- реквізити
`account_details` varchar(14) NOT NULL,
`account_balance` DECIMAL(8, 2) DEFAULT NULL,
 `client_id` int not null,
PRIMARY KEY(`account_details`),
FOREIGN KEY (`client_id`) REFERENCES `client` (`client_id`) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE `card_type`(
`card_type_id` INT,
`card_type_name` VARCHAR(20),
`description` VARCHAR(200),
PRIMARY KEY(`card_type_id`)
);


CREATE TABLE `card`(
`card_number` VARCHAR(19) NOT NULL UNIQUE,
`account_details` VARCHAR(14),
`card_type_id` INT,
`card_balance` DECIMAL(8, 2),
`expiry_date` DATE,
 PRIMARY KEY(`card_number`),
 FOREIGN KEY(`account_details`) REFERENCES `account`(`account_details`) ON UPDATE CASCADE ON DELETE RESTRICT,
 FOREIGN KEY(`card_type_id`) REFERENCES `card_type`(`card_type_id`) -- ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE `transaction`(
`transaction_id` INT,
`card_number` varchar(19) NOT NULL,
`date` DATE,
`time` TIME,
`amount` DECIMAL(8, 2),
`purpose` VARCHAR(50) DEFAULT NULL,
-- реквізити сторони-отримувача
`conterparty_card_number` varchar(19) NOT NULL, 
PRIMARY KEY(`transaction_id`),
FOREIGN KEY(`card_number`) REFERENCES `card`(`card_number`) 
);

CREATE TABLE `atm_type`(
`atm_type_id` INT,
`name` VARCHAR(40) UNIQUE,
`description` VARCHAR(100),
PRIMARY KEY(`atm_type_id`)
);

CREATE TABLE `atm`(
`atm_id` INT NOT NULL,
`atm_type` INT NOT NULL,
`branch_id` INT DEFAULT NULL,
PRIMARY KEY(`atm_id`),
FOREIGN KEY(`atm_type`) REFERENCES `atm_type`(`atm_type_id`)
);

CREATE TABLE `employee`(
`employee_id` INT,
`name` VARCHAR(20),
`surname` VARCHAR(20),
`post` VARCHAR(20),
`chief_id` INT,
`branch_id` INT NOT NULL,
`login` varchar(40) UNIQUE,
`password` varchar(100),
PRIMARY KEY(`employee_id`),
FOREIGN KEY(`chief_id`) REFERENCES `employee`(`employee_id`) -- ON UPDATE CASCADE
);

CREATE TABLE `address`(
`address_id` INT NOT NULL,
`city` VARCHAR(25) NOT NULL,
`street` VARCHAR(25) NOT NULL,
`building_num` VARCHAR(5) NOT NULL,
PRIMARY KEY(`address_id`)
);

CREATE TABLE `branch`(
`branch_id` INT,
`address_id` INT UNIQUE,
`head` INT, 
PRIMARY KEY(`branch_id`), 
FOREIGN KEY(`address_id`) REFERENCES `address`(`address_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
FOREIGN KEY(`head`) REFERENCES `employee`(`employee_id`) -- ON UPDATE CASCADE
);

ALTER TABLE `client` ADD CONSTRAINT `branchFK` FOREIGN KEY (`branch_id`) REFERENCES `branch`(`branch_id`); 
ALTER TABLE `atm` ADD CONSTRAINT `atmBranchFK` FOREIGN KEY (`branch_id`) REFERENCES `branch`(`branch_id`); 

CREATE TABLE `loan`(
`loan_id` INT,
`card_number` VARCHAR(19) NOT NULL,
`amount` DECIMAL(8, 2),
`loan_date` DATE,
-- rate in percents
`rate` DECIMAL(3, 1),
`term` VARCHAR(30),
PRIMARY KEY(`loan_id`),
FOREIGN KEY(`card_number`) REFERENCES `card`(`card_number`) ON DELETE RESTRICT
);

CREATE TABLE `deposit`(
`deposit_id` INT,
`card_number` VARCHAR(19) NOT NULL,
`amount` DECIMAL(8, 2),
-- rate in percents
`rate` DECIMAL(3, 1),
`date_to_withdraw` DATE,
PRIMARY KEY(`deposit_id`),
FOREIGN KEY(`card_number`) REFERENCES `card`(`card_number`) ON DELETE RESTRICT
);



