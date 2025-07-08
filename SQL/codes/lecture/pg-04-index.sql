-- pg-04-index.sql

-- 인덱스 조회
SELECT
	tablename,
	indexname,
	indexdef
FROM pg_indexes
WHERE tablename IN ('large_orders', 'large_customers');

ANALYZE large_orders;
ANALYZE large_customers;

-- 실제 운영에서는 X (캐시 날리기)
SELECT pg_stat_reset();

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id='CUST-25000.'; -- 123.687 ms

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE amount BETWEEN 800000 AND 1000000; -- 272.894 ms

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE -- 139.576 ms
	REGION='서울' AND amount > 500000 AND order_date >= '2024-07-08';

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE REGION='서울'
ORDER BY amount DESC -- 38797.72 / 171.952 ms
LIMIT 100;

CREATE INDEX idx_orders_customer_id ON large_orders(customer_id);
CREATE INDEX idx_orders_amount ON large_orders(amount);
CREATE INDEX idx_orders_region ON large_orders(region);
-- DROP INDEX idx_orders_amount;

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id='CUST-10254.'; -- cost=4.59 / 0.075 ms

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE amount BETWEEN 800000 AND 100000; -- cost=131.68 / 0.130 ms

EXPLAIN ANALYZE
SELECT COUNT(*) FROM large_orders
WHERE region='서울'; --  cost=37654.51 / 140.775 ms  인데싱후->  cost=3556.56 / 16.806 ms


-- 복합 인덱스
CREATE INDEX idx_orders_region_amount ON large_orders(region,amount);

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region='서울' AND amount > 800000; -- 1572 / 346.639 ms -> 736 / 183 ms


CREATE INDEX idx_orders_id_order_date ON large_orders(customer_id, order_date);

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id = 'CUST-25000.'
	AND order_date >= '2024-07-01'
ORDER BY order_date DESC; -- 0.089 ms -> 0.054 ms

-- Index 순서 가이드라인

-- 고유값 비율
SELECT
	COUNT(DISTINCT region) AS 고유지역수,
	COUNT(*) AS 전체행수,
	ROUND(COUNT(DISTINCT region) * 100 / COUNT(*), 2) AS 선택도
FROM large_orders; -- 0.0007%

SELECT
	COUNT(DISTINCT amount) AS 고유금액수,
	COUNT(*) AS 전체행수
FROM large_orders; -- 선택도 99%

SELECT
	COUNT(DISTINCT customer_id) AS 고유고객수,
	COUNT(*) AS 전체행수
FROM large_orders; -- 선택도 50%

















