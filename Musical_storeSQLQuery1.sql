/*QI: Who is the senior most employee based on job title?*/
select * from employee
where title like 'Senior%'

OR

select * from employee
order by levels desc
limit 1



/*Q2: Which countries have the most Invoices?*/
select count(invoice_id) as no_of_invoice ,billing_country from invoice
group by billing_country
order by no_of_invoice desc



/*Q3: What are top 3 values of total invoice?*/
select top 3 (total) from invoice
order by total desc



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select top 1 billing_city,sum(total) as totalsum from invoice
group by billing_city
order by totalsum desc



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 first_name,sum(total) as totalspend from customer as c
right join invoice as i on
C.customer_id=i.customer_id
group by first_name
order by totalspend desc


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */


select email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
		select track_id from track
		join genre on track.genre_id=genre.genre_id
		where genre.name='Rock'
		)
order by email


/* Method 2 */
select email, first_name, last_name, genre.name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
where genre.name='Rock'
order by email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 artist.name,count(track.track_id) from artist
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
join genre on track.genre_id= genre.genre_id
where genre.name like 'Rock%'
group by artist.name


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds from track
where milliseconds > (select Avg(milliseconds) from track)
order by milliseconds desc



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS 
(
select top 1 artist.artist_id, artist.name as artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) as total_sale from invoice_line 
join track on invoice_line.track_id=track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by artist.artist_id,artist.name
order by total_sale
)
select  c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice as i
join customer as c on c.customer_id = i.customer_id
JOIN invoice_line as il ON il.invoice_id = i.invoice_id
JOIN track as t ON t.track_id = il.track_id
JOIN album as alb ON alb.album_id = t.album_id
JOIN best_selling_artist as bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;




/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	/*ORDER BY customer.country ASC, purchases DESC*/
)
SELECT * FROM popular_genre WHERE RowNo <= 1
order by purchases desc


/* Method 2: : Using Recursive */

WITH sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY customer.country, genre.name, genre.genre_id
		/*ORDER BY customer.country*/
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY country)
		/*ORDER BY max_genre_number)*/

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
ORDER BY billing_country ASC,total_spending DESC

/* Method 2: Using Recursive */

WITH customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country),
		/*ORDER BY first_name,last_name DESC*/

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country as cc
JOIN country_max_spending  as ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;
