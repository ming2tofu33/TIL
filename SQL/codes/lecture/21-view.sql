-- 21-view.sql
USE lecture;
DROP VIEW customer_summary;
CREATE VIEW customer_summary AS 
SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(AVG(s.total_amount), 0) AS 평균주문액,
    COALESCE(MAX(s.order_date), '주문없음') AS 최근주문일,
    c.join_date AS 가입일
FROM customers c 
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;

-- 등급별 구매 평균
SELECT 
	customer_type,
    AVG(총구매액)
FROM customer_summary
GROUP BY customer_type;

-- 충성 고객 -> 주문 횟수가 5이상
SELECT * FROM customer_summary WHERE 주문횟수 >= 5;

-- 잠재고객 -> 최근 주문 빠른 10명
SELECT * FROM customer_summary
WHERE 최근주문일 != '주문없음'
ORDER BY 최근주문일 DESC
LIMIT 10;

-- View 2: 카테고리별 성과 요약 View (category_performance)
-- 카테고리 별로, 총 주문건수, 총매출액, 평균주문금액, 구매고객수, 판매상품수, 매출비중(전체매출에서 해당 카테고리가 차지하는 비율)
-- DROP VIEW category_performance;
-- CREATE VIEW category_performance AS
SELECT
	카테고리,
    SUM(주문건수) AS 총주문건수,
    SUM(매출) AS 총매출액,
    ROUND(AVG(매출)) AS 평균주문금액,
	COUNT(DISTINCT 고객아이디) AS 구매고객수,
    COUNT(DISTINCT 판매상품) AS 판매상품수,
	CONCAT(SUM(매출) / (SELECT SUM(total_amount) FROM sales) * 100, '%') AS  매출비중
FROM (
SELECT
	category AS 카테고리,
    customer_id AS 고객아이디,
    product_name AS 판매상품,
	COUNT(*) AS 주문건수, 
    SUM(total_amount) AS 매출
FROM sales
GROUP BY category, customer_id, product_name
) as cat
GROUP BY 카테고리;


-- View 3: 월별 매출 요약 (monthly_sales)
-- 년월(24-07), 월주문건수, 월평균매출액, 월활성고객수, 월신규고객수
-- SELECT
-- 	 년월,
--      COUNT(고객)
-- FROM(
SELECT
	DATE_FORMAT(s.order_date, '%Y-%m') AS 년월,
    s.customer_id AS 고객
FROM sales s
GROUP BY DATE_FORMAT(s.order_date, '%Y-%m'), s.customer_id;
-- ) AS ym;








