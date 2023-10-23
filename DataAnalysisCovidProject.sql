--SELECT *
--FROM PortfolioProject..CovidDeaths
--order by 3,4

---Selecting useable data

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--order by 3,4


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

--Looking at Total cases vs total Deaths percentage

SELECT location, date, total_cases, total_deaths, (total_deaths * 1.0 / total_cases *1.0) *100 as DeathPercentage
FROM [dbo].[CovidDeaths]
where location like '%eria%'
ORDER BY 1,2

--looking at total cases vs population
SELECT location, date, total_cases, population, (total_deaths * 1.0 / population *1.0) *100 as PopulationPercentageInfected
FROM [dbo].[CovidDeaths]
where location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases * 1.0 / population *1.0)) *100 as PopulationPercentageinfected
FROM [dbo].[CovidDeaths]
group by location, population
ORDER BY PopulationPercentageinfected  desc

--showing the countries with highest death count per population
SELECT location, MAX(total_deaths) as  PopulationDeath
FROM [dbo].[CovidDeaths]
where continent is not null
group by location
ORDER BY PopulationDeath  desc


--lets break it down by continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is not  null
group by continent
ORDER BY TotalDeathCount desc

--showing the continent with highest death count


SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is not  null
group by continent
ORDER BY TotalDeathCount desc

--Global numbers,2
--SELECT  SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeath, sum(new_deaths * 1.0)/sum(new_cases *1.0 ) *100 as DeathPercentage
--FROM [DBO].[CovidDeaths]
--WHERE continent IS NOT NULL
--ORDER BY 1

--looking at total population vs vacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte
with popvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
sum(convert( bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (Rollingpeoplevaccinated /population  ) 
from popvac


--tepm

drop table if exists #PercentVaccinated
Create table #PercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeoplevaccinated numeric
)
insert into #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
sum(convert( bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (population * 1.0 / rollingPeoplevaccinated * 1.0)*100
from #PercentVaccinated



--creating view to store data



Create View PercentVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
sum(convert( bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentVaccinated