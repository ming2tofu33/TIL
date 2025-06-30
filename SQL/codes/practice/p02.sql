-- p02.sql

-- practice db 이동
USE practice;

-- userinfo 테이블에 진행(p01 실습에서 진행했던 테이블)
-- 데이터 5건 넣기 (별명, 핸드폰) -> 별명 bob 을 포함하세요 C
INSERT INTO userinfo (nickname, phone) VALUES 
('가가', '01011111111'),
('나나', '01022222222'),
('다다', '01033333333'),
('라라', '01044444444'),
('baba', '01055555555'),
('bob', '01066666666')
;

-- 전체 조회 (중간중간 계속 실행하면서 모니터링) R
SELECT * FROM userinfo;
-- id가 3인 사람 조회 R
SELECT * FROM userinfo WHERE id=3;
-- 별명이 bob 인 사람 조회 R
SELECT * FROM userinfo WHERE nickname='bob';
-- 별명이 bob 인 사람의 핸드폰 번호를 0109999888로 수정 (id로 수정) U
UPDATE userinfo SET phone='0109999888' WHERE id=6;
-- 별명이 bob 인 사람 삭제 (id로 수정) D
DELETE FROM userinfo WHERE id=6;
