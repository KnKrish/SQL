## KK : 12/10/2018 : UCSD Bootcamp homework
########################################################################################

#Set database for query operation
use sakila;
## 1a. Display the first and last names of all actors from the table `actor`.
#Query table
SELECT first_name,last_name FROM actor;

## 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
#Query table
SELECT concat(first_name,last_name) AS 'Actor Name' FROM actor;

## 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
#Query table
SELECT  actor_id,first_name,last_name FROM actor
WHERE first_name like 'Joe%';

## 2b. Find all actors whose last name contain the letters `GEN`:
#Query table
SELECT  first_name,last_name  FROM actor
WHERE last_name like '%GEN%';

## 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
#Query table and display in order
SELECT first_name,last_name FROM actor
WHERE last_name like '%LI%'
order by last_name,first_name;

## 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
#Query table
SELECT country_id,country FROM country
WHERE country in ( 'Afghanistan', 'Bangladesh', 'China');

## 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
#Add column
ALTER TABLE actor
ADD description blob;

#commit
commit;

## 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
#check
select * from actor;

#Drop column
ALTER TABLE actor
DROP COLUMN description;

#commit
commit;

#Check
select * from actor;

## 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) AS last_name_cnt from actor
group by last_name;

## 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT * from (SELECT last_name, count(last_name) AS last_name_cnt from actor
group by last_name)V
WHERE last_name_cnt >1;

## 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#commit
commit;

## 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

#commit
commit;

#check
SELECT * from actor WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

## 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
# * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW create table address;

##* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
Select first_name,last_name, address from staff A left join address B
ON A.address_id = B.address_id;

## 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT A.staff_id,first_name,last_name,payment_date, SUM(amount) from staff A, payment B
WHERE A.staff_id = B.staff_id
      AND YEAR(payment_date) = '2005' AND MONTH(payment_date) = '08'
group by A.staff_id,first_name,last_name,payment_date;

## 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT title AS 'Film', count(A.actor_id) AS 'Number of Actor' from film_actor A,film B
WHERE A.film_id = B.film_id
group by title;

## 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select A.title 'Film', count(inventory_id) AS 'Copy Available' from film A, inventory B
WHERE A.film_id = B.film_id
      AND A.title = 'Hunchback Impossible';

## 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
Select A.first_name,A.last_name, SUM(amount) as 'Total Amount Paid' from Customer A, payment B
WHERE A.customer_id = B.customer_id
group by A.first_name,A.last_name
order by A.last_name;

## 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT  title, 'English' As Language from film
WHERE (title like 'K%' OR title like 'Q%')
      AND language_id IN (select language_id from language where name = 'English');

## 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name FROM actor 
WHERE actor_id IN (
      select actor_id from film_actor where film_id IN (
	  SELECT film_id from film WHERE title = 'ALONE TRIP'))
Order by first_name;


## 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name,last_name,email from customer A, address B, city C, country D
WHERE A. address_id = B.address_id
	  AND B.city_id = C.city_id
	  AND C.country_id = D.country_id
      AND D.country = 'Canada';

## 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT A.title from film A, category B,film_category C
WHERE c.category_id = b.category_id
	  AND b.Name = 'Family'
      AND c.film_id = a.film_id
      order by 1;
      

## 7e. Display the most frequently rented movies in descending order.

select title as 'film', count(title) as 'times_rented' from rental A, inventory B, film C
WHERE A.inventory_id = B.inventory_id
     AND B.film_id = C.film_id
group by title
order by times_rented desc;

## 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id,SUM(Amount) AS 'Sales Amount($)' from rental A, inventory B, payment C
WHERE c.rental_id = A.rental_id
	AND A.inventory_id = B.inventory_id
group by store_id;
    

## 7g. Write a query to display for each store its store ID, city, and country.

select store_id,city,country from store A, address B, city C, country D
WHERE a.address_id = b.address_id
      AND b.city_id = c.city_id
      AND c.country_id = D.country_id;


## 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT name as 'Genres' , sum(amount) AS 'Gross Revenue' from rental A, inventory B, payment C, film_category D, category E
WHERE c.rental_id = A.rental_id
	AND A.inventory_id = B.inventory_id
	AND B.film_id = D.film_id
    AND D.category_id  = E.category_id
group by name
order by 2 desc
Limit 5;
    
## 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE OR REPLACE VIEW sakila.Top5_Genres_Revenue_VIEW AS 
SELECT name as 'Genres' , sum(amount) AS 'Gross Revenue' from rental A, inventory B, payment C, film_category D, category E
WHERE c.rental_id = A.rental_id
	AND A.inventory_id = B.inventory_id
	AND B.film_id = D.film_id
    AND D.category_id  = E.category_id
group by name
order by 2 desc
Limit 5;

## 8b. How would you display the view that you created in 8a?
Select * from Top5_Genres_Revenue_VIEW;

## 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW sakila.Top5_Genres_Revenue_VIEW;
