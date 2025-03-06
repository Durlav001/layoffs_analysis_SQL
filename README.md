
# Layoffs Analysis using SQL

## Overview

This project explores global layoffs data using SQL, focusing on data cleaning and exploratory data analysis (EDA). By leveraging **Common Table Expressions (CTEs)** and **window functions**, I analyzed trends in layoffs across industries, companies, and countries. The insights derived can help understand patterns in workforce reductions over time.

## Dataset

The analysis is based on a layoffs dataset containing the following fields:

- **Company** – Name of the company
- **Industry** – Sector in which the company operates
- **Location** – City and country of the company’s headquarters
- **Total Laid Off** – Number of employees affected
- **Percentage Laid Off** – Proportion of workforce reduced
- **Date** – Date of layoffs
- **Stage** – Growth stage of the company
- **Country** – Country of operation
- **Funds Raised (in millions)** – Total funds raised by the company

## SQL Techniques Used

### Data Cleaning:

- Removed duplicates and null values to ensure data integrity.
- Standardized text formats for consistency (e.g., industry names, locations).
- Used **CTEs** to simplify complex queries and improve readability.

#### a) Removing Duplicates
The first step is to identify and remove any duplicate rows to ensure that the dataset is clean and consistent. Since the dataset doesn't have a unique identifier, I used a `CTE` with the `ROW_NUMBER()` window function to flag and remove duplicates.

```sql
-- Creating a duplicate table to preserve the original data
CREATE TABLE layoffs_dup
SELECT * FROM layoffs;

-- Inserting the original data into the duplicate table
INSERT INTO layoffs_dup
SELECT * FROM layoffs;

-- Finding duplicate rows using the ROW_NUMBER() function
WITH cte_dup AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_dup
)
SELECT * FROM cte_dup
WHERE row_num > 1;

-- Creating a new table to store row numbers
CREATE TABLE `layoffs_dup2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
);

-- Inserting row numbers into the new table
INSERT INTO layoffs_dup2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_dup;

-- Deleting rows with row_num greater than 1 (duplicates)
DELETE FROM layoffs_dup2
WHERE row_num > 1;
### Exploratory Data Analysis (EDA):

1. **Understanding Layoff Severity:**

   - Identified the maximum and minimum percentage of layoffs to assess the severity.

   ```sql
   SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
   FROM layoffs_dup2;
   ```

2. **Top 5 Industries with the Highest Layoffs:**

   - Summarized total layoffs by industry and identified the most affected sectors.

   ```sql
   SELECT industry, SUM(total_laid_off)
   FROM layoffs_dup2
   GROUP BY industry
   ORDER BY MAX(total_laid_off) DESC
   LIMIT 5;
   ```

3. **Companies That Shut Down:**

   - Queried companies with a 100% layoff rate, indicating complete shutdowns.

   ```sql
   SELECT company
   FROM layoffs_dup2
   WHERE percentage_laid_off = 1;
   ```

4. **Most Affected Locations:**

   - Aggregated total layoffs by country to highlight the most impacted regions.

   ```sql
   SELECT country, SUM(total_laid_off)
   FROM layoffs_dup2
   GROUP BY country
   ORDER BY MAX(total_laid_off) DESC;
   ```

5. **Layoffs in the Food Industry:**

   - Analyzed which country experienced the most food industry layoffs.

   ```sql
   SELECT industry, country, SUM(total_laid_off)
   FROM layoffs_dup2
   GROUP BY industry, country
   HAVING industry = 'Food'
   ORDER BY SUM(total_laid_off) DESC;
   ```

6. **Peak Year for Food Industry Layoffs:**

   - Identified the year with the highest percentage of food industry layoffs.

   ```sql
   SELECT YEAR(`date`) AS layoff_year, SUM(percentage_laid_off) AS Yearly_Percentage
   FROM layoffs_dup2
   WHERE industry = 'Food'
   GROUP BY layoff_year
   ORDER BY Yearly_Percentage DESC
   LIMIT 1;
   ```

7. **Rolling Total of Layoffs per Month:**

   - Used window functions to compute a rolling total of layoffs for each month.

   ```sql
   WITH rolling_cte AS (
       SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,
       SUM(total_laid_off) OVER(
           PARTITION BY SUBSTRING(`date`, 1, 7)
       ) AS total_off
       FROM layoffs_dup2
       WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
   )
   SELECT `MONTH`, MAX(total_off)
   FROM rolling_cte
   GROUP BY `MONTH`
   ORDER BY `MONTH` ASC;
   ```

8. **Company Layoffs per Year:**

   - Tracked yearly layoffs per company using window functions.

   ```sql
   WITH company_layoff AS (
       SELECT company, YEAR(`date`) AS `YEAR`,
       SUM(total_laid_off) OVER(
           PARTITION BY company, YEAR(`date`)
       ) AS company_total
       FROM layoffs_dup2
   )
   SELECT company, `YEAR`, company_total
   FROM company_layoff
   GROUP BY 1, 2, 3
   ORDER BY `YEAR` ASC;
   ```

## Key Insights

- **Tech and finance sectors** experienced the highest layoffs.
- **Startups and late-stage companies** were more prone to workforce reductions.
- Layoff trends correlate with **funding downturns** and global economic shifts.
- **Certain countries and industries** faced a disproportionate impact.

## Future Enhancements

- **Connect SQL database to Tableau** for interactive visualizations.
- Automate data updates for real-time tracking.
- Expand analysis to include external economic indicators.

## How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/sql-layoffs-analysis.git
   ```
2. Open the SQL script in your preferred SQL environment.
3. Run queries in sequence to clean and analyze the data.

## Tool Used

- **SQL  (SQL Server)**
- 

## Contact

If you have any questions or suggestions, feel free to connect with me on **GitHub** or **LinkedIn**.

---

This project is part of my data analysis portfolio, showcasing my SQL expertise in handling real-world datasets.

