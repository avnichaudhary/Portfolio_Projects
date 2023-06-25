
Use PortfolioProject 

Select*
From PortfolioProject..Coviddeaths
Where continent is not null
Order by 3,4


--Select*
--From PortfolioProject..Covidvaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.Coviddeaths
Where continent is not null
order by 1,2

-- change datatype of columns
Alter Table PortfolioProject.dbo.Coviddeaths
Alter Column total_cases Float
Alter table PortfolioProject.dbo.Coviddeaths
alter column total_deaths Float

-- total cases Vs Total deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases) as Deathpercentage
From PortfolioProject.dbo.Coviddeaths
Where location like '%India%'
and continent is not null
order by 1,2

-- total cases Vs population

Select Location, date, total_cases, population, (total_cases/population)*100 as casespercentage
From PortfolioProject.dbo.Coviddeaths
--Where location like '%India%'
Where continent is not null
order by 1,2

-- Countries with highest infection rate compared to population

Select Location,population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentofPopulationInfected
From PortfolioProject.dbo.Coviddeaths
--Where location like '%India%'
Where continent is not null
Group by Location,population
order by PercentofPopulationInfected desc

-- Countries with highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject.dbo.Coviddeaths
--Where location like '%India%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

Select location, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject.dbo.Coviddeaths
--Where location like '%India%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Continent with highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject.dbo.Coviddeaths
--Where location like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not null 
--Group By date
order by 1,2

-- CovidVaccinations table Data Exploration

Select*
From PortfolioProject.dbo.Covidvaccinations

-- both tables joined by date and location

Select*
From PortfolioProject..Coviddeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date



-- Looking at total population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USING CTE

with PopvsVac( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select*,(RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE 

DROP TABLE If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location
 Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select*,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select * 
from PercentPopulationVaccinated

