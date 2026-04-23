WITH
-- СТЕ з подіями початку сесії
session_start AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params)
      WHERE key = 'ga_session_id') AS session_id,
    -- Витягуємо page_path з page_location
    REGEXP_EXTRACT(
      (SELECT value.string_value FROM UNNEST(event_params)
        WHERE key = 'page_location'),
      r'https?://[^/]+(/[^?#]*)'
    ) AS page_path
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'session_start'
    AND _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
),

-- СТЕ з подіями покупки
purchase_sessions AS (
  SELECT DISTINCT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params)
      WHERE key = 'ga_session_id') AS session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
    AND _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
)

-- Фінальна вибірка: рахуємо кількість сесій і конверсію
SELECT
  s.page_path,
  COUNT(DISTINCT CONCAT(s.user_pseudo_id, '-', s.session_id)) AS user_sessions_count,
  COUNT(DISTINCT CONCAT(p.user_pseudo_id, '-', p.session_id)) AS purchase_sessions_count,
  SAFE_DIVIDE(
    COUNT(DISTINCT CONCAT(p.user_pseudo_id, '-', p.session_id)),
    COUNT(DISTINCT CONCAT(s.user_pseudo_id, '-', s.session_id))
  ) AS conversion_rate
FROM session_start s
LEFT JOIN purchase_sessions p
  ON s.user_pseudo_id = p.user_pseudo_id
  AND s.session_id = p.session_id
GROUP BY s.page_path
ORDER BY conversion_rate DESC;
