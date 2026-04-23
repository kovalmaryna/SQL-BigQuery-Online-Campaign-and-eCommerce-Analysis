WITH sessions AS (
  SELECT
    user_pseudo_id,
    event_params.value.int_value AS session_id,
    MAX(CASE WHEN event_params.key = 'session_engaged' THEN CAST(event_params.value.string_value AS INT64) ELSE 0 END) AS session_engaged_flag,
    SUM(CASE WHEN event_params.key = 'engagement_time_msec' THEN COALESCE(event_params.value.int_value, 0) ELSE 0 END) AS total_engagement_time,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_made
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`,
    UNNEST(event_params) AS event_params
  GROUP BY
    user_pseudo_id,
    session_id
)

SELECT
  CORR(session_engaged_flag, purchase_made) AS corr_engaged_purchase,
  CORR(total_engagement_time, purchase_made) AS corr_time_purchase
FROM sessions;
