{% macro test_customer_lifetime_value_positive(model, column_name) %}
SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 0
LIMIT 1
{% endmacro %}
