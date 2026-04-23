WITH src AS (
  SELECT
    event_timestamp,
    event_name,
    user_pseudo_id,
    (SELECT value.int_value    FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source')   AS source,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium')   AS medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS campaign
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
),

-- Сесії (тільки session_start)
sessions AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,  -- дата старту сесії з event_timestamp
    source,
    medium,
    campaign,
    user_pseudo_id,
    ga_session_id,
    CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS user_session_id
  FROM src
  WHERE event_name = 'session_start'
),

-- Сесії, де був доданий товар у кошик
cart AS (
  SELECT DISTINCT CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS user_session_id
  FROM src
  WHERE event_name = 'add_to_cart'
),

-- Сесії, де був початий чек-аут
checkout AS (
  SELECT DISTINCT CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS user_session_id
  FROM src
  WHERE event_name = 'begin_checkout'
),

-- Сесії, де була покупка
purchase AS (
  SELECT DISTINCT CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS user_session_id
  FROM src
  WHERE event_name = 'purchase'
)

SELECT
  s.event_date,
  COALESCE(s.source, '(not set)')   AS source,
  COALESCE(s.medium, '(not set)')   AS medium,
  COALESCE(s.campaign, '(not set)') AS campaign,
  COUNT(DISTINCT s.user_session_id) AS user_sessions_count,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(c.user_session_id  IS NOT NULL, s.user_session_id, NULL)),
    COUNT(DISTINCT s.user_session_id)
  ) AS visit_to_cart,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(ch.user_session_id IS NOT NULL, s.user_session_id, NULL)),
    COUNT(DISTINCT s.user_session_id)
  ) AS visit_to_checkout,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(p.user_session_id  IS NOT NULL, s.user_session_id, NULL)),
    COUNT(DISTINCT s.user_session_id)
  ) AS visit_to_purchase
FROM sessions s
LEFT JOIN cart     c  USING (user_session_id)
LEFT JOIN checkout ch USING (user_session_id)
LEFT JOIN purchase p  USING (user_session_id)
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4;