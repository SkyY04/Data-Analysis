-- Exploratory Data Analysis
select *
from layoffs_staging2;

-- date range for this data
select min(`date`), max(`date`)
from layoffs_staging2;
	-- March 2020 to March 2023

-- what industry laid off the most
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;
	-- Consumer and Retail is the most -> affected by COVID-19
    
-- Which year laid off the most
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;
	-- 2023 is highest BUT it only has 3 months of data -> expect more laid off
    
-- check total laid off of each month
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;
    
-- rolling total laid off
with Rolling_Total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;
	-- how devastating around the world end of 2022 to 2023

-- how many company laying off every year
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;
	-- Big companies like Google, Meta, Amazon has the most number of laid off
    
-- rank companies every year based on total laid off 
with Company_Year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),
Company_Year_Rank as
(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_Year
where years is not null
)
select *
from Company_Year_Rank
where Ranking <= 5;