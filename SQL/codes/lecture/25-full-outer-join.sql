-- 25-full-outer-join.sql
USE lecture;

-- 데이터 무결성 검사(양쪽에 비어있는 데이터 찾기)
-- MySQL에는 FULL OUTER JOIN 
-- LEFT JOIN + RIGHT JOIN -> 비어 있는 값
SELECT 
	'LEFT에서' AS 출처,
    c.customer_name,
    s.product_name
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
UNION
SELECT 
	'RIGHT에서' AS 출처,
    c.customer_name,
    s.product_name
FROM customers c
RIGHT JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_id IS NULL;
