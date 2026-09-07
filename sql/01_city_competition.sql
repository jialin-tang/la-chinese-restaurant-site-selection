/*
Project: Los Angeles Chinese Restaurant Site Selection
Purpose:
    Compare high-confidence Chinese restaurant candidates
    with all active restaurant facilities by city.

Notes:
    - One row in restaurant_facilities represents one FACILITY ID.
    - Special large venues are excluded from the standard market count.
    - Chinese restaurant identification is preliminary and keyword-based.
*/

WITH all_restaurants AS (
    SELECT
        facility_city,
        COUNT(DISTINCT facility_id) AS all_restaurant_count
    FROM restaurant_facilities
    WHERE special_venue = FALSE
    GROUP BY facility_city
),

chinese_restaurants AS (
    SELECT
        facility_city,
        COUNT(DISTINCT facility_id) AS chinese_candidate_count,
        ROUND(
            AVG(average_latest_score),
            2
        ) AS average_score
    FROM high_confidence_chinese
    GROUP BY facility_city
),

city_competition AS (
    SELECT
        a.facility_city,
        a.all_restaurant_count,

        COALESCE(
            c.chinese_candidate_count,
            0
        ) AS chinese_candidate_count,

        c.average_score,

        ROUND(
            100.0
            * COALESCE(c.chinese_candidate_count, 0)
            / a.all_restaurant_count,
            2
        ) AS chinese_candidate_share_pct

    FROM all_restaurants AS a

    LEFT JOIN chinese_restaurants AS c
        ON a.facility_city = c.facility_city
)

SELECT
    facility_city,
    all_restaurant_count,
    chinese_candidate_count,
    chinese_candidate_share_pct,
    average_score
FROM city_competition
WHERE
    all_restaurant_count >= 100
    AND chinese_candidate_count >= 5
ORDER BY
    chinese_candidate_share_pct DESC,
    chinese_candidate_count DESC
LIMIT 20;
