USE pharma_market_sizing;

SELECT product, company, modality, route, dosing, initial_approval_year,
       reported_sales_usd_m, sales_year, sales_scope, indication_scope
FROM competitors
ORDER BY product;
