
-- Consulta Recursiva

WITH RECURSIVE subordinates AS (
	SELECT employee_id, manager_id,	full_name
	FROM employees
	WHERE manager_id is null

	UNION

	SELECT	e.employee_id,	e.manager_id, e.full_name
	FROM employees e
		INNER JOIN subordinates s ON s.employee_id = e.manager_id
)
SELECT *
FROM subordinates;

-- Consulta Recursiva con campo calculado

WITH RECURSIVE subordinates AS (
	SELECT employee_id, manager_id,	full_name, 0 nivel
	FROM employees
	WHERE manager_id is null

	UNION

	SELECT	e.employee_id,	e.manager_id, e.full_name, nivel + 1
	FROM employees e
		INNER JOIN subordinates s ON s.employee_id = e.manager_id
)
SELECT *
FROM subordinates;


-- Agrupamiento común, promedio de precio
SELECT
    model_year,
    AVG(list_price) avg_price
FROM product
GROUP BY model_year;

-- Nos piden un listado que sea el año del modelo, el nombre del producto, el precio y "el promedio por modelo"
SELECT
   model_year,
   product_name,
   list_price,
   avg(list_price) over (partition by model_year)
FROM products
group by 1,2,3;


-- Productos ordenados por precio pero con el nro de orden del precio
SELECT
    model_year, product_name, list_price,
    RANK() OVER (partition by model_year ORDER BY list_price) rank,
    dense_rank() over (partition by model_year ORDER BY list_price) dense_rank
FROM products;


-- Listado de precio anterior

SELECT
   product_name,
   list_price,
   order_date,
   discount
FROM products p
    join order_items oi on p.product_id = oi.product_id
    join orders o on o.order_id = oi.order_id
order by product_name, order_date;

-- Quiero obtener el precio anterior y el posterior particionado por producto
select
   product_name,
   list_price,
   order_date,
   discount,
   lag(discount) over (partition by product_name order by order_date) anterior,
   lead(discount) over (partition by product_name order by order_date) posterior
FROM products p
    join order_items oi on p.product_id = oi.product_id
    join orders o on o.order_id = oi.order_id;

-- producto mas vendido por año
-- año, producto, cantidad

-- esta consulta nos da la cantidad ordenada en forma descendente
SELECT anio, oi.product_id, p.product_name, count(*) cantidad
FROM products p
    join order_items oi on p.product_id = oi.product_id
    join orders o on o.order_id = oi.order_id
group by 1,2,3
order by 1,4 desc;

-- Obtener el producto mas vendido por año (forma sin funciones de ventana)
SELECT o.anio, oi.product_id, p.product_name, count(*) cantidad
FROM products p
    join order_items oi on p.product_id = oi.product_id
    join orders o on o.order_id = oi.order_id
where (select count(*) from order_items oi1 join orders o1 on o1.order_id = oi1.order_id
                       where oi1.product_id = oi.product_id and o1.anio = o.anio)
   = (select count(*) from order_items oi1 join orders o1 on o1.order_id = oi1.order_id
                      where o1.anio = o.anio
                      group by o1.anio, oi1.product_id
                      order by 1 desc
                      limit 1)
group by 1,2,3;

-- Con funciones de Ventana

select * from (
    SELECT anio, p.product_id, product_name, count(*),
        RANK() OVER (partition by anio ORDER BY count(*) desc) rank
    FROM products p
        join order_items oi on p.product_id = oi.product_id
        join orders o on o.order_id = oi.order_id
    group by 1,2,3) as t
where t.rank in (1);


-- Puedo numerar las filas por lista de precio
select *,
       row_number() over (order by list_price)
from products
order by 1;

	
	
	
	