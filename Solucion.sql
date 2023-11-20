--Conceptos Basicos:
--qty: cantidad de productos en una transaccion especifica.
--Transaccion: Es una secuencia de operaciones que se realizan como una unidad única e indivisible

-- 1. Cantidad total vendida de todos los productos:
SELECT SUM(qty) AS cantidad_total_vendida
FROM ventas;
-- 2. Ingreso total generado por todos los productos antes de descuentos:
SELECT SUM(precio * qty) AS ingreso_total
FROM ventas;
-- 3. Ingreso promedio generado por todos los productos antes de descuentos:
SELECT AVG(precio * qty) AS ingreso_promedio
FROM ventas;
--4. Ingreso total generado por cada producto antes de descuentos (ordenado de mayor a menor):
SELECT id_producto, SUM(precio * qty) AS ingreso_total
FROM ventas
GROUP BY id_producto
ORDER BY ingreso_total DESC;
--5. Porcentaje total de descuento sobre el ingreso total para todos los productos:
SELECT (SUM(descuento) / SUM(precio * qty)) * 100 AS porcentaje_descuento_total
FROM ventas;
-- 6. Porcentaje total de descuento sobre el ingreso total por cada producto:
SELECT id_producto, (SUM(descuento) / SUM(precio * qty)) * 100 AS porcentaje_descuento
FROM ventas
GROUP BY id_producto;
-- 7. Cantidad de transacciones únicas:
-- Numero total de eventos distintos que han ocurrido en un conjunto de datos
-- id_txn identificador unico de una transaccion
SELECT COUNT(DISTINCT id_txn) AS transacciones_unicas
FROM ventas;
--8. Ventas totales brutas de cada transacción:
SELECT id_txn, SUM(precio * qty) AS ventas_brutas
FROM ventas
GROUP BY id_txn;
--9. Cantidad de productos totales comprados en cada transacción:
SELECT id_txn, SUM(qty) AS cantidad_productos
FROM ventas
GROUP BY id_txn;
--10. Valor de descuento promedio por transacción:
SELECT id_txn, AVG(descuento) AS descuento_promedio
FROM ventas
GROUP BY id_txn;
--11. Ingreso promedio neto por transacción para miembros "t":
--Se refiere al promedio de ingresos después de tener en cuenta los descuentos. En otras palabras, representa cuánto dinero en promedio se está generando por transacción después de aplicar descuentos.
SELECT id_txn, AVG(precio * qty - descuento) AS ingreso_promedio_neto
FROM ventas
WHERE miembro = 't'
GROUP BY id_txn;
--12. Los 3 productos más vendidos en función a los ingresos totales:
SELECT TOP 3 id_producto, SUM(precio * qty) AS ingresos_totales
FROM ventas
GROUP BY id_producto
ORDER BY ingresos_totales DESC;

--13. Cantidad total vendida, ingresos brutos y descuento de cada segmento de producto:

SELECT
  pd.id_segmento,
  COUNT(v.qty) AS cantidad_total_vendida,
  SUM(v.precio * v.qty) AS ingresos_brutos,
  SUM(v.descuento) AS descuento_total
FROM producto_detalle pd
JOIN ventas v ON CAST(pd.id_producto AS varchar(max)) = v.id_producto
GROUP BY pd.id_segmento;

--14. Producto más vendido de cada categoría:

WITH ProductosPorCategoria AS (
  SELECT
    pd.id_categoria,
    v.id_producto,
    ROW_NUMBER() OVER (PARTITION BY pd.id_categoria ORDER BY SUM(v.qty) DESC) AS rn
  FROM producto_detalle pd
  JOIN ventas v ON CAST(pd.id_producto AS varchar(max)) = v.id_producto
  GROUP BY pd.id_categoria, v.id_producto
)
SELECT id_categoria, id_producto
FROM ProductosPorCategoria
WHERE rn = 1;

--15 ¿Cuál es el producto más vendido para cada segmento?

WITH ProductosPorSegmento AS (
  SELECT
    pd.nombre_segmento,
    pd.nombre_producto,
    SUM(v.qty) AS cantidad_vendida,
    SUM(v.precio * v.qty - v.descuento) AS ventas_netas,
    ROW_NUMBER() OVER (PARTITION BY pd.nombre_segmento ORDER BY SUM(v.qty) DESC) AS rn
  FROM producto_detalle pd
  JOIN ventas v ON CAST(pd.id_producto AS VARCHAR(MAX)) = CAST(v.id_producto AS VARCHAR(MAX))
  GROUP BY pd.nombre_segmento, pd.nombre_producto
)
SELECT nombre_segmento, nombre_producto, cantidad_vendida, ventas_netas
FROM ProductosPorSegmento
WHERE rn = 1;