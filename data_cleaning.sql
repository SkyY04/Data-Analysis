-- Data Cleaning

SELECT *
FROM layoffs;

-- Leave raw data available and make copied one
create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

-- 1. Remove Duplicates
-- 1-1. Identify Duplicates
with duplicate_cte as
(
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;
	-- example
select *
from layoffs_staging
where company='Casper';
-- 1-2. Create a new table for duplicated data.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into layoffs_staging2
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging;
-- 1-3. Select duplicated data
select *
from layoffs_staging2
where row_num>1;
-- 1-4. Delete ONLY duplicated data but leave one
delete
from layoffs_staging2
where row_num>1;


-- 2. Standardize the Data (finding issues in data and fix it)
-- 2-1. Trim company (take the white space off)
update layoffs_staging2
set company=trim(company);
select company, trim(company)
from layoffs_staging2;
-- 2-2. Standardize industry
	-- Ex. Crypto, Crypto Currency, CryptoCurrency => Crypto
select *
from layoffs_staging2
where industry like 'Crypto%';
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';
-- 2-3. Standardize country
	-- Ex. trailing period - United States, United States.
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
where country like 'United States%';
-- 2-4. change time series format (yyyy-mm-dd)
update layoffs_staging2
set `date`=str_to_date(`date`, '%m/%d/%Y');
select `date`
from layoffs_staging2;
-- 2-4. change time series data type (text -> date)
alter table layoffs_staging2
modify column `date` date;


-- 3. Null Values or Blank Values
-- 3-1. Set blank values to null values
update layoffs_staging2
set industry = null
where industry = '';
-- 3-2. check null values on industry
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
where t1.industry is null
and t2.industry is not null;
-- 3-3. Populate null values to existed data
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;
	-- Ex. Airbnb
select *
from layoffs_staging2
where company='Airbnb';


-- 4. Delete data (total_laid_off is null AND percentage_laid_off is null)
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


-- 5. Delete row_num column
alter table layoffs_staging2
drop column row_num;


select *
from layoffs_staging2;

