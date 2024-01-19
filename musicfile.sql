/* Q1: Who is the senior most employee based on job title? */
select first_name,last_name,title,levels
FROM music_database.employee
order by levels desc
limit 5; 

/* Q2: Which countries have the most Invoices? */
select count(*) as c, billing_country
FROM music_database.invoice
group by billing_country 
order by c desc
limit 5;
/* Q3: What are top 3 values of total invoice? */
select invoice_id,total from music_database.invoice
order by total desc;

/* Q4: Which city has the best customers? We would like to 
throw a promotional Music Festival in the city we made the 
most money. Write a query that returns one city that has 
the highest sum of invoice totals.Return both the city name 
& sum of all invoice totals 
*/
select billing_city, sum(total) as invoice_total
from music_database.invoice
group by billing_city
order by invoice_total desc
limit 5;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT customer.customer_id, customer.first_name, customer.last_name,SUM(invoice.total) AS total_spending
FROM music_database.customer  
JOIN music_database.invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY SUM(invoice.total) DESC
LIMIT 5;
/* Q1: Write query to return the email, first name, last name, 
& Genre of all Rock Music listeners. Return your list ordered
 alphabetically by email starting with A. */
USE music_database; 
select distinct first_name, last_name, email, genre.name AS Name
from music_database.customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.track_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;
/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
