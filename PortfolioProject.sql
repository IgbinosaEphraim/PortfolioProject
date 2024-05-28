--SELECT *
--From Portfolioproject..['CovidVaccination$']
--order by 3,4

--Select Data that we are going to be using 

--SELECT *
--From Portfolioproject..Deaths$
--where continent is not null
--order by 3,4

Select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..Deaths$
order by 1,2

-- looking at total cases vs total deaths 
-- shows likelikehood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..Deaths$
where location like '%nigeria%'
order by 1,2


-- looking at total cases vs population 
-- shows what percentage of population got covid


select location, date, total_cases,population, (CONVERT(float,population) / NULLIF(CONVERT(float, total_cases), 0)) as PercentPopulationInfected
from PortfolioProject..Deaths$
--where location like '%nigeria%'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max (total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as PercentPopulationInfected
from PortfolioProject..Deaths$
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Deaths$
--where location Nigeria
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

-- showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..Deaths$
--where location nigeria
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


select sum(new_cases)as total_cases, sum (cast(new_deaths as int))as total_deaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..Deaths$
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated
from PortfolioProject..covid_vaccinations vac
join PortfolioProject..Deaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated
from PortfolioProject..covid_vaccinations vac
join PortfolioProject..Deaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population) * 100 
from PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar (255),
date datetime, 
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated
from PortfolioProject..covid_vaccinations vac
join PortfolioProject..Deaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population) * 100 
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated
from PortfolioProject..covid_vaccinations vac
join PortfolioProject..Deaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

