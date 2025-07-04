-- p09.sql
USE practice;

SELECT COUNT(*) FROM sales
UNION
SELECT COUNT(*) FROM customers;

-- 주문 거래액이 가장 높은 10건의 고객명, 상품명, 주문금액
SELECT
	customer_name AS 고객명,
    product_name AS 상품명,
    total_amount AS 주문금액
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
ORDER BY total_amount DESC
LIMIT 10;

-- 고객 유형별 [고객 유형, 주문건수, 평균주문금액]을 평균주문금액 높은순으로 정렬해서 보여주자.
SELECT
	c.customer_type AS 고객유형,
    COUNT(s.id) AS 주문건수,
    AVG(total_amount) AS 평균주문금액
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_type;

-- 문제 1: 모든 고객의 이름과 구매한 상품명 조회
SELECT
	c.customer_name AS 고객명,
    coalesce(s.product_name, '❎') AS 상품명
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
ORDER BY customer_name;

-- 문제 2: 고객 정보와 주문 정보를 모두 포함한 상세 조회
SELECT
	c.customer_name AS 고객명,
    c.customer_type AS 고객유형,
    c.join_date AS 가입일,
    s.product_name AS 상품명,
    s.category AS 카테고리,
    s.total_amount AS 주문금액,
    s.order_date AS 주문일
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
ORDER BY 주문일 DESC;

-- 문제 3: VIP고객들의 구매 내역만 조회
SELECT
    c.customer_name AS 고객명,
    c.customer_type AS 고객유형,
    s.total_amount AS 주문금액,
    s.product_name AS 제품명,
    s.region AS 지역,
    s.order_date AS 주문일
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
WHERE c.customer_type = 'VIP'
ORDER BY s.total_amount DESC;

-- 문제 4: 건당 50만원 이상 주문한 기업 고객들
SELECT
    *
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
WHERE c.customer_type = '기업' AND s.total_amount >= 500000
ORDER BY s.total_amount DESC;
-- 고객 별 분석 GROUP BY

-- 문제 5: 2024년 하반기(7~12월) 전자제품 구매 내역
SELECT
	*
FROM sales
WHERE order_date BETWEEN '2024-07-01' AND '2024-12-31' AND category = '전자제품';

-- 문제 6: 고객 주문 통계 (INNER JOIN) [고객명, 유형, 주문횟수, 총구매금액, 평균구매금액, 최근주문일]
SELECT
	c.customer_id AS 고객아이디,
	c.customer_name aS 고객명,
    c. customer_type AS 유형,
    COUNT(*) AS 주문횟수,
    SUM(s.total_amount) AS 총구매금액,
    ROUND(AVG(s.total_amount)) AS 평균구매금액,
    MAX(s.order_date) AS 최근주문일
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY 평균구매금액;

-- 문제 7: 모든 고객의 주문 통계 (LEFT JOIN) - 주문 없는 고객도 포함
SELECT
	c.customer_id AS 고객아이디,
	c.customer_name aS 고객명,
    c.customer_type AS 유형,
    c.join_date AS 가입일,
    COUNT(s.id) AS 주문횟수, -- COUNT 주의
    coalesce(SUM(s.total_amount),0) AS 총구매금액, -- NULL 값 주의
    ROUND(coalesce(AVG(s.total_amount),0),0) AS 평균구매금액,
    coalesce(MAX(s.order_date),0) AS 최근주문일
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type, c.join_date
ORDER BY 총구매금액;

-- 문제 8: 상품 카테고리별로 구매한 고객 유형 분석ALL
SELECT
	s.category AS 카테고리,
    c.customer_type AS 고객유형,
    COUNT(*) AS 주문건수,
    SUM(s.total_amount) AS 총구매액,
    AVG(s.total_amount) AS 평균구매액
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY s.category, c.customer_type
ORDER BY s.category, c.customer_type;

-- 문제 9: 고객별 등급 분류 
-- 활동등급(구매횟수) : [0(잠재고객) < 브론즈 <= 3 < 실버 <= 5 < 골드 <= 10 < 플래티넘]
-- 구매등급(구매총액) : [0(신규) < 일반 <= 10만 < 우수 <= 20 < VIP <= 50만 < VIP+]
SELECT 
	c.customer_id AS 고객아이디,
	c.customer_name AS 고객명,
    c.customer_type AS 고객유형,
    COUNT(s.id) AS 구매횟수,
    coalesce(SUM(s.total_amount),0) AS 총구매액,
	CASE
		WHEN COUNT(s.id) = 0 THEN '잠재고객'
        WHEN COUNT(s.id) <= 3 THEN '브론즈'
        WHEN COUNT(s.id) <= 5 THEN '실버'
        WHEN COUNT(s.id) <= 10 THEN '골드'
		ELSE '플래티넘'
	END AS 활동등급,
	CASE
		WHEN SUM(coalesce(s.total_amount, 0)) = 0 THEN '신규'
        WHEN SUM(s.total_amount) <= 100000 THEN '일반'
        WHEN SUM(s.total_amount) <= 200000 THEN '우수'
        WHEN SUM(s.total_amount) <= 500000 THEN 'VIP'
		ELSE 'VIP+'
	END AS 구매등급
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY c.customer_name;

-- 문제 10: 활성 고객 분석
-- 고객상태('2024-12-31' - 최종구매일) [NULL(구매없음) | 활성고객 <= 30 < 관심고객 <= 90 < 휴면고객]별로 
-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석 
SELECT
	고객상태,
	COUNT(*) AS 고객수,
	SUM(고객별주문건수) AS 총주문건수,
    SUM(고객별주문금액) AS 총매출액,
    ROUND(AVG(고객별평균주문금액)) AS 평균주문금액
FROM (
SELECT
	c.customer_id AS 고객아이디,
	c.customer_name AS 고객명,	
	CASE
		WHEN Max(s.order_date) IS NULL THEN '구매없음'
        WHEN DATEDIFF('2024-12-31', Max(s.order_date)) <= 30 THEN '활성고객'
        WHEN DATEDIFF('2024-12-31', Max(s.order_date)) <= 90 THEN '관심고객'
        ELSE '휴면고객'
	END AS 고객상태,
    COUNT(s.id) AS 고객별주문건수,
    COALESCE(SUM(s.total_amount),0) AS 고객별주문금액,
    COALESCE(ROUND(AVG(s.total_amount)),0) AS 고객별평균주문금액
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id 
GROUP BY c.customer_id
) AS customer_analysis
GROUP BY 고객상태
ORDER BY 총매출액 DESC;

SELECT
	c.customer_id AS 고객아이디,
	c.customer_name AS 고객명,
	CASE
		WHEN Max(s.order_date) IS NULL THEN '구매없음'
        WHEN DATEDIFF('2024-12-31', Max(s.order_date)) <= 30 THEN '활성고객'
        WHEN DATEDIFF('2024-12-31', Max(s.order_date)) <= 90 THEN '관심고객'
        ELSE '휴면고객'
	END AS 고객상태,
    COUNT(s.id) AS 고객별주문건수,
    COALESCE(SUM(s.total_amount),0) AS 고객별주문금액,
    COALESCE(ROUND(AVG(s.total_amount)),0) AS 고객별평균주문금액
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;










