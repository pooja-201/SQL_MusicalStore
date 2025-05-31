**🎵 Musical Store SQL Analysis Project
**
📌 Project Overview

A SQL-based data analysis project on a music store database (Chinook) to uncover insights about sales, customers, and artist performance.

🧰 Tools & Environment

Database: Microsoft SQL Server
SQL Client Tool: SQL Server Management Studio (SSMS)


Dataset: (open-source)
🗂️ Database Schema-![image](https://github.com/user-attachments/assets/c010ceba-f554-4f48-ab3e-35896c50c3e9)
📂 Database Tables Used

albums
artists
customers
employees
genres
invoices
invoice_items
media_types
playlists
playlist_tracks
tracks

📊 Key SQL Queries / Insights Extracted
🎯 Question Set 1 – Easy

**Senior most employee based on job title**

SELECT * FROM employee ORDER BY levels DESC LIMIT 1;
Countries with the most invoices
SELECT billing_country, COUNT(*) AS total_invoices FROM invoice GROUP BY billing_country ORDER BY total_invoices DESC;
Top 3 invoice totals
SELECT total FROM invoice ORDER BY total DESC LIMIT 3;
City with highest invoice total
SELECT billing_city, SUM(total) AS total_revenue FROM invoice GROUP BY billing_city ORDER BY total_revenue DESC LIMIT 1;

**Best customer (most money spent)**

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent 
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id 
GROUP BY c.customer_id 
ORDER BY total_spent DESC 
LIMIT 1;

🧠 Question Set 2 – Moderate

**Emails of Rock music listeners**

SELECT DISTINCT c.email, c.first_name, c.last_name 
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id 
JOIN invoice_line il ON i.invoice_id = il.invoice_id 
JOIN track t ON il.track_id = t.track_id 
JOIN genre g ON t.genre_id = g.genre_id 
WHERE g.name = 'Rock' 
ORDER BY c.email;

**Top 10 rock bands by track count**

SELECT ar.name AS artist, COUNT(*) AS track_count 
FROM artist ar 
JOIN album al ON ar.artist_id = al.artist_id 
JOIN track t ON al.album_id = t.album_id 
JOIN genre g ON t.genre_id = g.genre_id 
WHERE g.name = 'Rock' 
GROUP BY ar.name 
ORDER BY track_count DESC 
LIMIT 10;

**Tracks longer than average length**

SELECT name, milliseconds 
FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track) 
ORDER BY milliseconds DESC;

🔍 Question Set 3 – Advanced

**Amount spent by each customer on artists**

SELECT c.first_name || ' ' || c.last_name AS customer, ar.name AS artist, SUM(il.unit_price * il.quantity) AS total_spent 
FROM invoice i 
JOIN customer c ON i.customer_id = c.customer_id 
JOIN invoice_line il ON i.invoice_id = il.invoice_id 
JOIN track t ON il.track_id = t.track_id 
JOIN album al ON t.album_id = al.album_id 
JOIN artist ar ON al.artist_id = ar.artist_id 
GROUP BY customer, ar.name 
ORDER BY total_spent DESC;

**Most popular genre by country**

WITH genre_country AS (
  SELECT c.country, g.name AS genre, COUNT(*) AS purchases 
  FROM customer c 
  JOIN invoice i ON c.customer_id = i.customer_id 
  JOIN invoice_line il ON i.invoice_id = il.invoice_id 
  JOIN track t ON il.track_id = t.track_id 
  JOIN genre g ON t.genre_id = g.genre_id 
  GROUP BY c.country, g.name
), ranked AS (
  SELECT *, RANK() OVER(PARTITION BY country ORDER BY purchases DESC) AS rnk 
  FROM genre_country
)
SELECT country, genre, purchases 
FROM ranked 
WHERE rnk = 1;

**Top customer per country by spend**

WITH customer_country AS (
  SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(i.total) AS total_spent 
  FROM customer c 
  JOIN invoice i ON c.customer_id = i.customer_id 
  GROUP BY c.customer_id, c.first_name, c.last_name, c.country
), ranked AS (
  SELECT *, RANK() OVER(PARTITION BY country ORDER BY total_spent DESC) AS rnk 
  FROM customer_country
)
SELECT country, first_name, last_name, total_spent 
FROM ranked 
WHERE rnk = 1;

▶️ How to Run

Download and install Microsoft SQL Server and SSMS.
Import the Chinook database into SQL Server.
Open SSMS, connect to the database, and run the queries from this repository.
Explore different insights or create your own extensions of the analysis.
Hub
