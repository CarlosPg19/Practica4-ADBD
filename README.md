# Sistema de Gestión de Viveros - Tajinaste S.A.
**Asignatura:** Administración y Diseño de Bases de Datos   

---

## Imagen Modelo Relacional
![Diagrama Modelo Relacional](./Modelo_Relacional.png)

## Descripción del Proyecto

Este repositorio contiene el diseño relacional e implementación física en PostgreSQL para la gestión de la red de viveros **Tajinaste S.A.**. 

El modelo implementa:
- Integridad referencial mediante claves primarias, foráneas y borrados en cascada/restricción.
- Validación de datos mediante restricciones `CHECK` (coordenadas GPS, importes no negativos).
- Atributos derivados automáticos mediante columnas generadas (`STORED`) y **Triggers** para la actualización en tiempo real de importes de pedidos y volumen de compras por cliente.

---

## Despliegue de la Base de Datos

Para ejecutar el script completo de creación de base de datos, usuario, tablas y carga de datos iniciales:

```bash
sudo -u postgres psql -f Script.sql
```

## Consultas SELECT para cada tabla de la base de datos

- SELECT * FROM VIVERO;

![IMAGE](Capturas/Vivero.png)

- SELECT * FROM PRODUCTO;

![IMAGE](Capturas/Producto.png)

- SELECT * FROM CLIENTE;

![IMAGE](Capturas/Cliente.png)

- SELECT * FROM EMPLEADO;

![IMAGE](Capturas/Empleado.png)

- SELECT * FROM TAREA;

![IMAGE](Capturas/Tarea.png)

- SELECT * FROM ZONA;

![IMAGE](Capturas/Zona.png)

- SELECT * FROM MIEMBRO_PLUS;

![IMAGE](Capturas/Miembro_Plus.png)

- SELECT * FROM STOCK_ZONA;

![IMAGE](Capturas/Stock_Zona.png)

- SELECT * FROM PEDIDO;

![IMAGE](Capturas/Pedido.png)

- SELECT * FROM COMPONENTE_PEDIDO;

![IMAGE](Capturas/Componente_Pedido.png)

- SELECT * FROM TAREA_EMPLEADO_ZONA;

![IMAGE](Capturas/Tarea_Empleado_Zona.png)
