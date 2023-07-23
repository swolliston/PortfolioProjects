Select * from Portfolio..[CovidDeaths project]

--Showing continents with highest death count per population

Select continent,MAX(cast(Total_deaths as int)) as TotalDealthCount
From Portfolio..[CovidDeaths project]
where continent is not null
Group by continent
order by TotalDealthCount desc

--Global Numbers per day

Select date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 as DeathPercentage  
From Portfolio..[CovidDeaths project]
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Global Number Death Percentage

Select SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 as DeathPercentage  
From Portfolio..[CovidDeaths project]
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--or
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.Location)
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--continued using Convert

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..[CovidDeaths project] dea
Join Portfolio..[CovidVaccinations project] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--created view

Select *
From PercentPopulationVaccinated
