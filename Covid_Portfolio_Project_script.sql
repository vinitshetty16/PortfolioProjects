/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject_Covid.dbo.CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_Covid.dbo.CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases Vs Total Deaths
-- Likelihood of dying by COVID in India

Select Location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 AS Death_Rate
From PortfolioProject_Covid.dbo.CovidDeaths
WHERE Location like '%india%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid in India

Select Location, date, population, total_cases, (total_cases/population)*100 AS Infected_Percentage
From PortfolioProject_Covid.dbo.CovidDeaths
WHERE Location like '%india%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) AS TotalInfectionCount, MAX(total_cases/population)*100 AS Infected_Percentage
From PortfolioProject_Covid.dbo.CovidDeaths
Where continent is not null 
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject_Covid.dbo.CovidDeaths
Where continent is not null 
GROUP BY location
ORDER BY 2 DESC

-- Breaking down things by Continent

-- Continents with Highest Death Rate

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject_Covid.dbo.CovidDeaths
Where continent is not null 
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers per day

Select date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 


-- Total Population vs Vaccinations

-- Percentage of Population that has recieved at least one Covid Vaccine

SELECT death.continent , death.location , death.date, death.population, vac.new_vaccinations , 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location ORDER By death.location, death.date) AS RolligPeopleVaccinated
FROM PortfolioProject_Covid.dbo.CovidDeaths death
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RolligPeopleVaccinated)
as 
(
SELECT death.continent , death.location , death.date, death.population, vac.new_vaccinations , 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location ORDER By death.location, death.date) AS RolligPeopleVaccinated
FROM PortfolioProject_Covid.dbo.CovidDeaths death
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null
)

SELECT *, (RolligPeopleVaccinated/Population)*100 AS RollinVaccinationPercentage
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RolligPeopleVaccinated numeric,
)

INSERT INTO #PercentagePopulationVaccinated
SELECT death.continent , death.location , death.date, death.population, vac.new_vaccinations , 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location ORDER By death.location, death.date) AS RolligPeopleVaccinated
FROM PortfolioProject_Covid.dbo.CovidDeaths death
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null


Select *, (RolligPeopleVaccinated/Population)*100 AS RollinVaccinationPercentage
From #PercentagePopulationVaccinated 


-- Creating View to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT death.continent , death.location , death.date, death.population, vac.new_vaccinations , 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by death.location ORDER By death.location, death.date) AS RolligPeopleVaccinated
FROM PortfolioProject_Covid.dbo.CovidDeaths death
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null