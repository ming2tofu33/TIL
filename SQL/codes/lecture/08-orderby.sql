-- 08-orderby.sql

USE lecture;
-- 특정 컬럼을 기준으로 정렬함
-- ASC 오름차순 | DESC 내림차순

SELECT * FROM students;

-- 이름 ㄱㄴㄷ 순으로 정렬 -> Default(기본) 정렬 방식 = ASC
SELECT * FROM students ORDER BY name;
SELECT * FROM students ORDER BY name ASC; -- 위와 결과 동일
SELECT * FROM students ORDER BY name DESC; -- 내림차순

-- 테이블 구조 변경 -> 컬럼 추가 -> grade -> char(1) -> 기본값으로 'B'
ALTER TABLE students ADD COLUMN grade CHAR(1) DEFAULT 'B';
-- 데이터 변경. id -> id 1~3 -> A | id  7~10 -> C
UPDATE students SET grade = 'A' WHERE id BETWEEN 1 and 3;
UPDATE students SET grade = 'C' WHERE id BETWEEN 8 and 10;

# 다중 컬럼 정렬 -> 앞에 말한 게 우선 정렬
SELECT * FROM students ORDER BY age ASC, grade DESC;
SELECT * FROM students ORDER BY grade DESC, age ASC;

-- 나이가 40 미만인 학생들 중에서 학점순 - 나이 많은 순으로 상위 5명 뽑기
SELECT * FROM students
WHERE age < 40 
ORDER BY grade, age DESC 
LIMIT 5;