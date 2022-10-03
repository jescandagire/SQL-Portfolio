DROP TABLE IF EXISTS walmart_sales;
CREATE TABLE walmart_sales
(
    store        INT,
    date         DATE,
    weekly_sales FLOAT,
    holiday_flag INT,
    temperature  FLOAT,
    fuel_price   FLOAT,
    cpi          FLOAT,
    unemployment FLOAT
);
COPY walmart_sales
    FROM 'C:\Documents\Data Analytics and BI\personal\Walmart.csv'
    DELIMITER ','
    CSV HEADER;

SELECT *
FROM walmart_sales
LIMIT 10;

            -- ###################################################################
            -- #                   WHICH YEAR HAD THE HIGHEST SALES?             #
            -- ###################################################################
            SELECT SUM(weekly_sales) AS total_sales, date_part('year', date) AS year
            FROM walmart_sales
            GROUP BY year
            ORDER BY total_sales DESC LIMIT 1;

-- YEAR WITH HIGHEST SALES VIEW
CREATE VIEW highest_sales_year_view AS (
                                       SELECT SUM(weekly_sales) AS total_sales, date_part('year', date) AS year
                                       FROM walmart_sales
                                       GROUP BY year
                                       ORDER BY total_sales DESC LIMIT 1
                                       );


-- ############ WORKING WITH VIEWS ##############
CREATE VIEW total_yearly_sales AS
(
SELECT SUM(weekly_sales) AS total_sales, date_part('year', date) AS year
FROM walmart_sales
GROUP BY year
ORDER BY year
    );
SELECT *
FROM total_yearly_sales;

CREATE VIEW highest_sales_view AS
(
WITH yearlySales AS (
    SELECT SUM(weekly_sales) AS total_sales, date_part('year', date) AS year
    FROM walmart_sales
    GROUP BY year
    ORDER BY year
)
SELECT MAX(total_sales)
FROM yearlySales
    );
SELECT *
FROM highest_sales_view;

CREATE VIEW year_with_highest_sales_view AS
SELECT year, total_sales
FROM total_yearly_sales
WHERE total_sales = (SELECT * FROM highest_sales_view);

SELECT * FROM year_with_highest_sales_view;


            -- ##################################################################################################
            -- # HOW WAS THE WEATHER DURING THE YEAR OF HIGHEST SALES?                                          #
            -- # it is seen that the year with the highest sales had the lowest average temperature             #
            -- ##################################################################################################

            SELECT date_part('year', date) AS year, AVG(temperature)
            FROM walmart_sales
            WHERE date_part('year', date) = (SELECT year FROM highest_sales_year_view)
            group by year;


            -- ##################################################################################################
            -- # CONCLUDE WHETHER THE WEATHER HAS AN ESSENTIAL IMPACT ON SALES                                  #
            -- ##################################################################################################

            -- ##################################################################################################
            -- # DO THE SALES ALWAYS RISE NEAR THE HOLIDAY SEASON FOR ALL THE YEARS?                            #
            -- ##################################################################################################

            -- ##################################################################################################
            -- # ANALYZE THE RELATIONSHIP BETWEEN SALES AND THE DIFFERENT MACROECONOMIC VARIABLES               #
            -- ##################################################################################################

