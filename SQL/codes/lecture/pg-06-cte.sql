-- pg-06-cte.sql

-- CTE (Common Table Expression) -> 쿼리 속의 '이름이 있는' 임시 테이블

-- [평균 주문 금액] 보다 큰 주문들의 고객 정보

SELECT c.customer_name, o.amount
FROM customers c
INNER JOIN orders o ON o.customer_id = c.customer_id
WHERE o.amount > (SELECT AVG(amount) FROM orders)
LIMIT 10;

-- 1단계: 평균 주문 금액 계산
WITH avg_order AS (
	SELECT AVG(amount) AS avg_amount
	FROM orders
)
-- 2단계: 평균보다 큰 주문 찾기
SELECT c.customer_name, o.amount, ao.avg_amount
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN avg_order ao ON  o.amount > ao.avg_amount
LIMIT 10;


-- 요구사항:
-- 1. 각 지역별 고객 수(DISTINCT customer_id)와 지역별 주문 수를 계산하세요
-- 2. 지역별 평균 주문 금액도 함께 표시하세요
-- 3. 고객 수가 많은 지역 순으로 정렬하세요
-- 힌트:
-- - 먼저 지역별 기본 통계를 CTE로 만들어보세요
-- - 그 다음 고객 수 기준으로 정렬하세요
-- 지역    고객수   주문수   평균주문금액
-- 서울    143     7,234   567,890
-- 부산    141     6,987   534,123
-- 대구    140     6,876   545,678

WITH region_summary AS (
	SELECT
		c.region AS 지역, 
		COUNT(DISTINCT c.customer_id) AS 고객수,
		COUNT(DISTINCT o.order_id) AS 주문수,
		ROUND(COALESCE(AVG(o.amount),0)) AS 평균주문금액
	FROM customers c
	LEFT JOIN orders o ON c.customer_id = o.customer_id
	GROUP BY c.region
)
SELECT
	지역,
	고객수,
	주문수,
	평균주문금액
FROM region_summary
ORDER BY 고객수 DESC;


-- 요구사항:
-- 1. 각 상품의 총 판매량과 총 매출액을 계산하세요
-- 2. 상품 카테고리별로 그룹화하여 표시하세요
-- 3. 각 카테고리 내에서 매출액이 높은 순서로 정렬하세요
-- 4. 각 상품의 평균 주문 금액도 함께 표시하세요
-- 힌트:
-- - 먼저 상품별 판매 통계를 CTE로 만들어보세요
-- - products 테이블과 orders 테이블을 JOIN하세요
-- - 카테고리별로 정렬하되, 각 카테고리 내에서는 매출액 순으로 정렬하세요
-- ---
-- 카테고리      상품명           총판매량   총매출액      평균주문금액   주문건수   상품가격
-- 전자제품      스마트폰 123     450       125,678,900   279,286       450       567,890
-- 전자제품      노트북 456       298       98,234,500    329,644       298       1,234,567
-- 전자제품      태블릿 789       356       87,654,321    246,197       356       890,123
-- 컴퓨터        키보드 234       567       45,678,900    80,563        567       123,456
-- 컴퓨터        마우스 345       678       34,567,890    50,982        678       89,012
-- 액세서리      이어폰 456       234       23,456,789    100,243       234       234,567

-- 카테고리별 매출 비중 분석
WITH product_sales AS (
	SELECT
		p.category AS 카테고리, 
		p.product_name AS 제품명,
		p.price AS 상품가격,
		SUM(COALESCE(o.quantity,0)) AS 제품총판매량,
		SUM(COALESCE(o.amount,0)) AS 제품총매출액,
		COUNT(o.order_id) AS 주문건수,
		ROUND(AVG(o.amount)) AS 평균주문금액
	FROM products p
	LEFT JOIN orders o ON p.product_id = o.product_id
	GROUP BY p.category, p.product_name, p.price
),
category_total AS (
	SELECT
		카테고리,
		SUM(제품총매출액) AS 카테고리총매출액
	FROM product_sales
	GROUP BY 카테고리
)
SELECT
	ps.카테고리,
	ps.제품명,
	-- ps.제품총매출액,
	-- ct.카테고리총매출액,
	ROUND(ps.제품총매출액 * 100 / ct.카테고리총매출액, 2) AS 카테고리매출비중
FROM product_sales ps
INNER JOIN category_total ct ON ps.카테고리 = ct.카테고리
ORDER BY ps.카테고리, ps.제품총매출액 DESC;


-- 고객 구매 금액에 따라 VIP(상위 20%)/ 일반(전체평균보다 높음) / 신규(나머지) 로 나누어 등급 통계를 보자.
-- [등급, 등급별 회원수, 등급별 구매액총합, 등급별 평균 주문수]

-- 1. 고객별 총 구매 금액 + 총 주문수
WITH customer_total AS(
	SELECT
		customer_id AS 고객아이디,
		SUM(amount) AS 총구매금액,
		COUNT(*) AS 총주문수
	FROM orders
	GROUP BY customer_id
),
-- 2. 구매 금액 기준 계산
	lvl AS(
	SELECT 
		-- 상위20% 기준값 구하기
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY 총구매금액) AS VIP기준,
		AVG(총구매금액) AS 일반기준
	FROM customer_total
),
-- 3. 고객 등급 분류
customer_lvl AS (
	SELECT
		고객아이디,
		총구매금액,
		총주문수,
		CASE
			WHEN 총구매금액 >= lvl.vip기준 THEN 'VIP'
			WHEN 총구매금액 >= lvl.일반기준 THEN '일반'
			ELSE '신규'
		END AS 등급
	FROM customer_total
	CROSS JOIN lvl
)
-- 4. 등급별 통계 출력
SELECT
	등급,
	COUNT(*) AS 등급별고객수,
	SUM(총구매금액) AS 등급별총구매금액,
	ROUND(AVG(총주문수), 2) AS 등급별평균주문수
FROM customer_lvl
GROUP BY 등급;










