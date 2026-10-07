USE pharma_market_sizing;

INSERT INTO model_assumptions VALUES
('adult_population','US adult resident population age 18+',262083034,'people','epidemiology','PUBLIC FACT','Census SCPRC-EST2023-18+POP','July 1 2023 resident population'),
('prevalence_proxy','Broad migraine/severe-headache prevalence proxy',0.153,'fraction','epidemiology','PUBLIC FACT','Burch et al. PMID 29527677','15.3% self-reported migraine or severe headache over 3 months; used as a broad historical proxy'),
('diagnosis_rate','Migraine ever medically diagnosed',0.562,'fraction','funnel','PUBLIC FACT','AMPP PMID 17371352','56.2% of people with migraine had ever received a medical diagnosis; applied here as a simplified funnel input'),
('treatment_engagement','Modeled prescription-treatment engagement',0.32,'fraction','funnel','ANALYST ASSUMPTION','Illustrative assumption','Not a direct sequential rate from one study'),
('preventive_candidate_rate','Preventive-treatment candidate rate',0.40,'fraction','funnel','PUBLIC FACT','AHS 2024 DOI 10.1111/head.14692','AHS states preventive therapy is indicated in approximately 40% of patients with migraine; the model applies this as a simplified sequential funnel input'),
('commercial_access_factor','Illustrative Commercial Access Factor',0.40,'fraction','access','ANALYST ASSUMPTION','Illustrative assumption','Hypothetical portion of the modeled preventive-treatment pool assumed commercially reachable by a new branded product; not clinical eligibility or a universal payer rule'),
('wac','Illustrative WAC',12500,'USD/patient-year','pricing','HYPOTHETICAL CLIENT INPUT','Calystren Therapeutics','Fictional post-approval launch assumption'),
('gtn','Illustrative GTN deduction',0.40,'fraction','pricing','ANALYST ASSUMPTION','Illustrative assumption','Round simplifying assumption'),
('base_share_y5','Base Year 5 market share',0.12,'fraction','adoption','ANALYST ASSUMPTION','Illustrative assumption','Not benchmarked to competitor adoption data'),
('sensitivity_share_low','Sensitivity market share low',0.08,'fraction','sensitivity','ANALYST ASSUMPTION','Illustrative range','Low case'),
('sensitivity_share_high','Sensitivity market share high',0.16,'fraction','sensitivity','ANALYST ASSUMPTION','Illustrative range','High case'),
('sensitivity_price_low_factor','Sensitivity net price factor low',0.80,'multiple','sensitivity','ANALYST ASSUMPTION','Illustrative range','80% of derived base net price'),
('sensitivity_price_high_factor','Sensitivity net price factor high',1.20,'multiple','sensitivity','ANALYST ASSUMPTION','Illustrative range','120% of derived base net price'),
('sensitivity_pool_low','Sensitivity patient pool factor low',0.80,'multiple','sensitivity','ANALYST ASSUMPTION','Illustrative range','80% of base addressable pool'),
('sensitivity_pool_high','Sensitivity patient pool factor high',1.20,'multiple','sensitivity','ANALYST ASSUMPTION','Illustrative range','120% of base addressable pool');

INSERT INTO adoption_assumptions VALUES
('Downside',1,0.0075,0.80),('Downside',2,0.0200,0.80),('Downside',3,0.0375,0.80),('Downside',4,0.0500,0.80),('Downside',5,0.0600,0.80),
('Base',1,0.0150,1.00),('Base',2,0.0400,1.00),('Base',3,0.0750,1.00),('Base',4,0.1000,1.00),('Base',5,0.1200,1.00),
('Upside',1,0.0225,1.20),('Upside',2,0.0600,1.20),('Upside',3,0.1125,1.20),('Upside',4,0.1500,1.20),('Upside',5,0.1800,1.20);

INSERT INTO competitors VALUES
('Nurtec ODT / Vydura','Pfizer','CGRP receptor antagonist','Oral ODT','Every other day for prevention; as-needed for acute treatment',2020,928,2023,'Global','Product revenue includes acute and preventive uses','Pfizer 2023 Form 10-K'),
('Qulipta','AbbVie','CGRP receptor antagonist','Oral tablet','Once daily',2021,408,2023,'Global','$405M US + $3M international; preventive migraine product','AbbVie FY2023 results'),
('Aimovig','Amgen','CGRP receptor monoclonal antibody','Subcutaneous injection','Monthly',2018,323,2023,'Global','$303M US + $20M ROW; preventive migraine','Amgen FY2023 results'),
('Botox Therapeutic','AbbVie','OnabotulinumtoxinA','Injection','Every 12 weeks for chronic migraine',1989,2991,2023,'Global therapeutic sales','$2.991B across therapeutic indications; not migraine-specific revenue','AbbVie FY2023 results; FDA label');

