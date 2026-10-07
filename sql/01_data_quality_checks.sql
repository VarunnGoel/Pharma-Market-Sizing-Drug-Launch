USE pharma_market_sizing;

SELECT assumption_id, assumption_name, value, unit, source_type
FROM model_assumptions
WHERE value IS NULL OR unit IS NULL OR source_type IS NULL;

SELECT assumption_id, value
FROM model_assumptions
WHERE unit = 'fraction' AND (value < 0 OR value > 1);

SELECT scenario, year_number, market_share, price_factor
FROM adoption_assumptions
WHERE market_share < 0 OR market_share > 1 OR price_factor <= 0;

SELECT source_type, COUNT(*) AS rows_count
FROM model_assumptions
GROUP BY source_type
ORDER BY source_type;
