CREATE DATABASE transactions_info;
CREATE TABLE Id
(Id_check INT,
ID_client INT,
Count_products INT,
Sum_payment DECIMAL(10,2),
date_new date
);
DROP TABLE Id;

CREATE TABLE Id
(Id_check INT,
ID_client INT,
Count_products INT,
Sum_payment DECIMAL(10,2),
date_new date
);

CREATE DATABASE customer_info;
CREATE TABLE Id
(Id_client INT,
Total_amount INT,
Gender varchar(5),
Age	INT,
Count_city INT,	
Response_communcation INT,
Communication_3month INT,	
Tenure INT);

SELECT 
    t.ID_client
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client
HAVING COUNT(DISTINCT CONCAT(YEAR(t.date_new), '-', MONTH(t.date_new))) = 12;

SELECT 
    t.ID_client,
    SUM(t.Sum_payment) / COUNT(t.Id_check) AS average_check,  
    SUM(t.Sum_payment) / 12 AS average_monthly_sales,         
    COUNT(t.Id_check) AS total_operations                    
FROM id t
WHERE t.ID_client IN (
    SELECT t.ID_client
    FROM id t
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY t.ID_client
    HAVING COUNT(DISTINCT CONCAT(YEAR(t.date_new), '-', MONTH(t.date_new))) = 12
)
AND t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client;

#средняя сумма чека в месяц
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    SUM(t.Sum_payment) / COUNT(t.Id_check) AS average_check  
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new)
ORDER BY year, month;

#среднее количество операций в месяц;
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    COUNT(t.Id_check) AS average_operations  
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new)
ORDER BY year, month;


#среднее количество клиентов, которые совершали операции
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    COUNT(DISTINCT t.ID_client) AS average_clients
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new)
ORDER BY year, month;

#доля от общего количества операций за год в разрезе месяцев
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    COUNT(t.Id_check) AS monthly_operations,  
    (COUNT(t.Id_check) / (SELECT COUNT(Id_check) FROM id WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS operations_share
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new)
ORDER BY year, month;

#доля от общей суммы операций за год в разрезе месяцев
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    SUM(t.Sum_payment) AS monthly_sum, 
    (SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM id WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS sum_share
FROM id t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new)
ORDER BY year, month;

#% соотношение M/F/NA в каждом месяце с их долей затрат
#количество клиентов по каждому полу за месяц
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    c.Gender, 
    COUNT(t.Id_client) AS total_clients   
FROM transactions_info.id t
JOIN customer_info.id c ON t.Id_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new), c.Gender;

#общая сумму затрат по каждому полу за месяц
SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    c.Gender, 
    SUM(t.Sum_payment) AS total_spending    
FROM transactions_info.id t
JOIN customer_info.id c ON t.Id_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new), c.Gender;

SELECT 
    YEAR(t.date_new) AS year, 
    MONTH(t.date_new) AS month, 
    c.Gender, 
    COUNT(t.Id_client) AS total_clients,  
    ROUND((COUNT(t.Id_client) / SUM(COUNT(t.Id_client)) OVER (PARTITION BY YEAR(t.date_new), MONTH(t.date_new))) * 100, 2) AS percentage_clients,   
    SUM(t.Sum_payment) AS total_spending, 
    ROUND((SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY YEAR(t.date_new), MONTH(t.date_new))) * 100, 2) AS percentage_spending   
FROM transactions_info.id t
JOIN customer_info.id c ON t.Id_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(t.date_new), MONTH(t.date_new), c.Gender
ORDER BY year, month, c.Gender;


#возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций за весь период, и поквартально - средние показатели и %.
SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'No Age Info'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    SUM(t.Sum_payment) AS total_sum,         
    COUNT(t.Id_check) AS total_operations   
FROM transactions_info.id t
JOIN customer_info.id c ON t.Id_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group
ORDER BY age_group;

SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'No Age Info'
        ELSE CONCAT(FLOOR(c.Age / 10) * 10, '-', FLOOR(c.Age / 10) * 10 + 9)
    END AS age_group,
    YEAR(t.date_new) AS year, 
    QUARTER(t.date_new) AS quarter,  
    COUNT(t.Id_check) AS total_operations,  
    SUM(t.Sum_payment) AS total_sum,       
    ROUND(SUM(t.Sum_payment) / COUNT(t.Id_check), 2) AS avg_sum, 
    ROUND((COUNT(t.Id_check) / SUM(COUNT(t.Id_check)) OVER (PARTITION BY YEAR(t.date_new), QUARTER(t.date_new))) * 100, 2) AS percentage_operations 
FROM transactions_info.id t
JOIN customer_info.id c ON t.Id_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group, YEAR(t.date_new), QUARTER(t.date_new)
ORDER BY year, quarter, age_group;





