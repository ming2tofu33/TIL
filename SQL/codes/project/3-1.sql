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


-- 상 난이도
-- 월별 매출 및 전월 대비 증감률
-- 각 연월(YYYY-MM)별 총 매출과, 전월 대비 매출 증감률을 구하세요.
-- 결과는 연월 오름차순 정렬하세요.
WITH ts AS (
	SELECT
		TO_CHAR(invoice_date, 'YYYY-MM') AS month,
		SUM(total) AS total_sales
	FROM invoices
	GROUP BY month
),
ps AS (
	SELECT
		month,
		total_sales,
		LAG(total_sales) OVER (ORDER BY month) AS previous_sales
	FROM ts
)
SELECT 
	month,
	total_sales,
	CASE
		WHEN previous_sales IS NULL THEN NULL
		ELSE ROUND((total_sales - previous_sales) * 100 / previous_sales,2)::TEXT || '%'
	END AS rate_of_change
FROM ps;


-- 장르별 상위 3개 아티스트 및 트랙 수
-- 각 장르별로 트랙 수가 가장 많은 상위 3명의 아티스트(artist_id, name, track_count)를 구하세요.
-- 동점일 경우 아티스트 이름 오름차순 정렬.
WITH tca AS (
	SELECT
		t.genre_id,
		g.name AS genre_name,
		al.artist_id,
		ar.name AS artist_name,
		COUNT(*) AS track_count,
		ROW_NUMBER() OVER (PARTITION BY t.genre_id ORDER BY COUNT(*) DESC) AS rank
	FROM tracks t
	INNER JOIN genres g ON t.genre_id = g.genre_id
	INNER JOIN albums al ON al.album_id = t.album_id
	INNER JOIN artists ar ON ar.artist_id = al.artist_id
	GROUP BY t.genre_id, genre_name, al.artist_id, ar.name
)
SELECT
	genre_name,
	artist_name,
	track_count
FROM tca
WHERE rank <= 3
ORDER BY genre_name, rank
;


-- 고객별 누적 구매액 및 등급 산출
-- 각 고객의 누적 구매액을 구하고,
-- 상위 20%는 'VIP', 하위 20%는 'Low', 나머지는 'Normal' 등급을 부여하세요.
WITH cs AS (
	SELECT
		c.customer_id,
		c.first_name,
		c.last_name,
		COALESCE(SUM(i.total)) AS customer_sales
	FROM customers c
	LEFT JOIN invoices i ON c.customer_id = i.customer_id
	GROUP BY c.customer_id
),
g AS (
	SELECT
		customer_id,
		first_name,
		last_name,
		customer_sales,
		NTILE(5) OVER (ORDER BY customer_sales DESC) AS grade
	FROM cs
)
SELECT
	customer_id,
	first_name,
	last_name,
	customer_sales,
	CASE
		WHEN grade = 1 THEN 'VIP'
		WHEN grade IN (2,3,4) THEN 'Normal'
		WHEN grade = 5 THEN 'Low'
	END AS customer_grade
FROM g;


-- 국가별 재구매율(Repeat Rate)
-- 각 국가별로 전체 고객 수, 2회 이상 구매한 고객 수, 재구매율을 구하세요.
-- 결과는 재구매율 내림차순 정렬.
SELECT
	billing_country,
	-- COUNT(DISTINCT customer_id) AS count_country_customers,
	(SELECT COUNT(*) FROM invoices GROUP BY billing_country, customer_id)
FROM invoices
GROUP BY billing_country;


SELECT billing_country, COUNT(DISTINCT customer_id) FROM invoices GROUP BY billing_country

-- 최근 1년간 월별 신규 고객 및 잔존 고객
-- 최근 1년(마지막 인보이스 기준 12개월) 동안,
-- 각 월별 신규 고객 수와 해당 월에 구매한 기존 고객 수를 구하세요.
WITH fi AS (
	SELECT
		customer_id,
		invoice_date,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY invoice_date) AS first_invoice
	FROM invoices
),
fim AS (
	SELECT
		customer_id,
		invoice_date,
		first_invoice,
		TO_CHAR(invoice_date, 'YYYY-MM') AS first_invoice_month
	FROM fi
	WHERE first_invoice = 1
),
filtered_invoices AS (
	SELECT
		i.customer_id,
		TO_CHAR(i.invoice_date, 'YYYY-MM') AS month,
		f.first_invoice_month
	FROM invoices i
	INNER JOIN fim f ON i.customer_id = f.customer_id
	WHERE i.invoice_date BETWEEN 
		(SELECT MAX(invoice_date) - INTERVAL '1 year' FROM invoices) AND
		(SELECT MAX(invoice_date) FROM invoices)
)
SELECT
	month,
	COUNT(DISTINCT customer_id) AS remained_customers,
	COUNT(DISTINCT 
		CASE 
			WHEN month = first_invoice_month THEN customer_id END
		) AS new_customers
FROM filtered_invoices
GROUP BY month;





