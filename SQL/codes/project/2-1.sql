SELECT * FROM albums;
SELECT * FROM artists;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM genres;
SELECT * FROM invoice_items;
SELECT * FROM invoices;
SELECT * FROM media_types;
SELECT * FROM playlist_track;
SELECT * FROM playlists;
SELECT * FROM tracks;


-- 중 난이도
-- 직원별 담당 고객 수 집계
-- 각 직원(employee_id, first_name, last_name)이 담당하는 고객 수를 집계하세요.
-- 고객이 한 명도 없는 직원도 모두 포함하고, 고객 수 내림차순으로 정렬하세요.
SELECT
	e.employee_id,
	e.first_name,
	e.last_name,
	COALESCE(COUNT(c.customer_id),0) AS count_customers
FROM employees e
LEFT JOIN customers c ON e.employee_id = c.support_rep_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY count_customers DESC;


-- 가장 많이 팔린 트랙 TOP 5
-- 판매량(구매된 수량)이 가장 많은 트랙 5개(track_id, name, 총 판매수량)를 출력하세요.
-- 동일 판매수량일 경우 트랙 이름 오름차순 정렬하세요.
SELECT
	it.track_id,
	t.name,
	SUM(quantity) AS total_sales
FROM invoices i
INNER JOIN invoice_items it ON it.invoice_id = i.invoice_id
INNER JOIN tracks t ON it.track_id = t.track_id
GROUP BY it.track_id,t.name
ORDER BY total_sales DESC, t.name;

-- SELECT t.track_id, t.name, SUM(ii.quantity) AS total_sold
-- FROM tracks t
-- JOIN invoice_items ii ON t.track_id = ii.track_id
-- GROUP BY t.track_id, t.name
-- ORDER BY total_sold DESC, t.name ASC
-- LIMIT 5;


-- 2010년 이전에 가입한 고객 목록
-- 2010년 1월 1일 이전에 첫 인보이스를 발행한 고객의 customer_id, first_name, last_name, 첫구매일을 조회하세요.
WITH f AS (
	SELECT
		customer_id,
		MIN(invoice_date) AS first_invoice
	FROM invoices
	GROUP BY customer_id
)
SELECT
	c.customer_id,
	c.first_name, 
	c.last_name,
	f.first_invoice
FROM f
INNER JOIN customers c ON f.customer_id = c.customer_id
WHERE first_invoice < '2010-01-01'
ORDER BY f.first_invoice;


-- 국가별 총 매출 집계 (상위 10개 국가)
-- 국가(billing_country)별 총 매출을 집계해, 매출이 많은 상위 10개 국가의 국가명과 총 매출을 출력하세요.
WITH s AS (
	SELECT
		invoice_line_id,
		invoice_id,
		unit_price * quantity AS sales
	FROM invoice_items
)
SELECT
	i.billing_country,
	SUM(sales) AS sales
FROM s
INNER JOIN invoices i ON s.invoice_id = i.invoice_id
GROUP BY i.billing_country
ORDER BY sales DESC
LIMIT 10;

-- SELECT billing_country, SUM(total) AS total_sales
-- FROM invoices
-- GROUP BY billing_country
-- ORDER BY total_sales DESC
-- LIMIT 10;

-- 각 고객의 최근 구매 내역
-- 각 고객별로 가장 최근 인보이스(invoice_id, invoice_date, total) 정보를 출력하세요.
WITH ri AS (
	SELECT
		c.customer_id,
		c.first_name,
		c.last_name,
		i.invoice_id,
		i.invoice_date,
		i.total,
		ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY i.invoice_date DESC) AS recent_invoice
	FROM customers c
	LEFT JOIN invoices i ON i.customer_id = c.customer_id
)
SELECT
	customer_id,
	first_name,
	last_name,
	invoice_id,
	invoice_date,
	total
FROM ri
WHERE recent_invoice = 1
ORDER BY invoice_date DESC;

-- SELECT customer_id, invoice_id, invoice_date, total
-- FROM (
--     SELECT
--         customer_id,
--         invoice_id,
--         invoice_date,
--         total,
--         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY invoice_date DESC) AS rn
--     FROM invoices
-- ) t
-- WHERE rn = 1;






















