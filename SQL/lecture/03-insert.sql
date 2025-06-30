-- 03-insert.sql

USE lecture;
DESC members;

-- 데이터 입력
INSERT INTO members (name, email) VALUES ('김도민', 'amy@a.com');
INSERT INTO members (name, email) VALUES ('현현현', 'dh@a.com');
-- 여러줄, (col1, col2) 순서 잘 맞추기!
INSERT INTO members (email, name) VALUES 
('yh@a.com', '양양양'), 
('jj@a.com', '진진진')
;

-- 데이터 전체 조회 (Retreive)
SELECT * FROM members;
-- 단일 데이터 조회ALTER
SELECT * FROM members WHERE id=1;
