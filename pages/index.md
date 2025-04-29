---
title: Invoice Insights Dashboard
---

```sql customer
SELECT
    customer_name as customer
FROM Supabase.invoice
GROUP BY customer_name
ORDER BY customer_name
```

```sql year
SELECT
    EXTRACT(YEAR FROM billing_date) as year 
FROM Supabase.invoice
GROUP BY year
ORDER BY year
```

```sql country
SELECT
    destination_country as country
FROM Supabase.invoice
GROUP BY destination_country
ORDER BY country
```

```sql currency
SELECT
    doc_currency as currency
FROM Supabase.invoice
GROUP BY doc_currency
ORDER BY currency
```

```sql sales_unit
SELECT
    sales_unit as sales_unit
FROM Supabase.invoice
GROUP BY sales_unit
ORDER BY sales_unit
```

```sql sku
SELECT
    material_description as sku
FROM Supabase.invoice
GROUP BY material_description
ORDER BY sku
```

<center>
<Dropdown data={customer} name=customer value=customer title="Customer">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={year} name=year value=year title="Year" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={country} name=country value=country title="Country" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={currency} name=currency value=currency title="Currency" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={sales_unit} name=sales_unit value=sales_unit title="Sales Unit" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={sku} name=sku value=sku title="SKU" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>
</center>

```sql total_cust_served
SELECT
    DATE_TRUNC('month', billing_date) AS month,
    COUNT(DISTINCT customer_name) AS unique_customers
FROM invoice
WHERE EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    AND customer_name LIKE '${inputs.customer.value}'
    AND destination_country LIKE '${inputs.country.value}'
    AND doc_currency LIKE '${inputs.currency.value}'
    AND sales_unit LIKE '${inputs.sales_unit.value}'
    AND material_description LIKE '${inputs.sku.value}'  
GROUP BY month
ORDER BY month
```

```sql sku_count_served
SELECT
    DATE_TRUNC('year', billing_date) AS year,
    COUNT(DISTINCT sku_id) AS unique_skus
FROM invoice
WHERE EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    AND customer_name LIKE '${inputs.customer.value}'
    AND destination_country LIKE '${inputs.country.value}'
    AND doc_currency LIKE '${inputs.currency.value}'
    AND sales_unit LIKE '${inputs.sales_unit.value}'
    AND material_description LIKE '${inputs.sku.value}'
GROUP BY year
ORDER BY year
```

<Grid cols=2>
<LineChart 
    data={total_cust_served}
    x=month
    y=unique_customers
    title="Total Customers Served Over Time"
/>

<LineChart 
    data={sku_count_served}
    x=year
    y=unique_skus
    title="SKU Count Served Over Time"
/>
</Grid>

```sql sku_price_changes
WITH base AS (
    SELECT
        customer_name AS customer,
        destination_country AS country,
        material_description AS sku,
        billing_date,
        billing_document,
        net,
        billing_qty,
        sales_unit,
        doc_currency AS currency,
        EXTRACT(YEAR FROM billing_date) AS billing_year,
        unit_price
    FROM invoice
),  
year_ref AS (
    SELECT MAX(EXTRACT(YEAR FROM billing_date)) AS latest_year
    FROM invoice
),
aggregated AS (
    SELECT
        customer,
        country,
        sku,
        MAX(billing_date) AS latest_invoice_date,
        ANY_VALUE(sales_unit) AS sales_unit,
        ANY_VALUE(currency) AS currency,
        ANY_VALUE(unit_price) AS current_unit_price,
        (
            SELECT b2.unit_price
            FROM base b2
            WHERE b2.customer = base.customer
                AND b2.sku = base.sku
                AND b2.billing_date < MAX(base.billing_date)
                AND b2.unit_price <> ANY_VALUE(base.unit_price)
                AND b2.unit_price > 0
            ORDER BY b2.billing_date DESC
            LIMIT 1
        ) AS last_unit_price,
        (
            SELECT billing_date
            FROM base b2
            WHERE b2.customer = base.customer
                AND b2.sku = base.sku
                AND b2.billing_date < MAX(base.billing_date)
                AND b2.unit_price <> ANY_VALUE(base.unit_price)
                AND b2.unit_price > 0
            ORDER BY b2.billing_date DESC
            LIMIT 1
        ) AS last_price_change_date,
        (
            SELECT
                EXTRACT(YEAR FROM MAX(base.billing_date))
                - EXTRACT(YEAR FROM b2.billing_date)
            FROM base b2
            WHERE b2.customer = base.customer
                AND b2.sku = base.sku
                AND b2.billing_date < MAX(base.billing_date)
                AND b2.unit_price <> ANY_VALUE(base.unit_price)
                AND b2.unit_price > 0
            ORDER BY b2.billing_date DESC
            LIMIT 1
        ) AS years_since_price_change,
        COUNT(DISTINCT billing_document) AS orders,
        SUM(billing_qty) AS sku_quantity,
        ROUND(
            SUM(billing_qty) * 1.0
            / NULLIF(COUNT(DISTINCT billing_document), 0)
        , 2) AS avg_sku_per_order,
        SUM(
            CASE
                WHEN billing_year = (SELECT latest_year FROM year_ref)
                THEN net ELSE 0
            END
        ) AS revenue_1y,
        SUM(
            CASE
                WHEN billing_year = (SELECT latest_year FROM year_ref) - 2
                THEN net ELSE 0
            END
        ) AS revenue_3y
    FROM base
    WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer LIKE '${inputs.customer.value}'
        AND country LIKE '${inputs.country.value}'
        AND currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND sku LIKE '${inputs.sku.value}'
    GROUP BY customer, country, sku
)
SELECT
    customer,
    country,
    sku,
    latest_invoice_date,
    sales_unit,
    currency,
    current_unit_price,
    last_unit_price,
    '/pricing/details/' || customer || '/' || sku AS detail_link,
    NULLIF(
        last_price_change_date::DATE,
        '1970-01-01'::DATE
    )::TEXT AS last_price_change_date,
    years_since_price_change,
    orders,
    sku_quantity,
    avg_sku_per_order,
    revenue_1y,
    revenue_3y
FROM aggregated
ORDER BY revenue_1y DESC
```

<DataTable 
    data={sku_price_changes}
    title="Customer SKU Pricing Overview"
    link=detail_link
    rows=15
    wrapTitles=true
>
    <Column id="customer" title="Customer" align="left" />
    <Column id="country" title="Country" align="center" />
    <Column id="sku" title="Material Name" align="left" />
    <Column id="sales_unit" title="Unit" align="center" />
    <Column id="currency" title="Currency" align="center" />
    <Column id="latest_invoice_date" title="Latest Invoice" align="center" colGroup="Timing"/>
    <Column id="last_price_change_date" title="Last Price Change" align="center" colGroup="Timing"/>
    <Column id="years_since_price_change" title="Yrs Since Change" align="center" colGroup="Timing"/>
    <Column id="current_unit_price" title="Current Price" align="center" colGroup="Pricing"/>
    <Column id="last_unit_price" title="Prev. Price" align="center" colGroup="Pricing"/>
    <Column id="orders" title="Orders" align="center" colGroup="Volume"/>
    <Column id="avg_sku_per_order" title="Avg/Order" align="center" colGroup="Volume"/>
    <Column id="sku_quantity" title="SKU Qty Sold" fmt='num1k' align="center" colGroup="Volume"/>
    <Column id="revenue_1y" title="Revenue (1Y)" fmt="num1k" align="center" colGroup="Revenue"/>
    <Column id="revenue_3y" title="Revenue (3Y)" fmt="num1k" align="center" colGroup="Revenue"/>
</DataTable>


