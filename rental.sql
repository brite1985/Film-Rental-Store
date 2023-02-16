show databases;
use sakila;

/*Which rating do we have the most films in?*/

SELECT rating
FROM film
Group by rating
ORDER by count(*)
limit 1;

/*Which rating is most prevalant in each store?*/

Select temp.store_id, temp.rating, max(temp.cnt)
from
(select s.store_id,f.rating,count(*) as cnt
from
store s join inventory i on s.store_id = i.store_id
join film f on i.film_id = f.film_id
group by s.store_id,f.rating)  temp
group by temp.store_id;

/* List of films by Film Name, Category, Language*/

select f.title as 'film name', c.name as category, l.name as language
from
film f 
join film_category fc on f.film_id = fc.film_id
join language l on f.language_id = l.language_id
join category c on c.category_id = fc.category_id; 

/* How many times each movie has been rented out? */

select f.title, count(*) as 'cnt of rent'
from inventory i 
join rental r on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by i.film_id
order by count(*) desc;

/*Revenue per Movie */

select f.title, COUNT(i.film_id)*f.rental_rate AS revenue_per_movie
from inventory i 
join rental r on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by i.film_id
order by COUNT(i.film_id)*f.rental_rate desc;

/* Most Spending Customer so that we can send him/her rewards or debate points*/

select c.customer_id, c.first_name, c.last_name, SUM(p.amount) as "Total Spending"
from customer c
join payment p on c.customer_id = p.customer_id
group by c.customer_id
order by SUM(p.amount) desc;

/* What Store has historically brought the most revenue */

select s.store_id, sum(p.amount) as store_revenue
from
store s  
join inventory i on s.store_id = i.store_id
join rental r on r.inventory_id= i.inventory_id
join payment p on p.rental_id = r.rental_id
group by s.store_id
order by sum(p.amount) desc;

/*How many rentals we have for each month*/

select count(*) as 'number of rental', DATE_FORMAT(r.rental_date, '%Y-%m') as 'year and month'
from rental r
group by 2
order by 2 desc;

/* For each movie, when was the first time and last time it was rented out? */

select f.film_id, f.title, min(r.rental_date) as 'first time', max(r.rental_date) as 'last time'
from
film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id
group by f.film_id;

/* How many distint Renters per month*/

select DATE_FORMAT(p.payment_date, '%Y-%m') as 'month', count(distinct p.customer_id) as num_renters
from
payment p 
group by 1;

/*Number of Distinct Film Rented Each Month */

select i.film_id, f.title, DATE_FORMAT(r.rental_date, '%Y-%m') as "month", COUNT(i.film_id) as "num Of rental times"
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
group by 1, 3
order by 1, 2, 3;

/* Number of Rentals in Comedy , Sports and Family */

select c.name,count(*) as 'num_of rental'
from 
film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
where c.name in ("Comedy", "Sports", "Family")
group by 1;

/*Users who have been rented at least 3 times*/

select c.customer_id, c.first_name, c.last_name, count(*) as 'rental times'
from
customer c 
join rental r on c.customer_id = r.customer_id
group by c.customer_id
having count(*) >= 3;

/*How much revenue has one single store made over PG13 and R rated films*/

select s.store_id, sum(p.amount)
from
film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id	
join store s on s.store_id = i.store_id
join payment p on p.rental_id = r.rental_id
where f.rating in ('PG-13','R')
group by s.store_id;

/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_active_users;
CREATE TEMPORARY TABLE tbl_active_users(
SELECT c.*, a.phone
FROM customer c
JOIN address a ON a.address_id = c.address_id
WHERE c.active = 1);

/* Reward Users : who has rented at least 30 times*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewards_user;
CREATE TEMPORARY TABLE tbl_rewards_user(
SELECT r.customer_id, COUNT(r.customer_id) AS total_rents, max(r.rental_date) AS last_rental_date
FROM rental r
GROUP BY 1
HAVING COUNT(r.customer_id) >= 30);

/* Reward Users who are also active */
select au.customer_id, au.first_name, au.last_name, au.email
from tbl_rewards_user ru
join tbl_active_users au on au.customer_id = ru.customer_id;

/* All Rewards Users with Phone */
select  c.customer_id,a.phone
from tbl_rewards_user ru
join customer c on ru.customer_id = c.customer_id
join address a on c.address_id = a.address_id;

