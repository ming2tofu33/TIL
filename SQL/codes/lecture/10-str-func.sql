-- 10-str-func.sql

USE lecture;

-- 길이
SELECT CHAR_LENGTH('hello sql');
SELECT nickname, LENGTH(nickname) FROM dt_demo; -- 영어는 정상적으로 출력되지만 한국어는 아님
SELECT name, CHAR_LENGTH(name) AS '이름 길이' FROM dt_demo;

-- 연결ALTER
SELECT CONCAT('hello','sql','!!');
SELECT CONCAT(name, '(', score, ')') AS info FROM dt_demo;
SELECT CONCAT('이름:', name, '닉넴:', nickname, '생일:', birth, '점수:', score) AS 'personal info' FROM dt_demo;

-- 대소문자 변환
SELECT 
	nickname, 
	UPPER(nickname) AS UN,
    LOWER(nickname) AS LN
FROM dt_demo;

-- 부분 문자열 추출 (문자열, 시작점, 길이)
SELECT SUBSTRING('hello sql!', 2, 4);
SELECT LEFT('hello sql!', 5);
SELECT RIGHT('hello sql!', 5);

SELECT 
	description,
    CONCAT(
		SUBSTRING(description, 1, 5), '...'
	) AS intro,
        CONCAT(
		LEFT(description, 3), 
        '...',
        RIGHT(description, 3)
	) AS summary
FROM dt_demo;

-- 문자열 치환
SELECT REPLACE('a@test.com', 'test.com', 'gmail.com');
SELECT
	description,
    REPLACE(description, '학생', '**') AS secret
FROM dt_demo;

