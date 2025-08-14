
DROP VIEW IF EXISTS Top_Rated_Dramas_Per_Genre;

CREATE VIEW Top_Rated_Dramas_Per_Genre AS
SELECT 
    genre,
    drama_name,
    rating
FROM 
    Genre 
JOIN 
    Genre_Drama ON Genre.genre_id = Genre_Drama.genre_id
JOIN 
    Drama ON Genre_Drama.drama_id = Drama.drama_id
WHERE 
    Drama.rating = (
        SELECT 
            MAX(Drama_2.rating) 
        FROM 
            Drama Drama_2
        JOIN 
            Genre_Drama Genre_Drama_2 ON Drama_2.drama_id = Genre_Drama_2.drama_id
        WHERE 
            Genre_Drama_2.genre_id = Genre.genre_id
    );
-- Purpose: Lists the top-rated drama for each genre.


DROP VIEW IF EXISTS Dramas_With_Short_Duration;

CREATE VIEW Dramas_With_Short_Duration AS
SELECT 
    drama_name, 
    duration_min
FROM 
    Drama 
WHERE 
    duration_min < (
        SELECT AVG(duration_min) 
        FROM Drama
    );
    
-- Purpose: Lists all dramas with episode durations less than the average drama duration.


DROP VIEW IF EXISTS Directors_With_High_Rated_Dramas;

CREATE VIEW Directors_With_High_Rated_Dramas AS
SELECT 
    Director.first_name, 
    Director.last_name,
    COUNT(Drama.drama_id) AS high_rated_dramas
FROM 
    Director 
JOIN 
    Director_Drama ON Director.director_id = Director_Drama.director_id
JOIN 
    Drama ON Director_Drama.drama_id = Drama.drama_id
WHERE 
    Drama.rating > 8.5
GROUP BY 
    Director.director_id
HAVING 
    COUNT(Drama.drama_id) > 1;
    
-- Purpose: directors who have directed multiple high-rated dramas (rating above 8.5).


DROP VIEW IF EXISTS Top_Networks_By_High_Rated_Dramas;


CREATE VIEW Top_Networks_By_High_Rated_Dramas AS
SELECT 
    Original_Network.original_network, 
    COUNT(Drama.drama_id) AS high_rated_dramas
FROM 
    Original_Network 
JOIN 
    Original_Network_Drama 
    ON Original_Network.original_network_id = Original_Network_Drama.original_network_id
JOIN 
    Drama 
    ON Original_Network_Drama.drama_id = Drama.drama_id
WHERE 
    Drama.rating > 8.5
GROUP BY 
    Original_Network.original_network_id
HAVING 
    COUNT(Drama.drama_id) > 1;
-- Purpose: Lists original networks with multiple high-rated dramas (rating > 8.5).




DROP PROCEDURE IF EXISTS Get_Highest_Rated_Drama_By_Genre;

DELIMITER //

CREATE PROCEDURE Get_Highest_Rated_Drama_By_Genre(IN genre_name VARCHAR(15))
BEGIN
    SELECT 
        drama_name, 
        rating 
    FROM 
        Drama 
    JOIN 
        Genre_Drama ON Drama.drama_id = Genre_Drama.drama_id
    JOIN 
        Genre ON Genre.genre_id = Genre_Drama.genre_id
    WHERE 
        genre = genre_name
    ORDER BY 
        rating DESC;
END //

DELIMITER ;


-- Purpose: Returns the highest-rated drama for a specified genre.
-- Quick Example
CALL Get_Highest_Rated_Drama_By_Genre('Romance');



DROP PROCEDURE IF EXISTS List_Dramas_By_Original_Network;

DELIMITER //

CREATE PROCEDURE List_Dramas_By_Original_Network(IN network_name VARCHAR(15))
BEGIN
    SELECT 
        Drama.drama_name, 
        Drama.release_year, 
        Drama.rating, 
        Original_Network.original_network 
    FROM 
        Drama 
    JOIN 
        Original_Network_Drama ON Drama.drama_id = Original_Network_Drama.drama_id
    JOIN 
        Original_Network ON Original_Network.original_network_id = Original_Network_Drama.original_network_id
    WHERE 
        Original_Network.original_network = network_name
    ORDER BY 
        rating DESC;
END //

DELIMITER ;

-- Purpose: Returns all dramas broadcasted by a specified original network, sorted by rating.

-- Example
CALL List_Dramas_By_Original_Network('tvN');


DROP FUNCTION IF EXISTS Calculate_Average_Rating_By_Genre;

DELIMITER //

CREATE FUNCTION Calculate_Average_Rating_By_Genre(genre_name VARCHAR(15))
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3,2);

    SELECT 
        AVG(rating) 
    INTO 
        avg_rating
    FROM 
        Drama 
    JOIN 
        Genre_Drama ON Drama.drama_id = Genre_Drama.drama_id
    JOIN 
        Genre ON Genre.genre_id = Genre_Drama.genre_id
    WHERE 
        Genre.genre = genre_name;
    
    RETURN avg_rating;
END //

DELIMITER ;

-- Purpose: Calculates the average rating of all dramas within a specified genre.

-- Example
SELECT Calculate_Average_Rating_By_Genre('Romance');




DROP FUNCTION IF EXISTS Calculate_Highest_Rated_Drama_By_Director;


DELIMITER //

CREATE FUNCTION Calculate_Highest_Rated_Drama_By_Director(
    director_first_name VARCHAR(15), 
    director_last_name VARCHAR(10)
)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE highest_rated_drama VARCHAR(50);

    SELECT 
        Drama.drama_name 
    INTO 
        highest_rated_drama
    FROM 
        Drama 
    JOIN 
        Director_Drama ON Drama.drama_id = Director_Drama.drama_id
    JOIN 
        Director ON Director.director_id = Director_Drama.director_id
    WHERE 
        Director.first_name = director_first_name 
        AND Director.last_name = director_last_name
    ORDER BY 
        Drama.rating DESC;
    
    RETURN highest_rated_drama;
END //

DELIMITER ;

-- Purpose: Returns the highest-rated drama directed by a specified director.

-- Example
SELECT Calculate_Highest_Rated_Drama_By_Director('Hyun-Jin', 'Bae');



DROP TRIGGER IF EXISTS Auto_Set_Default_Content_Rating;


DELIMITER //

CREATE TRIGGER Auto_Set_Default_Content_Rating 
BEFORE INSERT ON Drama
FOR EACH ROW
BEGIN
    
    IF NEW.content_rating IS NULL THEN
        SET NEW.content_rating = 'PG';
    END IF;
END //

DELIMITER ;

 -- Automatically sets the content rating to 'PG' if not provided.

-- Example:

-- INSERT INTO Drama (drama_id, drama_name, release_year, aired_on, rating, 'rank', duration_min)
-- VALUES (321, 'Kingdom', 2019, 'Friday', 9.2, 3, 55);



