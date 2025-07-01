-- 07-select2.sql

-- SELECT 컬럼 
-- FROM 테이블
-- WHERE 조건 
-- ORDER BY  정렬기준 
-- LIMIT 개수

USE lecture;

DROP TABLE studends;

CREATE TABLE students (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20),
    age INT
);

DESC students;

INSERT INTO students (name, age) VALUES
('김 가나', 50),
('유 다라', 30),
('이 마바', 20),
('오 사아', 25),
('권 일이', 33),
('하 삼사', 45),
('이 오육', 88),
('박 칠팔', 67)
;

SELECT * FROM students;

SELECT * FROM students WHERE name = '김 가나';
SELECT * FROM students WHERE age >= 20; -- 이상
SELECT * FROM students WHERE age > 20; -- 초과
SELECT * FROM students WHERE id <> 1; -- 해당 조건 여집합
SELECT * FROM students WHERE id != 1; -- 해당 조건이 아닌
SELECT * FROM students WHERE age BETWEEN 20 and 40; -- 20 이상, 40 이하
SELECT * FROM students WHERE id IN (1,3,5,7);

-- 문자열 패턴 LIKE (% -> 있을 수도, 없을 수도 있다. _ -> 정확히 개수만큼 글자가 있다.)
-- 이 씨만 찾기
SELECT * FROM students WHERE name LIKE '이 %';
-- '창' 글자가 들어가는 사람
SELECT * FROM students WHERE name LIKE '%오%';
-- 이름이 정확히 3글자인 유씨
SELECT * FROM students WHERE name LIKE '유 __';
-- SELECT * FROM students WHERE name LIKE '010-____-____';

