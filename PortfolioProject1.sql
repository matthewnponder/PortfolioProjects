--SELECTING ALL OF OUR COVID DATA
--DATA PROVIDED FROM OURWORLDOFDATA.COM  
select * 
from coviddeaths
order by 3, 4


select * 
from covidvaccinations
order by 3, 4



-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKLIHOOD OF DYING IF YOU CONTRACT COVID IN THE UNITED STATES
select location, date, total_cases, total_deaths
	, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%states%'
order by 3 desc, 1, 2

--LOOKING AT TOTAL CASES VS POPULATION
select location, date, total_cases, population
	, (total_cases/population)*100 as PercentPopulationInfected 
from coviddeaths
--where location like '%states%'
order by 1, 2



--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
select location, population, max(total_cases) as HighestInfectionCount
	, max((total_cases/population))*100 as PercentPopulationInfected 
from coviddeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location
	, max(cast(total_deaths as int)) as TotalDeathCount
	, population
	, max((total_deaths/population))*100 as DeathPerPopulation 
from coviddeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount  desc


--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select date
	, sum(new_cases) as TotalCases
	, sum(cast(new_deaths as int)) as TotalDeaths
	, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1, 2

--TOTAL POPULATION VS VACCINATIONS
select dea.continent
	, dea.location
	, dea.date
	, population
	, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	, (RollingPeopleVaccinated/population) * 100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent
	, dea.location
	, dea.date
	, population
	, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	, (RollingPeopleVaccinated/population) * 100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac

--USE TEMPORARY TABLE 
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255)
	,location nvarchar(255)
	,date datetime
	,population numeric
	,new_vaccinations numeric
	,RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent
	, dea.location
	, dea.date
	, population
	, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) * 100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated
	
--CREATING VIEWS TO USE FOR LATER DATA VISUALIZATION 
Create View GlobalNumbers as 
select date
	, sum(new_cases) as TotalCases
	, sum(cast(new_deaths as int)) as TotalDeaths
	, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
--where location like '%states%'
where continent is not null
group by date
--order by 1, 2

select * 
from globalnumbers

USE PortfolioProject1
GO
Create view CountryTotalDeath as 
select location
	, max(cast(total_deaths as int)) as TotalDeathCount
	, population
	, max((total_deaths/population))*100 as DeathPerPopulation 
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
--order by TotalDeathCount  desc

USE PortfolioProject1
GO
Create view USCasesvsDeaths as
select location, date, total_cases, total_deaths
	, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
--order by 3 desc, 1, 2

USE PortfolioProject1
GO
Create view ContinentTotalDeaths as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

USE PortfolioProject1
GO
Create view CasesbyPopulation as
select location, date, total_cases, population
	, (total_cases/population)*100 as PercentPopulationInfected 
from coviddeaths
where location like '%states%'
--order by 1, 2