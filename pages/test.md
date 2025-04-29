---
title: Price Analysis Per Day
---

```sql unit_price_daily
-- Average unit price aggregated by day
SELECT 
  billing_date::date as date,
  AVG(unit_price) as avg_unit_price,
  COUNT(*) as transaction_count
FROM invoice
GROUP BY date
ORDER BY date
```

```sql crude_oil_daily
-- Average crude oil price aggregated by day
SELECT 
  date::date as date,
  AVG(dollars_per_barrel) as avg_barrel_price,
  COUNT(*) as price_records
FROM crudeoil
GROUP BY date
ORDER BY date
```

```sql joined_prices
-- Join the tables to identify missing data issues
WITH unit_price_daily AS (
  SELECT 
    billing_date::date as date,
    AVG(unit_price) as avg_unit_price,
    COUNT(*) as transaction_count
  FROM invoice
  GROUP BY date
),
crude_oil_daily AS (
  SELECT 
    date::date as date,
    AVG(dollars_per_barrel) as avg_barrel_price,
    COUNT(*) as price_records
  FROM crudeoil
  GROUP BY date
)
SELECT 
  COALESCE(u.date, c.date) as date,
  u.avg_unit_price,
  u.transaction_count,
  c.avg_barrel_price,
  c.price_records,
  CASE 
    WHEN u.date IS NULL THEN 'Missing unit price'
    WHEN c.date IS NULL THEN 'Missing barrel price'
    ELSE 'Complete data'
  END as data_status
FROM unit_price_daily u
FULL OUTER JOIN crude_oil_daily c ON u.date = c.date
ORDER BY date
```

<DataTable
  data={unit_price_daily}
  title="Average Unit Price Per Day"
  search=true
/>

<DataTable
  data={crude_oil_daily}
  title="Average Crude Oil Price Per Day"
  search=true
/>

<DataTable
  data={joined_prices}
  title="Joined Price Analysis"
  wrapTitles=true
  search=true
>
  <Column id="date" title="Date" />
  <Column id="avg_unit_price" title="Avg Unit Price" />
  <Column id="transaction_count" title="# of Transactions" />
  <Column id="avg_barrel_price" title="Avg Barrel Price" />
  <Column id="price_records" title="# of Price Records" />
  <Column id="data_status" title="Data Status" />
</DataTable>

### Analysis of Missing Data

The table above shows days where:
1. We have invoice unit prices but no crude oil prices
2. We have crude oil prices but no invoice data
3. We have complete data for both

By examining the "Data Status" column, we can identify the specific dates where crude oil prices are missing despite transaction data being available.
