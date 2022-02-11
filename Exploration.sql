
Select * 
From PortfolioProject..CovidDeaths
order by 3,4


Select * 
From PortfolioProject..CovidVaccinations
order by 3,4 

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population

Select location, date, total_cases, population,(total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'India'
where continent is not null
group by location, population
order by 4 desc


-- Showing Countries with Highest Death Count per population

Select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount 
--MAX((total_deaths/population))*100 as PercentagePopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like 'India'
group by location
order by 2 desc


-- Segregating data by continent

Select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount 
--MAX((total_deaths/population))*100 as PercentagePopulationDied
From PortfolioProject..CovidDeaths
Where continent is null
--Where location like 'India'
group by location
order by 2 desc

Select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount 
--MAX((total_deaths/population))*100 as PercentagePopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like 'India'
group by continent
order by 2 desc




--Showing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount 
--MAX((total_deaths/population))*100 as PercentagePopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like 'India'
group by continent
order by 2 desc



-- GLOBAL NUMBERS

Select 
	   SUM(new_cases) as Total_cases, 
	   SUM(CAST(new_deaths as INT)) as Total_deaths, 
	   SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'India'
where continent is not null
--group by date
order by 1,2



-- Looking at Total Population vs Vaccinations


--- Part 1 -> Using window function to show rolling sum of people who are vaccinated, segregated by location and date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) OVER (
		Partition by dea.location
		order by dea.location, dea.date
	) as RollingSumofPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date 	 
where dea.continent is not null
order by 2,3

--- Part 2 -> Using CTE for "total vaccination / Population"
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingSumofPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(bigint, vac.new_vaccinations)) OVER (
			Partition by dea.location
			order by dea.location, dea.date
		) as RollingSumofPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location and dea.date = vac.date 	 
	where dea.continent is not null
--	order by 2,3
)
Select Continent, Location, Date, Population, New_Vaccinations, RollingSumofPeopleVaccinated
,(RollingSumofPeopleVaccinated/Population)*100 as TheRatio
From PopvsVac;




-- Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as  
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(bigint, vac.new_vaccinations)) OVER (
			Partition by dea.location
			order by dea.location, dea.date
		) as RollingSumofPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location and dea.date = vac.date 	 
	where dea.continent is not null
	--order by 2,3