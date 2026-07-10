# E-Commerce Order Analytics System

An end-to-end e-commerce order analytics system combining Python and SQL. This project covers data generation with intentional anomalies, automated cleaning using Pandas, database schema creation with relational integrity constraints in SQLite, complex analytical SQL queries, and a standard-library command-line reporting tool.

---

## System Architecture

```
[Raw Data Source] ──(generate_data.py)──> [data/raw/ (CSVs)]
                                                │
                                                ▼
                                         (clean_data.py)
                                                │
                                                ▼
[SQLite DB (ecommerce.db)] <──(db_setup.py)── [data/cleaned/ (CSVs)]
           │
           ├─(test_queries.py)──────────> SQL Analytics Output
           │
           └─(report_cli.py)────────────> CLI Performance Reports
```

---

## Directory Structure

The project conforms to the required folder structure:

```
ecommerce-analytics-system/
├── data/
│   ├── raw/                      # Generated raw CSV datasets with inconsistencies
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── orders.csv
│   │   └── order_items.csv
│   └── cleaned/                  # Cleaned and validated CSV datasets
│       ├── customers_clean.csv
│       ├── products_clean.csv
│       ├── orders_clean.csv
│       ├── order_items_clean.csv
│       └── cleaning_report.txt   # Execution report of the cleaning pipeline
├── scripts/
│   ├── generate_data.py          # Python script to generate mock raw data
│   ├── clean_data.py             # Pandas pipeline script for cleaning & validation
│   ├── test_edge_cases.py        # Unit tests verifying edge case handling
│   ├── db_setup.py               # SQLite schema deployment and data loading
│   ├── test_queries.py           # Verification script executing all SQL analysis
│   └── report_cli.py             # Python CLI report tool (Pure standard library)
├── sql/
│   ├── schema.sql                # SQL DDL schemas and relational constraints
│   ├── aggregations.sql          # Basic and Intermediate joins & aggregates
│   ├── window_functions.sql      # Advanced window functions, CTEs & segmentation
│   └── cohort_analysis.sql       # Complex Cohort & monthly user retention queries
├── output/
│   └── sample_reports/           # Saved CLI report outputs
│       ├── monthly_report.txt
│       └── daily_report.txt
└── README.md                     # Documentation
```

---

## Getting Started

### Prerequisites

The project requires `pandas` for cleaning. Install dependencies using:

```bash
pip install pandas
```

*Note: The CLI reporting tool, database setups, and queries run using Python's built-in `sqlite3` and `argparse` modules, meaning no external CLI styling or database libraries are needed.*

---

## Step-by-Step Execution Guide

### Step 1: Generate Mock Datasets
Generate 4 raw relational tables containing 500+ records each. This script intentionally injects realistic data anomalies:
- **Orders**: 5% of records have `NULL` customer IDs, and 8% contain dates in the wrong format (`DD-MM-YYYY`).
- **Order Items**: 3% of rows have negative quantities (simulating returns), and 10 orphaned order items with non-existent orders are added.
- **Products**: 10% of product names have extra leading/trailing whitespace or mixed casing.
- **Customers**: 2% of email addresses are missing the `@` or domain suffix.

```bash
python scripts/generate_data.py
```

### Step 2: Run Data Cleaning & Validations
Clean the dataset anomalies, resolve formatting issues, validate integrity, and generate an evaluation report:
- `clean_orders()`: Standardizes dates to `YYYY-MM-DD HH:MM:SS`, filters out orders with empty/NULL customer IDs, and drops duplicate orders.
- `clean_products()`: Trims whitespace and normalizes name strings to title case.
- `validate_emails()`: Returns and logs a report listing all customer IDs with invalid email formats.
- `check_referential_integrity()`: Discards orphaned items that map to non-existent orders or products.

```bash
python scripts/clean_data.py
```
This generates the cleaned tables in `data/cleaned/` and outputs a comprehensive evaluation log at `data/cleaned/cleaning_report.txt`.

