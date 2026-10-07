USE pharma_market_sizing;

SELECT
  driver,
  ROUND(low_input,4) AS low_input,
  ROUND(base_input,4) AS base_input,
  ROUND(high_input,4) AS high_input,
  ROUND(low_revenue,2) AS low_revenue,
  ROUND(base_revenue,2) AS base_revenue,
  ROUND(high_revenue,2) AS high_revenue,
  ROUND(high_revenue - low_revenue,2) AS revenue_spread
FROM vw_sensitivity
ORDER BY revenue_spread DESC;
