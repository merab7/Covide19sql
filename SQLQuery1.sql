USE covid_19;

-- SELECTING STARTING DATA
SELECT DATE, location, total_cases, new_cases, total_deaths FROM DEATHS
ORDER BY location;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) WORLDWIDE
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'world'
ORDER BY location, date;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) IN GEORGIA
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'Georgia'
ORDER BY date;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) IN CHINA
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'china'
ORDER BY date;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) IN SPAIN
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'spain'
ORDER BY date;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) IN INDIA
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'india'
ORDER BY date;

-- CHECK TOTAL CASES VS TOTAL DEATHS (DEATHS PERCENTAGE) IN THE USA
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM DEATHS
WHERE location = 'UNITED STATES';

-- Total Cases by Location:
SELECT location, total_cases
FROM DEATHS
ORDER BY total_cases DESC;

-- Total Deaths per Million by Continent:
SELECT continent, AVG(total_deaths_per_million) as avg_deaths_per_million
FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY avg_deaths_per_million DESC;

-- New Cases Trend:
SELECT date, SUM(new_cases) as daily_new_cases
FROM DEATHS
GROUP BY date
ORDER BY date ASC;

-- ICU Admissions Over Time by Location:
SELECT location, date, SUM(weekly_icu_admissions) as weekly_icu
FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY date, location
ORDER BY location, date ASC;

-- Top 10 Locations with Highest Reproduction Rate (the current number of new infectious created by one infectious individual):
SELECT TOP 10 location, MAX(reproduction_rate) as max_reprod_rate
FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_reprod_rate DESC;

-- What percentage of population had COVID-19 (world):
SELECT date, location, population, total_cases, (total_cases/population)*100 as exposed_to_covid FROM DEATHS
WHERE location = 'world'
ORDER BY date;

-- What percentage of population had COVID-19 (Georgia):
SELECT date, location, population, total_cases, (total_cases/population)*100 as exposed_to_covid FROM DEATHS
WHERE location = 'georgia'
ORDER BY date;

-- Highest cases compared to population (Georgia):
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as exposed_to_covid FROM DEATHS
WHERE location = 'georgia'
GROUP BY POPULATION, LOCATION;

-- Highest cases compared to population (WORLD):
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as exposed_to_covid FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY POPULATION, LOCATION
ORDER BY exposed_to_covid DESC;

-- Countries with highest death per population:
SELECT location, max(total_deaths) as HighestDeathCount FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY HighestDeathCount DESC;

-- Continents with highest death per population:
SELECT continent, max(total_deaths) as HighestDeathCount FROM DEATHS
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Death percentage day by day in the world:
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM DEATHS
WHERE location = 'world' and new_cases > 0
GROUP BY date
ORDER BY date;

-- Vaccination Data:
WITH pvac (Continent, Location, Date, Population, New_vaccinations, Peoplevactinatedaddedupbydate) AS
(
	SELECT DTH.continent, DTH.location, DTH.date, DTH.population, VAC.new_vaccinations,
	SUM(VAC.new_vaccinations) OVER (Partition by vac.location
	ORDER by dth.date, DTH.LOCATION ROWS UNBOUNDED PRECEDING) AS Peoplevactinatedaddedupbydate
	FROM DEATHS AS DTH
	JOIN VACTINATIONS AS VAC
	ON DTH.location = VAC.location 
	AND DTH.date = VAC.date
	WHERE DTH.continent IS NOT NULL
)

-- Number of people in population that got vaccinated:
SELECT *, (Peoplevactinatedaddedupbydate/Population) * 100 as percentageOfVaccinatedPeople FROM pvac;



-- top 10 countries with percentage of people who got booster from the people who got vactinated 

SELECT TOP 10
location, MAX(population) AS Population, 
(MAX(people_vaccinated)/max(population)) * 100 as percentageOfVaccinatedPeople, 
MAX(total_boosters) AS boosters,  
(MAX(total_boosters)/MAX(people_vaccinated)) * 100 AS booster_Percentage
FROM VACTINATIONS
WHERE continent IS NOT NULL and people_vaccinated IS NOT NULL and total_boosters IS NOT null 
GROUP BY location
ORDER BY percentageOfVaccinatedPeople desc;


--creating viw of top 10 countries with percentage of people who got booster from the people who got vactinated

create view top10vactinatedboosterdCountries AS
SELECT TOP 10
location, MAX(population) AS Population, 
(MAX(people_vaccinated)/max(population)) * 100 as percentageOfVaccinatedPeople, 
MAX(total_boosters) AS boosters,  
(MAX(total_boosters)/MAX(people_vaccinated)) * 100 AS booster_Percentage
FROM VACTINATIONS
WHERE continent IS NOT NULL and people_vaccinated IS NOT NULL and total_boosters IS NOT null 
GROUP BY location
ORDER BY percentageOfVaccinatedPeople desc;

--USING VIEW
SELECT * FROM top10vactinatedboosterdCountries