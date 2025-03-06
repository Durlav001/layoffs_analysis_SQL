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

# Layoffs Data Analysis with SQL

## Overview
This project aims to analyze global layoffs data to identify patterns, trends, and insights into workforce reductions across various industries and countries. Using SQL, I performed data cleaning and Exploratory Data Analysis (EDA) to generate valuable insights on layoffs over time, with a focus on industries, companies, and countries. The project leverages advanced SQL techniques such as Common Table Expressions (CTEs), window functions, and aggregation to explore the data and generate meaningful visualizations for deeper understanding.

## Dataset
The analysis uses a dataset with the following key fields:
- **Company** – Name of the company
- **Industry** – Sector of operation
- **Location** – City and country of company headquarters
- **Total Laid Off** – Number of employees laid off
- **Percentage Laid Off** – Proportion of the company's workforce affected
- **Date** – Date when the layoffs occurred
- **Stage** – Growth stage of the company (e.g., startup, mature)
- **Country** – Country of operation
- **Funds Raised (in millions)** – Total funds raised by the company

## SQL Techniques

### 1. Data Cleaning

#### a) Finding and Dealing with Duplicates
To ensure that there are no duplicate rows, I used a Common Table Expression (CTE) to assign row numbers based on a partition of the key columns. This way, duplicates could be identified and removed.

```sql
WITH cte_dup AS (
    SELECT *,
    row_number() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_dup
)
SELECT * FROM cte_dup
WHERE row_num > 1;

### b) Removing Duplicates
After identifying the duplicates, I created a new table (layoffs_dup2) with a row_num column and inserted the cleaned data. Duplicates (rows with row_num > 1) were then deleted.
```sql
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

INSERT INTO layoffs_dup2
SELECT *,
row_number() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_dup;

DELETE
FROM layoffs_dup2
WHERE row_num > 1;

### c) Standardizing Text Fields
For consistency, I removed unwanted whitespaces in the company column and standardized certain industry names (e.g., Crypto).
``sql
-- Removing unwanted whitespace from the company column
SELECT company, TRIM(company)
FROM layoffs_dup2;

-- Updating the company column by removing unwanted whitespace
UPDATE layoffs_dup2
SET company = TRIM(company);

``sql
-- Standardizing the industry column for 'Crypto'
UPDATE layoffs_dup2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

### d) Standardizing the country Column
Inconsistencies in the country column, such as trailing periods, were corrected.
``sql
-- Removing periods from the country name
UPDATE layoffs_dup2
SET country = TRIM(TRAILING '.' FROM country);

## e) Converting the date Column Data Type
The date column, which was initially in text format, was converted to the proper date format.
``sql
-- Converting the `date` column from text to date format
UPDATE layoffs_dup2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Altering the table with the new date data type
ALTER TABLE layoffs_dup2
CHANGE `date` `date` DATE;
## f) Handling Null Values
Null values in the industry column were replaced with relevant data where applicable, and records with both total_laid_off and percentage_laid_off being null were removed.
``sql
-- Updating null values in the industry column
UPDATE layoffs_dup2
SET industry = NULL
WHERE industry = '';

-- Removing rows where both total_laid_off and percentage_laid_off are null
DELETE
FROM layoffs_dup2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

## g) Updating Missing Location Information
When the industry column was missing for a company but could be inferred from another record with the same company and location, I updated the missing values.
``sql
-- Updating missing industry values based on available data
UPDATE layoffs_dup2 t1
JOIN layoffs_dup2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

### h) Dropping the Temporary row_num Column
After handling duplicates and cleaning the data, I dropped the row_num column that was used to track duplicates.
```sql
-- Dropping the row_num column
ALTER TABLE layoffs_dup2
DROP COLUMN row_num;


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

## Tools Used
- **SQL (PostgreSQL / MySQL / SQL Server)**
- **Tableau** (for potential visualization integration)
- **Kaggle** (Data source)

## Contact
If you have any questions or suggestions, feel free to connect with me on **GitHub** or **LinkedIn**.

---
This project is part of my data analysis portfolio, showcasing my SQL expertise in handling real-world datasets.

