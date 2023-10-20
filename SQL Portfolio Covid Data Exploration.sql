
--select*
--from PortfolioProject..CovidDeaths
--order by 3,4

select*
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


select*
from PortfolioProject..CovidVaccinations
order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


--looking at toal cases vs total deaths
-- shows likelihood of dying if you contract covid in your country	

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2



-- looking at total case vs population
-- Shows what percentage of population got Covid
select location, date, population,total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compare to populalion

select location, population,max(total_cases), max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by population, location
order by PercentPopulationInfected desc

-- Showing the cpuntries with the highest death count per population
select location, population,max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentDeathperPopulation
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by population, location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc
-- this is not the right order because the North America continent doesn't count Canada

-- Lets make this right
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--Showing the continent	with the highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, sum (new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathsPercentage--total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-------------------------------------------------------------------------------------------------

-- looking at total population vs vaccinations
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- looking how many people get vaccinated in each country
-- use CTE
with PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) *100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
insert into #PercentPopulationVaccinated
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population) *100 as PercentVaccinated
from #PercentPopulationVaccinated




--Creating view to store data for later visualization
create view PercentPopulationVaccinated as
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated