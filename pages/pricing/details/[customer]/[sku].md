```sql sku_summary
WITH filtered_data AS (
    SELECT
        customer_name AS customer,
        destination_country AS country,
        material_description AS sku,
        billing_date,
        billing_document,
        total_amount,
        billing_qty,
        sales_unit,
        doc_currency,
        unit_price,
        billing_type,
        incoterms_part1,
        payment_term_desc,
        material_group_desc
    FROM supabase.invoice
    WHERE billing_qty > 0
        AND customer_name LIKE '${inputs.customer.value}'
        AND material_description LIKE '${inputs.sku.value}'
        AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
        AND material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND payment_term_desc LIKE '${inputs.payment_term_desc.value}'
),
base_stats AS (
    SELECT
        COUNT(DISTINCT billing_document) AS total_orders,
        SUM(billing_qty) AS total_qty,
        ROUND(SUM(billing_qty) * 1.0 / NULLIF(COUNT(DISTINCT billing_document), 0), 2) AS avg_qty_per_order,
        MIN(billing_date) AS first_order,
        MAX(billing_date) AS last_order,
        SUM(total_amount) AS total_revenue
    FROM filtered_data
),
monthly_orders AS (
    SELECT
        DATE_TRUNC('month', billing_date) AS month,
        COUNT(DISTINCT billing_document) AS orders
    FROM filtered_data
    GROUP BY 1
),
monthly_stats AS (
    SELECT
        COUNT(*) AS months_active,
        ROUND(SUM(orders) * 1.0 / COUNT(*), 2) AS avg_orders_per_month
    FROM monthly_orders
),
yearly_revenue_split AS (
    SELECT
        EXTRACT(YEAR FROM billing_date) AS year,
        SUM(total_amount) AS revenue
    FROM filtered_data
    GROUP BY 1
),
latest_txn AS (
    SELECT
        unit_price,
        sales_unit,
        doc_currency
    FROM (
        SELECT
            unit_price,
            sales_unit,
            doc_currency,
            billing_date
        FROM filtered_data
        ORDER BY billing_date DESC
        LIMIT 1
    ) AS latest
),
currencies AS (
    SELECT
        STRING_AGG(DISTINCT doc_currency, ', ' ORDER BY doc_currency) AS currency_list,
    FROM filtered_data
),
final AS (
    SELECT
        bs.total_orders,
        bs.total_qty,
        bs.avg_qty_per_order,
        ms.avg_orders_per_month,
        bs.first_order,
        bs.last_order,
        bs.total_revenue,
        COALESCE(yr.revenue, 0) AS current_year_revenue,
        ROUND(COALESCE(yr.revenue, 0) * 100.0 / NULLIF(bs.total_revenue, 0), 2) AS current_year_share,
        lt.unit_price AS latest_unit_price,
        lt.sales_unit,
        c.currency_list AS currency,
    FROM base_stats bs
    CROSS JOIN monthly_stats ms
    LEFT JOIN yearly_revenue_split yr ON yr.year = EXTRACT(YEAR FROM CURRENT_DATE)
    CROSS JOIN latest_txn lt
    CROSS JOIN currencies c
)
SELECT * FROM final
```


```sql sku_price_oil_price
WITH invoice_data AS (
    SELECT
        i.billing_date AS date,
        AVG(i.unit_price) AS unit_price
    FROM Supabase.invoice i
    WHERE i.customer_name LIKE '${inputs.customer.value}'
        AND i.material_description LIKE '${inputs.sku.value}'
        AND i.billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
        AND i.material_group_desc LIKE '${inputs.material_group_desc.value}'
        AND i.payment_term_desc LIKE '${inputs.payment_term_desc.value}'
    GROUP BY i.billing_date
),
oil_data AS (
    SELECT 
        o.date,
        o.dollars_per_barrel,
        o.usd_inr
    FROM Supabase.crudeoil o
    WHERE EXISTS (
        SELECT 1 FROM invoice_data i
        WHERE i.date::date = o.date
    )
),
combined_data AS (
    SELECT
        i.date AS month,
        i.unit_price,
        o.dollars_per_barrel,
        o.usd_inr
    FROM invoice_data i
    JOIN oil_data o ON i.date::date = o.date
)
SELECT 
    month,
    'Unit Price' AS category,
    unit_price AS value
FROM combined_data

UNION ALL

SELECT 
    month,
    'Oil Price' AS category,
    dollars_per_barrel AS value
FROM combined_data

UNION ALL

SELECT 
    month,
    'USD-INR' AS category,
    usd_inr AS value
FROM combined_data
ORDER BY month, category
```

```sql revenue_and_quantity_over_time
SELECT
    DATE_TRUNC('month', billing_date) AS month,
    SUM(total_amount) AS revenue,
    SUM(billing_qty) AS quantity
FROM Supabase.invoice
WHERE customer_name LIKE '${inputs.customer.value}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    AND material_group_desc LIKE '${inputs.material_group_desc.value}'
    AND payment_term_desc LIKE '${inputs.payment_term_desc.value}'
GROUP BY month
ORDER BY month
```

```sql sku_price_changes_by_customer
SELECT
    billing_date,
    billing_document,
    material_description AS sku,
    total_amount,
    doc_currency AS currency,
    sales_unit,
    unit_price,
    billing_qty,
    material_group_desc,
    payment_term_desc
FROM Supabase.invoice
WHERE customer_name LIKE '${inputs.customer.value}'
    AND material_description LIKE '${inputs.sku.value}'
    AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    AND billing_qty > 0
    AND material_group_desc LIKE '${inputs.material_group_desc.value}'
    AND payment_term_desc LIKE '${inputs.payment_term_desc.value}'
ORDER BY billing_date DESC
```


```sql sku
  select
      material_description as sku
  from Supabase.invoice
  where customer_name = '${params.customer}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
  group by material_description
```

```sql customer
  select
      customer_name as customer
  from Supabase.invoice
  where customer_name = '${params.customer}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
  group by customer_name
```
```sql year
SELECT
  EXTRACT(YEAR FROM billing_date) AS year
FROM Supabase.invoice
WHERE customer_name LIKE '${params.customer}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
GROUP BY year
ORDER BY year DESC
```


<center>

<Dropdown data={year} name=year value=year defaultValue='%' title="Year" >
<DropdownOption value="%" valueLabel="All Years"/>
</Dropdown>

<Dropdown data={material_group_desc} name=material_group_desc value=material_group_desc defaultValue='%' title="Material Group">
  <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={payment_term_desc} name=payment_term_desc value=payment_term_desc defaultValue='%' title="Payment Term">
  <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

<Dropdown data={customer} name=customer value=customer defaultValue='{params.customer}' title="Customer">
</Dropdown>

<Dropdown data={sku} name=sku value=sku defaultValue='{params.sku}' title="SKU">
  <DropdownOption value="%" valueLabel="All"/>
</Dropdown>

</center>

### SKU Pricing Summary for {params.customer} - {params.sku}

<Grid cols=3>
    <BigValue 
        data={sku_summary} 
        value=total_orders
        title="Total Orders"
        fmt=num0
    />
    <BigValue 
        data={sku_summary} 
        value=total_qty
        title="Total Quantity Sold"
        fmt=num0
    />
    <BigValue 
        data={sku_summary} 
        value=avg_qty_per_order
        title="Avg Qty per Order"
        fmt=num0
    />
</Grid>

<Grid cols=3>
    <BigValue 
        data={sku_summary} 
        value=avg_orders_per_month
        title="Avg Monthly Orders"
        fmt=num0
    />
    <BigValue 
        data={sku_summary} 
        value=total_revenue
        title="Total Revenue"
        fmt=num0
    />
    <BigValue 
        data={sku_summary} 
        value=current_year_revenue
        title="Current Year Revenue"
        fmt=num0
    />
</Grid>

<Grid cols=3>
    <BigValue 
        data={sku_summary} 
        value=currency
        title="Currency"
    />
    <BigValue 
        data={sku_summary} 
        value=first_order
        title="First Order Date"
    />
    <BigValue 
        data={sku_summary} 
        value=last_order
        title="Last Order Date"
    />
</Grid>

<ButtonGroup name=matric display=buttons>
    <ButtonGroupItem valueLabel="Crude Oil Price" value="crude_oil_price" default />
    <ButtonGroupItem valueLabel="USD-INR" value="usd_inr" />
</ButtonGroup>

<Grid cols=2>
<!--
    <LineChart 
    
        data={sku_price_oil_price}
        x=month
        y=value
        yAxisTitle="Values"
        series=category
        title="Customer SKU Pricing Over Time"
        colorPalette={[
  '#E4572E', // fiery orange-red
   // bright teal
  '#FFC914', // vivid yellow
  '#17BEBB', // strong blue
  '#F45B69'  // punchy pink
]}
        independentYAxes={true}
    />
-->

<LineChart
data={price_comparison_table}
x=date
y=unit_price
y2="{inputs.matric}"
title="Customer SKU Pricing Over Time"
colorPalette={[
  '#E4572E', // fiery orange-red
  '#17BEBB', // bright teal
  '#FFC914', // vivid yellow
  '#2E86AB', // strong blue
  '#F45B69'  // punchy pink
]}
/>

    <LineChart 
        data={revenue_and_quantity_over_time}
        x=month
        y=revenue
        y2=quantity
        y2SeriesType=bar
        yAxisTitle="Revenue"
        y2AxisTitle="Quantity"
        title="Revenue & Quantity Over Time"
        ytitle="Revenue"
        y2title="Quantity"
        colorPalette={[
  '#E4572E', // fiery orange-red
  '#17BEBB', // bright teal
  '#FFC914', // vivid yellow
  '#2E86AB', // strong blue
  '#F45B69'  // punchy pink
]}
    />
