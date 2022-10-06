DROP TABLE IF EXISTS books;
CREATE TABLE books (
    title VARCHAR,
    category VARCHAR,
    rating VARCHAR,
    price FLOAT,
    stock VARCHAR,
    quantity INT
);
COPY books
FROM 'C:\Documents\Data Analytics and BI\personal\books_scraped.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM books LIMIT 10;
SELECT DISTINCT category FROM books;

-- ##############################################################################################
-- #      WHICH BOOK IS THE MOST EXPENSIVE AND WHAT'S ITS RATING AND CATEGORY?                  #
-- ##############################################################################################
CREATE OR REPLACE VIEW most_expensive_book_view AS SELECT title, category, price, rating FROM books ORDER BY price DESC LIMIT 1;
SELECT * FROM most_expensive_book_view;
-- ##############################################################################################
-- #      WHAT ARE THE TOP 5 RATED BOOKS IN EACH CATEGORY?                                      #
-- ##############################################################################################
CREATE OR REPLACE VIEW top_rated_books_view AS SELECT title, category, rating FROM books ORDER BY rating LIMIT 5;
SELECT * FROM top_rated_books_view;
-- ##############################################################################################
-- #     WHICH CATEGORY HAS THE MOST EXPENSIVE BOOKS, WHAT IS THE BOOK COUNT AND TOTAL PRICE?   #
-- ##############################################################################################
CREATE OR REPLACE VIEW most_expensive_books_view AS SELECT category, COUNT(title) AS book_count, SUM(price) AS total_price FROM books GROUP BY category ORDER BY total_price DESC;
SELECT * FROM most_expensive_books_view;