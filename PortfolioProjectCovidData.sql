--The Excel files for this project 
--may be found in the SQLDataExploration repository 
--under CovidDeaths.xlsx and CovidVaccinations.xlsx


SELECT * 
FROM dbo.CovidDeaths
order by 3,4

SELECT *
FROM dbo.CovidVaccinations
order by 3,4

--Select data that I will use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM dbo.CovidDeaths
order by 1,2

--Looking at total cases vs popluation

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM dbo.CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries w/ highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- showing countries w/ highest death count per population

SELECT Location, MAX(CAST(total_deaths as int)) as total_death_count
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC


--Break it down by continent
--Showing continents w/ highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as total_death_count
FROM dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC


--global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent is not null
order by 1,2

--global numbers by date

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2


--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea. date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccine_count
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location
and dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccine_count)
AS
(
SELECT dea.continent, dea.location, dea. date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccine_count
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location
and dea.date = vacc.date
WHERE dea.continent is not null
)

SELECT *, (rolling_vaccine_count/population)*100
FROM PopvsVac


--Temp table

CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccine_count numeric)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea. date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccine_count
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location
and dea.date = vacc.date
WHERE dea.continent is not null

SELECT *, (rolling_vaccine_count/population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated 


--VIEWS
--creating view to store for visualizations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea. date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccine_count
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location
and dea.date = vacc.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated






