\# **Retail Sales Analysis SQL Project**



This project contains SQL scripts analyzing retail sales data from a retail store.  

It includes creating views, performing data quality checks, analyzing sales trends, store revenue, customer segmentation, and understanding revenue drivers.  



The dataset includes \*\*customers, products, transactions, and stores\*\* information.



---



\## **Folder Structure**



Retail-Sales-Analysis/

├─ data/

│ └─ sales\_data.csv ← Raw data in CSV format (exported from Excel)

├─ sql/

│ └─ retail\_analysis.sql ← All SQL queries and views

├─ output/ ← Optional: exported results (CSV/screenshots)

└─ README.md ← Project description (this file)





---



\## **Data Description**



The `sales\_data.csv` file contains the following information:



\- \*\*Customers\*\*: customerID, firstname, gender, city  

\- \*\*Products\*\*: productID, productName, category, unitPrice, costPrice  

\- \*\*Transactions\*\*: transactionID, date, quantity, discount, paymentMethod, customerID, productID, storeID  

\- \*\*Stores\*\*: storeID, storeName  



> **The CSV file should be imported into MySQL Workbench for analysis.**



---



\## **SQL Workflow**



\### \*\*1. Import CSV into MySQL Workbench\*\*

1\. Open MySQL Workbench.  

2\. Create a new schema/database, e.g., `retail\_sales`.  

3\. Use the \*\*Table Data Import Wizard\*\* to import `sales\_data.csv` into a table.  

&nbsp;  - Map columns correctly.  

&nbsp;  - Verify data types (e.g., INT, VARCHAR, DATE).  



---



\### \*\***2. Run Analysis Queries**\*\*

All queries are in `sql/retail\_analysis.sql`. They include:



\#### **a) Create Views**

```sql

-- Combine customers, products, transactions, and stores

CREATE VIEW retail\_analysis AS

SELECT

&nbsp;   c.customerID, c.firstname, c.gender, c.city,

&nbsp;   p.productID, p.productName, p.category, p.unitPrice, p.costPrice,

&nbsp;   t.transactionID, STR\_TO\_DATE(t.date,'%d/%m/%y') AS date, t.quantity, t.discount, t.paymentMethod,

&nbsp;   s.storeID, s.storeName

FROM customers c

JOIN transactions t ON c.customerID = t.customerID

JOIN products p ON p.productID = t.productID

JOIN stores s ON s.storeID = t.storeID;



-- **Cleaned view removing rows with null dates**

CREATE VIEW retails\_analysis AS

SELECT \* FROM retail\_analysis

WHERE date IS NOT NULL;



**b) Data Quality Check**

WITH ini\_count AS (SELECT COUNT(\*) AS initial\_count FROM retail\_analysis),

&nbsp;    fin\_count AS (SELECT COUNT(\*) AS final\_count FROM retails\_analysis)

SELECT ((initial\_count - final\_count) / initial\_count) \* 100 AS lost\_percentage

FROM ini\_count, fin\_count;



**c) Monthly Sales Trend**

SELECT storeID, YEAR(date) AS year, MONTHNAME(date) AS months, SUM(quantity \* unitPrice) AS total\_revenue

FROM retails\_analysis

GROUP BY monthname(date), storeID, YEAR(date)

ORDER BY storeID, monthname(date);



**d) Store-wise Revenue**

SELECT storeID, storeName, COUNT(transactionID) AS count\_trans, SUM(quantity \* unitPrice) AS total\_revenue

FROM retails\_analysis

GROUP BY storeID, storeName

ORDER BY total\_revenue DESC;



**e) Revenue vs Volume by Category**

SELECT category, SUM(quantity \* unitPrice) AS total\_sale, SUM(quantity) AS sold\_count

FROM retails\_analysis

GROUP BY category

ORDER BY total\_sale DESC;



**f) Impact of Discounts**

SELECT category,

&nbsp;      (CASE WHEN discount > 0 THEN 'discounted' ELSE 'no discount' END) AS discount\_flag,

&nbsp;      SUM(quantity \* unitPrice) AS total\_revenue,

&nbsp;      SUM(quantity) AS sold\_count

FROM retails\_analysis

GROUP BY discount\_flag, category;



**g) Top 3 Customers per Store**

WITH ranks AS (

&nbsp;   SELECT storeID, storeName, customerID, firstname,

&nbsp;          SUM(quantity \* unitPrice) AS revenue,

&nbsp;          DENSE\_RANK() OVER(PARTITION BY storeID ORDER BY SUM(quantity \* unitPrice) DESC) AS ranking

&nbsp;   FROM retails\_analysis

&nbsp;   GROUP BY storeID, storeName, customerID, firstname

)

SELECT \*

FROM ranks

WHERE ranking < 4;



**h) Customer Segmentation**

WITH quartile AS (

&nbsp;   SELECT storeID, storeName, customerID, firstname,

&nbsp;          SUM(quantity \* unitPrice) AS purchased\_amt,

&nbsp;          NTILE(3) OVER(PARTITION BY storeID ORDER BY SUM(quantity \* unitPrice) DESC) AS cate\_flag

&nbsp;   FROM retails\_analysis

&nbsp;   GROUP BY storeID, storeName, customerID, firstname

)

SELECT storeID, storeName, customerID, firstname, purchased\_amt,

&nbsp;      (CASE WHEN cate\_flag = 1 THEN 'High Value'

&nbsp;            WHEN cate\_flag = 2 THEN 'Mid Value'

&nbsp;            ELSE 'Low Value' END) AS customer\_type

FROM quartile

ORDER BY storeID;



**i) Revenue from Single vs Repeat Customers**

WITH cust\_count AS (

&nbsp;   SELECT storeID, storeName, customerID, COUNT(transactionID) AS visited\_count,

&nbsp;          SUM(quantity \* unitPrice) AS total\_revenue,

&nbsp;          (CASE WHEN COUNT(transactionID) > 1 THEN 'repeat' ELSE 'single visit' END) AS cust\_type

&nbsp;   FROM retails\_analysis

&nbsp;   GROUP BY storeID, storeName, customerID

)

SELECT storeID, storeName,

&nbsp;      SUM(CASE WHEN cust\_type = 'repeat' THEN total\_revenue ELSE 0 END) AS repeat\_revenue,

&nbsp;      SUM(CASE WHEN cust\_type = 'single visit' THEN total\_revenue ELSE 0 END) AS single\_visit\_revenue

FROM cust\_count

GROUP BY storeID, storeName

ORDER BY storeID;



**How to Run the Project**

* Place sales\_data.csv in the data/ folder.
* Open MySQL Workbench → create a schema (e.g., retail\_sales).
* Import the CSV into MySQL Workbench as tables.
* Open sql/retail\_analysis.sql → run the queries.
* Export important query results to output/ as CSV or screenshots (optional).
* This ensures your repo is easy to run even for viewers who are new to SQL.



**Key Insights**

* Monthly and store-wise revenue trends.
* Top revenue-driving products and categories.
* Identification of high-value customers per store.
* Analysis of repeat vs single-visit customer revenue.
* Impact of discounts on revenue and volume.



Author

Santhiya K





