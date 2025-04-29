```sql sku_summary
WITH filtered_data AS (
    SELECT
        customer_name AS customer,
        destination_country AS country,
        material_description AS sku,
        billing_date,
        billing_document,
        net,
        billing_qty,
        sales_unit,
        doc_currency,
        unit_price
    FROM supabase.invoice
    WHERE billing_qty > 0
        AND customer_name LIKE '${inputs.customer.value}'
        AND material_description LIKE '${inputs.sku.value}'
),
base_stats AS (
    SELECT
        COUNT(DISTINCT billing_document) AS total_orders,
        SUM(billing_qty) AS total_qty,
        ROUND(SUM(billing_qty) * 1.0 / NULLIF(COUNT(DISTINCT billing_document), 0), 2) AS avg_qty_per_order,
        MIN(billing_date) AS first_order,
        MAX(billing_date) AS last_order,
        SUM(net) AS total_revenue
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
        SUM(net) AS revenue
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
        lt.doc_currency AS currency
    FROM base_stats bs
    CROSS JOIN monthly_stats ms
    LEFT JOIN yearly_revenue_split yr ON yr.year = EXTRACT(YEAR FROM CURRENT_DATE)
    CROSS JOIN latest_txn lt
)
SELECT * FROM final
```



```sql sku_price_oil_price
SELECT
    i.billing_date,
    i.unit_price AS avg_unit_price,
    i.billing_qty,
    o.dollars_per_barrel
FROM Supabase.invoice i
LEFT JOIN Supabase.crudeoil o ON o.date = i.billing_date::date
WHERE i.customer_name LIKE '${inputs.customer.value}'
    AND i.material_description LIKE '${inputs.sku.value}'
    AND i.billing_qty > 0
ORDER BY i.billing_date
```

```sql revenue_and_orders_over_time
SELECT
    DATE_TRUNC('month', billing_date) AS month,
    SUM(net) AS revenue,
    COUNT(DISTINCT billing_document) AS orders
FROM Supabase.invoice
WHERE customer_name LIKE '${inputs.customer.value}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
GROUP BY month
ORDER BY month
```

```sql sku_price_changes_by_customer
SELECT
    billing_date,
    billing_document,
    material_description AS sku,
    net,
    doc_currency AS currency,
    unit_price,
    billing_qty
FROM Supabase.invoice
WHERE customer_name LIKE '${inputs.customer.value}'
    AND material_description LIKE '${inputs.sku.value}'
    AND billing_qty > 0
ORDER BY billing_date DESC
```
```sql sku
  select
      material_description as sku
  from Supabase.invoice
  where customer_name = '${params.customer}'
  group by material_description
```
```sql customer
  select
      customer_name as customer
  from Supabase.invoice
  where customer_name = '${params.customer}'
  group by customer_name
```

<Grid cols=2>

<Dropdown data={sku} name=sku value=sku defaultValue='{params.sku}' title="SKU">
  <DropdownOption value="%" valueLabel="All"/>
</Dropdown>


<Dropdown data={customer} name=customer value=customer defaultValue='{params.customer}' title="Customer">
</Dropdown>

</Grid>

### SKU Pricing Summary for {params.customer} - {params.sku}

<Grid cols=3>
    <BigValue 
        data={sku_summary} 
        value=total_orders
        title="Total Orders"
    />
    <BigValue 
        data={sku_summary} 
        value=total_qty
        title="Total Quantity Sold"
    />
    <BigValue 
        data={sku_summary} 
        value=avg_qty_per_order
        title="Avg Qty per Order"
    />
</Grid>

<Grid cols=3>
    <BigValue 
        data={sku_summary} 
        value=avg_orders_per_month
        title="Avg Monthly Orders"
    />
    <BigValue 
        data={sku_summary} 
        value=total_revenue
        title="Total Revenue"
        fmt=num0k
    />
    <BigValue 
        data={sku_summary} 
        value=current_year_revenue
        title="Current Year Revenue"
        fmt=num0k
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

<Grid cols=2>
    <LineChart 
        data={sku_price_oil_price}
        x=billing_date
        y=avg_unit_price
        y2=dollars_per_barrel
        yAxisTitle="Unit Price"
        y2AxisTitle="Oil Price"
        color=billing_qty
        title="Customer SKU Pricing Over Time"
        colorPalette={[
            '#1E90FF',  // Blue
            '#654321',  // Dark Brown
        ]}
    />

    <LineChart 
        data={revenue_and_orders_over_time}
        x=month
        y=revenue
        y2=orders
        y2SeriesType=bar
        yAxisTitle="Revenue"
        y2AxisTitle="Orders"
        title="Revenue & Orders Over Time"
        ytitle="Revenue"
        y2title="Orders"
        colorPalette={[
            '#01579B',
            '#e88a87',
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
>
    <Column id=billing_date title="Date" align=left/>
    <Column id=billing_document fmt=0 align=center/>
    <Column id=sku title="Material" align=center/>
    <Column id=net title="Net" fmt=num1k align=center/>
    <Column id=currency title="Curr" align=center/>
    <Column id=unit_price title="Unit Price" fmt=0.0 align=center/>
    <Column id=billing_qty title="Qty" fmt=0 align=center/>
</DataTable>

```sql sku_share_over_time
SELECT
  DATE_TRUNC('month', billing_date) AS month,
  SUM(CASE 
      WHEN sku_id LIKE '${inputs.sku.value}'
      THEN net::numeric 
      ELSE 0 
  END) AS sku_revenue,
  SUM(net::numeric) AS total_revenue,
  CASE 
    WHEN SUM(net::numeric) = 0 THEN 0
    ELSE 
      SUM(CASE 
          WHEN sku_id LIKE '${inputs.sku.value}'
          THEN net::numeric 
          ELSE 0 
      END) / SUM(net::numeric)
  END AS sku_share_raw
FROM supabase.invoice
WHERE 
  billing_qty > 0
  AND customer_id LIKE '${inputs.customer.value}'
  AND net ~ '^[0-9.]+$'
GROUP BY 1
ORDER BY 1;
```


