Select *
FROM [Portfolio Projects].[dbo].[CovidDeaths]
order by 3,4

Select *
FROM [Portfolio Projects].[dbo].[CovidVaccinations]
order by 3,4

---Select Data that we will be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects].[dbo].[CovidDeaths]
order by 1,2

---Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
Where Location like '%states%'
order by 1,2

---Looking at Total Cases vs Population
---Shows what percentage of population gets Covid
Select Location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as PercentagePopulationInfected
FROM [Portfolio Projects].[dbo].[CovidDeaths]
Where Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate comapared to Population
 Select Location, population, Max(total_cases) as HighestInfectionCount, Max ((total_cases/population))*100 as PercentagePopulationInfected
FROM [Portfolio Projects].[dbo].[CovidDeaths]
---Where Location like '%states%'
group by Location, population
order by PercentagePopulationInfected desc

---Showing Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as HighestDeathCount
FROM [Portfolio Projects].[dbo].[CovidDeaths]
---Where Location like '%states%'
Where continent is not null
group by Location, population
order by HighestDeathCount desc

---Showing Continents with highest death count per population
Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
FROM [Portfolio Projects].[dbo].[CovidDeaths]
---Where Location like '%states%'
Where continent is not null
group by continent
order by HighestDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM [Portfolio Projects].[dbo].[CovidDeaths]
---Where Location like '%states%'
Where continent is not null
---group by date
order by 1, 2

---Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
Join [Portfolio Projects].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

---USE CTE

With PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
Join [Portfolio Projects].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

---TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
Join [Portfolio Projects].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
---where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

---Creating View to store data for later visualization
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
FROM [Portfolio Projects].[dbo].[CovidDeaths] dea
Join [Portfolio Projects].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentagePopulationVaccinated
