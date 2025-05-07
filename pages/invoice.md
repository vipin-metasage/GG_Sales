---
title: Invoice Insights Dashboard
---

```sql material_group_desc
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    material_group_desc as material_group_desc
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY material_group_desc
ORDER BY material_group_desc
```

```sql customer
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    customer_name as customer
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)   
GROUP BY customer_name
ORDER BY customer_name
```

```sql incoterms
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    incoterms_part1 as incoterms
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY incoterms_part1
ORDER BY incoterms_part1
```

```sql year
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    EXTRACT(YEAR FROM billing_date) as year 
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY year
ORDER BY year
```

```sql country
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    destination_country as country
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY destination_country
ORDER BY country
```


```sql currency
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    doc_currency as currency
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY doc_currency
ORDER BY currency
```

```sql sales_unit
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    sales_unit as sales_unit
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY sales_unit
ORDER BY sales_unit
```

```sql sku
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    material_description as sku
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY material_description
ORDER BY sku
```

```sql sku_id
WITH max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    sku_id as sku_id
FROM Supabase.invoice
WHERE billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
        AND customer_name LIKE '${inputs.customer.value}'
        AND destination_country LIKE '${inputs.country.value}'
        AND doc_currency LIKE '${inputs.currency.value}'
        AND sales_unit LIKE '${inputs.sales_unit.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND billing_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
GROUP BY sku_id
ORDER BY sku_id
```

<center>

<Dropdown data={year} name=year value=year title="Year" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={country} name=country value=country title="Country" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={currency} name=currency value=currency title="Currency" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={incoterms} name=incoterms value=incoterms title="Ship Type" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>


<Dropdown data={sales_unit} name=sales_unit value=sales_unit title="Sales Unit" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={sku} name=sku value=sku title="SKU" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={sku_id} name=sku_id value=sku_id title="SKU ID" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={material_group_desc} name=material_group_desc value=material_group_desc title="Material Group" defaultValue="%">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={customer} name=customer value=customer title="Customer">
    <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

</center>  


```sql sku_price_changes
WITH base AS (
    SELECT
        customer_name AS customer,
        destination_country AS country,
        material_description AS sku,
        sku_id,
        billing_date,
        billing_document,
        total_amount,
        billing_qty,
        sales_unit,
        doc_currency AS currency,
        EXTRACT(YEAR FROM billing_date) AS billing_year,
        unit_price,
        billing_type,
        incoterms_part1,
        material_group_desc
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
        sku_id,
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
                THEN total_amount ELSE 0
            END
        ) AS revenue_1y,
        SUM(
            CASE
                WHEN billing_year >= (SELECT latest_year FROM year_ref) - 2
                AND billing_year <= (SELECT latest_year FROM year_ref)
                THEN total_amount ELSE 0
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
        AND sku_id LIKE '${inputs.sku_id.value}'
        AND incoterms_part1 LIKE '${inputs.incoterms.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
    GROUP BY customer, country, sku, sku_id
),
max_date AS (
    SELECT MAX(billing_date) AS max_billing_date
    FROM invoice
)
SELECT
    customer,
    country,
    sku,
    sku_id,
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
WHERE latest_invoice_date >= (SELECT max_billing_date - INTERVAL '3 months' FROM max_date)
ORDER BY revenue_1y DESC
```



<DataTable 
    data={sku_price_changes}
    title="Customer SKU Pricing Overview"
    link=detail_link
    rows=22
    wrapTitles=true
    search=true
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
    <Column id="last_unit_price" title="Prev. Price" align="center" fmt="0.00" colGroup="Pricing"/>
    <Column id="orders" title="Total Orders" align="center" colGroup="Volume"/>
    <Column id="avg_sku_per_order" title="Avg Order Qty" align="center" colGroup="Volume"/>
    <Column id="sku_quantity" title="SKU Qty Sold" fmt='num1k' align="center" colGroup="Volume"/>
    <Column id="revenue_1y" title="Revenue (1Y)" fmt="num1k" align="center" colGroup="Revenue"/>
    <Column id="revenue_3y" title="Revenue (3Y)" fmt="num1k" align="center" colGroup="Revenue"/>
</DataTable>


