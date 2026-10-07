USE pharma_market_sizing;

WITH
population_checks AS (
  SELECT
    MAX(CASE WHEN stage_order=1 THEN population END) AS adult_population,
    MAX(CASE WHEN stage_order=2 THEN population END) AS disease_population,
    MAX(CASE WHEN stage_order=3 THEN population END) AS diagnosed_population,
    MAX(CASE WHEN stage_order=4 THEN population END) AS treatment_engaged_population,
    MAX(CASE WHEN stage_order=5 THEN population END) AS preventive_candidate_pool,
    MAX(CASE WHEN stage_order=6 THEN population END) AS commercially_addressable_pool
  FROM vw_patient_funnel
),
scenario_year5 AS (
  SELECT
    MAX(CASE WHEN scenario='Downside' THEN market_share END) AS downside_share,
    MAX(CASE WHEN scenario='Base' THEN market_share END) AS base_share,
    MAX(CASE WHEN scenario='Upside' THEN market_share END) AS upside_share,
    MAX(CASE WHEN scenario='Downside' THEN modeled_annual_net_sales END) AS downside_revenue,
    MAX(CASE WHEN scenario='Base' THEN modeled_annual_net_sales END) AS base_revenue,
    MAX(CASE WHEN scenario='Upside' THEN modeled_annual_net_sales END) AS upside_revenue
  FROM vw_revenue_model
  WHERE year_number=5
),
required_ids AS (
  SELECT 'adult_population' AS assumption_id UNION ALL
  SELECT 'prevalence_proxy' UNION ALL
  SELECT 'diagnosis_rate' UNION ALL
  SELECT 'treatment_engagement' UNION ALL
  SELECT 'preventive_candidate_rate' UNION ALL
  SELECT 'commercial_access_factor' UNION ALL
  SELECT 'wac' UNION ALL
  SELECT 'gtn' UNION ALL
  SELECT 'base_share_y5' UNION ALL
  SELECT 'sensitivity_share_low' UNION ALL
  SELECT 'sensitivity_share_high' UNION ALL
  SELECT 'sensitivity_price_low_factor' UNION ALL
  SELECT 'sensitivity_price_high_factor' UNION ALL
  SELECT 'sensitivity_pool_low' UNION ALL
  SELECT 'sensitivity_pool_high'
),
required_check AS (
  SELECT COUNT(*) AS bad_required
  FROM required_ids r
  LEFT JOIN model_assumptions a ON a.assumption_id=r.assumption_id
  WHERE a.assumption_id IS NULL
     OR a.value IS NULL
     OR a.value < 0
     OR (r.assumption_id='wac' AND a.value <= 0)
     OR (r.assumption_id IN ('sensitivity_price_low_factor','sensitivity_price_high_factor','sensitivity_pool_low','sensitivity_pool_high') AND a.value <= 0)
),
percentage_check AS (
  SELECT
    (SELECT COUNT(*) FROM model_assumptions WHERE unit='fraction' AND (value < 0 OR value > 1)) +
    (SELECT COUNT(*) FROM adoption_assumptions WHERE market_share < 0 OR market_share > 1) AS bad_fraction_rows
),
duplicate_assumption_check AS (
  SELECT COUNT(*) AS duplicate_groups
  FROM (SELECT assumption_name FROM model_assumptions GROUP BY assumption_name HAVING COUNT(*) > 1) d
),
duplicate_scenario_check AS (
  SELECT COUNT(*) AS duplicate_groups
  FROM (SELECT scenario, year_number FROM adoption_assumptions GROUP BY scenario, year_number HAVING COUNT(*) > 1) d
),
duplicate_competitor_check AS (
  SELECT COUNT(*) AS duplicate_groups
  FROM (SELECT product FROM competitors GROUP BY product HAVING COUNT(*) > 1) d
),
scenario_completeness AS (
  SELECT COUNT(*) AS valid_scenarios
  FROM (
    SELECT scenario, COUNT(*) AS year_count, COUNT(DISTINCT year_number) AS distinct_years,
           MIN(year_number) AS min_year, MAX(year_number) AS max_year
    FROM adoption_assumptions
    GROUP BY scenario
  ) s
  WHERE scenario IN ('Downside','Base','Upside')
    AND year_count=5 AND distinct_years=5 AND min_year=1 AND max_year=5
),
net_price_sanity AS (
  SELECT MAX(net_price) AS net_price, MAX(wac) AS wac, MAX(gtn) AS gtn
  FROM vw_model_inputs
),
sensitivity_check AS (
  SELECT COUNT(*) AS valid_rows
  FROM vw_sensitivity
  WHERE low_revenue < base_revenue AND base_revenue < high_revenue
),
revenue_check AS (
  SELECT COUNT(*) AS bad_rows
  FROM vw_revenue_model
  WHERE ABS(modeled_annual_net_sales - (modeled_product_patients * net_price)) > 0.01
),
patient_constraint AS (
  SELECT COUNT(*) AS bad_rows
  FROM vw_revenue_model
  WHERE modeled_product_patients > addressable_pool + 0.01
),
checks AS (
  SELECT
    'Population hierarchy' AS check_name,
    IF(adult_population >= disease_population
       AND disease_population >= diagnosed_population
       AND diagnosed_population >= treatment_engaged_population
       AND treatment_engaged_population >= preventive_candidate_pool
       AND preventive_candidate_pool >= commercially_addressable_pool,
       'PASS','FAIL') AS result,
    IF(adult_population >= disease_population
       AND disease_population >= diagnosed_population
       AND diagnosed_population >= treatment_engaged_population
       AND treatment_engaged_population >= preventive_candidate_pool
       AND preventive_candidate_pool >= commercially_addressable_pool,
       'All funnel stages decrease or stay flat','At least one funnel stage exceeds the prior stage') AS detail
  FROM population_checks
  UNION ALL
  SELECT 'Percentage bounds', IF(bad_fraction_rows=0,'PASS','FAIL'),
         IF(bad_fraction_rows=0,'All fractional assumptions and scenario shares are within 0–1','Out-of-bounds fractional value detected')
  FROM percentage_check
  UNION ALL
  SELECT 'Revenue consistency', IF(bad_rows=0,'PASS','FAIL'),
         IF(bad_rows=0,'All modeled sales outputs equal modeled patients × net price','At least one revenue row does not reconcile to its model outputs')
  FROM revenue_check
  UNION ALL
  SELECT 'Scenario ordering', IF(downside_share < base_share AND base_share < upside_share
                                  AND downside_revenue < base_revenue AND base_revenue < upside_revenue,'PASS','FAIL'),
         IF(downside_share < base_share AND base_share < upside_share
            AND downside_revenue < base_revenue AND base_revenue < upside_revenue,
            'Downside < Base < Upside for share and Year 5 revenue','Scenario ordering is inconsistent')
  FROM scenario_year5
  UNION ALL
  SELECT 'Patient constraint', IF(bad_rows=0,'PASS','FAIL'),
         IF(bad_rows=0,'All modeled product patients are within the addressable pool','At least one modeled patient output exceeds the addressable pool')
  FROM patient_constraint
  UNION ALL
  SELECT 'Sensitivity ordering', IF(valid_rows=3,'PASS','FAIL'),
         IF(valid_rows=3,'Low < Base < High for all sensitivity drivers','At least one sensitivity driver is not ordered Low < Base < High')
  FROM sensitivity_check
  UNION ALL
  SELECT 'Net price < WAC', IF(net_price < wac,'PASS','FAIL'),
         IF(net_price < wac,'Derived net price is below WAC','Derived net price is not below WAC')
  FROM net_price_sanity
  UNION ALL
  SELECT 'GTN bounds', IF(gtn BETWEEN 0 AND 1,'PASS','FAIL'),
         IF(gtn BETWEEN 0 AND 1,'GTN is within 0–1','GTN is outside 0–1')
  FROM net_price_sanity
  UNION ALL
  SELECT 'Required-value checks', IF(bad_required=0,'PASS','FAIL'),
         IF(bad_required=0,'All required model assumptions are populated and non-negative','Missing, blank, or negative required assumption detected')
  FROM required_check
  UNION ALL
  SELECT 'Duplicate checks', IF((SELECT duplicate_groups FROM duplicate_assumption_check)=0
                                 AND (SELECT duplicate_groups FROM duplicate_scenario_check)=0
                                 AND (SELECT duplicate_groups FROM duplicate_competitor_check)=0,'PASS','FAIL'),
         IF((SELECT duplicate_groups FROM duplicate_assumption_check)=0
            AND (SELECT duplicate_groups FROM duplicate_scenario_check)=0
            AND (SELECT duplicate_groups FROM duplicate_competitor_check)=0,
            'No unexpected duplicate assumption names, scenario-year rows, or competitor products','Unexpected duplicate detected')
  FROM duplicate_assumption_check
  UNION ALL
  SELECT 'Scenario completeness',
         IF(valid_scenarios=3 AND (SELECT COUNT(DISTINCT scenario) FROM adoption_assumptions)=3,'PASS','FAIL'),
         IF(valid_scenarios=3 AND (SELECT COUNT(DISTINCT scenario) FROM adoption_assumptions)=3,
            'Downside, Base, and Upside each contain Years 1–5','One or more required scenarios is missing or an unexpected scenario is present')
  FROM scenario_completeness
)
SELECT check_name AS `Check`, result AS `Result`, detail AS `Detail`
FROM checks;
