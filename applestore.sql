-- Combining data

CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL 
SELECT * FROM appleStore_description4

-- EXPLORATORY DATA ANALYSIS

-- Check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore


SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined


-- Check for missing values in key fields

SELECT COUNT (*) AS MissingValues
FROM AppleStore
WHERE track_name IS null or user_rating IS null or prime_genre IS NULL


SELECT COUNT (*) as MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null 


-- Find out the number of apps per genre

SELECT prime_genre, COUNT (*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps desc

-- Get an overview of the apps' ratings 

SELECT min(user_rating) as MinRating, 
		    max(user_rating) as MaxRating,
        avg(user_rating) As AvgRating
FROM AppleStore

-- Get an overview of languages supported

SELECT min(lang_num) As MinNumLangs,
		    max(lang_num) as MaxNumLangs,
        avg(lang_num) as AvgNumLangs
FROM AppleStore


-- DATA ANALYSIS

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
		WHEN price > 0 THEN 'Paid'
   	ELSE 'Free'
  END as AppType,
  avg(user_rating) as AvgRating
FROM AppleStore
GROUP BY AppType

-- Paid apps have higher average ratings than free apps

-- Determine whether apps with more supported languages have higher ratings

SELECT CASE
		WHEN lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 and 30 THEN '10-30 languages'
        ELSE '>30 languages'
    END AS language_bucket,
    avg(user_rating) as AvgRating
FROM AppleStore
GROUP BY language_bucket
ORDER BY AvgRating desc

-- Having more supported languages does not increase average user ratings

-- Check genres with low ratings

SELECT prime_genre, avg(user_rating) as AvgRating
FROM AppleStore
GROUP BY prime_genre
ORDER BY AvgRating ASC
LIMIT 10

-- there is opportunity to build apps with improved features in these genres

-- Check if there is a correlation between the length of app description and user ratings

SELECT CASE 
		WHEN length(app_desc) < 500 THEN 'Short'
    WHEN length(app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
    ELSE 'Long'
  END AS description_length_bucket,
  avg(user_rating) as AvgRating
FROM
	AppleStore as a
JOIN
	appleStore_description_combined as b
ON
	a.id = b.id
GROUP BY description_length_bucket
ORDER BY AvgRating desc

-- The longer the app description , the better the user ratings on average

-- Check the top rated apps on each genre

SELECT 
	 prime_genre,
   track_name,
   user_rating
FROM (
  	SELECT 
  	 prime_genre,
  	 track_name,
  	 user_rating,
  	 RANK () OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot desc) as rank
  	FROM
  	AppleStore
  ) as a 
WHERE a.rank = 1