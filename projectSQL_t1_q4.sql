-- Q4_biggest_month_reach_increase
WITH all_ads AS (
    -- Facebook
    SELECT
        f.ad_date::date                           AS ad_date,
        'Facebook Ads'::text                      AS source,
        c.campaign_name                           AS campaign_name,
        a.adset_name                              AS adset_name,
        COALESCE(f.spend,0)::numeric              AS spend,
        COALESCE(f.impressions,0)::bigint         AS impressions,
        COALESCE(f.reach,0)::bigint               AS reach,
        COALESCE(f.clicks,0)::bigint              AS clicks,
        COALESCE(f.leads,0)::bigint               AS leads,
        COALESCE(f.value,0)::numeric              AS value
    FROM public.facebook_ads_basic_daily f
    LEFT JOIN public.facebook_adset   a ON f.adset_id   = a.adset_id
    LEFT JOIN public.facebook_campaign c ON f.campaign_id = c.campaign_id

    UNION ALL

    -- Google
    SELECT
        g.ad_date::date                           AS ad_date,
        'Google Ads'::text                        AS source,
        g.campaign_name                           AS campaign_name,
        g.adset_name                              AS adset_name,
        COALESCE(g.spend,0)::numeric              AS spend,
        COALESCE(g.impressions,0)::bigint         AS impressions,
        COALESCE(g.reach,0)::bigint               AS reach,
        COALESCE(g.clicks,0)::bigint              AS clicks,
        COALESCE(g.leads,0)::bigint               AS leads,
        COALESCE(g.value,0)::numeric              AS value
    FROM public.google_ads_basic_daily g
),
monthly AS (
    SELECT
        date_trunc('month', ad_date)::date AS month_start,
        campaign_name,
        SUM(reach)::bigint AS month_reach
    FROM all_ads
    GROUP BY date_trunc('month', ad_date)::date, campaign_name
),
with_lag AS (
    SELECT
        campaign_name,
        month_start,
        month_reach,
        LAG(month_reach) OVER (PARTITION BY campaign_name ORDER BY month_start) AS prev_month_reach
    FROM monthly
)
SELECT
    campaign_name,
    month_start            AS month_of_record,
    month_reach,
    prev_month_reach,
    (month_reach - prev_month_reach) AS abs_increase
FROM with_lag
WHERE prev_month_reach IS NOT NULL
ORDER BY abs_increase DESC
LIMIT 1;
