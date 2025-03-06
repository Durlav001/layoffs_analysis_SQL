
-- SQL cleaning project
-- dataset: 
-- 1 Finding duplicates
-- 2. Standardizing the data
-- 3 dealing with null values
-- 4 deleting unwanted column

select * from layoffs;


-- creating a duplicate table beacasue don't want to use original table in case anything happens
create table layoffs_dup
select * from layoffs;


-- inserting the values from original table
insert into layoffs_dup
select * from layoffs;


# 1. Finding and dealing with duplicates

-- giving row counts to each row so that if any row appear twice , it get 2, 3... and so on
with cte_dup as(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num
from layoffs_dup)

-- checking duplicates row with row_num greater than 1, that means they are duplicates
select * from cte_dup
where row_num > 1;

-- since , this data does not have a unique id so cannot delete duplicates directly , so adding new column into table with row_num 
CREATE TABLE `layoffs_dup2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- inserting row_num values from above CTE with roe_num column
insert into layoffs_dup2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num
from layoffs_dup;

-- now deleting the row with row_num greater than 2 , ( duplicates)
delete
from layoffs_dup2
where row_num > 1;


# 2. Standardizing the data


-- deleting unwanted whitespace from company column
select company, trim(company)
from layoffs_dup2;


-- updating the comapny column by removing unwanted white space
update layoffs_dup2
set company= trim(company);

-- checking if whitespace is removed
select company
 from layoffs_dup2;

-- identifying potential inconsistencies in the industry names by retrieving a distinct list and ordering it alphabetically for easier comparison.
select distinct industry from layoffs_dup2
order by 1;

-- checking for crypto because there are two companies named Crypto Currency and Crypto
SELECT * 
FROM layoffs_dup2
WHERE industry LIKE '%Crypto%';

-- this query helps standardize the industry column by ensuring that any value containing “Crypto” is uniformly labeled as "Crypto."
update layoffs_dup2
set industry='Crypto'
WHERE industry LIKE '%Crypto%';

-- checking if there is anything wrong with the country column like typo or unwanted character 
select distinct country
from layoffs_dup2;

-- removing (.)  that appears at the end of country name (United States.)
select distinct trim(trailing '.' from country)
from layoffs_dup2
order by 1;

-- updating the table with respect to above querey
update layoffs_dup2
set country=trim(trailing '.' from country);

-- changing date data type from text to date
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_dup2;

-- updating the table with above querey
update layoffs_dup2
set `date`=str_to_date(`date`, '%m/%d/%Y');

-- altering the table with new data type
alter table layoffs_dup2
CHANGE `date` `date` DATE;

-- changing value to NULL if there are blanks in the table
update layoffs_dup2
set industry=NULL
where industry='';



-- if there are blank values in the location for the same company in the same location then updating the blank values with the location
select *
from layoffs_dup2 t1
join layoffs_dup2 t2
on t1.company=t2.company
and t1.location=t2.location
where t1.industry is null 
and t2.industry is not null;



-- updating the table with the above querey
update layoffs_dup2 t1
join layoffs_dup2 t2
	on t1.company=t2.company
    and t1.location=t2.location
    set t1.industry=t2.industry
    where t1.industry is null 
and t2.industry is not null;

-- checking for Airbnb location with the updated location
select * from layoffs_dup2
where company ='Airbnb';

-- if total laid off and percentage laid off column is null then i don't need that for my analysis
select * from 
layoffs_dup2
where total_laid_off is null and percentage_laid_off is null;

-- deleting the null total laid off and percentage laid off column
delete
from layoffs_dup2
where  total_laid_off is null and percentage_laid_off is null;

-- finally dropping the row_num column that i used to delete duplicate values
alter table layoffs_dup2
drop column row_num;

select * from 
layoffs_dup2











