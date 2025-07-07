-- 27-self-join.sql
USE lecture;

SELECT * FROM employees;

-- id가 1 차이나면 적은 사람이 상사, 많은 사람이 직원
SELECT
	상사.name AS 상사명,
    직원.name AS 직원명
FROM employees 상사
LEFT JOIN employees 직원 ON 직원.id = 상사.id + 1;

-- 고객 간의 패턴 유사성
-- customers <- inner join ->sales <- inner join -> customers
-- [손님1, 손님2, 공통 구매 카테고리수, 공통 카테고리 이름(GROUP_CONCAT)]
SELECT
	c1.customer_id, 
    c1.customer_name, 
    c2.customer_id, 
    c2.customer_name,
    COUNT(DISTINCT s1.category) AS 공통구매카테고리수,
    GROUP_CONCAT(DISTINCT s1.category) AS 공통카테고리
-- 1번 손님의 구매 데이터
FROM customers c1
INNER JOIN sales s1 ON c1.customer_id = s1.customer_id -- 1번 손님의 구매데이터
-- 2번 손님의 구매 데이터
INNER JOIN customers c2 ON c1.customer_id < c2.customer_id -- 1번 손님과 다른 사람(2번)을 고르는 중
INNER JOIN sales s2 ON c2.customer_id = s2.customer_id 
	AND s1.category = s2.category-- 2번 손님의 구매 데이터
GROUP BY c1.customer_id, c1.customer_name, c2.customer_id, c2.customer_name






