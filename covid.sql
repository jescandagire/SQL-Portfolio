CREATE TABLE covid_vaccines(
                               iso_code VARCHAR(255),
                               continent VARCHAR(255),
                               location VARCHAR(255),
                               date DATE,
                               population BIGINT,
                               total_cases INT,
                               new_cases INT,
                               new_cases_smoothed FLOAT,
                               total_tests BIGINT,
                               new_tests BIGINT,
                               total_tests_per_thousand FLOAT,
                               new_tests_per_thousand FLOAT,
                               new_tests_smoothed INT,
                               new_tests_smoothed_per_thousand FLOAT,
                               positive_rate FLOAT,
                               tests_per_case FLOAT,
                               tests_units VARCHAR(255),
                               total_vaccinations BIGINT,
                               people_vaccinated BIGINT,
                               people_fully_vaccinated BIGINT,
                               total_boosters BIGINT,
                               new_vaccinations INT,
                               new_vaccinations_smoothed INT,
                               total_vaccinations_per_hundred FLOAT,
                               people_vaccinated_per_hundred FLOAT,
                               people_fully_vaccinated_per_hundred FLOAT,
                               total_boosters_per_hundred FLOAT,
                               new_vaccinations_smoothed_per_million INT,
                               new_people_vaccinated_smoothed INT,
                               new_people_vaccinated_smoothed_per_hundred FLOAT,
                               stringency_index FLOAT,
                               population_density FLOAT,
                               median_age FLOAT,
                               aged_65_older FLOAT,
                               aged_70_older FLOAT,
                               gdp_per_capita FLOAT,
                               extreme_poverty FLOAT,
                               cardiovasc_death_rate FLOAT,
                               diabetes_prevalence FLOAT,
                               female_smokers FLOAT,
                               male_smokers FLOAT,
                               handwashing_facilities FLOAT,
                               hospital_beds_per_thousand FLOAT,
                               life_expectancy FLOAT,
                               human_development_index FLOAT,
                               excess_mortality_cumulative_absolute FLOAT,
                               excess_mortality_cumulative FLOAT,
                               excess_mortality FLOAT,
                               excess_mortality_cumulative_per_million FLOAT
)
    COPY covid_vaccines
FROM 'C:\Documents\Data Analytics and BI\personal\covidVaccines.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE covid_deaths (
                              iso_code VARCHAR(255),
                              continent VARCHAR(255),
                              location VARCHAR(255),
                              date DATE,
                              population BIGINT,
                              total_cases INT,
                              new_cases INT,
                              new_cases_smoothed FLOAT,
                              total_deaths BIGINT,
                              new_deaths BIGINT,
                              new_deaths_smoothed FLOAT,
                              total_cases_per_million FLOAT,
                              new_cases_per_million FLOAT,
                              new_cases_smoothed_per_million FLOAT,
                              total_deaths_per_million FLOAT,
                              new_deaths_per_million FLOAT,
                              new_deaths_smoothed_per_million FLOAT,
                              reproduction_rate FLOAT,
                              icu_patients INT,
                              icu_patients_per_million FLOAT,
                              hosp_patients BIGINT,
                              hosp_patients_per_million FLOAT,
                              weekly_icu_admissions INT,
                              weekly_icu_admissions_per_million FLOAT,
                              weekly_hosp_admissions BIGINT,
                              weekly_hosp_admissions_per_million FLOAT

)
    COPY covid_deaths
FROM 'C:\Documents\Data Analytics and BI\personal\covidDeaths.csv'
DELIMITER ','
CSV HEADER ;

SELECT * FROM covid_vaccines LIMIT 3;
SELECT * FROM covid_deaths LIMIT 3;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_deaths
ORDER BY 1,2;

SELECT DISTINCT(location)
FROM covid_deaths;

SELECT location
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location;

-- total_cases Vs total_deaths and the death percentage
-- this shows the likelihood of dying on getting covid in uganda
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths::FLOAT/total_cases::FLOAT)*100 AS death_percentage
FROM covid_deaths
WHERE location='Uganda'
ORDER BY 1,2;

-- total_cases Vs population and the contraction percentage
-- this shows the likelihood of contracting covid in uganda
SELECT location,date,total_cases,population,(total_cases::FLOAT/population::FLOAT)*100 AS contraction_percentage
FROM covid_deaths
WHERE location='Uganda'
ORDER BY 1,2;

-- the country highest number of population infected/ COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location,MAX(total_cases) AS highestNumberofCases,population,MAX((total_cases::FLOAT/population::FLOAT))*100 AS infection_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC;

--  COUNTRIES WITH HIGHEST DEATH RATE
SELECT location,MAX(total_deaths) AS highestNumberofDeaths,population,MAX((total_deaths::FLOAT/population::FLOAT))*100 AS death_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY death_rate DESC;

-- CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT continent, SUM(total_deaths) AS death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC;

-- COUNTRIES HIGHEST DEATH COUNT
SELECT location, SUM(total_deaths) AS death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;

-- DAILY TOTAL CASES GLOBALLY
SELECT date,SUM(new_cases) AS global_daily_cases_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date;

-- DAILY TOTAL DEATHS GLOBALLY
SELECT date,SUM(new_deaths) AS global_daily_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date;

-- 03-Oct-2022
-- GLOBAL DEATHS
SELECT * FROM covid_deaths LIMIT 20;

-- DAILY GLOBAL DEATHS
SELECT date, SUM(new_cases) AS total_daily_cases, sum(new_deaths) AS total_daily_deaths, sum(new_deaths)/sum(new_cases)*100 as daily_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- TOTAL DEATHS AND DEATH PERCENTAGE GLOBALLY
SELECT SUM(new_cases) AS global_total_cases_count, SUM(new_deaths) AS global_total_death_count, SUM(new_deaths)/SUM(new_cases)*100 AS global_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

--                 VACCINES TABLE
SELECT * FROM covid_vaccines LIMIT 20;

-- JOINING THE COVID_DEATHS AND COVID_VACCINES TABLES
SELECT * FROM covid_deaths cd
                  INNER JOIN covid_vaccines cv ON cd.location = cv.location
    AND cd.date = cv.date;

-- LOOKING AT TOTAL GLOBAL POPULATION vs DAILY VACCINATIONS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM covid_deaths cd
         INNER JOIN covid_vaccines cv ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- LOOKING AT THE CUMULATIVE VACCINATIONS (ROLLING VACCINATIONS VALUE) BY LOCATION
-- NEED TO FIND OUT HOW ITS DONE IN POSTGRES
-- SQL VERSION
-- SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cv.new_vaccinations OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingPeopleVaccinated
-- FROM covid_deaths cd
--          INNER JOIN covid_vaccines cv ON cd.location = cv.location
--     AND cd.date = cv.date
-- WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3;

-- TO GET THE ROLLING PERCENTAGE WE USE A CTE( Common Table Expression) SO AS TO GET ACCESS TO THE "rollingPeopleVaccinated" VARIABLE
-- WITH populationVsVaccinations (Continent, Location, Date, New_Vaccinations, RollingPeopleVaccinated)
-- AS(
--         SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cv.new_vaccinations OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingPeopleVaccinated
--         FROM covid_deaths cd
--             INNER JOIN covid_vaccines cv ON cd.location = cv.location
--             AND cd.date = cv.date
--         WHERE cd.continent IS NOT NULL;
--     )
-- SELECT *, (RollingPeopleVaccinated/Population)*100 AS rollingVaccinationPercentage
-- FROM populationVsVaccinations;

-- TEMP TABLE
-- DROP TABLE IF EXISTS PercentPopulationVaccinated;
-- CREATE TABLE PercentPopulationVaccinated(
--     Continent VARCHAR,
--     Location VARCHAR,
--     Date DATE,
--     Population NUMERIC,
--     New_Vaccinations NUMERIC,
--     RollingPeopleVaccinated NUMERIC
-- );
-- INSERT INTO PercentPopulationVaccinated
-- SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cv.new_vaccinations OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingPeopleVaccinated
--         FROM covid_deaths cd
--             INNER JOIN covid_vaccines cv ON cd.location = cv.location
--             AND cd.date = cv.date;
-- SELECT *, (RollingPeopleVaccinated/Population)*100 AS rollingVaccinationPercentage
-- FROM populationVsVaccinations;

-- CREATING  A VIEW