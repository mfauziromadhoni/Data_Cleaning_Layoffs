# 🧹 SQL Data Cleaning Project — `layoffs` Table

## 📌 Overview
This project focuses on cleaning and preparing the `layoffs` dataset for further analysis.  
The process involves:
1. **Removing duplicate records** to avoid skewed results.
2. **Standardizing data** to ensure consistency in formats and values.
3. **Dropping unnecessary columns** to optimize the dataset.

The goal is to ensure that the dataset is accurate, consistent, and ready for analysis.

---

## 1️⃣ Remove Duplicates

Duplicate rows can distort analysis and lead to misleading insights.  
We identified duplicates using a `ROW_NUMBER()` window function, partitioned by key identifying columns, and kept only the first occurrence.

**SQL Query:**
```sql
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, date
               ORDER BY company
           ) AS row_num
    FROM layoffs
)
DELETE FROM layoffs
WHERE ctid IN (
    SELECT ctid
    FROM duplicate_cte
    WHERE row_num > 1
);
```

## 2️⃣ Standardize Data

Standardization ensures consistency across the dataset, which is critical for accurate querying and aggregation.  
We performed the following actions:

- Trimmed whitespace from string columns.
- Converted text values to consistent casing (e.g., title case for company names).
- Standardized date format by converting text to `DATE` type, making it easier to filter or group by time.

## 3️⃣ Remove Unnecessary Columns

Columns that do not add analytical value or are redundant are removed to keep the dataset clean and efficient.

