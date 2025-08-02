select *
from portfolio..CovidDeaths
order by 3,4

--select *
--from portfolio..CovidVaccinations
--order by 3,4

-- Select Data
select location, date, total_cases, new_cases, total_deaths, population
from portfolio..CovidDeaths
order by 1,2

-- Percentages of Total Cases / Total Deaths
-- how many percentages people dying from covid in a specific country
select location, date, total_cases, total_deaths,
(CAST(total_deaths AS FLOAT) / total_cases)*100 as DeathPercentage
from portfolio..CovidDeaths
where location like 'Canada'
order by 1,2

ALTER TABLE portfolio..CovidDeaths
ALTER COLUMN population BIGINT;


-- Percentages of Total Cases / Total Deaths
-- show what percentage of population got Covide in specific country
select location, date, population, total_cases,
(total_cases / population)*100 as DeathPercentage
from portfolio..CovidDeaths
where location like 'Canada'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases / population))*100 as PercentPopulationInfected
from portfolio..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- Highest Death count per Population
	-- Country
select location, max(total_deaths) as TotalDeathCount
from portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
	-- Continent
select location, max(total_deaths) as TotalDeathCount
from portfolio..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- Death Percentages across the world
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(cast(new_cases as float))*100 as DeathPercentage
from portfolio..CovidDeaths
where continent is not null
order by 1,2

-- Vaccinated Percentages base on Population
-- Join two tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
from portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--1. CTE
with VaccinatedOfPop (Continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
from portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingVaccinated/population)*100
from VaccinatedOfPop

--2.Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
from portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccinated/population)*100
from #PercentPopulationVaccinated


-- Create a View to store date for visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinated
from portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated