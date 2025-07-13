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


-- 하 난이도 --
-- 모든 고객 목록 조회
-- 고객의 customer_id, first_name, last_name, country를 조회하고, customer_id 오름차순으로 정렬하세요.
SELECT
	customer_id, 
	first_name, 
	last_name, 
	country
FROM customers
ORDER BY customer_id;


-- 모든 앨범과 해당 아티스트 이름 출력
-- 각 앨범의 title과 해당 아티스트의 name을 출력하고, 앨범 제목 기준 오름차순 정렬하세요.
SELECT
	alb.title,
	art.name
FROM albums alb
INNER JOIN artists art ON alb.artist_id = art.artist_id
ORDER BY title;


-- 트랙(곡)별 단가와 재생 시간 조회
-- tracks 테이블에서 각 곡의 name, unit_price, milliseconds를 조회하세요.
-- 5분(300,000 milliseconds) 이상인 곡만 출력하세요.
SELECT
	name, 
	unit_price, 
	milliseconds
FROM tracks
WHERE 300000 < milliseconds;


-- 국가별 고객 수 집계
-- 각 국가(country)별로 고객 수를 집계하고, 고객 수가 많은 순서대로 정렬하세요.
SELECT
	country,
	COUNT(*) AS count_customers
FROM customers
GROUP BY country
ORDER BY count_customers DESC;


-- 각 장르별 트랙 수 집계
-- 각 장르(genres.name)별로 트랙 수를 집계하고, 트랙 수 내림차순으로 정렬하세요.
SELECT
	g.name,
	COUNT(*) AS count_tracks
FROM tracks t
LEFT JOIN genres g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY count_tracks DESC;



