USE sakila;
-- display first and last names of all actors from table actor
DESCRIBE actor;
SELECT first_name, last_name
FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters.  Name the column Actor Name
SELECT CONCAT(first_name, ' ', last_name) as 'Actor Name'
FROM actor;

-- You need to find the ID number, first name, and last name of an actor,  of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe';

-- Find all actors whose last name contain the letters GEN
SELECT *
FROM actor
WHERE last_name LIKE '%Gen%';  

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT *
FROM actor
WHERE first_name LIKE '%Li%'
ORDER BY  last_name, first_name; 

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
DESCRIBE country;
SELECT *
FROM country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China');

-- Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) NULL AFTER first_name;

-- Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

-- Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

-- List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
--  the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND  last_name = 'Williams';

SELECT last_name, first_name
FROM actor
WHERE last_name = 'Williams';

-- Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
SELECT first_name, last_name
FROM actor
WHERE first_name = 'HARPO';  -- have no idea what is this mean.....

-- 5 a You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;          -- not sure..... 

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT first_name, last_name, address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
DESCRIBE payment;
SELECT * FROM payment;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT COUNT(actor_id) AS 'Number of actors', title
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id
GROUP BY film.title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory 
WHERE film_id IN
	(
    SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
    );

-- 6e, Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
DESCRIBE customer; -- last_name, 
DESCRIBE payment; -- customer id common  amount
SELECT SUM(amount) AS 'Total Paid', last_name
FROM payment
INNER JOIN customer ON customer.customer_id = payment.customer_id
GROUP BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, language_id
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%'  AND language_id IN
	(
    SELECT language_id
    FROM language
    WHERE name = 'English');



-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor 
WHERE actor_id in
	(
    SELECT actor_id
    FROM film 
    WHERE title = 'Alone Trip'
    );

--  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
	(
    SELECT address_id 
    FROM address
    WHERE city_id IN
		(
        SELECT city_id
        FROM city
        WHERE country_id IN
			(
            SELECT country_id 
            FROM country
            WHERE country = 'Canada'
            )
		)
	);

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
SELECT *
FROM film
WHERE rating = 'G' or rating = 'PG';

--  Display the most frequently rented movies in descending order.
SELECT *
FROM film
ORDER BY rental_duration DESC; 

--  Write a query to display how much business, in dollars, each store brought in.
SELECT SUM(amount) AS 'Total Revenue', staff_id
FROM payment
INNER JOIN store ON store.manager_staff_id = payment.staff_id
GROUP BY staff_id;

--  Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, address.address, city.city, country.country
FROM store
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

 SELECT sum(amount) AS 'Revenue', category.category_id
FROM payment
INNER JOIN rental on rental.rental_id = payment.rental_id
INNER JOIN inventory on inventory.inventory_id = rental.inventory_id
INNER JOIN film_category on film_category.film_id = inventory.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category_id
ORDER BY Revenue DESC
LIMIT 5;

select * from category;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_category AS
SELECT sum(amount) AS 'Revenue', category.category_id
FROM payment
INNER JOIN rental on rental.rental_id = payment.rental_id
INNER JOIN inventory on inventory.inventory_id = rental.inventory_id
INNER JOIN film_category on film_category.film_id = inventory.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category_id
ORDER BY Revenue DESC
LIMIT 5;

--  How would you display the view that you created in 8a?
SELECT * 
FROM sakila.top_5_category;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_category;


















