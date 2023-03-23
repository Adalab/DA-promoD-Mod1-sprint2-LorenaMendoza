/* EVALUACIÓN 2 DE SQL */

USE northwind;

/* Para esta evaluación usaremos la BBDD de northwind con la que ya estamos familiarizadas de
 los ejercicios de pair programming. En esta evaluación tendréis que contestar a las siguientes 
 preguntas:*/
 
 /*1. Selecciona todos los campos de los productos, que pertenezcan a los proveedores con
 códigos: 1, 3, 7, 8 y 9, que tengan stock en el almacén, y al mismo tiempo que sus precios unitarios
 estén entre 50 y 100. Por último, ordena los resultados por 
 código de proveedor de forma ascendente. */
 
SELECT * 
FROM products
WHERE supplier_id IN (1, 3, 7, 8, 9) AND units_in_stock <> 0
HAVING unit_price BETWEEN 50 AND 100
ORDER BY supplier_id;

-- Intento con una CTE:
WITH Productos AS(
			 SELECT *
			 FROM products
			 WHERE supplier_id IN (1,3,7,8,9) AND unit_price BETWEEN 50 AND 100 AND units_in_stock <> 0)
			
SELECT *
FROM Productos
ORDER BY supplier_id ASC;

  /*2. Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6, 
  además que hayan vendido a clientes que tengan códigos que comiencen con las letras de la A
  hasta la G. Por último, en esta búsqueda queremos filtrar solo por aquellos envíos que 
  la fecha de pedido este comprendida entre el 22 y el 31 de Diciembre de cualquier año.*/
  
  
SELECT employee_id, first_name, last_name
  FROM employees
  NATURAL JOIN orders
  WHERE employee_id IN (3,4,5,6) AND customer_id REGEXP '^[A-G].*' AND MONTH(order_date) = 12 AND DAY(order_date) BETWEEN 22 AND 31;
  
  /*3.Calcula el precio de venta de cada pedido una vez aplicado el descuento. 
  Muestra el id del la orden, el id del producto, el nombre del producto, el precio unitario,
  la cantidad, el descuento y el precio de venta después de haber aplicado el descuento.*/
 
  SELECT o.order_id, o.product_id, p.product_name, o.unit_price, o.quantity, o.discount, ROUND((o.unit_price * quantity) * (1- o.discount),2) AS PrecioVenta
  FROM order_details AS o
  INNER JOIN products AS p
  ON o.product_id = p.product_id
  ORDER BY order_id;
  
  /*4. Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio medio 
  total de los productos de la BBDD.*/
  -- CON SUBCONSULTA
  -- mostrar productos cuyos precios > del precio medio total de los productos de la BBDD
  
-- PEQUEÑA SUBCONSULTA DE AYUDA:
  SELECT AVG(unit_price)
  FROM products; -- precio medio de todos los productos es 28.86
  
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT ROUND(AVG(unit_price), 2)
                    FROM products);
   
  /*5. ¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos?*/
  
SELECT first_name AS "Nombre", last_name AS "Apellido", product_name AS "Producto", SUM(quantity) AS "Cantidad_total_vendida", employees.employee_id
FROM employees
INNER JOIN orders
	ON employees.employee_id = orders.employee_id
INNER JOIN order_details
	ON order_details.order_id = orders.order_id
INNER JOIN products
	ON order_details.product_id = products.product_id
GROUP BY employees.employee_id, products.product_name
ORDER BY employees.employee_id, Producto;

  -- Se hace esa unión de tablas a través de INNER JOIN para poder ir accediendo a cada una de las informaciones
  -- que se van solicitando para poder sacar la consulta y completarla:
  -- De la primera tabla "employees" sacamos los datos de los empleados. Esta se une a "orders" para, después,
  -- poder hacer la unión con order_details y poder acceder a la información de quantity y sacar un compendio de productos totales.
  -- Se realiza así, sucesivamente, con la tabla "products" para poder llegar al nombre del producto.
  
  /*6.Basándonos en la query anterior, ¿qué empleado es el que vende más productos? 
  Soluciona este ejercicio con una subquery 
  BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/
  
  SELECT first_name AS "Nombre", last_name AS "Apellido", COUNT(product_name) AS "Número_productos_vendidos"
    FROM (
			SELECT DISTINCT  first_name, last_name, employees.employee_id, product_name
			FROM employees
			INNER JOIN orders -- necesitas poner el distinct para ver cuánto vende realmente cada personaporque sino cambian los datos
				ON employees.employee_id = orders.employee_id
			INNER JOIN order_details
				ON order_details.order_id = orders.order_id
			INNER JOIN products
				ON order_details.product_id = products.product_id) AS empleados_productos
    GROUP BY employee_id;
    
    -- Se toma la consulta anterior y para poder tomarla como referencia se usa en el FROM para, así, 
    -- poder obtener los datos que se solicitan ahora. Se hace un conteo del nombre de los productos
    -- (podría haber sido el id del producto) para obtener así el dato del número de productos que vende cada trabajador.
 /* BONUS ¿Podríais solucionar este mismo ejercicio con una CTE?*/
 
 WITH empleados_productos AS (
			SELECT DISTINCT first_name AS "Nombre", last_name AS "Apellido", employees.employee_id AS "IDEmpleado", product_name AS "Producto"
			FROM employees
			INNER JOIN orders
				ON employees.employee_id = orders.employee_id
			INNER JOIN order_details
				ON order_details.order_id = orders.order_id
			INNER JOIN products
				ON order_details.product_id = products.product_id)
                
	SELECT Nombre, Apellido, COUNT(Producto) AS "Número_productos_vendidos"
    FROM empleados_productos
    GROUP BY IDEmpleado;
    
    -- Se realiza un conteo de los productos para sacar el número de productos diferentes que vende
    -- cada uno de los empleados.