/*Churn rate by month*/

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
), 
cross_join AS 
  (SELECT * FROM subscriptions
   CROSS JOIN months),
status AS
  (SELECT id, first_day AS month, 
    CASE
      WHEN (subscription_start < first_day) 
        AND (
        subscription_end > first_day
        OR subscription_end IS NULL
        ) THEN 1
      ELSE 0
    END as is_active,
    CASE
      WHEN (subscription_end 
        BETWEEN first_day and last_day) 
        THEN 1
      ELSE 0
    END AS is_canceled 
   FROM cross_join) ,
status_aggregate AS 
  (SELECT month, 
   SUM(is_active) AS sum_active,
   SUM(is_canceled) AS sum_canceled
   from status
   GROUP BY month)
SELECT month, 
   round((1.0*sum_canceled/sum_active),2) AS churn_rate,
   sum_active AS active, 
   sum_canceled AS canceled
from status_aggregate;


/*Churn rates by segments*/

WITH months AS
  (SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
  SELECT
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
  SELECT
    '2017-03-01' as first_day,
    '2017-03-31' as last_day
  ),

cross_join AS
  (SELECT *
  FROM subscriptions
  CROSS JOIN months),

status AS
  (SELECT id, first_day as month,
    CASE
      WHEN (subscription_start < first_day)
        AND (subscription_end > first_day
        OR subscription_end IS NULL)
        AND segment=87 THEN 1
      ELSE 0
    END as is_active_87,
    CASE
      WHEN (subscription_start < first_day)
        AND (subscription_end > first_day
        OR subscription_end IS NULL)
        AND segment=30 THEN 1
      ELSE 0
    END as is_active_30,
    CASE 
      WHEN subscription_end BETWEEN first_day AND last_day 
        AND segment=87 THEN 1
      ELSE 0
    END as is_canceled_87,
    CASE 
      WHEN subscription_end BETWEEN first_day AND last_day AND segment=30 THEN 1
      ELSE 0
    END as is_canceled_30
  FROM cross_join),

status_aggregate AS
  (SELECT
    month,
    SUM(is_active_87) as sum_active_87,
    SUM(is_active_30) as sum_active_30,
    SUM(is_canceled_87) as sum_canceled_87,
    SUM(is_canceled_30) as sum_canceled_30
  FROM status
  GROUP BY month)

SELECT month, round((1.0*sum_canceled_87/sum_active_87),2) AS churn_rate_87, 
    sum_active_87 AS active_87,
    sum_canceled_87 AS canceled_87,
    round((1.0*sum_canceled_30/sum_active_30),2) AS churn_rate_30, 
    sum_active_30 AS active_30,
    sum_canceled_30 AS canceled_30
FROM status_aggregate;