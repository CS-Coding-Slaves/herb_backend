DROP DATABASE IF EXISTS `herbDB`;
CREATE DATABASE IF NOT EXISTS `herbDB`;

USE `herbDB`;

-- 중복되지 않는 랜덤한 8자리 숫자를 생성
DELIMITER $$
CREATE PROCEDURE generate_random_id(OUT new_id INT)
BEGIN
    DECLARE id_exists INT DEFAULT 1;

    WHILE id_exists = 1 DO
        SET new_id = FLOOR(RAND() * 90000000) + 10000000;
        SELECT COUNT(*) INTO id_exists FROM users WHERE id = new_id;
    END WHILE;
END$$
DELIMITER ;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    pw VARCHAR(20) NOT NULL,
    type BOOLEAN DEFAULT 0 -- 0: 개인회원 1: 기업회원
);

CREATE TABLE object (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price INT NOT NULL
);

CREATE TABLE company(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

-- 구매, 등록 테이블이 너무 유사해서 하나로 합쳤음
CREATE TABLE transaction_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_id INT,
    object_id INT NOT NULL,
    num INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (company_id) REFERENCES company(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (object_id) REFERENCES object(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE register (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transaction_details(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE receipt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transaction_details(id) ON DELETE CASCADE ON UPDATE CASCADE
);
-- Category도 만드나? 일단 이건 보류..
CREATE TABLE Category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255) NOT NULL
);

DELIMITER $$
CREATE TRIGGER before_insert_user
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    DECLARE new_id INT;
    CALL generate_random_id(new_id);
    SET NEW.id = new_id;
END$$
DELIMITER ;

-- 테스트 코드) users 테이블에 임의의 데이터를 삽입
INSERT INTO users (name, pw) VALUES ('Alice', 'password123');
INSERT INTO users (name, pw) VALUES ('Bob', 'securepwd');
INSERT INTO users (name, pw) VALUES ('Charlie', 'mypassword');
INSERT INTO users (name, pw) VALUES ('Dave', 'passw0rd');
INSERT INTO users (name, pw) VALUES ('Eve', 'password!@#');
SELECT * FROM users;

-- 테스트 코드2) 구매/등록 절차 예시
-- object 및 company 테이블에 필요한 데이터 삽입
INSERT INTO object (name, price) VALUES ('Item A', 100);
INSERT INTO object (name, price) VALUES ('Item B', 200);

INSERT INTO company (name) VALUES ('Company X');
INSERT INTO company (name) VALUES ('Company Y');
-- 사용자 이름 기반으로 user_id 조회 후 transaction_details에 삽입
INSERT INTO transaction_details (user_id, company_id, object_id, num) SELECT 
    (SELECT id FROM users WHERE name = 'Alice'),  -- 사용자 이름에 기반한 user_id
    (SELECT id FROM company WHERE name = 'Company Y'),  -- 회사 이름에 기반한 company_id
    (SELECT id FROM object WHERE name = 'Item A'),  -- 물품 이름에 기반한 object_id
    10    -- 수량
;
SELECT * FROM transaction_details;