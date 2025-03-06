2. Standardizing the Data
a) Removing Unwanted Whitespace
Whitespace in the company column was removed to ensure data consistency.

sql
Copy
Edit
-- Remove unwanted whitespace from company column
SELECT company, TRIM(company)
FROM layoffs_dup2;

-- Update the company column to remove unwanted whitespace
UPDATE layoffs_dup2
SET company = TRIM(company);
