-- p06.sql

USE practice;

SELECT * FROM userinfo;

-- 별명 길이 확인
SELECT CHAR_LENGTH(nickname) AS 별명길이 FROM userinfo;
-- 별명 과 email 을 '-' 로 합쳐서 info (Alias)컬럼으로 확인해 보기
SELECT CONCAT(nickname, '-', email) FROM userinfo;
-- 별명 은 모두 대문자로, email은 모두 소문자로 확인
SELECT UPPER(nickname), LOWER(email) FROM userinfo;
-- email 에서 gmail.com 을 naver.com 으로 모두 new_email 컬럼으로 추출
SELECT REPLACE(email,'gmail.com', 'naver.com') AS new_email FROM userinfo;

-- email 앞에 붙은 단어만 username 컬럼 으로 확인
SELECT LOCATE('@', email) AS username FROM userinfo;
SELECT 
	SUBSTRING( -- 추출한다.
		email, 1, LOCATE('@', email) - 1  -- email 의 1번 글자부터 @등장 전 글자까지(-1 의 이유)
    ) AS username  -- 추출한 글자들을 username 이라고 alias
FROM userinfo;

-- (추가 과제 -> email 이 NULL 인 경우 'No Mail' 이라고 표시
-- SELECT IFNULL(email, 'No Mail!') FROM userinfo;
SELECT
	email,
    CASE
		WHEN email is NOT NULL
        THEN SUBSTRING(email, 1, LOCATE('@', email) - 1)
        ELSE 'NO Mail :('
		END AS username
FROM userinfo;