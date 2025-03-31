--Q1: Who is the senior most employee based on job title ?
select 
employee_id,
CONCAT(last_name,' ',first_name) as full_name,
title 
from employee
where title like '%Senior%'

select top 1 
employee_id,
CONCAT(first_name,' ',last_name) as full_name,
title,
levels
from employee
order by levels desc

--Which countries have the most Invoices ?
select top 5 
billing_country as Country,
COUNT(invoice_id) as total_invoice

from invoice
group by billing_country
order by COUNT(invoice_id) desc

-- What are the top 3 values of total invoice
select top 3
invoice_id,
round(total,2)
from invoice
order by total desc

/*
Which city has the best customers? We would like to throw a 
promotional music festival in the city we made the most money. write a query 
that returns one city that has the highest sum of invoice to tales return both the city name and sum of all invoice totals.
*/

select top 3 
C.city,
round(sum(total),2) as total_revenue
from customer C
join invoice I
on C.customer_id=I.customer_id
group by C.city
order by total_revenue desc

select  top 3
billing_city,
round(sum(total),2) as total_revenue
from invoice
group by billing_city
order by total_revenue desc

/*Who is the best customer? The customer Who has spent the most money will be declared the best customer.
 write aquerry that returns the portion who has spend the most money */
select TOP 1
c.customer_id,
CONCAT(C.first_name,' ',c.last_name) as full_name,
round(sum(total),2) as total_spend
from customer C 
join invoice I 
on C.customer_id=I.customer_id
group by C.customer_id,CONCAT(C.first_name,' ',c.last_name)
order by total_spend desc

/* Write query to return the email, first name, last name & genre of all rock music listeners.
Return your list ordered alphabetically by email starting with A */

select
Distinct C.email,
C.first_name,
C.last_name,
G.name
from customer C
join Invoice I
on C.customer_id=I.customer_id
join invoice_line IL
on I.invoice_id=IL.invoice_id
join Track T
on T.track_id=IL.track_id
join Genre G
on G.genre_id=T.genre_id
where G.name like '%Rock%'
order by C.email asc

/*
Let's invite the artist who have written the most rock music in our dataset.
write a query that returns the artist name and total track count of the top 10 rock bands */

select top 10
Art.name as artist_name,
G.name as genre_name,
COUNT(G.name) as total_track_write
from genre G
join track T
on G.genre_id=T.genre_id
join Album A
on A.album_id= T.album_id
join artist Art
on Art.artist_id=A.artist_id
where g.name like'%rock%'
group by G.name,Art.name
order by total_track_write desc

SELECT TOP 10 
ar.name AS artist_name,
COUNT(t.track_id) AS rock_track_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY rock_track_count DESC;

/* 
Return all the track names that have a song length longer than the average song length.
Return the name and milliseconds for each track. Order by the song length with the longest songs listed first. */

select
name,
milliseconds
from track
where milliseconds >(select AVG(milliseconds) from track)
order by milliseconds desc

SELECT name AS track_name, milliseconds
FROM track
GROUP BY name, milliseconds
HAVING milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

 /*
 Find how much amount spent by each customer on artists 
 write a query to return customer name artist name and total spent.
 */
select 
ART.name AS ARTIST_NAME,
concat(c.first_name,' ',c.last_name),
round(SUM(il.unit_price * il.quantity),2) as total_amount --OVER(PARTITION BY CONCAT(c.first_name,' ',c.last_name),ART.NAME )
from customer c
join invoice I
on c.customer_id=I.customer_id
JOIN invoice_line IL
ON I.invoice_id= IL.invoice_id
JOIN track T
ON T.track_id=IL.track_id
JOIN album A
ON A.album_id=T.album_id
JOIN artist ART
ON ART.artist_id=A.artist_id
GROUP BY ART.name,c.first_name,c.last_name
order by artist_name,total_amount desc ,concat(c.first_name,' ',c.last_name)asc



SELECT DISTINCT 
    c.first_name + ' ' + c.last_name AS customer_name,
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) OVER (PARTITION BY c.customer_id, ar.artist_id) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
ORDER BY 
artist_Name desc,total_spent DESC;

/*
We want to find out the most popular music genre for each country. we determine the most
popular genre as the genre with the highest amount of purchase */
with cte as(
select customer.country,
       genre.name as genre_name,
	   sum(round(invoice_line.unit_price,1)*invoice_line.quantity) as price,
	   row_number() over(partition by customer.country order by sum(round(invoice_line.unit_price,1)*invoice_line.quantity) desc) as genre_rank
	   
from Customer join Invoice on Customer.customer_id=Invoice.customer_id
              join invoice_line on Invoice.invoice_id=invoice_line.invoice_id
			  join track on track.track_id = invoice_line.track_id
			  join Genre on genre.genre_id= track.genre_id
group by customer.country,genre.name)

select country,genre_name,price 
from cte
where genre_rank=1
order by price desc

/*
Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount 
*/
with cte as(
select
concat(customer. first_name,' ',customer.last_name) full_name,
customer.country,
SUM(invoice_line.unit_price*invoice_line.quantity) as total_spend,
row_number() over(partition by customer.country order by SUM(invoice_line.unit_price*invoice_line.quantity) desc) as serial
from customer join Invoice on customer.customer_id=Invoice.customer_id
	          join invoice_line on invoice_line.invoice_id=invoice.invoice_id
group by concat(customer. first_name,' ',customer.last_name),customer.country)

select full_name,
       country,
	   round(total_spend,1) as spend
from cte
where serial<=1









