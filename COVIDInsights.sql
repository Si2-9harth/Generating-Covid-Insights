SELECT *
FROM CovidInsightsProjet.dbo.CovidVaccinations
ORDER BY 3,4

--SELECT *
--FROM CovidInsightsProjet.dbo.CovidDeaths
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidInsightsProjet.dbo.CovidDeaths
ORDER BY 1,2

--Percentage of Deaths per Diagnosed Cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Percentage of People getting Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Top Infection Rate
SELECT location, population, MAX(total_cases) as HighestPositiveCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM CovidInsightsProjet.dbo.CovidDeaths
GROUP BY location, population
order by PercentagePopulationInfected desc

--Top Death Count 
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
order by HighestDeathCount desc

--Top Death Count by Continent
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
order by HighestDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
order by HighestDeathCount desc

--global figures
SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidInsightsProjet.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- For Covid Vaccinations
SELECT * FROM CovidInsightsProjet.dbo.CovidVaccinations


SELECT * FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date

--Population VS Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations as new_vaccinations_per_day
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3

--Using CTE
WITH PopVsVac(Continent,Location,Date,Population,New_Vaccinations,Total_Vaccinations_Till_Day)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null
)
SELECT *
FROM PopVsVac

--Percentage of Vaccinations on Populations
WITH PopVsVac(Continent,Location,Date,Population,New_Vaccinations,Total_Vaccinations_Till_Day)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null
)
SELECT *, (Total_Vaccinations_Till_Day/Population)*100 as Percentage_of_Vaccinations
FROM PopVsVac

--Using TEMP Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations_Till_Day numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CONVERT(bigint,cv.new_vaccinations))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date

SELECT *, (Total_Vaccinations_Till_Day/Population)*100 as Percentage_of_Vaccinations
FROM #PercentPopulationVaccinated

--View Creations for Visualisations
CREATE View PopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int))
OVER (Partition by cd.location order by cd.location,cd.date) AS count_of_vaccinations_till_day 
FROM CovidInsightsProjet.dbo.CovidDeaths as cd
INNER JOIN CovidInsightsProjet.dbo.CovidVaccinations as cv
ON cd.location=cv.location
and cd.date=cv.date
WHERE cd.continent is not null