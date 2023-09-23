Use pizza_runner;
-- A. Pizza Metrics

/* How many pizzas were ordered? */
select
    count(pizza_id) as count_pizza
from customer_orders;

/* How many unique customer orders were made? */
select 
   count(distinct order_id) as number_of_customers
from customer_orders;

/* How many successful orders were delivered by each runner? */
select
	runner_id,
    count(order_id) as count_order
from runner_orders
where not pickup_time = 'null'
group by 1;

/* How many of each type of pizza was delivered? */
select
	pizza_name,
	count(customer_orders.pizza_id) as pizza_delivered
from pizza_names
inner join customer_orders
	on customer_orders.pizza_id = pizza_names.pizza_id
inner join runner_orders
	on customer_orders.order_id = runner_orders.order_id
where not pickup_time = 'null'
group by pizza_name;

/* How many Vegetarian and Meatlovers were ordered by each customer? */
select
	customer_id,
    sum(case when pizza_id = 1 then 1 else 0 end) as meatlovers,
    sum(case when pizza_id = 2 then 1 else 0 end) as meatlovers
from customer_orders
group by customer_id;

/* What was the maximum number of pizzas delivered in a single order? */
create temporary table max_pizza
select
	customer_orders.order_id,
    count(customer_orders.pizza_id) as pizza_delivered
from runner_orders
	inner join customer_orders
		on runner_orders.order_id = customer_orders.order_id
where not pickup_time = 'null'
group by 1;

select 
max(pizza_delivered) as max_pizza_delivere
from max_pizza;

/* For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */
select
	customer_id,
    sum(case when exclusions is not null and exclusions <> 'null' and length(exclusions) > 0 
		or extras is not null and extras <> 'null' and length(extras) > 0 then 1 else 0 end) as changes, 
	sum(case when exclusions is not null and exclusions <> 'null' and length(exclusions) > 0 
		or extras is not null and extras <> 'null' and length(extras) > 0 then 0 else 1 end) as no_changes
from customer_orders
	left join runner_orders
		on customer_orders.order_id = runner_orders.order_id
where distance <> 'null'
group by 1;

/* How many pizzas were delivered that had both exclusions and extras? */
select
    sum(case
			when (exclusions is not null and exclusions <> 'null' and length(exclusions) > 0)
			and (extras is not null and extras <> 'null' and length(extras) > 0)
            then 1
            else 0
            end) as pizza_delivered_with_both_changes
from customer_orders
	left join runner_orders
		on customer_orders.order_id = runner_orders.order_id
where distance <> 'null';

/* What was the total volume of pizzas ordered for each hour of the day? */
select 
    hour(order_time) as hours,
    count(hour(order_time)) as pizza_count
from customer_orders
group by 1
order by hours;

/* What was the volume of orders for each day of the week? */
select
    dayname(order_time)as day_of_week,
    count(pizza_id) as pizzas
from customer_orders
group by day_of_week