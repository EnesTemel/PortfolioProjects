--Looking at the main table
select * from [Portfolio Project].dbo.CovidDeaths$ where continent is not null 
order by 3,4

--select * from [dbo].[CovidVaccination]   order by 3,4

--  selected the data i am gonna be using  
SELECT location,date,total_cases,new_cases,total_deaths,population,continent
FROM [Portfolio Project].dbo.CovidDeaths$ order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows Probability of dying if you contract covid in your country
SELECT Location, date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage'
FROM [Portfolio Project].dbo.CovidDeaths$ where location like '%Turkey%'
order by 2 asc
--Looking at TotalCases vs Population
--Shows what percentage of population got covid 
SELECT Location, date ,population, total_cases, (total_cases/population)*100 as 'PercentPopulationInfected'
FROM [Portfolio Project].dbo.CovidDeaths$   where location like '%Turkey'
order by 2 asc
--Showing which countries has the highest infection rate compared to population  
SELECT Location,population,MAX(total_cases) as HighestCaseCount , MAX((total_cases/population))*100 as 'PercentPopulationInfected'
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null   
group by  Location,population
order by PercentPopulationInfected desc
--Showing which countries has the highest death count  
SELECT Location,  MAX(CAST(Total_deaths as float )) as TotalDeathCount 
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null   
group by  Location 
order by TotalDeathCount desc
--Highest Death Count by continents
SELECT location,  MAX(CAST(Total_deaths as float )) as TotalDeathCount 
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is null   
group by location  
order by TotalDeathCount desc
--Total Deaths Worldwide
Select Location ,sum(total_cases)as TotalCases, MAX(total_deaths) as TotalDeaths,
SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage  from [Portfolio Project].dbo.CovidDeaths$
WHERE location like '%World'
group by location
--Global Numbers 
SELECT Date , sum(new_cases) as New_Cases,  MAX(Total_deaths) as TotalDeathCount  
,SUM(new_deaths) as New_Deaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
where continent is not null   
group by  date
 order by date 
 ---Joining Vaccination and Covid Deaths/Looking at Total Populations vs Total Vaccination 
 Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 Sum(CAST( vac.new_vaccinations as float )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingVaccinationTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null   
 order by 2,3

 --USÝNG CTE  
 With PopulationvsVaccination (continent,location,date,population,new_vaccinations,rollingvaccinationtotal)
 as 
 (
 Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 Sum(CONVERT( float,vac.new_vaccinations  )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingVaccinationTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null   
 --order by 2,3
 )
 Select *, (rollingvaccinationtotal/population)*100 from PopulationvsVaccination
 where rollingvaccinationtotal is not null and new_vaccinations is not null 
 
 
 --Looking At Total Tests vs Total Population 
 Select dea.continent,dea.location,dea.date, dea.population, vac.new_tests,
 Sum(CAST( vac.new_tests as float )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingTestsTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null  and new_tests is not null 
 order by 2,3
 
 
 --TEMP TABLE
 
  
 Create Table #TotalTestvsPopulation
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_tests numeric ,
 RollingTestsTotal numeric)

 Insert into #TotalTestvsPopulation

 Select dea.continent,dea.location,dea.date, dea.population, vac.new_tests,
 Sum(CAST( vac.new_tests as float )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingTestsTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null  and new_tests is not null 
 --order by 2,3
  
 Select * ,  (RollingTestsTotal/population)*100 as PercentPopulationTested from #TotalTestvsPopulation 
 order by location,date

 --Creating View to store data for later visualizations
 Create View  PercentPopulationVaccinated1   as
 Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 Sum(CAST( vac.new_vaccinations as float )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingVaccinationTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null   
 --order by 2,3
  
------
 Create View  PercentPopulationTested1  as
 Select dea.continent,dea.location,dea.date, dea.population, vac.new_tests,
 Sum(CAST( vac.new_tests as float )) OVER (Partition by dea.location order by dea.location , dea.date) as RollingTestsTotal
 From [Portfolio Project].dbo.CovidDeaths$ dea join [Portfolio Project]..CovidVaccination$ vac 
 on dea.date= vac.date and dea.location=vac.location
 where dea.continent is not null  and new_tests is not null 
 --order by 2,3
 ----

