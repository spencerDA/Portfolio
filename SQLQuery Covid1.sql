			-- Data taken as of 4/22/2022

-- Preliminary viewing

Select *
From Covid..Covid_deaths
Where continent is not null
order by 3,4

--Select *
--From Covid..Covid_vaccinations
--order by 3,4


-- Select Data to be used
--Select location, date, total_cases, new_cases, total_deaths, population
--From Covid..Covid_deaths
--order by 1,2

-- Total Cases vs Total Deaths

Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases) deathspercase
From Covid..Covid_deaths
Where location = 'United States'
order by 1,2


-- Countries with highest infection rate
Select location, max(total_cases)/max(population) infec_rate
From Covid..Covid_deaths
group by location
order by infec_rate desc



-- Countries with highest death rate
Select location, max(cast(total_deaths as int))/max(population) death_rate, max(cast(total_deaths as int)) total_death
From Covid..Covid_deaths
where continent is not null
group by location
order by death_rate desc

-- Continents with highest death rate
Select continent, location
from Covid..Covid_deaths
--where location = 'canada'
group by location, continent
order by continent, location

 
Select continent, max(cast(total_deaths as int))/max(population) death_rate, max(cast(total_deaths as int)) total_death
Into #continent_death
From Covid..Covid_deaths
where continent is not null
group by continent 
order by death_rate desc 



Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From Covid..Covid_deaths
Where continent is null
Group by location
order by TotalDeathCount desc



	-- Global Numbers
Select date, total_cases, total_deaths
From Covid..Covid_deaths
where continent is not null




	-- Join tables together
Select de.continent, de.location, de.date, de.population, va.new_vaccinations, Sum(convert(int, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rollingvaccs
From Covid_deaths de
Join Covid_vaccinations va
	On de.location = va.location
	AND de.date = va.date
where de.continent is not null
order by 2,3



-- With CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rollingpeopvacc)
as
(Select de.continent, de.location, de.date, de.population, va.new_vaccinations, Sum(convert(bigint, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rollingvaccs
From Covid..Covid_deaths de
Join Covid..Covid_vaccinations va
	On de.location = va.location
	AND de.date = va.date
where de.continent is not null
--order by 2,3
)
Select *, (Rollingpeopvacc/Population)*100 as vacbyPop
From PopvsVac

-- With Temp Table
Drop Table if exists #PercentPopVacc
Create Table #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeopvacc numeric
)

Insert into #PercentPopVacc
Select de.continent, de.location, de.date, de.population, va.new_vaccinations, Sum(convert(bigint, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rollingvaccs
From Covid..Covid_deaths de
Join Covid..Covid_vaccinations va
	On de.location = va.location
	AND de.date = va.date
where de.continent is not null
--order by 2,3


Select *, (Rollingpeopvacc/population) as proporPopVacc
from #PercentPopVacc




-- Creating View for data visualizations

Create View PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations, Sum(convert(bigint, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rollingvaccs
From Covid..Covid_deaths de
Join Covid..Covid_vaccinations va
	On de.location = va.location
	AND de.date = va.date
where de.continent is not null


Select *
From PercentPopulationVaccinated






