</Grid>

### 📅 SKU Historical Pricing

<DataTable 
    data={sku_price_changes_by_customer} 
    rows=15 
    wrapTitles=true 
    wrapCells=true 
    sort="billing_date desc" 
    rowShading=true
    search=true
>
    <Column id=billing_date title="Date" align=left/>
    <Column id=billing_document fmt=0 align=center/>
    <Column id=sku title="Material" align=center/>
    <Column id=sales_unit title="Sales Unit" align=center/>
    <Column id=total_amount title="Total Amount" fmt=num1k align=center/>
    <Column id=currency title="Curr" align=center/>
    <Column id=unit_price title="Unit Price" fmt=0.00 align=center/>
    <Column id=billing_qty title="Qty" fmt=0 align=center/>
</DataTable>

```sql avg_qty_per_order_over_time
SELECT
    DATE_TRUNC('month', billing_date) AS month,
    SUM(billing_qty) / COUNT(DISTINCT billing_document) AS avg_qty_per_order
FROM Supabase.invoice
WHERE customer_name LIKE '${inputs.customer.value}'
    AND material_description LIKE '${inputs.sku.value}'
    AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    AND billing_qty > 0
GROUP BY month
ORDER BY month
```

<LineChart
data={avg_qty_per_order_over_time}
x=month
y=avg_qty_per_order
yAxisTitle="Avg Quantity"
title="Average Order Quantity Over Time"
colorPalette={[
'#17BEBB' // bright teal
]}
/>

```sql price_comparison_table
WITH invoice_data AS (
    SELECT
        i.billing_date AS date,
        i.doc_currency AS currency,
        AVG(i.unit_price) AS unit_price
    FROM Supabase.invoice i
    WHERE i.customer_name LIKE '${inputs.customer.value}'
        AND i.material_description LIKE '${inputs.sku.value}'
        AND i.billing_qty > 0
        AND EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    GROUP BY i.billing_date, i.doc_currency
),
oil_data AS (
    SELECT 
        o.date,
        o.dollars_per_barrel,
        o.usd_inr
    FROM Supabase.crudeoil o
    WHERE EXISTS (
        SELECT 1 FROM invoice_data i
        WHERE i.date::date = o.date
    )
)
SELECT
    i.date,
    i.currency,
    i.unit_price,
    o.dollars_per_barrel AS crude_oil_price,
    o.usd_inr
FROM invoice_data i
JOIN oil_data o ON i.date::date = o.date
ORDER BY i.date DESC, i.currency
```



<!--

<Grid >
<ButtonGroup name=oil_metric >
    <ButtonGroupItem valueLabel="Oil Price" value="dollars_per_barrel" default />
    <ButtonGroupItem valueLabel="Dollar Price" value="usd_inr" />
</ButtonGroup>
</Grid>

```sql price_comparison_table_2
    WITH invoice_data AS (
        select
            billing_date AS date,
            doc_currency AS currency,
            unit_price
        from supabase.invoice
        where customer_name = '${inputs.customer.value}'
        and material_description = '${inputs.sku.value}'
        and billing_qty > 0
        and EXTRACT(YEAR FROM billing_date) like '${inputs.year.value}'
    )
    SELECT
        i.date,
        i.currency,
        i.unit_price,
        c.dollars_per_barrel,
        c.usd_inr
    FROM invoice_data i
    LEFT JOIN supabase.crudeoil c ON i.date::date = c.date
    group by i.date, i.currency, i.unit_price, c.dollars_per_barrel, c.usd_inr
    ORDER BY i.date
```

<LineChart
data={price_comparison_table_2}
x=date
y=unit_price
y2="{inputs.oil_metric}"
series=currency
/>
-->

```sql material_group_desc
SELECT
    material_group_desc as material_group_desc
FROM Supabase.invoice
WHERE customer_name = '${params.customer}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
    AND material_group_desc LIKE '${inputs.material_group_desc.value}'
GROUP BY material_group_desc
ORDER BY material_group_desc
```

```sql payment_term_desc
SELECT
    payment_term_desc as payment_term_desc
FROM Supabase.invoice
WHERE customer_name = '${params.customer}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
    AND EXTRACT(YEAR FROM billing_date) LIKE '${inputs.year.value}'
    AND material_group_desc LIKE '${inputs.material_group_desc.value}'
    AND payment_term_desc LIKE '${inputs.payment_term_desc.value}'
GROUP BY payment_term_desc
ORDER BY payment_term_desc
```