### Step 3: Run Edge Case Test Suite
Run the unit test suite verifying data integrity filters and corner-case exceptions:
- Orphaned order items mapped to non-existent orders.
- Invalid discount percentage thresholds (`discount_percent` outside 0–100%).
- Order line items with zero quantities.
- Orders placed in future dates.

```bash
python scripts/test_edge_cases.py
```

### Step 4: Deploy SQLite Database
Create the database tables matching the schema definitions in `sql/schema.sql` (defining primary keys, foreign key relationships, check constraints), and load the cleaned records into `ecommerce.db`:

```bash
python scripts/db_setup.py
```

### Step 5: Execute SQL Analysis Queries
Evaluate advanced SQL metrics, window functions, user categorization, and cohort statistics directly on the database:

```bash
python scripts/test_queries.py
```
This script runs the queries from all three SQL script files:
- **`sql/aggregations.sql`**: Categories net revenues, top 10 customers, trailing 12-month order volume, undelivered customers, net negative return products, and category-level return rates.
- **`sql/window_functions.sql`**: Regional daily revenue running totals, product ranking inside categories, inter-order lag analysis, multi-tiered customer spend counts, NTILE customer segmentation, YoY monthly growth metrics, category shift analysis, and products frequently bought together.
- **`sql/cohort_analysis.sql`**: Standard monthly cohort registration size and customer retention rates for months 0, 1, 2, and 3.

---

## Command-Line Reporting Tool

The command-line tool `scripts/report_cli.py` lets you generate summaries directly from the command line.

### CLI Syntax

```bash
python scripts/report_cli.py [--report {daily,weekly,monthly}] [--start-date YYYY-MM-DD] [--end-date YYYY-MM-DD]
```

### Example Commands

1. **Default Monthly Report** (Displays last 30 days of the database range with month-over-month comparisons):
   ```bash
   python scripts/report_cli.py
   ```
2. **Weekly Breakdown**:
   ```bash
   python scripts/report_cli.py --report weekly
   ```
3. **Custom Date Range with Daily breakdown**:
   ```bash
   python scripts/report_cli.py --report daily --start-date 2026-06-01 --end-date 2026-06-05
   ```

### Sample CLI Report Output

Stored in `output/sample_reports/`, here is an example execution:

```
======================================================================
             E-COMMERCE ORDER ANALYTICS SUMMARY REPORT
             Report Type: DAILY
             Current Period:  2026-06-01 to 2026-06-05
             Previous Period: 2026-05-27 to 2026-05-31
======================================================================

[KEY PERFORMANCE METRICS]
-----------------+----------------+-----------------+---------
Metric           | Current Period | Previous Period | % Change
-----------------+----------------+-----------------+---------
Total Orders     | 21             | 27              | -22.22% 
Net Revenue      | 68,851.22      | 84,994.10       | -18.99% 
Unique Customers | 20             | 26              | -23.08% 
-----------------+----------------+-----------------+---------

[TOP 3 PRODUCTS BY REVENUE]
-------------+----------+------------+--------
Product Name | Category | Units Sold | Revenue
-------------+----------+------------+--------
Sneakers 455 | Clothing | 13         | 6,614.95
Sneakers 888 | Clothing | 8          | 4,789.90
Rug 864      | Home     | 7          | 4,491.55
-------------+----------+------------+--------

[PERIODIC BREAKDOWN (DAILY)]
-----------+--------+----------+-----------------
Period     | Orders | Revenue  | Unique Customers
-----------+--------+----------+-----------------
2026-06-01 | 6      | 20,515.93 | 6               
2026-06-02 | 4      | 14,901.69 | 4               
2026-06-03 | 5      | 12,734.94 | 5               
2026-06-04 | 3      | 12,593.76 | 3               
2026-06-05 | 3      | 8,104.89 | 3               
-----------+--------+----------+-----------------
```
