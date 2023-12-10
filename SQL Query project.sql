Q)ALL data of coviddeaths
select * from portfolioprojects..coviddeaths
order by 2,3


Q)ALL data of covidvaccination
select * from portfolioprojects..covidvaccination
order by 3,4



Q)Data of coviddeaths
select location,date,total_cases,new_cases,total_deaths,population_density
from portfolioprojects..coviddeaths
order by 1,2
  

Q)looking at total cases VS total deaths,ie shows likelihood of percentage of ppl dyiyng in united states country
select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 
as DeathPercentage
from portfolioprojects..coviddeaths
where location like '%states%'
order by 1,2

Q)percentage of population affectes by covid
select location,date,total_cases,total_deaths,population_density,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population_density), 0))*100 as populationpercentageinfected
from portfolioprojects..coviddeaths
where location like '%states%'
order by 1,2

Q)looking at countries with highest infection rate as compared to population in USA
select location,max(total_cases),population_density,
max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population_density), 0)))*100 as populationpercentageinfected
from portfolioprojects..coviddeaths
where location like '%states%'
group by location,population_density
order by 3,4

Q)countries showing highest deathcount as compared to population in USA
select location,max(cast(total_deaths as int )) as highestdeath_rate
from portfolioprojects..coviddeaths
where location like '%states%' and continent is not null
group by location
order by highestdeath_rate desc

--lets break down as continent
select continent,max(cast(total_deaths as int )) as highestdeath_rate
from portfolioprojects..coviddeaths
where continent is not null
group by continent
order by highestdeath_rate  desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioprojects..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Q)looking at total population vs total vaccination
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
from portfolioprojects..coviddeaths dea
join portfolioprojects..covidvaccination vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3
Q)Total Population vs Vaccination 
Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


Q)Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


Q)Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Q)Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated



