-- pg-08-window.sql
-- window 함수 -> over() 구문

-- 전체구매액 평균
SELECT AVG(amount) FROM orders;
-- 고객별 구매액 평균
SELECT
	customer_id,
	AVG(amount)
FROM orders
GROUP BY customer_id;

-- 각 데이터와 전체 평균을 동시에 확인
SELECT
	order_id,
	customer_id,
	amount,
	AVG(amount)	OVER() as 전체평균
FROM orders
LIMIT 10;

-- ROW_NUMBER() -> 줄세우기 [ROW_NUMBER() OVER(ORDER BY 정렬기준)]
-- 주문 금액이 높은 순서로
SELECT
	order_id,
	customer_id,
	amount,
	ROW_NUMBER() OVER (ORDER BY amount DESC) as 순위
FROM orders
ORDER BY 순위
LIMIT 20 OFFSET 40;

-- 주문 날짜가 최신인 순서대로 번호 매기기
SELECT
	order_id,
	customer_Id,
	amount,
	order_date,
	ROW_NUMBER() OVER (ORDER BY order_date DESC) AS 최근주문순서,
	RANK() OVER (ORDER BY order_date DESC) AS 랭크,
	DENSE_RANK() OVER (ORDER BY order_date DESC) AS 덴스랭크
FROM orders
ORDER BY 최근주문순서
LIMIT 30;

-- 7월 매출 TOP 3 고객 찾기
-- [이름, 아이디, (해당고객)7월 구입액, 순위]
-- CTE
-- 1. 고객별 7월의 월구매액 구하기 [고객id, 월구매액]
-- 2. 기존 컬럼에 번호 붙이기 [고객id, 구매액, 순위]
-- 3. 보여주기
WITH july_sales AS (
	SELECT
		customer_id,
		SUM(amount) AS 월구매액
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
	GROUP BY customer_id
),
ranking AS(
	SELECT
		customer_id,
		월구매액,
		RANK() OVER (ORDER BY 월구매액 DESC) AS 순위
	FROM july_sales
)
SELECT
	r.customer_id,
	c.customer_name,
	r.월구매액,
	r.순위
FROM ranking r
INNER JOIN customers c ON r.customer_id = c.customer_id
ORDER BY r.순위


-- 각 지역에서 매출 1위 고객 => ROW_NUMBER()로 숫자를 매기고, 이 컬럼의 값이 1인 사람
-- [지역, 고객이름, 총구매액]
-- CTE
-- 1. 지역-사람별 "매출 데이터" 생성 [지역, 고객id, 이름, 해당 고객의 총 매출]
-- 2. "매출데이터" 에 새로운 열(ROW_NUMBER) 추가
WITH region_sales AS (
	SELECT
		region, 
		customer_id, 
		sum(amount) AS 총구매액
	FROM orders
	GROUP BY region, customer_id
),
region_top_sale AS (
	SELECT
		region,
		customer_id,
		총구매액,
		RANK() OVER (PARTITION BY region ORDER BY 총구매액 DESC) AS 순위
	FROM region_sales
)
SELECT 
	r.region AS 지역,
	r.customer_id AS 고객ID,
	c.customer_name AS 이름,
	r.순위,
	r.총구매액
FROM region_top_sale r
INNER JOIN customers c ON r.customer_id = c.customer_id
WHERE 순위 = 1





