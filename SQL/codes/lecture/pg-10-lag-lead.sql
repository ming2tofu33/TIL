-- pg-10-lag-lead.sql

-- 매일 체중 기록
-- LAG() - 이전 값을 가져온다.
-- 전월 대비 매출 분석

-- 매달 매출을 확인
-- 위 테이블에 증감률 컬럼추가

-- 전월 대비 매출 분석
WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) AS 월매출
	FROM orders
	GROUP BY 월
), monthly_diff AS(
SELECT
	TO_CHAR(월, 'YYYY-MM') AS 년월,
	월매출,
	LAG(월매출, 1) OVER (ORDER BY 월) AS 전월매출
FROM monthly_sales
)
SELECT
	년월,
	월매출,
	월매출 - 전월매출 AS 증감액,
	CASE
		WHEN 전월매출 IS NULL THEN NULL
		ELSE ROUND((월매출 - 전월매출) * 100 / 전월매출,2):: TEXT || '%'
	END AS 증감률
FROM monthly_diff
ORDER BY 년월;
	

--  고객별 다음 구매를 예측?
-- [고객ID, 주문일, 구매액, 다음구매일, 다음구매액수]
-- 고객별로 PARTITION BY
-- ORDER BY customer_id, order_date LIMIT 10;
SELECT
	customer_id AS 고객ID, 
	order_date AS 주문일,
	amount AS 구매액,
	LEAD(order_date,1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일, 
	LEAD(amount,1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매액수
FROM orders
WHERE customer_id = 'CUST-000001'
ORDER BY 고객ID, 주문일 


-- [고객id, 주문일, 금액, 구매순서(ROW_NUMBER)]
--	이전구매간격, 다음구매간격
-- 금액변화=(이번-저번), 금액변화율
-- 누적 구매 금액(SUM OVER)
-- [추가]누적 평균 구매 금액 (AVG OVER)
WITH c_orders AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as 구매순서,
		customer_id AS 고객ID, 
		order_date AS 주문일,
		amount AS 구매액,
		LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매일,
		LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
		LAG(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매액,
		LEAD(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매액		
	FROM orders
)
SELECT
	구매순서,
	고객ID,
	주문일,
	구매액,
	-- 구매간격
	주문일 - 이전구매일 AS 이전구매간격,
	다음구매일 - 주문일 AS 다음구매간격,
	-- 구매금액변화
	구매액 - 이전구매액 AS 금액변화,
	-- 구매금액변화율
	CASE
		WHEN 이전구매액 IS NULL THEN NULL
		ELSE ROUND((구매액 - 이전구매액) *100 / 이전구매액,2)::TEXT || '%'
	END AS 금액변화율,
	-- 누적구매통계
	SUM(구매액) OVER (PARTITION BY 고객ID ORDER BY 주문일) AS 누적구매액,
	-- 평균구매통계
	ROUND(AVG(구매액) OVER (PARTITION BY 고객ID ORDER BY 주문일),2) AS 평균구매액,
	-- 고객 구매 단계 분류
	CASE
		WHEN 구매순서 = 1 THEN '첫구매'
		WHEN 구매순서 <= 3 THEN '신규고객'
		WHEN 구매순서 <= 10 THEN '일반고객'
		ELSE 'VIP'
	END AS 고객등급
FROM c_orders
ORDER BY 고객ID, 주문일;



































