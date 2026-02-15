use retail_sales;
create view retail_analysis as  (select
 c.customerID,c.firstname,c.gender,c.city,
 p.productid,p.productname,p.category,p.unitprice,p.costprice,
 t.transactionid, str_to_date(t.date,'%d/%m/%y')as date,t.quantity,t.discount,t.paymentmethod,
 s.storeid,s.storename 
 from customers c join transactions t on c.customerid=t.customerid 
 join products p on p.productid=t.productid 
 join stores s on s.storeid=t.storeid );
 create view retails_analysis as (select * from retail_fin where date is not null);
 /*Data Quality Insight*/
 select* from retails_sali;
with ini_count as (select count(*) as initial_count from retail_analysis),
fin_count as(select count(*) as final_count from retails_analysis)
select ((initial_count-final_count)/initial_count)*100 as lost_percentage from ini_count,fin_count;
 /*Monthly  sales trend*/
 select storeid,year(date) as year,monthname(date) as months,sum(quantity*unitprice) as total_revenue from retails_analysis group by monthname(date),storeid,year(date) order by storeid,monthname(date);
 /*store wise revenue*/
 select storeid,storename,count(transactionid) as count_trans,sum(quantity*unitprice) as total_revenue from retails_analysis group by storeid,storename order by total_revenue desc;
/*Which categories drive revenue vs volume?*/
select category,sum(quantity*unitprice) as total_sale,sum(quantity) as sold_count from retails_analysis group by category order by total_sale;
/*Do discounts drive revenue for each product?*/
select category,(case when discount>0 then 'discounted' else 'no discount' end) as discount_flag,sum(quantity*unitprice) as total_revenue,sum(quantity) as sold_count from retails_analysis group by discount_flag,category;
/*top 3 revenue making customers from each store*/
with ranks as (select storeid,storename,customerid,firstname,sum(quantity*unitprice) as revenue,dense_rank() over(partition by storeid order by sum(quantity*unitprice) desc) as ranking from retails_analysis group by storename,firstname,storeid,customerid)
select * from ranks where ranking<4;
/*segmenting the customers*/
with quartile as (select storeid,storename,customerid,firstname,sum(quantity*unitprice) as purchased_amt,ntile(3) over(partition by storeid order by sum(quantity*unitprice) desc) as cate_flag from retails_analysis group by storeid,storename,customerid,firstname)
select storeid,storename,customerid,firstname,purchased_amt,(case when cate_flag=1 then 'High Value' when cate_flag=2 then 'Mid Value' else 'Low Value' end) as customer_type from quartile order by storeid;
/*revenue driven by sing time or repeating customers*/
with cust_count as(select storeid,storename,customerid,count(transactionid) as visited_count,sum(quantity*unitprice) as total_revenue,(case when count(transactionid)>1 then 'repeat' else 'single visit' end)as cust_type from retails_analysis group by storeid,storename,customerid order by storeid asc,total_revenue desc)
select storeid,storename,sum(case when cust_type='repeat' then total_revenue else 0 end) as repeat_revenue,sum(case when cust_type='single visit' then total_revenue else 0 end) as single_visit_revenue from cust_count group by storeid,storename order by storeid;
/**/



