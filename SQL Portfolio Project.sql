-- looking at total cases vs total deaths
-- Shows liklihood of dying if you contract Covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- looking at Total Cases vs Population
-- Shows what percentage of the population has gotten Covid
select location, date, total_cases, population , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population , max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population 
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location 
order by HighestDeathCount desc

-- Breaking down by continent
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent  
order by HighestDeathCount desc

-- Global numbers as total percentage of people who died. removed new_cases = 0
select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths, sum(new_deaths) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths 
where continent is not NULL and new_cases <> 0
--group by date
order by 1,2

-- Global numbers as total percentage of people who died by date. removed new_cases = 0
select date, sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths, sum(new_deaths) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths 
where continent is not NULL and new_cases <> 0
group by date
order by 1,2

-- Looking at Total Population vs Vaccination
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not NULL 
order by 2,3

--use CTE
with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingVaccinations)
as 
(
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not NULL 
--order by 2,3
)
select *, (RollingVaccinations/population)*100
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date date, Population float, New_Vaccinations bigint, RollingVaccinations float) 

insert into #PercentPopulationVaccinated
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
	--where dea.continent is not NULL 
	--order by 2,3

select *, (RollingVaccinations/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not NULL 