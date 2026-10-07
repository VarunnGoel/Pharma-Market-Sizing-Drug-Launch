CREATE DATABASE IF NOT EXISTS pharma_market_sizing;
USE pharma_market_sizing;

CREATE TABLE model_assumptions (
  assumption_id VARCHAR(40) PRIMARY KEY,
  assumption_name VARCHAR(160) NOT NULL,
  value DECIMAL(18,6) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  source_type VARCHAR(50) NOT NULL,
  source_reference VARCHAR(255),
  notes VARCHAR(500),
  CHECK (source_type IN ('PUBLIC FACT','ANALYST ASSUMPTION','HYPOTHETICAL CLIENT INPUT'))
);

CREATE TABLE adoption_assumptions (
  scenario VARCHAR(20) NOT NULL,
  year_number INT NOT NULL,
  market_share DECIMAL(10,6) NOT NULL,
  price_factor DECIMAL(10,6) NOT NULL,
  PRIMARY KEY (scenario, year_number),
  CHECK (market_share >= 0 AND market_share <= 1),
  CHECK (price_factor > 0)
);

CREATE TABLE competitors (
  product VARCHAR(80) PRIMARY KEY,
  company VARCHAR(80) NOT NULL,
  modality VARCHAR(120),
  route VARCHAR(80),
  dosing VARCHAR(160),
  initial_approval_year INT,
  reported_sales_usd_m DECIMAL(12,2),
  sales_year INT,
  sales_scope VARCHAR(120),
  indication_scope VARCHAR(255),
  source_reference VARCHAR(255)
);
