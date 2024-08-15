-- Data Cleaning 

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns or Rows

-- Duplicating Table (to keep the raw data available)
CREATE TABLE layoffs_staging
LIKE layoffs
;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, fund_raised_millions) AS row_num
 FROM layoffs_staging;

-- Creating CTE
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Checking the duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create layoffs_staging2 (I called 3 instead of 2) to eliminate duplicates.

-- Right clicked the table layoffs_staging -> Copy to CLipboard -> Create Statement (to copy the columns).
CREATE TABLE `layoffs_staging3` (
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

SELECT *
FROM layoffs_staging3
WHERE row_num > 1;

INSERT INTO layoffs_staging3
SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging;

-- Used this to make the DELETE function work
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging3
WHERE row_num > 1;

-- Checking if there was any duplicate left. There wasn't (it worked)
SELECT *
FROM layoffs_staging3
WHERE row_num > 1;

-- 2. Standardizing Data

-- Using TRIM to take off the white space of the ends
SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company = TRIM(company);

-- Fixing names in the industry column
SELECT DISTINCT industry
FROM layoffs_staging3
ORDER BY 1;

SELECT *
FROM layoffs_staging3
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Same thing but with the column: Country
SELECT DISTINCT country
FROM layoffs_staging3
ORDER BY 1;

-- Taking the "." out of the name. Making "United States." become "United States"
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging3
ORDER BY 1;

UPDATE layoffs_staging3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Fixing the date: From string to date
SELECT `date`
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- Modifying in the table from string to date
ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

-- Null and Blank Values

SELECT *
FROM layoffs_staging3
WHERE company = 'Airbnb';

-- Changing the blank values to NULL
UPDATE layoffs_staging3
SET industry = NULL 
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL 
OR industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Deleting data that has no value for total_laid_off and percentage_laid_off
SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging3;

-- Getting rid of the column I created (row_num)
ALTER TABLE layoffs_staging3
DROP COLUMN row_num;



