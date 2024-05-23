--Having a brief look,through the Covid_Death's data and Covid_Vaccination's data
select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select*
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

--This displays a Country's number of Covid cases,total_deaths,recent_development_of_thhe new_variant,as well as date and population.
select  location, date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--A)Looking at the Total_Cases Vs Total_deaths

--1)This shows the likelyhood of dying,if you contact covid in a given location(Lets say,the United_States)
select  location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--2)This shows the likelyhood of dying,if you contact covid in Nigeria
select  location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%' and continent is not null
order by 1,2

--B)Looking at the Total_Cases Vs Population

--1)This shows what percentage of the population in Nigeria got Covid.
select  location, date,population,total_cases,(total_cases/population)*100 as Population_percentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--2)This shows what percentage of the population in the United_States got Covid.
select  location, date,population,total_cases,(total_cases/population)*100 as Population_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--3)This shows the percentage of the population that got Covid in each country.
select  location, date,population,total_cases,(total_cases/population)*100 as Population_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--c)TOTAL_DEATH_COUNT VS INFECTION_RATE IN EACH COUNTRY.

---1).Countries with a 'Higher_infection_rate' compared to population
select  location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 as Percentage_population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by Percentage_population_infected desc

--2).Countries with the 'Highest_death_count' per population
select  location,MAX(cast(Total_deaths as int)) AS Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc



--D).TOTAL_DEATH_COUNT PER CONTINENT:
select  continent,MAX(cast(Total_deaths as int)) AS Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc

select  location,MAX(cast(Total_deaths as int)) AS Total_death_count
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by Total_death_count desc



--E).GLOBAL NUMBERS per day:
--1).
select  date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100-- as int)) 
as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

---2).Overall across the world,we are looking at the total_cases,total_deaths,death_percentages
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100-- as int)) 
as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2











--Looking at Total_population vs Vaccinations
With popvsVac(continent,location,date,population,new_vaccinations,Rolling_people_vaccinated) as
(

select C_d.continent, C_d.location, C_d.date, C_d.population, C_v.new_vaccinations,
SUM(Cast(C_v.new_vaccinations as int)) OVER (Partition by C_d.Location Order by C_d.location,C_d.date) as Rolling_people_vacinated
from PortfolioProject..CovidDeaths AS C_d
join PortfolioProject..CovidVaccinations as C_v
           ON C_d.location=C_v.location
		   and C_d.date=C_v.date
where C_d.continent is not null
)

select*,(Rolling_people_vaccinated/population)*100 as vaccination_count
from popvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
Rolling_people_vaccinated numeric
)


Insert into #PercentPopulationVaccinated
select C_d.continent, C_d.location, C_d.date, C_d.population, C_v.new_vaccinations,
SUM(Cast(C_v.new_vaccinations as int)) OVER (Partition by C_d.Location Order by C_d.location,C_d.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths AS C_d
join PortfolioProject..CovidVaccinations as C_v
           ON C_d.location=C_v.location
		   and C_d.date=C_v.date
where C_d.continent is not null

select*,(Rolling_people_vaccinated/population)*100 as vaccination_count
from  #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated as
select C_d.continent, C_d.location, C_d.date, C_d.population, C_v.new_vaccinations,
SUM(Cast(C_v.new_vaccinations as int)) OVER (Partition by C_d.Location Order by C_d.location,C_d.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths AS C_d
join PortfolioProject..CovidVaccinations as C_v
           ON C_d.location=C_v.location
		   and C_d.date=C_v.date
where C_d.continent is not null


select*
From PercentPopulationVaccinated