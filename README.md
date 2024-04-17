# Introduction
In the wake of the COVID-19 pandemic and its economic repercussions, the technology sector has faced significant challenges, leading to widespread job layoffs. 

To shed light on this unfolding phenomenon and facilitate deeper analysis, the Layoffs Dataset has been compiled, spanning from the onset of the pandemic to the present day. This dataset aims to provide a comprehensive resource for researchers and analysts within the tech industry, enabling them to explore and extract valuable insights from the recent turmoil experienced by technology companies worldwide.

SQL Queries 🔎 Please check them out here: [sql_queries](/data_cleaning.sql)

You can access the dataset on Kaggle [dataset](<https://www.kaggle.com/datasets/swaptr/layoffs-2022>).

# Background
Tech firms globally are grappling with the repercussions of economic downturns precipitated by factors such as: 

- Sluggish consumer spending, 
- Heightened interest rates imposed by central banks, and 
- The strengthening of currencies abroad. 

These indicators hint at the looming specter of recession, prompting tech companies to implement significant workforce reductions. 

Notably, Meta's recent decision to terminate 13% of its employees, totaling over 11,000 individuals, underscores the severity of the situation. In response to these ongoing challenges, this dataset has been curated with the objective of empowering the Kaggle community and other stakeholders to delve into the analysis of recent tech industry upheavals and unearth actionable insights.

# Tools I used
I harnassed the power of several key tools:
- SQL
- PostgreSQL
- Visual Studio Code 
- Git & GitHub

# Data Cleaning
The initial phase of data cleaning involved several key steps to ensure the integrity and consistency of the Layoffs Dataset. 

- Duplicates removed based on multiple columns.
- NULL values in specific columns eliminated.
- Data standardized for consistency.
- Date formats converted for uniformity.
- Missing data addressed for completeness.

### Removing Duplicate Entries
This SQL query identifies and removes duplicate entries in the Layoffs Dataset based on several columns. It also eliminates rows with NULL values for specific columns to ensure data integrity.

```sql
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

```

### Standardizing Data
This SQL query standardizes the data in the Layoffs Dataset by removing extra spaces from the company column and standardizing column values such as industry and country.

```sql
-- Removing the extra spaces from the company column.
UPDATE job_layoffs_staging
SET company = TRIM(company);

-- Standardizing the column values for industry.
UPDATE job_layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardizing the column values for country.
UPDATE job_layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```

### Standardizing Date Formats
This SQL query standardizes the date format in the Layoffs Dataset to ensure consistency and compatibility for further analysis.

```sql
UPDATE job_layoffs_staging
SET date = TO_DATE(date, 'MM-DD-YYYY');

ALTER TABLE job_layoffs_staging
ALTER COLUMN date TYPE DATE USING date::DATE;
```

### Filling Empty Industry Values
This SQL query fills in empty industry values in the Layoffs Dataset by leveraging data from other entries with matching company and location.

```sql
UPDATE job_layoffs_staging AS t1
SET industry = t2.industry
FROM (
        SELECT company, industry
        FROM job_layoffs_staging
        WHERE industry IS NOT NULL
    ) AS t2
WHERE t1.company = t2.company AND t1.industry IS NULL;
```

# Conclusion
This SQL data cleaning project has been instrumental in refining the Layoffs Dataset, paving the way for insightful exploratory data analysis (EDA) and further in-depth analysis. By removing duplicate entries, standardizing data, and addressing inconsistencies, the dataset has been primed for comprehensive examination.

As I move forward, the next phase will involve delving into EDA to uncover patterns, trends, and correlations within the dataset. Through EDA, I aim to extract valuable insights that shed light on the dynamics of tech layoffs, industry trends, and potential factors influencing workforce reductions.

Stay tuned for upcoming analyses, where I will dive deeper into the Layoffs Dataset to extract actionable insights and facilitate a deeper understanding of the recent turmoil in the tech industry.

Thanks.