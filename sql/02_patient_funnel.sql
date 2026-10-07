USE pharma_market_sizing;

SELECT
  ROUND(MAX(CASE WHEN stage_order=1 THEN population END)) AS adult_population,
  ROUND(MAX(CASE WHEN stage_order=2 THEN population END)) AS disease_population,
  ROUND(MAX(CASE WHEN stage_order=3 THEN population END)) AS diagnosed_population,
  ROUND(MAX(CASE WHEN stage_order=4 THEN population END)) AS treatment_engaged_population,
  ROUND(MAX(CASE WHEN stage_order=5 THEN population END)) AS preventive_candidate_pool,
  ROUND(MAX(CASE WHEN stage_order=6 THEN population END)) AS commercially_addressable_pool
FROM vw_patient_funnel;
