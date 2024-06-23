/*

Covid 19 Data Exploration

Joins, CTE's, Temp Tables, Partitions, Aggregate Functions, Creating Views, etc.

*/


select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4


--START

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking At Total Cases VS Total Deaths
-- Shows likelihood of dying of Covid in Nigeria

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 AS PercentageOfCases
From PortfolioProject..CovidDeaths
where location like '%Nigeria%' and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOfCases
From PortfolioProject..CovidDeaths
--where location like '%italy%'
group by location, population
order by PercentageOfCases DESC



-- LET'S DO CONTINENT
-- Showing continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

--Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--From PortfolioProject..CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount DESC



-- GLOBAL NUMBERS

Select date, sum(new_cases) as TotalCases,
sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 AS GlobalDeathPercentage
From PortfolioProject..CovidDeaths
where CONTINENT Is not null
group by date
order by 1,2

Select sum(new_cases) as TotalCases,
sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 AS GlobalDeathPercentage
From PortfolioProject..CovidDeaths
where CONTINENT Is not null
--group by date
order by 1,2



-- Looking at Total Population VS Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by DEA.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3




-- WITH CTE

With PopVsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by DEA.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *,  (RollingPeopleVaccinated/population)*100 as PercentageRPVac
From PopVsVac






-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by DEA.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *,  (RollingPeopleVaccinated/population)*100 as PercentageRPVac
From #PercentPopulationVaccinated




--Creating Views to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by DEA.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated
