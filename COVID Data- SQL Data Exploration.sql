SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;

--Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) AS death_percentage
FROM coviddeaths
WHERE location = 'Canada'
ORDER BY 1,2;

--Looking at Total Cases Vs Population
--Shows what percentage of Population got Covid

SELECT location, date, population, total_cases, Round((total_cases/population)*100,2) AS PercentPopulationInfected
FROM coviddeaths
WHERE location = 'Canada'
ORDER BY 1,2;

--Looking at Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, Round(MAX(total_cases/population)*100,2) AS PercentPopulationInfected
FROM coviddeaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

--Showing Countries with Highest Death Count

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM coviddeaths
WHERE continent is not null AND total_deaths is not null
GROUP BY location
ORDER BY Total_Death_Count DESC;

--Showing Continents with Highest Death Count

SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, Round(SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100,2) AS Death_Rate
FROM coviddeaths
WHERE continent IS not null
GROUP BY Date
ORDER BY 1,2;

--Total Population Vs Vaccinations

SELECT DEA.CONTINENT,
	DEA.LOCATION,
	DEA.DATE,
	DEA.POPULATION,
	VAC.NEW_VACCINATIONS,
	SUM(NEW_VACCINATIONS) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	--, Round((Rolling_People_Vaccinated/population)*100,2) AS PercentPopulationVaccinated
FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATIONS AS VAC ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 2,3;

-- Using CTE

WITH Pop_Vs_Vac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
As
(
SELECT DEA.CONTINENT,
	DEA.LOCATION,
	DEA.DATE,
	DEA.POPULATION,
	VAC.NEW_VACCINATIONS,
	SUM(NEW_VACCINATIONS) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATIONS AS VAC ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
)
SELECT *,Round((Rolling_People_Vaccinated/population)*100,2) AS Percent_Population_Vaccinated 
FROM Pop_Vs_Vac;

-- Using Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMP TABLE PercentPopulationVaccinated
(continent varchar(255),
 location varchar(255),
 date date,
 population numeric,
 new_vaccinations numeric,
 Rolling_People_Vaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT DEA.CONTINENT,
	DEA.LOCATION,
	DEA.DATE,
	DEA.POPULATION,
	VAC.NEW_VACCINATIONS,
	SUM(NEW_VACCINATIONS) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATIONS AS VAC ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL;

SELECT *,Round((Rolling_People_Vaccinated/population)*100,2) AS Percent_Population_Vaccinated 
FROM PercentPopulationVaccinated;

