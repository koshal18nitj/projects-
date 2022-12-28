SELECT datname FROM pg_database;
use portfolioproject;

create table if not exists CovidDeath
(
iso_code varchar ,	continent	varchar ,
Current_location varchar	, dated date	, population integer,	total_cases float,	new_cases float,	
new_cases_smoothed float,	total_deaths float,	new_deaths float,	new_deaths_smoothed float,	
total_cases_per_million float,	new_cases_per_million float,	new_cases_smoothed_per_million float,	
total_deaths_per_million float,	new_deaths_per_million float,	new_deaths_smoothed_per_million float,	
reproduction_rate	float,icu_patients float,	icu_patients_per_million float,	hosp_patients float,	
hosp_patients_per_million float,	weekly_icu_admissions float,	weekly_icu_admissions_per_million float,	
weekly_hosp_admissions float,	weekly_hosp_admissions_per_million float,	total_tests float,	new_tests float,
total_tests_per_thousand float,	new_tests_per_thousand	float, new_tests_smoothed float,	
new_tests_smoothed_per_thousand float,	positive_rate float,	tests_per_case float
);

select * from CovidDeath; 

--- copy CovidDeath 
--- from 'D:\projects\sql\WorldCovid-19\CovidDeath.csv' 
--- delimiter ',' csv header;

select Count(iso_code) from coviddeath;

create table if not exists CovidVaccination
(
	iso_code varchar ,	continent	varchar ,
Current_location varchar	,	 dated date	,	new_tests	float,
total_tests_per_thousand	float, new_tests_per_thousand float,	new_tests_smoothed	float,
new_tests_smoothed_per_thousand float,	positive_rate float,	tests_per_case float,	
tests_units varchar,	total_vaccinations float,	people_vaccinated float,	people_fully_vaccinated float,	total_boosters	float,
new_vaccinations float,	new_vaccinations_smoothed float,	total_vaccinations_per_hundred	float,
people_vaccinated_per_hundred float,	people_fully_vaccinated_per_hundred float,	
total_boosters_per_hundred	float,
new_vaccinations_smoothed_per_million float,	new_people_vaccinated_smoothed	float,
new_people_vaccinated_smoothed_per_hundred	float, stringency_index float,	population_density float,
median_age float,	aged_65_older float,	aged_70_older float,	gdp_per_capita float,	extreme_poverty float,	
cardiovasc_death_rate float,	diabetes_prevalence float,	female_smokers float,	male_smokers float,	
handwashing_facilities	float, hospital_beds_per_thousand float,	life_expectancy float,	
human_development_index float,	excess_mortality_cumulative_absolute float,	excess_mortality_cumulative float,	
excess_mortality float,	excess_mortality_cumulative_per_million float
);


--- copy CovidVaccination
--- from 'D:\projects\sql\WorldCovid-19\CovidVaccination.csv' 
---- delimiter ',' csv header;

select * from covidvaccination limit 2;


-------------------------------------------------------------------------------------------------------------------------------------------------
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeath
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select current_location, dated, total_cases, new_cases, total_deaths, population
From CovidDeath
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select current_location, dated, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeath
Where current_location like '%States%' 
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select current_location, dated, Population, total_cases,  (total_cases/population)* 100  as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select current_location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Group by current_location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select current_location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by current_location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.current_location, dea.dated, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.current_location Order by dea.current_location, dea.Dated) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.current_location = vac.current_location
	and dea.dated = vac.dated
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, current_location, Dated, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.current_location, dea.dated, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.current_location Order by dea.current_location, dea.Dated) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.current_location = vac.current_location
	and dea.dated = vac.dated
where dea.continent is not null 
-- order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Current_Location varchar(255),
Dated date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.current_location, dea.dated, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.current_Location Order by dea.current_location, dea.Dated) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.current_location = vac.current_location
	and dea.dated= vac.dated
--where dea.continent is not null 
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVacc as
Select dea.continent, dea.current_location, dea.dated, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.current_Location Order by dea.current_location, dea.Dated) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.current_location = vac.current_location
	and dea.dated = vac.dated
where dea.continent is not null 





