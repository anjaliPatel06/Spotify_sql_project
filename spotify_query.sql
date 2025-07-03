-- Spotify project
DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify(
artist VARCHAR(255),
track VARCHAR(255),
album VARCHAR(255),
album_type VARCHAR(50),
danceability FLOAT,
enregy FLOAT,
loudness FLOAT,
speechiness FLOAT,
accousticness FLOAT,
instrumentalness FLOAT,
liveness FLOAT,
valence FLOAT,
tempo FLOAT,
duration_min FLOAT,
title VARCHAR(255),
channel VARCHAR(255),
views FLOAT,
likes BIGINT,
comments BIGINT,
licensed BOOLEAN, 
official_video BOOLEAN,
stream BIGINT,
energy_liveness FLOAT,
most_played_on VARCHAR(50)
)

ALTER TABLE spotify
RENAME COLUMN enregy TO energy;

SELECT * FROM spotify;

-- EDA 
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) as no_of_artist FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT DISTINCT channel FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify 
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT most_played_on,
       COUNT(*)
FROM spotify
GROUP BY 1

-- Data analysis - Easy Category

-- 1. Retrive the names of all tracks that have more than 1 billion streams
SELECT track,stream FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.
SELECT
    DISTINCT album,artist
FROM spotify
ORDER BY 1

-- 3. Get the total number of comments for tracks where licensed = True
SELECT 
    SUM(comments) as total_comments
FROM spotify
WHERE licensed = true;

-- 4. Find all tracks that belongs to the album type single
SELECT 
   track
FROM spotify
WHERE album_type = 'single'

-- 5. Count the total number of track by each artist
SELECT 
   artist,
   COUNT(*) as total_no_songs
FROM spotify
GROUP BY 1;


-Medium label problem

-- 6. Calculate the avg danceability of track in each album
SELECT 
    album,
	AVG(danceability)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

-- 7. Find the top 5 tracks with highest energy values
SELECT track,
       MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 8. List all tracks along with their views and likes where official_video = true;
SELECT 
    track,
    SUM(views) as total_views,
    SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
ORDER BY 2 DESC
LIMIT 5

-- 9. For each album calculate the total views of all associated tracks
SELECT 
   album,
   track,
   SUM(views)
FROM spotify
GROUP BY 1,2;

-- 10. Retrive the track names that have been streamed on spotify more than youtube
SELECT * FROM 
(
SELECT 
     track,
    COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY track
) AS T1
WHERE 
   streamed_on_spotify > streamed_on_youtube
   AND
   streamed_on_youtube <> 0


-- Advanced label problem

-- 11. Find the top 3 most viewed track for each artist using window function
WITH ranking_artist
AS
(
SELECT artist,
       track,
	   SUM(views) as total_view,
       RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1,2
)
SELECT * FROM ranking_artist
WHERE rank <= 3

-- 12. Write a query to find tracks where the liveness score is above the avg
SELECT 
    track,
    artist,
	liveness
FROM spotify
WHERE liveness >  (SELECT AVG(liveness) FROM spotify)

-- 13. use a with clause to calculate the diff btw the highest and loswest energy values for tracks in each album
WITH cte
AS
(
SELECT 
    album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
) 
SELECT 
   album,
   highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC

