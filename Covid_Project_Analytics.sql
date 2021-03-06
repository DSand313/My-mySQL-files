********************************

Queries used for tableau project

********************************

-- 1.

SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS unsigned)) AS total_deaths,
    SUM(CAST(new_deaths AS unsigned)) / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
ORDER BY 1,2

-- 2.

SELECT
    location,
    SUM(CAST(new_deaths as unsigned)) AS total_death_count
FROM covid_deaths
GROUP BY location
    
-- 3.

SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY 
    location,
    population
ORDER BY percent_population_infected DESC

-- 4.

SELECT
    location,
    population,
    date,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY 
    location,
    population,
    date
ORDER BY percent_population_infected DESC

**************************

Queries used for analytics

**************************


-- Looking at data for covid cases in all of North America for 2022 so far

SELECT
    location,
    date, 
    total_cases,
    new_cases,
    total_deaths,
    population
FROM covid_deaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying of covid in US in 2022

SELECT
    location,
    date, 
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location LIKE "%states%"
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows percentage of population in US that's had covid

SELECT
    location,
    date, 
    population,
    total_cases,
    (total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
WHERE location LIKE "%states%"
ORDER BY 1,2

-- Looking at areas of North America with highest infection rate compared to population

SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    (MAX(total_cases / population)) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY 
    location,
    population
ORDER BY percent_population_infected DESC

-- Showing countries within North America with highest death count

SELECT
    location,
    MAX(CAST(total_deaths AS unsigned)) AS total_death_count
FROM covid_deaths
GROUP BY location
ORDER BY total_death_count DESC

-- Showing total covid numbers by date across United States

SELECT
    date, 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS unsigned)) AS total_deaths,
    SUM(CAST(new_deaths AS unsigned)) / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location LIKE "%states%"
GROUP BY date
ORDER BY 1,2

-- Showing total covid stas so far for North America in 2022

SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS unsigned)) AS total_deaths,
    SUM(CAST(new_deaths AS unsigned)) / SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location LIKE "%states%"
ORDER BY 1,2

-- Joining covid_deaths with covid_vaccinations
-- Looking at total population vs vaccination with a cte

WITH pop_vs_vac (
    location,
    date,
    population,
    new_vaccinations,
    rolling_people_vaccinated
) AS (
SELECT
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(vac.new_vaccinations, unsigned)) 
	OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) 
        AS rolling_people_vaccinated
    -- (rolling_people_vaccinated / population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
)
SELECT *, (rolling_people_vaccinated / population) * 100
FROM pop_vs_vac

-- Creating a view for later visualizations

CREATE VIEW rolling_people_vaccinated AS
SELECT
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(vac.new_vaccinations, unsigned)) 
	OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
	AS rolling_people_vaccinated
    -- (rolling_people_vaccinated / population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

