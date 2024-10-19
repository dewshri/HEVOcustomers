-- tests/test_customer_lifetime_value_positive.sql

SELECT *
FROM {{ ref('customershevo') }}
WHERE customer_lifetime_value < 0