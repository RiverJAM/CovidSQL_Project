-- insert tables because import wizard will not work for this data on its own

CREATE TABLE IF NOT EXISTS Covid_Vax_1(
 iso_code VARCHAR(50),
 continent VARCHAR(50),
 location VARCHAR(50),
 obs_date DATE,
 total_tests BIGINT NULL,
 new_tests INT NULL,
 total_tests_per_thousand Double NULL,
 new_tests_per_thousand Double NULL,
 new_tests_smoothed FLOAT NULL,
 new_tests_smoothed_per_thousand FLOAT NULL,
 positive_rate FlOAT NULL, 
 tests_per_case FLOAT NULL,
 tests_units VARCHAR(50) NULL,
 total_vaccinations FLOAT NULL,
 people_vaccinated FLOAT NULL,
 people_fully_vaccinated FLOAT,
 total_boosters FLOAT NULL,
 new_vaccinations FLOAT NULL,
 new_vaccinations_smoothed FLOAT NULL,
 total_vaccinations_per_hundred FLOAT NULL,
 people_vaccinated_per_hundred FLOAT NULL,
 people_fully_vaccinated_per_hundred FlOAT NULL,
 total_boosters_per_hundred FLOAT NULL,
 new_vaccinations_smoothed_per_million FLOAT NULL,
 new_people_vaccinated_smoothed FLOAT NULL,
 new_people_vaccinated_smoothed_per_hundred FLOAT NULL,
 stringency_index FLOAT NULL,
 population_density FLOAT NULL,
 median_age FLOAT NULL,
 aged_65_older FLOAT NULL,
 aged_70_older FLOAT NULL,
 gdp_per_capita FLOAT NULL, 
 extreme_poverty FLOAT NULL,
 cardiovasc_death_rate FLOAT NULL,
 diabetes_prevalence FLOAT NULL,
 female_smokers FLOAT NULL,
 male_smokers FLOAT NULL,
 handwashing_facilities FLOAT NULL,
 hospital_beds_per_thousand FLOAT NULL,
 life_expectancy FLOAT NULL,
 human_development_index FLOAT NULL,
 excess_mortality_cumulative_absolute FLOAT NULL,
 excess_mortality_cumulative FLOAT NULL, 
 excess_mortality FLOAT NULL,
 excess_mortality_cumulative_per_million FLOAT NULL
 );
 
-- this was to test INT v BIG INT
-- select max(total_tests) as Maxwell  from Covid_Vax_1;
 
 
CREATE TABLE IF NOT EXISTS Covid_Deaths(
 iso_code VARCHAR(50),
 continent VARCHAR(50),
 location VARCHAR(50),
 obs_date DATE,
 population BIGINT NULL,
 total_cases BIGINT NULL,
 new_cases INT NULL,
 new_cases_smoothed INT NULL,
 total_deaths INT NULL, 
 new_deaths INT NULL,
 new_deaths_smoothed INT NULL,
 total_cases_per_million FLOAT NULL,
 new_cases_per_million FLOAT NULL,
 new_cases_smoothed_per_million FLOAT NULL,
 total_deaths_per_million FlOAT NULL,
 new_deaths_per_million FLOAT NULL,
 new_deaths_smoothed_per_million FLOAT NULL,
 reproduction_rate FLOAT NULL,
 icu_patients INT NULL,
 icu_patients_per_million FLOAT NULL,
 hosp_patients INT NULL,
 hosp_patients_per_million FLOAT NULL,
 weekly_icu_admissions FLOAT NULL,
 weekly_icu_admissions_per_million FLOAT NULL,
 weekly_hosp_admissions FLOAT NULL,
 weekly_hosp_admissions_per_million FLOAT NULL
 );
 
-- Select * From Covid_Deaths
-- Limit 10;
 
 -- SELECT * FROM Covid_Vax_1
 -- LIMIT 10;
 
 -- select Data
 
 SELECT LOCATION, obs_date, total_cases, new_cases, total_deaths, population
 FROM Covid_Deaths
 order by 1, 2;
 
 -- Look at Total Cases vs Total Deaths
-- shows liklihood of dying if you contract covid in your country

SELECT LOCATION, obs_date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM Covid_Deaths
 WHERE location like '%states%'
 order by 1, 2;
 
 -- Total cases vs Population
 SELECT LOCATION, obs_date, total_cases,population, (total_cases/population)*100 as InfectionPercentage
 FROM Covid_Deaths
 WHERE location like '%states%'
 order by 1, 2;
 
 -- which countries have the highest infection rates
  SELECT LOCATION, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRate
 FROM Covid_Deaths
 Group by Location, population
 order by 4 desc;
 
 -- Countries with the highest death count
SELECT LOCATION, Max(total_deaths) as TotalDeathCount
 FROM Covid_Deaths
 where continent is not null
 Group by LOCATION
 ORDER BY TotalDeathCount desc;
 
 -- By Continent death count
 SELECT location, Max(total_deaths) as TotalDeathCount
 FROM Covid_Deaths
 where continent is null
 Group by location
 ORDER BY TotalDeathCount desc;
 
 -- Global numbers
 select sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
 FROM Covid_Deaths
 Where continent is not null
 order by 1, 2;
 
 -- -------------------
 -- Covid Vaccinations table
 select * From Covid_Vax_1 limit 10;
 
 -- Join the tables
 Select * from Covid_deaths dea
 Join Covid_Vax_1 vax
 on dea.location = vax.location
 and dea.obs_date = vax.obs_date;
 
 -- looking at Total Population vs Vaccinations (using CTE)
 
With PopvsVac (continent, location, obs_date, population, new_vaccinations, RollingSumOfPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.obs_date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.obs_date) as RollingSumOfPeopleVaccinated
 FROM Covid_deaths dea
 Join Covid_Vax_1 vax
	on dea.location = vax.location
	and dea.obs_date = vax.obs_date
where dea.continent is not null
)
Select *, (RollingSumOfPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From PopvsVac;
 

 -- TEMP Table
Drop Table if exists PercentPopulationVaccinated;
Create TABLE PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
obs_date DATE,
population int,
new_vaccinations int,
RollingSumOfPeopleVaccinated BIGINT
);
 
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.obs_date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.obs_date) as RollingSumOfPeopleVaccinated
 FROM Covid_deaths dea
 Join Covid_Vax_1 vax
	on dea.location = vax.location
	and dea.obs_date = vax.obs_date
where dea.continent is not null;

Select * , (RollingSumOfPeopleVaccinated/population)*100
From PercentPopulationVaccinated;


-- create a view for late data visualizations

CREATE VIEW PercentPopulationVaccinated_2 as 
SELECT dea.continent, dea.location, dea.obs_date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.obs_date) as RollingSumOfPeopleVaccinated
 FROM Covid_deaths dea
 Join Covid_Vax_1 vax
	on dea.location = vax.location
	and dea.obs_date = vax.obs_date
where dea.continent is not null;

 