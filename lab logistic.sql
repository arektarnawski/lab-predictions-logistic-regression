USE sakila;

CREATE VIEW sakila_logistic AS
(
SELECT
	f.title,
    f.release_year,
    l.name,
    f.rental_rate,
    f.length,
    f.rating,
    f.special_features,
    d1.times_rented_before_aug,
    d2.rented_in_aug,
    c.name genre
FROM
	film f
    JOIN language l
		ON f.language_id = l.language_id
	LEFT JOIN 
		(
		SELECT 
			f.title,
			COUNT(*) times_rented_before_aug
		FROM 
			Rental r
		JOIN inventory i
			ON r.inventory_id = i.inventory_id
		JOIN film f
			ON i.film_id = f.film_id
		WHERE 
			r.rental_date < '2005-08-01'
		GROUP BY
			f.title
		) d1
		ON f.title = d1.title
	LEFT JOIN
		(
		SELECT
		title,
		rented_in_aug
		FROM
			(
			SELECT 
				f.title,
				CASE
					WHEN EXISTS(SELECT r2.inventory_id FROM rental r2 WHERE r2.rental_date BETWEEN '2005-08-01' AND '2005-08-31' AND r2.inventory_id = r.inventory_id) THEN 'Yes'
					ELSE 'No'
				END as rented_in_aug
			FROM 
				rental r
				JOIN inventory i
					ON r.inventory_id = i.inventory_id
				JOIN film f
				ON i.film_id = f.film_id
			WHERE 
				r.rental_date BETWEEN '2005-01-01' AND '2005-12-31'
			) d0
		WHERE
			rented_in_aug = 'Yes'
		GROUP BY
			title
		) d2
		ON f.title = d2.title
	LEFT JOIN film_category fc
		ON f.film_id = fc.film_id
	LEFT JOIN category c
		ON fc.category_id = c.category_id
)