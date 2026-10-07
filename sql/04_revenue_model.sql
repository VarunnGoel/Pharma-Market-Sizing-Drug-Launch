USE pharma_market_sizing;

SELECT
  scenario,
  year_number,
  ROUND(addressable_pool) AS addressable_pool,
  market_share,
  price_factor,
  ROUND(net_price,2) AS net_price,
  ROUND(modeled_product_patients) AS modeled_product_patients,
  ROUND(modeled_annual_net_sales,2) AS modeled_annual_net_sales
FROM vw_revenue_model
ORDER BY FIELD(scenario,'Downside','Base','Upside'), year_number;
