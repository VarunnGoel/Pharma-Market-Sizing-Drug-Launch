# Pharma Market Sizing & Drug Launch Strategy

## Project Overview
This portfolio case study uses public US migraine evidence, MySQL, and Excel to size a hypothetical post-approval commercial opportunity for **Project CYR-217**, a fictional oral CGRP receptor antagonist from **Calystren Therapeutics**. Public facts are separated from analyst assumptions and hypothetical client inputs, and all outputs are scenario estimates rather than a validated forecast.

## Business Question
How large could the US commercial opportunity be for a hypothetical preventive migraine product, and which assumptions matter most to the conclusion?

## Approach
Patient sizing -> commercial funnel -> revenue scenarios -> competitor context -> sensitivity analysis -> recommendation.

## Key Outputs
- Broad migraine/severe-headache population proxy: **40.10M adults**.
- Preventive candidate pool: **2.88M modeled patients**.
- Commercially addressable pool: **1.15M modeled patients**.
- Base Year 5 market share: **12%**.
- Base annual net price: **$7,500**, derived from **$12,500 WAC** and **40% GTN**.
- Base Year 5 modeled product patients: **138,458**.
- Base Year 5 modeled annual net sales: **$1.04B**.
- Base five-year cumulative modeled net sales: **$3.03B**.

## Methodology
The model starts with the July 1, 2023 US resident population age 18+ and applies a historical **15.3% self-reported migraine/severe-headache prevalence proxy**. It then applies the AMPP 56.2% ever-diagnosed estimate, a 32% treatment-engagement assumption, the AHS approximately 40% preventive-treatment context, and a separate 40% **Illustrative Commercial Access Factor**. The access factor represents the portion of the modeled preventive-treatment pool assumed commercially reachable by a new branded product; it is not clinical eligibility or a universal payer rule. Revenue is modeled as addressable pool x scenario market share x scenario net price.

## Technology Stack
**MySQL | Excel | Git/GitHub**

## Data Sources
Primary references include the US Census Bureau, PubMed-indexed migraine studies, the 2024 American Headache Society position statement, FDA labeling, and company/SEC disclosures for historical competitor sales. See `data/source_registry.csv` and `docs/sources.md`.

## Assumptions
The 32% treatment-engagement rate, 40% Illustrative Commercial Access Factor, market-share scenarios, WAC, GTN, and scenario price factors are illustrative inputs. **WAC and GTN are inputs; net price is derived as WAC x (1 - GTN).**

## Limitations
This is an illustrative commercial model, not a clinical, claims-based, profit, return, or valuation forecast. The patient funnel combines evidence from different studies and applies simplifying assumptions. Competitor sales have different reporting and indication scopes and are shown only as factual historical context.

## Repository Structure
```text
Pharma-Market-Sizing-Drug-Launch/
├── README.md
├── database/
│   ├── schema.sql
│   └── database.sql
├── data/
│   ├── raw/
│   │   ├── us_adult_population_census.csv
│   │   ├── migraine_model_inputs.csv
│   │   └── migraine_competitor_data.csv
│   └── source_registry.csv
├── sql/
│   ├── 01_data_quality_checks.sql
│   ├── 02_patient_funnel.sql
│   ├── 03_market_sizing.sql
│   ├── 04_revenue_model.sql
│   ├── 05_sensitivity_analysis.sql
│   ├── 06_competitor_benchmarking.sql
│   └── 07_validation_checks.sql
├── excel/
│   └── Pharma_Commercial_Model.xlsx
├── outputs/
│   └── executive_summary.pdf
└── docs/
    ├── assumptions.md
    ├── data_dictionary.md
    ├── methodology.md
    └── sources.md
```

## How to Run
1. In MySQL, run `database/schema.sql`.
2. Run `database/database.sql` to load model assumptions, scenario inputs, competitor benchmarks, and analytical views.
3. Run the SQL files in numeric order.
4. Open `excel/Pharma_Commercial_Model.xlsx` to review the formula-driven model, scenarios, sensitivity analysis, and dashboard.

## Recommendation
**Advance to the next stage of commercial validation.** The base case indicates meaningful modeled revenue potential, but the conclusion depends primarily on the size of the commercially addressable pool, achievable market share, and realized net price. Patient, physician, payer, and competitive assumptions should be tested with better data before a full launch commitment.
