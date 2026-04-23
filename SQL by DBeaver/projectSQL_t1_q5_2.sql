-- Q5_longest_continuous_adset_run
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
    LEFT JOIN public.facebook_adset    a ON f.adset_id    = a.adset_id
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
)
SELECT
    adset_name,
    MIN(ad_date) AS start_date,
    MAX(ad_date) AS end_date,
    COUNT(*)     AS streak_length
FROM (
    -- серія через ключ streak_group = ad_date - rn
    SELECT
        adset_name,
        ad_date,
        (ad_date - (rn || ' days')::interval)::date AS streak_group
    FROM (
        -- нумерація днів усередині adset після дедуплікації (1 запис на день)
        SELECT
            adset_name,
            ad_date,
            ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY ad_date) AS rn
        FROM (
            SELECT DISTINCT adset_name, ad_date
            FROM all_ads
            WHERE adset_name IS NOT NULL
        ) d
    ) n
) g
GROUP BY adset_name, streak_group
ORDER BY streak_length DESC, adset_name
LIMIT 1;
