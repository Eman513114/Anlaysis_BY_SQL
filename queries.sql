/*FIRST QUERY*/
/*Question 1
We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music. */ 

SELECT 
    title AS film_title,name AS category_name,COUNT(r.*) AS count_of_rentals
FROM
     inventory i
JOIN
    film f
ON  
    i.film_id=f.film_id
JOIN
     film_category fs
ON 
     fs.film_id=f.film_id
JOIN 
     category c 
ON 
    c.category_id= fs.category_id
JOIN
    rental r
ON 
   r.inventory_id=i.inventory_id
WHERE 
     name IN('Animation','Children','Classics', 'Comedy', 'Family','Music')
GROUP BY
      1 ,2
ORDER BY  3 DESC;
/*---------IT is diagram from this query------------*/
/*---------what is the most category which ordered for rental it's films?------------*/

SELECT category_name ,sum(count_of_rentals) as total
FROM (SELECT 
    title AS film_title,name AS category_name,COUNT(r.*) AS count_of_rentals
FROM
     inventory i
JOIN
    film f
ON  
    i.film_id=f.film_id
JOIN
     film_category fs
ON 
     fs.film_id=f.film_id
JOIN 
     category c 
ON 
    c.category_id= fs.category_id
JOIN
    rental r
ON 
   r.inventory_id=i.inventory_id
WHERE 
     name IN('Animation','Children','Classics', 'Comedy', 'Family','Music')
GROUP BY
      1 ,2
ORDER BY  3 DESC) multi
GROUP BY 1
order by 2 DESC;

/*----------------------------------------------------------------------------------------------------*/

/*SECOND QUERY*/
/*Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? Make sure to also indicate the category that these family-friendly movies fall into.*/


SELECT  
         film_title,category_name,rental_duration,
         
          ntile(4)over (ORDER BY rental_duration) AS standard_quartile
FROM
   (SELECT title AS film_title,name AS category_name,
       rental_duration
       FROM film f
       JOIN film_category fs
       ON fs.film_id=f.film_id
       JOIN category c 
       ON c.category_id= fs.category_id
       WHERE 
         name IN('Animation','Children','Classics', 'Comedy', 'Family','Music'))sub
         
 /*---for diagram from this query-----*/
  /*---what is the total rental duration for each category?-----*/ 

 
      SELECT category_name,sum(rental_duration) as total_rental_duration
FROM(SELECT  
         film_title,category_name,rental_duration,
         
          ntile(4)over (ORDER BY rental_duration) AS standard_quartile
FROM
   (SELECT title AS film_title,name AS category_name,
       rental_duration
       FROM film f
       JOIN film_category fs
       ON fs.film_id=f.film_id
       JOIN category c 
       ON c.category_id= fs.category_id
       WHERE 
         name IN('Animation','Children','Classics', 'Comedy', 'Family','Music'))sub) sub2
  GROUP BY 1
  ORDER BY 2 DESC;
            
         
         
/*----------------------------------------------------------------------------------------------------*/

/*THIRD QUERY*/
/*Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns. */ 

WITH query AS  (SELECT 
                    category_name,ntile(4) over(ORDER BY rental_duration) AS standard_quartile ,film_title   
                 FROM 
                        (SELECT title AS film_title,name AS category_name,
                                rental_duration
                          FROM  
                                film f
                          JOIN 
                                 film_category fs
                          ON 
                                fs.film_id=f.film_id
                          JOIN 
                                category c 
                          ON 
                                c.category_id= fs.category_id
                          WHERE 
                                name IN('Animation','Children','Classics', 'Comedy', 'Family','Music'))sub)

SELECT
      category_name,standard_quartile,COUNT(film_title) AS count
FROM 
      query
GROUP BY
      1,2
ORDER BY 1;


    /*-how many films in each category which has the highest length_rental--*/


WITH query AS  (SELECT 
                    category_name,ntile(4) over(ORDER BY rental_duration) AS standard_quartile ,film_title   
                 FROM 
                        (SELECT title AS film_title,name AS category_name,
                                rental_duration
                          FROM  
                                film f
                          JOIN 
                                 film_category fs
                          ON 
                                fs.film_id=f.film_id
                          JOIN 
                                category c 
                          ON 
                                c.category_id= fs.category_id
                          WHERE 
                                name IN('Animation','Children','Classics', 'Comedy', 'Family','Music'))sub)

SELECT
      category_name,standard_quartile,COUNT(film_title) AS count
FROM 
      query
GROUP BY
      1,2
      HAVING standard_quartile=4
ORDER BY 3 desc;



/*----------------------------------------------------------------------------------------------------*/

/*FORTHQUERY*/
/*question :
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers? */

WITH first AS(SELECT 
                   c.customer_id,concat(first_name,' ',last_name) as fullname,sum(amount) as total
                 fROM 
                   customer c
                 JOIN 
                   payment p
                 ON 
                   c.customer_id=p.customer_id
                 GROUP BY 1,2
                 ORDER BY 3 desc
                 LIMIT 10)

SELECT 
     fullname,date_trunc('month',payment_date) as pay_mon,count(p.*) as count,sum(amount) as amount
FROM 
    first f
JOIN 
    payment p
ON 
    f.customer_id=p.customer_id
GROUP BY 1,2
ORDER BY fullname ;

/*--diagram from this query--*/
/*how many orders in each top month where the total payment amount on the top?*/
WITH first AS(SELECT 
                   c.customer_id,concat(first_name,' ',last_name) as fullname,sum(amount) as total
                 fROM 
                   customer c
                 JOIN 
                   payment p
                 ON 
                   c.customer_id=p.customer_id
                 GROUP BY 1,2
                 ORDER BY 3 desc
                 LIMIT 10)
SELECT pay_mon, sum(count) as total_orders,sum(amount) as total_payment 
FROM(SELECT 
     fullname,date_part('month',payment_date) as pay_mon,count(p.*) as count,sum(amount) as amount
FROM 
    first f
JOIN 
    payment p
ON 
    f.customer_id=p.customer_id
GROUP BY 1,2
ORDER BY fullname)sun
GROUP BY 1
ORDER BY 3 DESC;
         
/*----------------------------------------------------------------------------------------------------*/