CREATE OR REPLACE VIEW vw_model_inputs AS
SELECT
  MAX(CASE WHEN assumption_id='adult_population' THEN value END) AS adult_population,
  MAX(CASE WHEN assumption_id='prevalence_proxy' THEN value END) AS prevalence,
  MAX(CASE WHEN assumption_id='diagnosis_rate' THEN value END) AS diagnosis_rate,
  MAX(CASE WHEN assumption_id='treatment_engagement' THEN value END) AS treatment_rate,
  MAX(CASE WHEN assumption_id='preventive_candidate_rate' THEN value END) AS preventive_rate,
  MAX(CASE WHEN assumption_id='commercial_access_factor' THEN value END) AS access_factor,
  MAX(CASE WHEN assumption_id='wac' THEN value END) AS wac,
  MAX(CASE WHEN assumption_id='gtn' THEN value END) AS gtn,
  MAX(CASE WHEN assumption_id='wac' THEN value END) *
    (1 - MAX(CASE WHEN assumption_id='gtn' THEN value END)) AS net_price,
  MAX(CASE WHEN assumption_id='base_share_y5' THEN value END) AS base_share,
  MAX(CASE WHEN assumption_id='sensitivity_share_low' THEN value END) AS share_low,
  MAX(CASE WHEN assumption_id='sensitivity_share_high' THEN value END) AS share_high,
  MAX(CASE WHEN assumption_id='sensitivity_price_low_factor' THEN value END) AS price_low_factor,
  MAX(CASE WHEN assumption_id='sensitivity_price_high_factor' THEN value END) AS price_high_factor,
  MAX(CASE WHEN assumption_id='sensitivity_pool_low' THEN value END) AS pool_low_factor,
  MAX(CASE WHEN assumption_id='sensitivity_pool_high' THEN value END) AS pool_high_factor
FROM model_assumptions;

CREATE OR REPLACE VIEW vw_patient_funnel AS
SELECT 1 AS stage_order, 'US adult population' AS stage, adult_population AS population, 1.000000 AS conversion_rate,
       1.000000 AS share_of_adults FROM vw_model_inputs
UNION ALL
SELECT 2, 'Broad migraine/severe-headache population', adult_population * prevalence, prevalence,
       prevalence FROM vw_model_inputs
UNION ALL
SELECT 3, 'Diagnosed population', adult_population * prevalence * diagnosis_rate, diagnosis_rate,
       (adult_population * prevalence * diagnosis_rate) / adult_population FROM vw_model_inputs
UNION ALL
SELECT 4, 'Modeled treatment-engaged population', adult_population * prevalence * diagnosis_rate * treatment_rate, treatment_rate,
       (adult_population * prevalence * diagnosis_rate * treatment_rate) / adult_population FROM vw_model_inputs
UNION ALL
SELECT 5, 'Preventive candidate pool', adult_population * prevalence * diagnosis_rate * treatment_rate * preventive_rate, preventive_rate,
       (adult_population * prevalence * diagnosis_rate * treatment_rate * preventive_rate) / adult_population FROM vw_model_inputs
UNION ALL
SELECT 6, 'Commercially addressable pool', adult_population * prevalence * diagnosis_rate * treatment_rate * preventive_rate * access_factor, access_factor,
       (adult_population * prevalence * diagnosis_rate * treatment_rate * preventive_rate * access_factor) / adult_population FROM vw_model_inputs;

CREATE OR REPLACE VIEW vw_revenue_model AS
SELECT
  a.scenario,
  a.year_number,
  p.population AS addressable_pool,
  a.market_share,
  a.price_factor,
  m.net_price * a.price_factor AS net_price,
  p.population * a.market_share AS modeled_product_patients,
  p.population * a.market_share * (m.net_price * a.price_factor) AS modeled_annual_net_sales
FROM adoption_assumptions a
JOIN vw_patient_funnel p ON p.stage_order = 6
CROSS JOIN vw_model_inputs m;

CREATE OR REPLACE VIEW vw_sensitivity AS
SELECT
  'Market Share' AS driver,
  m.share_low AS low_input,
  m.base_share AS base_input,
  m.share_high AS high_input,
  m.addressable_pool * m.share_low * m.net_price AS low_revenue,
  m.addressable_pool * m.base_share * m.net_price AS base_revenue,
  m.addressable_pool * m.share_high * m.net_price AS high_revenue
FROM (
  SELECT v.addressable_pool, i.net_price, i.share_low, i.base_share, i.share_high
  FROM (SELECT population AS addressable_pool FROM vw_patient_funnel WHERE stage_order=6) v
  CROSS JOIN vw_model_inputs i
) m
UNION ALL
SELECT
  'Net Price',
  m.net_price * i.price_low_factor,
  m.net_price,
  m.net_price * i.price_high_factor,
  m.addressable_pool * m.share * (m.net_price * i.price_low_factor),
  m.addressable_pool * m.share * m.net_price,
  m.addressable_pool * m.share * (m.net_price * i.price_high_factor)
FROM (
  SELECT v.addressable_pool, i.net_price, i.base_share AS share
  FROM (SELECT population AS addressable_pool FROM vw_patient_funnel WHERE stage_order=6) v
  CROSS JOIN vw_model_inputs i
) m
CROSS JOIN vw_model_inputs i
UNION ALL
SELECT
  'Addressable Patient Pool',
  m.addressable_pool * i.pool_low_factor,
  m.addressable_pool,
  m.addressable_pool * i.pool_high_factor,
  m.addressable_pool * i.pool_low_factor * m.share * m.net_price,
  m.addressable_pool * m.share * m.net_price,
  m.addressable_pool * i.pool_high_factor * m.share * m.net_price
FROM (
  SELECT v.population AS addressable_pool, i.base_share AS share, i.net_price
  FROM vw_patient_funnel v
  CROSS JOIN vw_model_inputs i
  WHERE v.stage_order=6
) m
CROSS JOIN vw_model_inputs i;
