-- pg-05-various-index.sql

-- Data Structure (Graph, Tree, List, Hash...)

-- B-Tree 인덱스 생성 (기본)
CREATE INDEX <index_name> ON <table_name>(<col_name>)
-- 범위 검색 BETWEEN, >, <
-- 정렬 ORDER BY
-- 부분 일치 LIKE

-- Hash  인덱스
CREATE INDEX <index_name> ON <table_name> USING HASH(<col>)
-- 정확한 일치 검색 =
-- 범위 x, 정렬 x

-- 부분 인덱스
CREATE INDEX <index_name> ON <table_name>(<col_name>)
WHERE 조건='blah'
-- 특정 조건의 데이터만 자주 검색
-- 공간/비용 모두 절약

-- 인덱스를 사용하지 않음
-- 함수 사용
SELECT * FROM users WHERE UPPER(name) = 'JOHN';
-- 타입 변환
SELECT * FROM users WHERE age='25'; -- age는 숫자인데 문자를 넣음
-- 앞쪽 와일드 카드
SELECT * FROM users WHERE LIKE='%김'; -- LIKE -> 앞쪽 와일드 카드
-- 부정 조건
SELECT * FROM users WHERE age!=25;

-- 해결방법
-- 함수기반 인덱싱
CREATE INDEX <name> ON users(UPPER(name))

-- 타입 잘 쓰기
-- 전체 텍스트 검색 인덱스 고려

-- 부정조건 -> 범위조건
SELECT * FROM users WHERE age < 25 OR age > 25;

-- 인덱스는 검색 성능 + | 저장 공간 추가 필요 / 수정 성능 -
-- 실제 쿼리 패턴을 분석 -> 인덱스 설계
-- 성능 측정 => 실제 데이터



