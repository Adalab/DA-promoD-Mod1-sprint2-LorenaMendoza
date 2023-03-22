/* EVALUACIÓN 2 DE SQL */

USE northwind;

/* Para esta evaluación usaremos la BBDD de northwind con la que ya estamos familiarizadas de
 los ejercicios de pair programming. En esta evaluación tendréis que contestar a las siguientes 
 preguntas:*/
 
 /*1. Selecciona todos los campos de los productos, que pertenezcan a los proveedores con
 códigos: 1, 3, 7, 8 y 9, que tengan stock en el almacén, y al mismo tiempo que sus precios unitarios
 estén entre 50 y 100. Por último, ordena los resultados por 
 código de proveedor de forma ascendente. */
 
-- qué piden: todos los campos de productos cuando...
-- 1) sus proveedores_id sean 1,3,7,8,9
-- 2) que tengan stock en el almacen
-- 3) cuyos precios unitarios estén entre 50 y 100
-- ORDENA los resultados: ORDER BY* por proveedor_id ASC
-- TABLAS: products

-- CON CTEs:

WITH cte1 AS(
			 SELECT supplier_id, unit_price, units_in_stock
			 FROM products
			 WHERE supplier_id IN (1,3,7,8,9) AND unit_price BETWEEN 50 AND 100 AND units_in_stock > 0)
			
SELECT * 
FROM cte1
ORDER BY supplier_id ASC;

WITH cte2 AS(
			 SELECT *
			 FROM products
			 WHERE supplier_id IN (1,3,7,8,9) AND unit_price BETWEEN 50 AND 100 AND units_in_stock > 0)
			
SELECT supplier_id, unit_price, units_in_stock
FROM cte2
ORDER BY supplier_id ASC;
-- Se podría hacer con una subconsulta con ALL...(chequear apuntes consultas múltiples tablas4)
-- CON UNA CONSULTA DONDE HAY WHERE Y MÚLTIPLES CONDICIONES:

SELECT supplier_id, unit_price, units_in_stock
FROM products
WHERE supplier_id IN (1,3,7,8,9) AND unit_price BETWEEN 50 AND 100 AND units_in_stock > 0;
-- ORDER BY supplier_id ASC -> te lo da por defecto así 

SELECT*
FROM products; -- mirar bien si se podría hacer con una suconsulta en el where o en el from...
-- o un self-join pero este último dudo
 
  /*2. Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6, 
  además que hayan vendido a clientes que tengan códigos que comiencen con las letras de la A
  hasta la G. Por último, en esta búsqueda queremos filtrar solo por aquellos envíos que 
  la fecha de pedido este comprendida entre el 22 y el 31 de Diciembre de cualquier año.*/
  
  -- nombre y apellidos + id_empleados (tabla employees) cuando...
  -- 1) sus id_empleados entre 3 y 6
  -- 2) que hayan vendido a clientes con códigos que empiecen por la [a-g]% (orders)
  -- 3) cuyas order_date estén comprendidas entre el 22 y 31 de diciembre de cualquier año (orders)
  
  -- 2 y 3 en cte (orders)
  -- luego joins con employeessuppliers
  
  /*3.Calcula el precio de venta de cada pedido una vez aplicado el descuento. 
  Muestra el id del la orden, el id del producto, el nombre del producto, el precio unitario,
  la cantidad, el descuento y el precio de venta después de haber aplicado el descuento.*/
  -- TABLA: order_details
  -- qué piden: precio venta (ya aplicado el descuento): columna auxiliar con función agregada in
  -- para calcular precio venta: unit_price - (unit_price * discount)
  -- mostrar: order_id, product_id, product_name (en tabla products, hay que relacionarlas)
  -- mostrar: ... unit_price, quantity, discount y precio de venta después de aplicar discount.
  
  SELECT o.order_id, o.product_id, p.product_name, o.unit_price, o.quantity, o.discount, ROUND(o.unit_price - (o.unit_price * o.discount),2) AS PrecioVenta
  FROM order_details AS o
  NATURAL JOIN products AS p;
  
  /*4. Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio medio 
  total de los productos de la BBDD.*/
  -- CON SUBCONSULTA
  -- mostrar productos cuyos precios > del precio medio total de los productos de la BBDD
    
  SELECT SUM(unit_price) / COUNT(unit_price)
  FROM products; -- precio medio de todos los productos es 28.86
  
  SELECT product_id, product_name -- o todo con *
  FROM products
  WHERE unit_price > (SELECT SUM(unit_price) / COUNT(unit_price)
					  FROM products);
   
  /*5. ¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos?*/
  
  -- los productos vendidos por cada uno de los empleados ((product_name), product_id) y employee_id
  -- relación tablas: products, order_details (product_id ) OPCIONAL
  -- relación tablas: order_details y orders con order_id
  -- relación tablas: orders y employees con employee_id
  
  SELECT *
  FROM order_details;
  
  SELECT o1.product_id, o3.first_name AS Comercial, o2.employee_id, o1. quantity
  FROM order_details AS o1
  NATURAL JOIN orders AS o2
  NATURAL JOIN employees AS o3;
  
  /*6.Basándonos en la query anterior, ¿qué empleado es el que vende más productos? 
  Soluciona este ejercicio con una subquery 
  BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/
  -- SUBCONSULTAS:
  -- habría que hacer un SUM de productos/cantidad por empleado?
  
  SELECT o3.first_name AS Comercial, o2.employee_id, SUM(o1. quantity) AS TotalProductosVendidos
  FROM order_details AS o1
  NATURAL JOIN orders AS o2
  NATURAL JOIN employees AS o3
  GROUP BY Comercial, o2.employee_id;
  
 /* BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/
 
WITH cte4 AS(
			  SELECT employee_id, first_name AS Comercial
              FROM employees)
                                          
SELECT employee_id, Comercial, SUM(quantity) AS TotalProductosVendidos
FROM cte4
NATURAL JOIN orders
NATURAL JOIN order_details
GROUP BY Comercial, employee_id;