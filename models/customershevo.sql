WITH orders AS (
    SELECT 
        USER_ID AS customer_id,
        MIN(ORDER_DATE) AS first_order,
        MAX(ORDER_DATE) AS most_recent_order,
        COUNT(ID) AS number_of_orders
    FROM PC_HEVODATA_DB.PUBLIC.POSTGRES_CUSTOMERS_RAW_ORDERS
    GROUP BY USER_ID
),
payments AS (
    SELECT 
        o.USER_ID AS customer_id,
        SUM(p.AMOUNT) AS customer_lifetime_value
    FROM PC_HEVODATA_DB.PUBLIC.POSTGRES_CUSTOMERS_RAW_PAYMENTS p
    JOIN PC_HEVODATA_DB.PUBLIC.POSTGRES_CUSTOMERS_RAW_ORDERS  o ON p.ORDER_ID = o.ID
    GROUP BY o.USER_ID
)

SELECT 
    c.ID AS customer_id,
    c.FIRST_NAME,
    c.LAST_NAME,
    o.first_order,
    o.most_recent_order,
    COALESCE(o.number_of_orders,0) AS number_of_orders,
    COALESCE(p.customer_lifetime_value, 0) AS customer_lifetime_value
FROM PC_HEVODATA_DB.PUBLIC.POSTGRES_CUSTOMERS_RAW_CUSTOMERS  c
LEFT JOIN orders o ON c.ID = o.customer_id
LEFT JOIN payments p ON c.ID = p.customer_id
