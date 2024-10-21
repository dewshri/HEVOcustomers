# HEVOcustomers
# PostgreSQL to Snowflake Pipeline using Hevo for data ingestion and dbt for transformation

## Overview
This project demonstrates how to set up a data pipeline using PostgreSQL as the source and Snowflake as the destination, using Hevo for data ingestion and dbt for transformation.

## Prerequisites

1. **Access to GitHub**
2. **Database knowledge (SQL)**
3. **dbt knowledge**
4. **Free trial of Snowflake**: 
5. **Free trial of Hevo**: 
6. **Self-hosted PostgreSQL instance**: Ensure PostgreSQL is running in a Docker container.
7. **Networking knowledge**: For connecting to your local database from Hevo.


## Steps to Build the Project

### 1. Install PostgreSQL database (Docker-based image)
- Run a PostgreSQL instance using Docker:
  ```bash
  docker run --name your_postgres_container -e POSTGRES_PASSWORD=your_password -d -p 5432:5432 postgres



### **2. Access and Connect to PostgreSQL**
- Connect to your PostgreSQL instance. You can use any SQL client (like pgAdmin or by using DBeaver) or the psql command-line tool. If using psql run:
  ```bash
  docker exec -it your_postgres_container psql -U postgres


### **3. Create Tables**
- Once connected, execute the following SQL commands to create the required tables:

  sql:
  ```bash
  CREATE TABLE raw_orders (
    id SERIAL PRIMARY KEY,
    user_id INT,
    order_date DATE,
    status VARCHAR(100)
   );

  CREATE TABLE raw_customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100)
  );

  CREATE TABLE raw_payments (
    id SERIAL PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(100),
    amount DECIMAL
  );



### **4.Copy and Load CSV Data**
- Run below in Docker to copy file from your local path to Docker container.Make sure to adjust the path to where your CSV files are located:
  ```bash
  docker cp localpathtofile your_postgres_container:/tmp/orders.csv
  docker cp localpathtofile your_postgres_container:/tmp/customers.csv
  docker cp localpathtofile your_postgres_container:/tmp/payments.csv


- You can load above CSV files into tables created in PGSQL in step 3. For example:
  ```bash
  COPY raw_orders  FROM '/tmp/orders.csv' DELIMITER ',' CSV HEADER;
  COPY raw_customers  FROM '/tmp/customers.csv' DELIMITER ',' CSV HEADER;
  COPY raw_payments  FROM '/tmp/payments.csv' DELIMITER ',' CSV HEADER;



### **5. Sign Up for Snowflake**
Visit the Snowflake sign-up page and create a free trial account. Note down your account credentials for later use.



### **6. Sign Up for Hevo**
Create a free trial account at Hevo. After signing up, familiarize yourself with the Hevo interface.



### **7. Set Up Hevo Pipeline**
Log in to your Hevo account and click on Create Pipeline.
For Source, select PostgreSQL and enter your database connection details (host, port, user, password).
For Destination, choose Snowflake and provide the necessary credentials.
Make sure to select Logical Replication as the ingestion mode during the setup.



### **8. Install dbt or use dbt cloud**
- If you haven’t installed dbt, do so using pip:
  ```bash
   pip install dbt-snowflake



### **9. Initialize Your dbt Project**
- Create a new dbt project:

  ```bash
     dbt init your_project_name
  
- Navigate to the project directory:
   ```bash
      cd your_project_name

### **10. Create dbt Model**
- In the models directory, create a new file called customershevo.sql and add the following SQL code and save:

  ```bash
     WITH orders AS (
     SELECT 
        USER_ID AS customer_id,
        MIN(ORDER_DATE) AS first_order,
        MAX(ORDER_DATE) AS most_recent_order,
        COUNT(ID) AS number_of_orders
        FROM SNOWFLAKE_DATABASE.SCHEMA.POSTGRES_CUSTOMERS_RAW_ORDERS
     GROUP BY USER_ID
     ),
     payments AS (
        SELECT 
            o.USER_ID AS customer_id,
            SUM(p.AMOUNT) AS customer_lifetime_value
        FROM SNOWFLAKE_DATABASE.SCHEMA.POSTGRES_CUSTOMERS_RAW_PAYMENTS p
        JOIN SNOWFLAKE_DATABASE.SCHEMA.POSTGRES_CUSTOMERS_RAW_ORDERS  o
        ON p.ORDER_ID = o.ID
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
      FROM SNOWFLAKE_DATABASE.SCHEMA.POSTGRES_CUSTOMERS_RAW_CUSTOMERS  c
      LEFT JOIN orders o ON c.ID = o.customer_id
      LEFT JOIN payments p ON c.ID = p.customer_id



### **11. Add dbt Tests**
- In your models directory, create a schema.yml file with the following content to validate your model:

  ```bash
      version: 2

      models:
      - name: customershevo
        description: "This model aggregates customer data, including order and payment information."
        columns:
          - name: customer_id
            description: "Unique identifier for each customer."
            tests:
              - unique
              - not_null
          - name: first_name
            description: "First name of the customer."
            tests:
              - not_null
          - name: last_name
            description: "Last name of the customer."
        tests:
          - not_null
      - name: first_order
        description: "Date of the first order."
      - name: most_recent_order
        description: "Date of the most recent order."
      - name: number_of_orders
        description: "Total number of orders made by the customer."
        tests:
          - not_null
          - accepted_values:
              values: [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]  
      - name: customer_lifetime_value
        description: "Total sum of payments made by the customer."
        tests:
          - not_null
          - customer_lifetime_value_positive:
              column_name: "customer_lifetime_value >= 0"

- In your macros directory, create a test_customer_lifetime_value_positive.sql file with the following content to validate your model:
   ```bash
      {% macro test_customer_lifetime_value_positive(model, column_name) %}
      SELECT *
      FROM {{ model }}
      WHERE {{ column_name }} < 0
      LIMIT 1
      {% endmacro %}
   


### **12. Run dbt**
- Execute the following commands to run your dbt models and tests:

  ```bash
      dbt run
      dbt test

### **13. Push to GitHub or commit the changes in dbt cloud by configuring the repository**
- Create a new repository on GitHub.
  Initialize git in your project directory and push your code:
  ```bash
      git init
      git add .
      git commit -m "Initial commit"
      git remote add origin <your-repo-url>
      git push -u origin master
      (Replace <your-repo-url> with the actual URL of your GitHub repository).
