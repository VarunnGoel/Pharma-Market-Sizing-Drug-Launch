# Data Dictionary

## model_assumptions
Central source of truth for numerical model inputs. Percentages are stored as decimal fractions, for example 0.562 = 56.2%. `source_type` uses only **PUBLIC FACT**, **ANALYST ASSUMPTION**, and **HYPOTHETICAL CLIENT INPUT**.

Key fields:
- `adult_population` - people; public fact; input.
- `prevalence_proxy` - fraction; public fact; input.
- `diagnosis_rate` - fraction; public fact; input; published AMPP value applied as a simplified modeling input.
- `treatment_engagement` - fraction; analyst assumption; input.
- `preventive_candidate_rate` - fraction; public fact; input; AHS context applied as a simplified sequential funnel input.
- `commercial_access_factor` - fraction; analyst assumption; input; separate from clinical eligibility.
- `wac` - USD/patient-year; hypothetical client input.
- `gtn` - fraction; analyst assumption.
- `base_share_y5` - fraction; analyst assumption.
- sensitivity share factors - fractions; analyst assumptions.
- sensitivity pool factors - multiples; analyst assumptions.
- sensitivity price factors - multiples; analyst assumptions.

## Derived pricing output
- `net_price` - USD/patient-year; derived as `WAC × (1 − GTN)`. It is not stored as an independent assumption.

## adoption_assumptions
One row per scenario and model year with `scenario`, `year_number`, `market_share`, and `price_factor`. Years are Year 1 through Year 5. Scenario net price is derived as base net price × price factor.

## competitors
Real products only. Historical sales are retained with reporting-scope and indication-scope notes. The fictional product is not stored as a competitor or reported-sales row.

## Key derived outputs
- Disease population = adult population × prevalence proxy
- Diagnosed population = disease population × diagnosis rate
- Treatment-engaged population = diagnosed population × treatment-engagement assumption
- Preventive candidate pool = treatment-engaged population × preventive candidate rate
- Commercially addressable pool = preventive candidate pool × Illustrative Commercial Access Factor
- Modeled product patients = addressable pool × market share
- Modeled annual net sales = modeled product patients × derived net price
