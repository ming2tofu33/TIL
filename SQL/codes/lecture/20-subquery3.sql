-- 20-subquery3.sql
USE lecture;

-- 각 고객의 주문정보 [c_id, c_name, c_type, 총 주문횟수, 총 주문금액, 최근주문일]


-- 각 카테고리별 평균매출 중에서 50만 원 이상만 구하기
SELECT
	category,
    AVG(total_amount) as 평균매출액
FROM sales
GROUP BY category
HAVING 평균매출액 >= 500000;

-- 인라인 뷰(View) => 내가 만든 테이블
SELECT *
FROM (
	SELECT
	category,
    AVG(total_amount) as 평균매출액
	FROM sales
	GROUP BY category
    ) AS category_summary
WHERE 평균매출액 >= 500000;




-- 카테고리별 매출 분석 후 필터링
-- 카테고리명, 주문건수, 총매출, 평균매출, 0 <= 저단가 < 400000 <= 중단가 < 800000 <= 고단가]
SELECT
	카테고리,
    판매건수,
    총매출,
    평균매출,
    CASE
		WHEN 평균매출 >= 800000 THEN '고단가'
		WHEN 평균매출 >= 800000 THEN '중단가'
        ELSE '저단가'
	END AS 단가구분
FROM (
	SELECT
		category AS 카테고리,
        count(id) AS 판매건수,
        SUM(total_amount) AS 총매출,
        ROUND(AVG(total_amount)) AS 평균매출
    FROM sales
    GROUP BY category
) AS c_a
WHERE 평균매출 >= 300000;

-- 영업사원별 성과 등급 분류 [영업사원, 총매출액, 주문건수, 평균주문액, 매출등급, 주문등급]
-- 매출등급 -> 총매출[0 <= C < 1000000 <= B < 3000000 <= A < 5000000 <= S]ALTER
-- 주문등급 -> 주문건수 [0 <= C < 15 <= B < 30 <= A]
-- ODER BY 총매출액 DESC
SELECT
	영업사원, 총매출, 주문건수, 평균매출,
    CASE
		WHEN 총매출 >= 20000000 THEN 'S'
		WHEN 총매출 >= 15000000 THEN 'A'
		WHEN 총매출 >= 10000000 THEN 'B'
		ELSE 'C'
    END AS 매출등급,
	CASE
		WHEN 주문건수 >= 25 THEN 'A'
		WHEN 주문건수 >= 20 THEN 'B'
		ELSE 'C'
    END AS 주문등급
FROM (
SELECT
	sales_rep AS 영업사원,
    SUM(total_amount) AS 총매출,
    COUNT(*) AS 주문건수,
    ROUND(AVG(total_amount)) AS 평균매출
FROM sales
GROUP BY sales_rep
) AS rep
ORDER BY 총매출 DESC;



