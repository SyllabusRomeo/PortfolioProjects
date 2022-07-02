
select *
from PortfolioProject..CovidDeaths
order by 3, 4

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

-- Selecting Data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Total Cases Vs Total Death & Death Percentage
-- Shows the likelihood of dying if you contract covid in America
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--Looking at Total Cases Vs Population
--Shows what percentage of the population got covid
Select Location, date,population, total_cases, (total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

--Looking at countries with highest deathcount per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Looking at countries with highest deathcount per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc

---BREAKING THINGS DOWN BY CONTINENT---

---- By continents with highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS--
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- Looking at Total Population vs vaccinations
select * 
from PortfolioProject..CovidVaccinations

--Join Tables
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- total population vs vacination
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- total population vs vacination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, convert(numeric,vac.new_vaccinations))) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
from #PercentPopulationVaccinated

---VIEWS---
--Creating VIEW to store data for later visualizations

Use PortfolioProject

Create View PercentPopulationVaccinated as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * 
from PercentPopulationVaccinated


--View DeathCount Population--
Use PortfolioProject
Create View DeathCountPopulation as(
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
--order by TotalDeathCount desc
)

select *
from DeathCountPopulation