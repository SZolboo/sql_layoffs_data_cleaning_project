CREATE TABLE job_layoffs_staging 
LIKE job_layoffs;

INSERT INTO job_layoffs_staging (
    SELECT *
    FROM job_layoffs
);

SELECT * FROM job_layoffs_staging;

/* REMOVING DUPLICATES */

-- Duplicates are identified based on several columns and rows with NULL values for specific columns are also removed.
WITH duplicate_cte AS (
    SELECT company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        date,
        stage,
        country,
        funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            date,
            stage,
            country,
            funds_raised_millions
        ) AS row_num
    FROM job_layoffs_staging
)

DELETE FROM job_layoffs_staging
WHERE (
        company,
        location,
        industry,
        date,
        stage,
        country,
        funds_raised_millions
    ) IN (
        SELECT company,
            location,
            industry,
            date,
            stage,
            country,
            funds_raised_millions
        FROM duplicate_cte
        WHERE row_num > 1
    )
    AND (
        total_laid_off IS NULL
        OR percentage_laid_off IS NULL
    );

-- Duplicates are identified based on several columns, and the query only displays them without performing any deletions.
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 2351 outputs
SELECT COUNT(*)
FROM job_layoffs_staging;

-- 2361 outputs
SELECT COUNT(*)
FROM job_layoffs;

/* STANDARDIZING DATA */

-- Removing the extra spaces from the company column.
SELECT 
    company, 
    TRIM(company)
FROM job_layoffs_staging;

UPDATE job_layoffs_staging
SET company = TRIM(company);

-- Standardizing the the column values.
SELECT 
    DISTINCT industry
FROM job_layoffs_staging
ORDER BY industry;

SELECT * 
FROM job_layoffs_staging
WHERE industry LIKE 'Crypto%';

UPDATE job_layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT 
    DISTINCT country
FROM job_layoffs_staging
ORDER BY country;

SELECT 
    DISTINCT country,
    TRIM(TRAILING '.' FROM country)
FROM job_layoffs_staging
ORDER BY country;

UPDATE job_layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT TO_DATE(date, 'MM-DD-YYYY') AS converted_date
FROM job_layoffs_staging;

UPDATE job_layoffs_staging
SET date = TO_DATE(date, 'MM-DD-YYYY')

ALTER TABLE job_layoffs_staging
ALTER COLUMN date TYPE DATE USING date::DATE;

SELECT *
FROM job_layoffs_staging
WHERE industry IS NULL OR industry = '';

    -- Self join ** Filling the empty industry
SELECT *
FROM job_layoffs_staging AS t1
INNER JOIN job_layoffs_staging AS t2
    ON t1.company = t2.company AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL

UPDATE job_layoffs_staging
SET industry = NULL
WHERE industry = '';

UPDATE job_layoffs_staging AS t1
SET industry = t2.industry
FROM (
        SELECT company,industry
        FROM job_layoffs_staging
        WHERE industry IS NOT NULL
    ) AS t2
WHERE t1.company = t2.company AND t1.industry IS NULL;

-- Both  percentage_laid_off & total_laid_off are NULL
-- Can't perform calculations; Hence, they are deleted. 
DELETE
FROM job_layoffs_staging
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL;