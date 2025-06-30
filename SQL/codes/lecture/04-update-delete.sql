-- 04-update-delete.sql

SELECT * FROM members;

-- Update(데이터 수정)
UPDATE members SET name='홍길동', email='hong@a.com' WHERE id=1;
-- 원치 않는 케이스 (name이 같으면 동시 수정)
UPDATE members SET name='No name' WHERE name='김도민';

-- Delete(데이터 삭제)
DELETE FROM members WHERE id = 1;
-- 테이블 모든 데이터 삭제
DELETE FROM members;