SELECT * FROM layoffs;

--1. Remove Duplicates
SELECT *
FROM(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY
			company, location, industry, total_laid_off, percentage_laid_off,	date, stage, country, funds_raised_millions
		) AS row_num
	FROM layoffs
) duplicates
WHERE row_num > 1;

--And remove the duplicates:
WITH delete_cte AS(
	SELECT 
		ctid
	FROM(
		SELECT 
			ctid,
			ROW_NUMBER() OVER(PARTITION BY
				company, location, industry, total_laid_off, percentage_laid_off,	date, stage, country, funds_raised_millions
			) AS row_num
		FROM layoffs
	) duplicates
	WHERE row_num > 1
)
DELETE
FROM layoffs
USING delete_cte
WHERE layoffs.ctid = delete_cte.ctid;


--2. Standardize data
--Checking null values in industry column
SELECT * 
FROM layoffs
WHERE 
	industry IS NULL
	OR
	industry = ''
ORDER BY industry;

--Check case if any company have value in industry column
SELECT *
FROM layoffs
WHERE company LIKE '%Bally%';

SELECT *
FROM layoffs
WHERE company LIKE '%airbnb%';

--Transform null values into NULL
UPDATE layoffs
SET industry = NULL
WHERE industry = '';

--Fill NULL with other rows (if any)
UPDATE layoffs t1
SET industry = t2.industry
FROM layoffs t2
WHERE 
	t1.company = t2.company
	AND
	t1.industry IS NULL
	AND
	t2.industry IS NOT NULL;

--Verify is there any NULL in industry column
SELECT * 
FROM layoffs
WHERE 
	industry IS NULL
	OR
	industry = ''
ORDER BY industry;

-----------------------------------------------
--Standardize name category in industry column
SELECT
	DISTINCT industry
FROM layoffs
ORDER BY industry;

--Standardize 'Crypto' in one
UPDATE layoffs
SET industry = 'Crypto'
WHERE 
	industry
	IN
	('Crypto Currency', 'CryptoCurrency');

--Verify
SELECT
	DISTINCT industry
FROM layoffs
ORDER BY industry;

-----------------------------------------------
--Standardize name category in country column
SELECT
	DISTINCT country
FROM layoffs
ORDER BY country;

--Standardize 'United States' in one
UPDATE layoffs
SET country = TRIM(TRAILING '.' FROM country);

--Verify
SELECT
	DISTINCT country
FROM layoffs
ORDER BY country;

-------------------------------------------------
--Transform datatype into date in date column
UPDATE layoffs
SET date = TO_DATE(date, 'MM/DD/YYYY')
WHERE date ~ '^\d{1,2}/\d{1,2}/\d{4}$'; --because there is NULL (string) in date column

--Transform NULL (string) into NULL value 
UPDATE layoffs
SET date = NULL
WHERE date = 'NULL';

--Transform into date dtype
ALTER TABLE layoffs
ALTER COLUMN date TYPE DATE
USING date::date;

--Verify
SELECT
	date
FROM layoffs
LIMIT 5;


--3. Remove any columns we need to
SELECT * 
FROM layoffs
WHERE
	total_laid_off IS NULL
	AND
	percentage_laid_off IS NULL;

--Delete useless data we can't use
DELETE
FROM layoffs
WHERE
	total_laid_off IS NULL
	AND
	percentage_laid_off IS NULL;


-------------------------------------------------

--Finally this is the cleaned data
SELECT * FROM layoffs;


