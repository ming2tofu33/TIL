-- 16-subquery1.sql
USE lecture;

-- 매출 평균보다 더 높은 금액을 주문한 판매데이터(*) 보여줘
SELECT AVG(total_amount) FROM sales;
SELECT * FROM sales WHERE total_amount > 612862;

-- 서브쿼리
SELECT * FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);


SELECT
	product_name AS 이름,
    total_amount AS 판매액,
	total_amount - (SELECT AVG(total_amount) FROM sales) AS 평균차이
FROM sales
-- 평균보다 더 주문한
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);

-- 데이터 하나 나오는 경우
SELECT AVG(quantity) FROM sales;
-- 데이터가 여러개 나오는 경우
SELECT * FROM sales;

-- sales 에서 | 가장 비싼 걸 시킨 주문을 한 사람 -> total_amount
-- SELECT * FROM sales ODER BY total_amount DESC LIMIT 1;
SELECT * FROM sales WHERE total_amount = (SELECT MAX(total_amount) FROM sales);

-- 가장 최근 주문일 | 의 주문 데이터
SELECT * FROM sales WHERE order_date = (SELECT MAX(order_date) FROM sales);

-- 가장 [주문액수 평균]과 유사한 주문데이터 5개
SELECT 
	customer_id,
    product_name,
    order_date,
    total_amount,
    -- 평균과 주문 사이의 차액
    ABS((SELECT AVG(total_amount) FROM sales) - total_amount) AS 평균차액
FROM sales  
ORDER BY 평균차액
LIMIT 5;


