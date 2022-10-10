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
FROM walmart_sales LIMIT 10;

-- ###################################################################
-- #                   WHICH YEAR HAD THE HIGHEST SALES?             #
-- ###################################################################
SELECT SUM(weekly_sales) AS total_sales, DATE_PART('year', date) AS year
FROM walmart_sales
GROUP BY year
ORDER BY total_sales DESC
    LIMIT 1;

-- YEAR WITH HIGHEST SALES VIEW
CREATE
OR REPLACE VIEW highest_sales_year_view AS
(
SELECT SUM(weekly_sales) AS total_sales, DATE_PART('year', date) AS year
FROM walmart_sales
GROUP BY year
ORDER BY total_sales DESC
LIMIT 1 );

SELECT *
FROM highest_sales_year_view;

-- ############ WORKING WITH VIEWS ##############
CREATE VIEW total_yearly_sales AS
(
SELECT SUM(weekly_sales) AS total_sales, DATE_PART('year', date) AS year
FROM walmart_sales
GROUP BY year
ORDER BY year
    );
SELECT *
FROM total_yearly_sales;

CREATE VIEW highest_sales_view AS
(
WITH yearlySales AS (
    SELECT SUM(weekly_sales) AS total_sales, DATE_PART('year', date) AS year
FROM walmart_sales
GROUP BY year
ORDER BY year
    )
SELECT MAX(total_sales)
FROM yearlySales );
SELECT *
FROM highest_sales_view;

CREATE VIEW year_with_highest_sales_view AS
SELECT
        year, total_sales
        FROM total_yearly_sales
        WHERE total_sales = (SELECT * FROM highest_sales_view);

SELECT *
FROM year_with_highest_sales_view;


-- ##################################################################################################
-- # HOW WAS THE WEATHER DURING THE YEAR OF HIGHEST SALES?                                          #
-- # it is seen that the year with the highest sales had the lowest average temperature             #
-- ##################################################################################################
-- VIEW TO RETURN THE AVERAGE, MINIMUM AND MAXIMUM TEMPERATURE OF THE HIGHEST SALES YEAR
DROP VIEW IF EXISTS average_temperature_of_highest_sales_year_view;
CREATE
OR REPLACE VIEW average_temperature_of_highest_sales_year_view AS
SELECT DATE_PART('year', date) AS year, AVG(temperature) AS avg_temp, MAX(temperature) AS max_temp, MIN(temperature) AS min_temp
FROM walmart_sales
WHERE DATE_PART('year', date) = (SELECT year FROM highest_sales_year_view)
group by year;

SELECT *
FROM average_temperature_of_highest_sales_year_view;

-- FUNCTION TO RETURN THE AVERAGE, MINIMUM AND MAXIMUM TEMPERATURE OF THE HIGHEST SALES YEAR
DROP FUNCTION IF EXISTS avg_min_and_max_temp_of_highest_sales_year;
CREATE
OR REPLACE FUNCTION avg_min_and_max_temp_of_highest_sales_year()
RETURNS TABLE(avgTemp float, minTemp float, maxTemp float) AS
    $$
    DECLARE
highYear double precision;
BEGIN
SELECT year
INTO highYear
FROM highest_sales_year_view;
RETURN QUERY
SELECT AVG(temperature), MIN(temperature), MAX(temperature)
FROM walmart_sales
WHERE DATE_PART('year', date) = highYear;
end;
    $$
LANGUAGE plpgsql;

SELECT *
FROM avg_min_and_max_temp_of_highest_sales_year();


-- ##################################################################################################
-- # CONCLUDE WHETHER THE WEATHER HAS AN ESSENTIAL IMPACT ON SALES
-- FOR ALL THE YEARS COMPARE THE SALES, MONTH ON MONTH FOR THE YEAR WITH HIGHEST SALES
-- GET THE AVG TEMP OF EACH MONTH AND THE TOTAL SALES
-- SALES PER DAY#
-- ##################################################################################################
-- yearly sales analysis with the average temp
DROP VIEW IF EXISTS annual_sales_with_avg_temp_view;
CREATE
OR REPLACE VIEW annual_sales_with_avg_temp_view AS
SELECT DATE_PART('year', date) AS year, AVG(temperature), SUM(weekly_sales) AS total_sales
FROM walmart_sales
GROUP BY year
ORDER BY year;
SELECT *
FROM annual_sales_with_avg_temp_view;
-- monthly sales analysis with the average temp in all the years
DROP FUNCTION IF EXISTS monthly_sales_with_avg_temp_func;
CREATE
OR REPLACE FUNCTION monthly_sales_with_avg_temp_func()
RETURNS TABLE(yearDate double precision, monthDate double precision, avgTemp numeric, totalSales numeric)
AS $$
BEGIN
RETURN QUERY
SELECT DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, ROUND(AVG(temperature)::numeric,4), ROUND(SUM(weekly_sales)::numeric,4)
FROM walmart_sales
GROUP BY year, month
ORDER BY year, month;
end;
    $$
LANGUAGE plpgsql;

SELECT *
FROM monthly_sales_with_avg_temp_func();
-- ##################################################################################################
-- # DO THE SALES ALWAYS RISE NEAR THE HOLIDAY SEASON FOR ALL THE YEARS?
-- IDENTIFY THE HOLIDAY SEASONS, WORK WITH THE HOLIDAY WEEKS#
-- ##################################################################################################
DROP VIEW IF EXISTS sales_for_holiday_and_non_holiday;
CREATE
OR REPLACE VIEW sales_for_holiday_and_non_holiday AS
SELECT DATE_PART('year', date) AS year, DATE_PART('month',date) AS month, (CASE WHEN holiday_flag =1 THEN ROUND(SUM(weekly_sales)::numeric,3) END) AS holiday_sales, (CASE WHEN holiday_flag =0 THEN ROUND(SUM(weekly_sales)::NUMERIC,3) END) AS non_holiday_sales
FROM walmart_sales
GROUP BY year, month, holiday_flag
ORDER BY year, month;

SELECT *
FROM sales_for_holiday_and_non_holiday;
-- ##################################################################################################
-- # ANALYZE THE RELATIONSHIP BETWEEN SALES AND THE DIFFERENT MACROECONOMIC VARIABLES               #
-- ##################################################################################################
DROP VIEW IF EXISTS sales_with_macroeconomic_variables;
CREATE
OR REPLACE VIEW sales_with_macroeconomic_variables AS
SELECT DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, weekly_sales, cpi, unemployment
FROM walmart_sales;

SELECT *
FROM sales_with_macroeconomic_variables;
