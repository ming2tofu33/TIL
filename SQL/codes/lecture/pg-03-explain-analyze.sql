-- pg-03-explain-analyze.sql

-- 실행 계획을 보자
EXPLAIN
SELECT * FROM large_customers WHERE customer_type = 'VIP';
-- Seq Scan on large_customers  (cost=0.00..3746.00 rows=9770 width=160)
-- cost = 점수(낮을수록 좋음) / row * width = 총 메모리 사용량
-- Filter: (customer_type = 'VIP'::text)

-- 실행 + 통계
EXPLAIN ANALYZE
SELECT * FROM large_customers WHERE customer_type = 'VIP';
-- Seq Scan on large_customers  (cost=0.00..3746.00 rows=9770 width=160) 
-- 실제 시간(actual time=0.094..23.476 rows=9966 loops=1)
-- Filter: (customer_type = 'VIP'::text)
-- Rows Removed by Filter: 90034
-- Planning Time: 0.179 ms
-- Execution Time: 23.880 ms
-- 인덱스 없고
-- 테이블 대부분의 행을 읽어야 하고
-- 순차 스캔이 빠를 때

-- 버퍼 사용량 포함
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM large_customers WHERE loyalty_points > 8000;

-- 상세 정보 포함
EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT * FROM large_customers WHERE loyalty_points > 8000;

-- JSON 형태
EXPLAIN (ANALYZE, VERBOSE, BUFFERS, FORMAT JSON)
SELECT * FROM large_customers WHERE loyalty_points > 8000;


-- 진단
EXPLAIN ANALYZE
SELECT
FROM large_customers 
LEFT JOIN large_orders o ON c.customer_name = o.customer_id
GROUP BY c.customer_name



