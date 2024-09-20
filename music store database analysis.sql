-- senior most employee based on job titlle
select * from employee
order by levels desc
limit 1

-- country that have most invoices
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc

--top three values of total invoices
select total from invoice
order by total desc
limit 3

--The city that has the best customer
select * from invoice
select sum(total) as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc

-- The customer who has spent the most money i.e the THE BEST CUSTOMER
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) 
as total from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

-- The query to return the email,first_name, last_name and genre of all Rock music listeners.
select distinct email, first_name, last_name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(select track_id from track join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock')
-- list ordered by alphabatically by email
order by email

--let's invite the artist who have written the most rock music in our dataset.
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id= track.album_id
join artist on artist.artist_id= album.artist_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

--All the track names that have a song length longer than average song length ordered by the longest songs listed.
select name, milliseconds from track
where milliseconds > (
select avg(milliseconds) as avg_track_length from track
)
order by milliseconds desc

--A query to return customer name, artist name and spent to know the how much amount spent by each customer on artist.
with best_selling_artist as(
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id= invoice_line.track_id
join album on album.album_id= track.album_id
join artist on artist.artist_id= album.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--We want to find out the most popoular music genre for each country.
--(We determine the most popular genre as with the highest amount of purchases)
with popular_genre as
(
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc)as RowNo
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1

--A query that determines the customer that has spent most on music for each country
--And returns the country along with the top customers and how much they spent.
with recursive customer_with_country as (
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 2,3 desc
),
country_max_spending as (
select billing_country, max(total_spending) as max_spending
from customer_with_country cc
group by billing_country)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1