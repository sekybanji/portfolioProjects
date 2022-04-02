select *
from dbo.covidDeaths$
where continent is not null
order by 3,4



--select *
--from dbo.covidVaccinations$
--order by 3,4


--select data that we are going to be using 
--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid
USE [portifolio Project]

select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as Deathpercentage
from dbo.covidDeaths$
where location like '%states%'
order by 1,2


----looking at total cases vs population
----shows what percentage of population got covid
select location, date, total_cases, population, (total_deaths/population)*100 as contractpercentage
from dbo.covidDeaths$
where location like '%states%'
order by 1,2

----looking at countries with hishest infection rate compared to population

select location, population, max(total_cases as int) as Highestinfectioncount,MAX(total_deaths/total_cases))*100 as Populationinfectedpercentage
from dbo.covidDeaths$
--where location like '%states%'
group by location, population 
having location like '%states%'
order by Populationinfectedpercentage desc

--showing countries with highest death count per population

USE [portifolio Project]
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from dbo.covidDeaths$
where continent is not null
--where location like '%states%'
group by location
order by totaldeathcount desc

--let's break things down by continents

USE [portifolio Project]
select location, max(cast(total_deaths as int)) as totaldeathcount
from dbo.covidDeaths$
where continent is  null
group by location 
order by totaldeathcount desc

--looking at total population vs vaccination

USE [portifolio Project]
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations
from covidDeaths$ dea
join covidVaccinations$ vac 
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--rolling count
USE [portifolio Project]
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidDeaths$ dea
join covidVaccinations$ vac 
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--use cte
USE [portifolio Project];
with PopvsVac (continent, location,data,population, new__vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidDeaths$ dea
join covidVaccinations$ vac 
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
Drop table if exists #percentpopulationVaccinated 
Create table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #percentpopulationVaccinated
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidDeaths$ dea
join covidVaccinations$ vac 
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
select*,(rollingPeopleVaccinated/population)*100
from #percentpopulationVaccinated

--creating views to store data for future visulizations


create view percentpopulationvaccinated as 
select dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidDeaths$ dea
join covidVaccinations$ vac 
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated