WITH DateTable AS (
    SELECT CAST('2020-01-01' AS DATE) AS date_value
    UNION ALL
    SELECT DATEADD(DAY, 1, date_value)
    FROM DateTable
    WHERE date_value < '2030-12-31'
)
INSERT INTO dimDate (date_key, date, year, month, day, weekday, is_weekend)
SELECT 
    CAST(FORMAT(date_value, 'yyyyMMdd') AS INT) AS date_key,
    date_value AS date,
    YEAR(date_value) AS year,
    MONTH(date_value) AS month,
    DAY(date_value) AS day,
    DATENAME(WEEKDAY, date_value) AS weekday,
    CASE WHEN DATENAME(WEEKDAY, date_value) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS is_weekend
FROM DateTable
OPTION (MAXRECURSION 0);
