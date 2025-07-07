-- 24-many-to-many.sql

DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students_courses;

CREATE TABLE students (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20)
);

CREATE TABLE courses (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    classroom VARCHAR(20)
);

-- 중간테이블(Junction Table) students:courses = M : N
CREATE TABLE students_courses (
	student_id INT,
    course_id INT,
    grade VARCHAR(5),
    PRIMARY KEY (student_id, course_id), -- 복합 PK
    FOREIGN KEY(student_id) REFERENCES students(id),
    FOREIGN KEY(course_id) REFERENCES courses(id)
);

DESC students;

-- 데이터 삽입
INSERT INTO students VALUES
(1, '김학생'),
(2, '이학생' ),
(3, '박학생');

INSERT INTO courses VALUES
(1, 'MySQL 데이터베이스', 'A관 101호'),
(2, 'PostgreSQL 고급', 'B관 203호'),
(3, '데이터 분석', 'A관 704호');

INSERT INTO students_courses VALUES
(1, 1, 'A'),  -- 김학생이 MySQL 수강
(1, 2,'B+'), -- 김학생이 PostgreSQL 수강
(2, 1, 'A-'), -- 이학생이 MySQL 수강
(2, 3, 'B'),  -- 이학생이 데이터분석 수강
(3, 2, 'A+'), -- 박학생이 PostgreSQL 수강
(3, 3, 'A');  -- 박학생이 데이터분석 수강

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM students_courses;

-- 학생별 수강 과목
SELECT
	s.id AS 학생ID, 
	s.name AS 학생이름,
    GROUP_CONCAT(c.name) AS 수강과목,
	GROUP_CONCAT(sc.grade) AS 점수
FROM students s
INNER JOIN students_courses sc ON s.id = sc.student_id
INNER JOIN courses c ON c.id = sc.course_id
GROUP BY s.id, s.name;

-- 과목별 정리
-- [과목명, 강의실, 수강인원, 수강 학생들(,), 학점 평균(A+ 4.3/A 4.0/A- 3.7/B+ 3.3/B 3.0)]
SELECT
	c.id AS 과목아이디,
    c.name AS 과목명,
    c.classroom AS 강의실,
    COUNT(s.name) AS 수강인원,
    GROUP_CONCAT(s.name) AS 수강학생,
    AVG(CASE
		WHEN sc.grade = 'A+' THEN 4.3
        WHEN sc.grade = 'A' THEN 4.0
        WHEN sc.grade = 'A-' THEN 3.7
        WHEN sc.grade = 'B+' THEN 3.3
        WHEN sc.grade = 'B' THEN 3.0
    END
    ) AS 평균학점
FROM courses c
INNER JOIN students_courses sc ON c.id = sc.course_id
INNER JOIN students s ON s.id = sc.student_id
GROUP BY c.id, c.name, c.classroom;





