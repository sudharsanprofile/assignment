USE film_rental;

/* 1.	What is the total revenue generated from all rentals in the database?  */

select * from payment;

select sum(amount) as 'Total Revenue' from payment;


/* 2.	How many rentals were made in each month_name?  */
select * from payment;

select monthname(payment_date) as Month , count(payment_id) as 'No of Rentals'
from payment
group by Month
order by 2 desc;


/* 3.	What is the rental rate of the film with the longest title in the database?  */
select * from film;

select title , length(title) as 'length Title', rental_rate
from film
where length(title) = (select max(length(title)) from film);


/* 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")?  */
select * from rental
order by 2 asc ;

select * from film;
select * from inventory;

select  a.title, 
datediff( c.rental_date,"2005-05-05 22:04:30") as Difference,
avg(rental_rate) as avg_rent
from film a
left join inventory b
on a.film_id = b.film_id
left join rental c
on b.inventory_id = c.inventory_id
where datediff( c.rental_date,"2005-05-05 22:04:30") <= 30
group by 1,2
order by 1,2;


/* 5.	What is the most popular category of films in terms of the number of rentals? */

select * from film;
select * from inventory;
select * from rental;
select * from film_category;
select * from category;

select 
e.name as Category, 
count(c.rental_id) as Rentals
from film a
inner join inventory b
on a.film_id = b.film_id
inner join rental c
on b.inventory_id = c.inventory_id
inner join film_category d
on a.film_id = d.film_id 
inner join category e
on e.category_id = d.category_id
group by 1
order by Rentals desc
limit 1;



/* 6.	Find the longest movie duration from the list of films that have not been rented by any customer.  */

select * from film;
select * from rental;
select * from inventory;

with base as
(select title,
count(c.rental_id) as Rentals
from film a
left join inventory b
on a.film_id = b.film_id
left join rental c
on b.inventory_id = c.inventory_id
group by 1
order by Rentals asc)
select a.*, b.length
from base a
inner join film b
on a.title = b.title
having Rentals = 0
order by 3 desc
limit 1;


/* 7.	What is the average rental rate for films, broken down by category? */

select * from film;
select  * from film_category;
select * from category;

select  e.name,  a.title,
avg(rental_rate) 
from film a
inner join film_category d
on a.film_id = d.film_id
inner join category e 
on e.category_id = d.category_id
group by 1,2;


/*  8.	What is the total revenue generated from rentals for each actor in the database?  */

select * from film;
select * from film_actor;
select * from actor;

select a.actor_id, a.first_name, a.last_name, sum(c.rental_rate* c.rental_duration) as Revenue
from actor a
inner join film_actor b
on a.actor_id = b.actor_id
inner join film c
on b.film_id = c.film_id
group by 1,2,3
order by 1;


/* 9.	Show all the actresses who worked in a film having a "Wrestler" in the description.   */

select * from film;
select * from film_actor;
select * from actor;

select distinct a.first_name, a.last_name
from actor a
inner join film_actor b
on a.actor_id = b.actor_id
inner join film c
on b.film_id = c.film_id
where c.description like '%Wrestler%'
order by 1 ;

-- No column specifying the gender was given in any of the tables, so the whole actors were taken.


/* 10.	Which customers have rented the same film more than once?  */

select * from customer;
select * from rental;
select * from inventory;

select a.first_name,a.last_name, d.title, count(d.title) as Times_rented
from customer a
inner join rental b
on a.customer_id =b.customer_id
inner join inventory c
on b.inventory_id = c.inventory_id
inner join film d
on c.film_id = d.film_id
group by 1,2,3
having Times_rented>1
order by Times_rented desc ;

/* 11.	How many films in the comedy category have a rental rate higher than the average rental rate?   */

select * from film;
select * from film_category;
select * from category;

select c.name, count(distinct a.film_id) as 'Total films'
from film a
inner join film_category b
on a.film_id = b.film_id
inner join category c
on b.category_id = c.category_id
where c.name like '%comedy%' and a.rental_rate > (select avg(rental_rate) from film)
group by 1;


/* 12.	Which films have been rented the most by customers living in each city? */

select * from customer;
select * from rental;
select * from inventory;
select * from address;
select * from city;

with m_rented as
(select f.city, d.title, count(d.title) as Times_rented,
row_number() over(partition by f.city) as Most_rented
from customer a
inner join rental b
on a.customer_id =b.customer_id
left join inventory c
on b.inventory_id = c.inventory_id
left join film d
on c.film_id = d.film_id
left join address e
on e.address_id = a.address_id
left join city f
on f.city_id = e.city_id
group by 1,2)
select distinct city, title, Times_rented
from m_rented
where Most_rented = 1
order by Times_rented desc;


/* 13.	What is the total amount spent by customers whose rental payments exceed $200?   */

select * from payment;
select * from customer;

select b.customer_id, a.first_name, a.last_name, sum(b.amount) as Total_amount
from customer a
inner join payment b
on a.customer_id = b.customer_id
group by a.customer_id
having Total_amount >200;


/* 14.	Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema]   */

desc rental;

select * from information_schema.key_column_usage
where referenced_table_name = 'rental';


/* 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name.   */

select * from store;
select * from address;
select * from city;
select * from country;
select * from staff;
select * from payment;

create view Revenue_Generated as
select  c.city,d.country, e.first_name, e.last_name, sum(amount)
from store a
inner join address b
on a.address_id = b.address_id
inner join city c
on b.city_id = c.city_id
inner join country d
on c.country_id = d.country_id
inner join staff e
on a.store_id = e.store_id
inner join payment f
on e.staff_id = f.staff_id
group by 1,2,3,4;

select * from Revenue_generated;



/* 16.	Create a view based on rental information consisting of visiting_day, 
customer_name, the title of the film,  no_of_rental_days, the amount paid by the 
customer along with the percentage of customer spending.   */

select * from customer;
select * from rental;
select * from payment;
select * from inventory;
select * from film;

create view Rental_Info as
select b.rental_date as visiting_day, a.first_name, a.last_name, e.title, 
datediff(b.return_date,b.rental_date)  as no_of_rental_days, 
c.amount, round(c.amount/(sum(c.amount) over(partition by a.first_name ))*100,2) as Percentage_spent
from customer a
inner join rental b
on a.customer_id = b.customer_id
inner join payment c
on b.rental_id = c.rental_id
inner join inventory d
on b.inventory_id = d.inventory_id
inner join film e
on d.film_id = e.film_id 
having no_of_rental_days is not null ;

select * from Rental_Info;




/* 17.	Display the customers who paid 50% of their total rental costs within one day.   */

select * from payment;
select * from customer;

with base as 
(
select payment_date,customer_id,sum(amount) amount 
from payment 
group by 1,2 
),
base2 as
(
select payment_date,customer_id, amount, sum(amount) over (partition by customer_id) total_amount 
from base
) 
select a.payment_date,a.customer_id, b.first_name, b.last_name , a.amount, a.total_amount
from base2 a
inner join customer b
on a.customer_id= b.customer_id
where amount/total_amount >= 0.5 ; 