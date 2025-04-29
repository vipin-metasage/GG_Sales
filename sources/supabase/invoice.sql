SELECT
  billing_date::date,
  REGEXP_REPLACE(INITCAP(LOWER(customer_name)), '[^a-zA-Z0-9]', '_', 'g') as customer_name,
  LOWER(REGEXP_REPLACE(sold_to_party, '^0+', '')) as customer_id,
  destination_country,
  REGEXP_REPLACE(INITCAP(LOWER(material_description)), '[^a-zA-Z0-9]', '_', 'g') as material_description,
  LOWER(REGEXP_REPLACE(material_number, '^0+', '')) as sku_id,
  actual_invoiced_quantity::numeric as actual_invoiced_quantity,
  billing_qty::numeric as billing_qty,
  net::numeric as net,
  doc_currency,
  sales_unit,
  billing_document,
  sales_item,
  incoterms_part1,
  material_group,
  unit_price
FROM cust_gg.invoice_data1
WHERE 
  material_group IN (
    '0199', '0214', '0401', '0402', '0405', '0407', '0408', '0409', '0410', '0450', '0499',
    '0501', '0502', '0503', '0504', '0505', '0506', '0507', '0508', '0509', '0510', '0511', '0599',
    '0603', '0604', '0605', '0606', '0608', '0609', '0610', '0611', '0612', '0613', '0699',
    '0701', '0702', '0703', '0704', '0705', '0706', '0707', '0708', '0709', '0710', '0711', '0712',
    '0713', '0714', '0715', '0716', '0799'
  )
  AND billing_document IS NOT NULL
  AND material_group IS NOT NULL
  AND billing_date::date >= '2015-01-01'
ORDER BY billing_date DESC;
