
-- Alter data from Varchar where applicable

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_cases FLOAT
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths FLOAT
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN population FLOAT
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN date DATE
ALTER TABLE dbo.CovidVaccinations
ALTER COLUMN date DATE

-- Select data that we are going to be using  

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject01..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Chances of death if Covid19 is contracted in the United States from Jan of 2020 to April of 2021

SELECT location, date, total_cases, total_deaths,(total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM PortfolioProject01..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows us the percentage of the United States population that contacted Covid19 from Jan of 2020 to April of 2021

SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectionRate
FROM PortfolioProject01..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Loking at locations with the highest infection rate compared to it's population at the time

SELECT location, MAX(total_cases) as HighestNumOfCases, population,(MAX(total_cases)/NULLIF(population, 0))*100 as HighestInfectionRate
FROM PortfolioProject01..CovidDeaths
Group by Location, population
ORDER BY HighestInfectionRate desc;

-- We are looking at locations with the highest total death count

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject01..CovidDeaths
Group by Location
ORDER BY TotalDeathCount desc;

-- Looking at total population vs vaccinations

Select death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by death.location ORDER BY death.location, death.date) as RollingCountOfVaccinations
FROM PortfolioProject01..CovidDeaths as death
JOIN PortfolioProject01..CovidVaccinations as vac
	ON death.location = vac.location
	AND death.date = vac.date
ORDER By 1,2;

-- Use CTE to find highest percentage of the population vaccinated in the United States, Mexico and Canada from Jan of 2020 to April of 2021
WITH PopVsVac_CTE as 
(
Select death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by death.location ORDER BY death.location, death.date) as RollingCountOfVaccinations
FROM PortfolioProject01..CovidDeaths as death
JOIN PortfolioProject01..CovidVaccinations as vac
	ON death.location = vac.location
	AND death.date = vac.date
)
SELECT location, MAX(RollingCountOfVaccinations/NULLIF(population,0))*100 as HighestPrecentageOfVaccinations
FROM PopVsVac_CTE
WHERE location like 'United States'
or location like 'Mexico'
or location like 'Canada'
GROUP BY location
ORDER BY HighestPrecentageOfVaccinations desc;

-- Temp table example of finding the highest percentage of the population vaccinated in the United States, Mexico and Canada from Jan of 2020 to April of 2021

Create table #PercentPopulationVaccinated
(
Location varchar (255),
DATE date,
Population FLOAT,
New_vaccinations FLOAT,
RollingCountOfVaccinations FLOAT
)
Insert into #PercentPopulationVaccinated
Select death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by death.location ORDER BY death.location, death.date) as RollingCountOfVaccinations
FROM PortfolioProject01..CovidDeaths as death
JOIN PortfolioProject01..CovidVaccinations as vac
	ON death.location = vac.location
	AND death.date = vac.date;

SELECT location, MAX(RollingCountOfVaccinations/NULLIF(population,0))*100 as HighestPrecentageOfVaccinations
FROM #PercentPopulationVaccinated
WHERE location like 'United States'
or location like 'Mexico'
or location like 'Canada'
GROUP BY location
ORDER BY HighestPrecentageOfVaccinations desc;

-- Creating View to store data for later visualizations of the chances of death if Covid19 is contracted in the United States from Jan of 2020 to April of 2021

CREATE VIEW US_DeathRate as

SELECT location, date, total_cases, total_deaths,(total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM PortfolioProject01..CovidDeaths
WHERE location like '%states%';

-- Test View

SELECT *
FROM US_DeathRate;