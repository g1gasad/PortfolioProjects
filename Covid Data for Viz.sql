Select *
From PortfolioProject..CovidDeaths
where continent is not null
--we can add this where clause to every query to filter out the data 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases v Total deaths
--Shows likelyhood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location='India'
order by 1,2


--Looking at the Total Cases v Population
--Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where location='India'
order by 1,2


--Looking at countries with highest infection rates compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxInfectionPercentage
From PortfolioProject..CovidDeaths
--where location='India'
group by Location, population
order by MaxInfectionPercentage desc


--Showing the countries with the highest death counts per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location='India'
where continent is not null
group by Location
order by TotalDeathCount desc


--Showing the continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
       sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2	

--query to get all time data

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
       sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at total population v vaccinations

--CTE

with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as   --if the no. of columns in CTE is different than below, it's gonna give an error
(
select dea.Continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int)
	, sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
	--always convert to numeric, not int
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac



--TEMP TABLE
drop table if exists #Percent_Population_Vaccinated
Create table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations bigint,
RollingPeopleVaccinated numeric
)
insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint)
	--cast/convert as numeric, not int
	, sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 
from #Percent_Population_Vaccinated


--creating view to store data for later visualizations

--drop view Percent_Population_Vaccinated

go
CREATE VIEW Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population,
	   cast(vac.new_vaccinations as numeric) as new_vaccinations,
	--cast/convert as numeric, not int
	   sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3


select *
from Percent_Population_Vaccinated
