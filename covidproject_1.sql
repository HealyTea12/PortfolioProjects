-- checking that the data is there
-- select * from covid..coviddeaths;
-- select * from covid..covidvaccines order by location;


-- percent infected, percent killed and percent infected that died.


select location,total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_rate,
population,(total_cases/population)*100 as infection_perc,
(total_deaths/population)*100 as death_perc
from covid..coviddeaths
where location like 'Germ%'
order by location, date;

-- countries with largest infection rate

select location, max(total_cases/population)*100 as infection_perc
from covid..coviddeaths
group by location
order by infection_perc desc;

-- countries with largest death rate

select location, max(total_deaths/population)*100 as death_perc
from covid..coviddeaths
group by location
order by death_perc desc;

-- world

select DATEPART(year, date) as year_, DATEPART(week, date) as week_,
sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_cases as int)) as total_new_cases
from covid..coviddeaths
where continent is not null
group by DATEPART(year, date), DATEPART(week, date)
order by DATEPART(year, date), DATEPART(week, date);


-- joining the two tables 


select d.location, d.continent, d.date, v.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) as rolling_sum_vac
from covid..coviddeaths as d
inner join covid..covidvaccines as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by d.location, d.date;

-- as cCTE

with deathvac (location, continent, population, date, new_vaccinations, rolling_sum_vaccinations) as
(
select d.location, d.continent, d.population, d.date, v.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) as rolling_sum_vac
from covid..coviddeaths as d
inner join covid..covidvaccines as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select location, population, date, rolling_sum_vaccinations,
(rolling_sum_vaccinations/population)*100 as vaccination_perc
from deathvac;

-- turning into a view to export later

CREATE VIEW percvac as
with deathvac (location, continent, population, date, new_vaccinations, rolling_sum_vaccinations) as
(
select d.location, d.continent, d.population, d.date, v.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) as rolling_sum_vac
from covid..coviddeaths as d
inner join covid..covidvaccines as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select location, population, date, rolling_sum_vaccinations,
(rolling_sum_vaccinations/population)*100 as vaccination_perc
from deathvac;

