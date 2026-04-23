-- Q2_top5_days_by_romi
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
daily AS (
    SELECT
        ad_date,
        SUM(spend) AS spend,
        SUM(value) AS value
    FROM all_ads
    GROUP BY ad_date
)
SELECT
    ad_date,
    ROUND( (value::numeric - spend::numeric) / NULLIF(spend::numeric, 0), 4 ) AS romi
FROM daily
WHERE spend > 0
ORDER BY romi DESC, ad_date
LIMIT 5;
