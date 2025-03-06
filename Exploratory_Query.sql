select * from 
layoffs_dup2;
select distinct industry from layoffs_dup2;

-- 1. looking at the percentage to see how big these layoffs were

select max(percentage_laid_off) , min(percentage_laid_off)
from layoffs_dup2;

-- 2.Which 5 industries had the highest layoffs?
select industry , sum(total_laid_off)
from layoffs_dup2
group by industry
order by max(total_laid_off) desc
limit 5;

-- 3.which company had 1 (100%) laid off..basically shut down?

select company
from layoffs_dup2
where percentage_laid_off=1;


-- 4.Which locations (cities/countries) were most affected by layoffs?

select country , sum(total_laid_off)
from layoffs_dup2
group by  country
order by  max(total_laid_off) desc;

--  5.In which country food industry experienced more layoffs?
select industry, country, sum(total_laid_off)
from layoffs_dup2
group by industry, country
having industry='Food'
order by sum(total_laid_off) desc;


-- 6.What is the peak year for food laid off?
select (Year(`date`)) as layoff_year, sum(percentage_laid_off) as Yealry_Percentage
from layoffs_dup2
where industry='Food'
group by layoff_year
order by Yealry_Percentage desc
limit 1;

-- 7. Rolling total laid off per every month
with rolling_cte as(
select substring(`date`,1,7) as `MONTH`,
sum(total_laid_off) over(
 partition by substring(`date`,1,7)
) as total_off
from layoffs_dup2
where substring(`date`,1,7) is not null
)
select `MONTH`, max(total_off)
from rolling_cte
group by `MONTH`
order by `MONTH` asc;


-- 8. company laying off per year

with company_layoff as(
select company,year(`date`) as `YEAR`, 
sum(total_laid_off) over(
partition by  company, year(`date`)	
) as company_total
from layoffs_dup2)


select company, `YEAR`, company_total
from company_layoff
group by 1,2,3
order by `YEAR` asc

















