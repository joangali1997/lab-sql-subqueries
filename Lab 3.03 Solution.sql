			# LAB | SQL Subqueries 3.03

USE sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM sakila.inventory;

SELECT COUNT(inventory_id) FROM sakila.inventory
WHERE film_id IN (
	SELECT film_id FROM (
	SELECT title, film_id 
    FROM film
	WHERE title = 'Hunchback Impossible') sub1
);

SELECT COUNT(film_id) AS tot_H
FROM inventory
WHERE film_id = 439;



# 2. List all films whose length is longer than the average of all the films.
SELECT title, length FROM sakila.film
GROUP BY title, length;

SELECT AVG(length)
FROM sakila.film;  -- 115.2720

SELECT film_id, title FROM sakila.film
WHERE title IN (
	SELECT title  FROM (
    SELECT title, length, AVG(length) as avg_film
    FROM sakila.film
    WHERE title <> ''
    GROUP BY title, length
    HAVING length > '115.2720'
    ) sub1
);



# 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *
FROM sakila.film
WHERE title = 'Alone Trip';

SELECT * FROM film_actor
WHERE film_id = '17'; -- I must get '8' in the final solution


SELECT COUNT(DISTINCT actor_id) FROM sakila.film_actor
WHERE film_id IN (
	SELECT film_id 
    FROM (
		SELECT film_id, title 
		FROM sakila.film
		WHERE title = 'Alone Trip')
    sub1
);



# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film_category;
SELECT name FROM category;

SELECT DISTINCT film_id 
FROM sakila.film_category
WHERE category_id IN (
	SELECT category_id
    FROM (
		SELECT category_id, name
		FROM sakila.category
		WHERE name = 'Family')
    sub1
);

SELECT title AS Family_movies_list FROM film
JOIN film_category
USING (film_id)
JOIN category c
USING (category_id)
WHERE name = 'Family';



# 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT country_id
FROM country
WHERE country = 'Canada'; -- 20

SELECT *
FROM city
WHERE country_id = '20'; -- There are 7 registered cities in Canada

-- Solution
SELECT first_name, last_name, email, address_id
FROM sakila.customer
WHERE address_id IN (
	SELECT DISTINCT city_id
    FROM (
		SELECT city_id
		FROM sakila.city
		WHERE country_id = 20
	) sub1
);

SELECT * FROM customer;

-- Or alternative using join:
SELECT first_name, last_name, email FROM sakila.customer
JOIN sakila.address
USING (address_id)
JOIN sakila.city
USING (city_id)
JOIN sakila.country
USING (country_id)
WHERE country = 'Canada';



# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- Getting the most prolific actor_id:
SELECT actor_id, first_name, last_name, COUNT(film_id)
FROM sakila.actor
JOIN sakila.film_actor
USING (actor_id)
GROUP BY actor_id
ORDER BY count(film_id) DESC
LIMIT 1; -- 107, Gina Degeneres

-- Solution
SELECT title
FROM sakila.film
WHERE film_id IN (
	SELECT DISTINCT film_id
    FROM (
		SELECT actor_id, film_id
		FROM sakila.film_actor
		WHERE actor_id = 107
	) sub1
);

# Running every subquery to understand what I'm doing and if I'm doing it well
SELECT actor_id, film_id
		FROM sakila.film_actor
		WHERE actor_id = 107;



SELECT DISTINCT film_id
    FROM (
		SELECT actor_id, film_id 
		FROM sakila.film_actor
		WHERE actor_id = 107)
        sub1;



# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- Getting the most profitable customer_id
SELECT first_name, last_name, SUM(amount), customer_id AS Customer
FROM customer
JOIN payment
USING (customer_id)
GROUP BY customer
ORDER BY SUM(amount) DESC
LIMIT 1; -- KARL SEAL. Id: 526

-- Solution
SELECT title FROM sakila.film
JOIN inventory
USING (film_id)
JOIN rental
USING (inventory_id)
JOIN customer
USING (customer_id)
WHERE customer_id =
(SELECT customer_id AS Customer
FROM customer
JOIN payment
USING (customer_id)
GROUP BY customer
ORDER BY SUM(amount) DESC
LIMIT 1); 

# If asked for nº of films rented by most profitable customer:
SELECT COUNT(rental_id)
FROM sakila.rental
	WHERE rental_id IN (
	SELECT DISTINCT rental_id
		FROM (
			SELECT customer_id, rental_id
			FROM sakila.rental
			WHERE customer_id = 526
            )sub1
            );
-- The nº of films rented by most profitable customer are 45.


# Running different subqueries to check:

SELECT customer_id, rental_id
		FROM sakila.rental
		WHERE customer_id = 526;
        
SELECT DISTINCT rental_id
		FROM (
			SELECT customer_id, rental_id
			FROM sakila.rental
			WHERE customer_id = 526)sub1;



# 8. Customers who spent more than the average payments.
SELECT AVG(amount)
FROM sakila.payment; -- '4.200667'


SELECT AVG(amount), customer_id AS Customer, first_name, last_name 
FROM customer
JOIN payment
USING (customer_id)
GROUP BY customer
ORDER BY AVG(amount) DESC;

SELECT first_name, last_name FROM sakila.customer
WHERE customer_id IN (
	SELECT customer_id  FROM (
    SELECT customer_id, amount
    FROM sakila.payment
    GROUP BY customer_id, amount
    HAVING amount > '4.200667'
    ) sub
);
