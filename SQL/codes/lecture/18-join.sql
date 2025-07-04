-- 18-join.sql
-- 고객정보 + 주문정보
USE lecture;

SELECT
  *,
  (
    SELECT customer_name FROM customers c
    WHERE c.customer_id=s.customer_id
  ) AS 주문고객이름,
  (
    SELECT customer_type FROM customers c
    WHERE c.customer_id=s.customer_id
  ) AS 고객등급
FROM sales s;


-- JOIN
SELECT
*
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id;

SELECT
*
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;


-- 모든 고객의 구매 현황 분석(구매를 하지 않았어도 분석)

SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    -- 주문 횟수
    COUNT(s.id) AS 주문횟수,
    SUM(s.total_amount) AS 총구매액
FROM customers c
-- LEFT JOIN -> 왼쪽 테이블(c)의 모든 데이터와 + 매칭되는 오른쪽 데이터 | 매칭되는 오늘쪽 데이터 (없어도 등장)
LEFT JOIN sales s ON c.customer_id = s.customer_id
-- WHERE s.id IS NULL ; -> 한 번도 주문하지 않은 사람들
GROUP BY c.customer_id, c.customer_name, c.customer_type;


-- 고객마다의 구매 건수와 구매 총금액, 평균 구매액
SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount),0) AS 총구매액,
    COALESCE(AVG(s.total_amount),0) AS 평균구매액,
    CASE
		WHEN COUNT(s.id) = 0 THEN '잠재고객'
        WHEN COUNT(s.id) >= 5 THEN '충성고객'
		WHEN COUNT(s.id) >= 3 THEN '일반고객'
		ELSE '신규고객'
	END AS 활성도
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;

-- 카테고리별 제품명.
SELECT 
	category,
    product_name,
	COUNT(*),
    SUM(total_amount)
FROM sales
GROUP BY category, product_name
ORDER BY category;

-- INNER JOIN 교집합
SELECT 
	'1. INNER JOIN' AS 구분,
    COUNT(*) AS 줄수,
    COUNT(DISTINCT c.customer_id) AS 고객수
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id

UNION

-- LEFT JOIN 왼쪽(FROM 뒤에 온) 테이블은 무조건 다 나옴
SELECT
	'2.LEFT JOIN' AS 구분,
    COUNT(*) AS 줄수,
    COUNT(DISTINCT c.customer_id) AS 고객수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id

UNION

SELECT
	'3.전체 고객 수' AS 구분,
    COUNT(*) AS 행수,
    COUNT(*) AS 고객수
FROM customers;





