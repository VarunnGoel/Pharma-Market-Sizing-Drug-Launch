USE pharma_market_sizing;

SELECT
  'Disease Population' AS metric,
  ROUND(f.population) AS patients,
  NULL AS annual_value_usd,
  'Broad migraine/severe-headache population proxy' AS meaning
FROM vw_patient_funnel f
WHERE f.stage_order=2
UNION ALL
SELECT
  'Preventive Candidate Pool',
  ROUND(f.population),
  ROUND(f.population * m.net_price,2),
  'Modeled population potentially relevant to prevention'
FROM vw_patient_funnel f CROSS JOIN vw_model_inputs m
WHERE f.stage_order=5
UNION ALL
SELECT
  'Commercially Addressable Pool',
  ROUND(f.population),
  ROUND(f.population * m.net_price,2),
  'Addressable patient pool at modeled net price'
FROM vw_patient_funnel f CROSS JOIN vw_model_inputs m
WHERE f.stage_order=6
UNION ALL
SELECT
  'Year 5 Modeled Product Patients',
  ROUND(r.modeled_product_patients),
  ROUND(r.modeled_annual_net_sales,2),
  'Addressable pool × Base Year 5 share'
FROM vw_revenue_model r
WHERE r.scenario='Base' AND r.year_number=5;
