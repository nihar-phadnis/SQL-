/* 
Covid-19 Data exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From MiniProject..CovidDeaths
where continent is not null
order by 3,4

Select * 
from MiniProject..CovidVaccinations
where continent is not null
order by 3,4 

Use MiniProject

--EXEC sp_columns CovidDeaths

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths order by 1,2

-- Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2

-- Total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as PeopleInfected
from CovidDeaths
where location like '%states%'
order by 1,2

Select location, date, MAX(total_cases) as HighestCases, population, MAX(total_cases/population)*100 as PeopleInfected
from CovidDeaths
--where location like '%states%'
group by location, population, date
order by PeopleInfected desc

-- Highest amount of people infected vs the Population
Select location, population, MAX(total_cases) as HighestCases, MAX((total_cases/population))*100 as PeopleInfected 
from CovidDeaths
--where continent is null
group by location, population
order by PeopleInfected desc
	
--Now the deaths. Countries with highest death per populations

Select continent, population, MAX(cast(total_deaths as int)) as HighestDeaths, MAX((total_deaths/population))*100 as DeathsPerPopulation
from CovidDeaths
where continent is not null
group by continent, population
order by DeathsPerPopulation desc 

--By Continents now 

Select continent, MAX(cast(total_deaths as int)) as HighestDeaths, MAX((total_deaths/population))*100 as DeathsPerPopulation
from CovidDeaths
where continent is not null
group by continent
order by DeathsPerPopulation desc 

--Numbers for the whole world

Select date, SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as HighestDeaths, SUM(cast(total_deaths as int))/SUM(total_cases)*100 as DeathsPerPopulation
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Numbers for the whole world till now

Select SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as HighestDeaths, SUM(cast(total_deaths as int))/SUM(total_cases)*100 as DeathsPerPopulation
from CovidDeaths
where continent is not null
--group by date
order by 1,2

--Covid Vaccination

Select * from CovidDeaths

Select * from CovidDeaths deaths join CovidVaccinations vacc on deaths.location = vacc.location and deaths.date = vacc.date

-- Now we look at population vs the total vaccination

Select deaths.continent, deaths.location, deaths.continent, deaths.date, deaths.population, vacc.new_vaccinations 
from CovidDeaths deaths 
join CovidVaccinations vacc 
on deaths.location = vacc.location 
and deaths.date = vacc.date 
where deaths.continent is not null
order by 2,3

-- Now we look at population vs the total vaccination

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations , 
SUM(cast(vacc.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date ) as RollingPeopleVaccinated
from CovidDeaths deaths 
join CovidVaccinations vacc 
on deaths.location = vacc.location 
and deaths.date = vacc.date 
where deaths.continent is not null
order by 2,3

--Creating a table for rolling people vaccinated
Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations , 
SUM(cast(vacc.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date ) as RollingPeopleVaccinated
from CovidDeaths deaths 
join CovidVaccinations vacc 
on deaths.location = vacc.location 
and deaths.date = vacc.date 
where deaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPeopleVaccinated

--Creating view for later

Create View PercentPeopleVaccinated as 

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations , 
SUM(cast(vacc.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date ) as RollingPeopleVaccinated
from CovidDeaths deaths 
join CovidVaccinations vacc 
on deaths.location = vacc.location 
and deaths.date = vacc.date 
where deaths.continent is not null
--order by 2,3