-- =============================================================================
-- BASE DE DATOS: viveros
-- =============================================================================

-- Limpieza previa
DROP DATABASE IF EXISTS viveros;
DROP USER IF EXISTS admin_viveros;

-- 1. CREACION DE LA BASE DE DATOS Y USUARIO ADMINISTRADOR
CREATE DATABASE viveros;

-- Creacion del usuario administrador
CREATE USER admin_viveros WITH 
    PASSWORD 'AdminViveros2026'
    SUPERUSER;

-- Conectarse a la base de datos recien creada
\c viveros
SET ROLE admin_viveros;


-- 2. CREACION DE TABLAS Y RESTRICCIONES

-- Tabla: VIVERO
CREATE TABLE VIVERO (
    Cod_Vivero      INT,
    Nombre_Vivero   VARCHAR(100),
    Direccion       VARCHAR(200),
    Latitud         NUMERIC(9,6) CHECK (Latitud BETWEEN -90 AND 90),
    Longitud        NUMERIC(9,6) CHECK (Longitud BETWEEN -180 AND 180),
    Telefono        VARCHAR(20),
    Superficie_M2   NUMERIC(10,2) CHECK (Superficie_M2 > 0),
    CONSTRAINT PK_VIVERO PRIMARY KEY (Cod_Vivero)
);


-- Tabla: ZONA
CREATE TABLE ZONA (
    Cod_Vivero     INT,
    Cod_Zona       INT,
    Nombre_Zona    VARCHAR(100),
    Latitud        NUMERIC(9,6) CHECK (Latitud BETWEEN -90 AND 90),
    Longitud       NUMERIC(9,6) CHECK (Longitud BETWEEN -180 AND 180),
    CONSTRAINT PK_ZONA PRIMARY KEY (Cod_Vivero, Cod_Zona),
    CONSTRAINT FK_ZONA_VIVERO FOREIGN KEY (Cod_Vivero)
        REFERENCES VIVERO (Cod_Vivero)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- Tabla: PRODUCTO
CREATE TABLE PRODUCTO (
    Cod_Producto   INT,
    Nombre         VARCHAR(100),
    Precio         NUMERIC(10,2) CHECK (Precio >= 0),
    Categoria      VARCHAR(50),
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (Cod_Producto)
);


-- Tabla: STOCK_ZONA 
CREATE TABLE STOCK_ZONA (
    Cod_Vivero     INT,
    Cod_Zona       INT,
    Cod_Producto   INT,
    Cantidad_Stock INT DEFAULT 0 CHECK (Cantidad_Stock >= 0),
    CONSTRAINT PK_STOCK_ZONA PRIMARY KEY (Cod_Vivero, Cod_Zona, Cod_Producto),
    CONSTRAINT FK_STOCK_ZONA_ZONA FOREIGN KEY (Cod_Vivero, Cod_Zona)
        REFERENCES ZONA (Cod_Vivero, Cod_Zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_STOCK_ZONA_PRODUCTO FOREIGN KEY (Cod_Producto)
        REFERENCES PRODUCTO (Cod_Producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- Tabla: CLIENTE
CREATE TABLE CLIENTE (
    Cod_Cliente     INT,
    DNI             VARCHAR(15)   NOT NULL UNIQUE,
    Fecha_Registro  DATE          NOT NULL DEFAULT CURRENT_DATE,
    -- Atributo derivado acumulado (actualizado mediante Trigger)
    Volumen_Compras NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (Volumen_Compras >= 0),
    CONSTRAINT PK_CLIENTE PRIMARY KEY (Cod_Cliente)
);


-- Tabla: MIEMBRO_PLUS
CREATE TABLE MIEMBRO_PLUS (
    Cod_Cliente INT,
    Fecha_Alta  DATE         NOT NULL DEFAULT CURRENT_DATE,
    Fecha_Baja  DATE         NULL,
    Puntos      INT          NOT NULL DEFAULT 0 CHECK (Puntos >= 0),
    Nombre      VARCHAR(100) NOT NULL,
    Telefono    VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_MIEMBRO_PLUS PRIMARY KEY (Cod_Cliente),
    CONSTRAINT FK_MIEMBRO_CLIENTE FOREIGN KEY (Cod_Cliente)
        REFERENCES CLIENTE (Cod_Cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CHK_FECHAS_MIEMBRO CHECK (Fecha_Baja IS NULL OR Fecha_Baja >= Fecha_Alta)
);


-- Tabla: EMPLEADO
CREATE TABLE EMPLEADO (
    Cod_Empleado       INT,
    Nombre             VARCHAR(100) NOT NULL,
    Correo             VARCHAR(100) NOT NULL UNIQUE,
    Fecha_Contratacion DATE         NOT NULL CHECK (Fecha_Contratacion <= CURRENT_DATE),
    DNI                VARCHAR(15)  NOT NULL UNIQUE,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (Cod_Empleado)
);


-- Tabla: TAREA
CREATE TABLE TAREA (
    Cod_Tarea    INT,
    Nombre_Tarea VARCHAR(100) NOT NULL,
    Descripcion  TEXT,
    CONSTRAINT PK_TAREA PRIMARY KEY (Cod_Tarea)
);


-- Tabla: PEDIDO
CREATE TABLE PEDIDO (
    Cod_Pedido   INT           NOT NULL,
    Cod_Cliente  INT           NOT NULL,
    Cod_Empleado INT           NULL, -- Permite SET NULL si el empleado es dado de baja
    Fecha_Compra DATE          NOT NULL DEFAULT CURRENT_DATE,
    -- Atributo derivado calculado a partir de COMPONENTE_PEDIDO
    Precio_Total NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (Precio_Total >= 0),
    CONSTRAINT PK_PEDIDO PRIMARY KEY (Cod_Pedido),
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (Cod_Cliente)
        REFERENCES CLIENTE (Cod_Cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT FK_PEDIDO_EMPLEADO FOREIGN KEY (Cod_Empleado)
        REFERENCES EMPLEADO (Cod_Empleado)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- Tabla: COMPONENTE_PEDIDO
CREATE TABLE COMPONENTE_PEDIDO (
    Cod_Pedido   INT           NOT NULL,
    Cod_Producto INT           NOT NULL,
    Cantidad     INT           NOT NULL CHECK (Cantidad > 0),
    Precio_Venta NUMERIC(10,2) NOT NULL CHECK (Precio_Venta >= 0),
    -- ATRIBUTO DERIVADO
    Subtotal     NUMERIC(10,2) GENERATED ALWAYS AS (Cantidad * Precio_Venta) STORED,
    CONSTRAINT PK_COMPONENTE_PEDIDO PRIMARY KEY (Cod_Pedido, Cod_Producto),
    CONSTRAINT FK_COMPONENTE_PEDIDO_PEDIDO FOREIGN KEY (Cod_Pedido)
        REFERENCES PEDIDO (Cod_Pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_COMPONENTE_PEDIDO_PRODUCTO FOREIGN KEY (Cod_Producto)
        REFERENCES PRODUCTO (Cod_Producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- Tabla: TAREA_EMPLEADO_ZONA
CREATE TABLE TAREA_EMPLEADO_ZONA (
    Cod_Empleado INT          NOT NULL,
    Cod_Vivero   INT          NOT NULL,
    Cod_Zona     INT          NOT NULL,
    Cod_Tarea    INT          NOT NULL,
    Fecha_Inicio DATE         NOT NULL,
    Fecha_Fin    DATE         NULL,
    Productividad INT         NULL CHECK (Productividad BETWEEN 1 AND 10),
    Puesto       VARCHAR(50)  NULL,
    CONSTRAINT PK_TAREA_EMPLEADO_ZONA PRIMARY KEY (Cod_Empleado, Cod_Vivero, Cod_Zona, Cod_Tarea, Fecha_Inicio),
    CONSTRAINT FK_TEZ_EMPLEADO FOREIGN KEY (Cod_Empleado)
        REFERENCES EMPLEADO (Cod_Empleado)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_TEZ_ZONA FOREIGN KEY (Cod_Vivero, Cod_Zona)
        REFERENCES ZONA (Cod_Vivero, Cod_Zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_TEZ_TAREA FOREIGN KEY (Cod_Tarea)
        REFERENCES TAREA (Cod_Tarea)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT CHK_FECHAS_TAREA CHECK (Fecha_Fin IS NULL OR Fecha_Fin >= Fecha_Inicio)
);




-- 3. GESTION DE ATRIBUTOS DERIVADOS ENTRE TABLAS (TRIGGERS)

CREATE OR REPLACE FUNCTION fn_recalcular_totales_pedido()
RETURNS TRIGGER AS $$
DECLARE
    v_cod_pedido INT;
    v_cod_cliente INT;
BEGIN
    v_cod_pedido := COALESCE(NEW.Cod_Pedido, OLD.Cod_Pedido);


    -- 1. Actualizar el atributo derivado Precio_Total en la tabla PEDIDO
    UPDATE PEDIDO
    SET Precio_Total = COALESCE((
        SELECT SUM(Subtotal)
        FROM COMPONENTE_PEDIDO
        WHERE Cod_Pedido = v_cod_pedido
    ), 0.00)
    WHERE Cod_Pedido = v_cod_pedido;


    -- 2. Obtener el cliente asociado al pedido
    SELECT Cod_Cliente INTO v_cod_cliente FROM PEDIDO WHERE Cod_Pedido = v_cod_pedido;


    -- 3. Actualizar el atributo derivado Volumen_Compras en la tabla CLIENTE
    IF v_cod_cliente IS NOT NULL THEN
        UPDATE CLIENTE
        SET Volumen_Compras = COALESCE((
            SELECT SUM(Precio_Total)
            FROM PEDIDO
            WHERE Cod_Cliente = v_cod_cliente
        ), 0.00)
        WHERE Cod_Cliente = v_cod_cliente;
    END IF;


    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger sobre la tabla COMPONENTE_PEDIDO
CREATE TRIGGER trg_actualizar_totales_componente
AFTER INSERT OR UPDATE OR DELETE ON COMPONENTE_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_totales_pedido();




-- 4. INSERCION DE DATOS DE PRUEBA


-- 1. VIVERO
INSERT INTO VIVERO (Cod_Vivero, Nombre_Vivero, Direccion, Latitud, Longitud, Telefono, Superficie_M2) VALUES
(1, 'Vivero Tajinaste Norte', 'Av. Las Palmeras 12, La Orotava', 28.389200, -16.521100, '922010101', 4500.00),
(2, 'Vivero Tajinaste Sur', 'Calle San Bartolome 45, Arona', 28.058300, -16.681900, '922020202', 6200.50),
(3, 'Vivero Anaga Plantas', 'Carretera Taganana Km 4, Santa Cruz', 28.512000, -16.192100, '922030303', 3100.00),
(4, 'Vivero Central Laguna', 'Camino Tornero 88, La Laguna', 28.485300, -16.315900, '922040404', 8000.00),
(5, 'Vivero Brena Baja', 'Calle Los Cipreses 3, La Palma', 28.648100, -17.771200, '922050505', 2500.00);


-- 2. ZONA
INSERT INTO ZONA (Cod_Vivero, Cod_Zona, Nombre_Zona, Latitud, Longitud) VALUES
(1, 101, 'Invernadero', 28.389210, -16.521110),
(1, 102, 'Exterior', 28.389250, -16.521150),
(2, 201, 'Zona Cactus', 28.058310, -16.681910),
(3, 301, 'Interior', 28.512010, -16.192110),
(4, 401, 'Almacen', 28.485310, -16.315910),
(5, 501, 'Exposicion Principal', 28.648110, -17.771210);


-- 3. PRODUCTO
INSERT INTO PRODUCTO (Cod_Producto, Nombre, Precio, Categoria) VALUES
(1, 'Substrato Universal 50L', 12.50, 'Sustratos y Abonos'),
(2, 'Rosa', 24.99, 'Planta Exterior'),
(3, 'Tijeras de Podar', 18.00, 'Herramientas'),
(4, 'Margarita', 29.50, 'Planta Interior'),
(5, 'Maceta Ceramica 30cm', 15.00, 'Decoracion');


-- 4. STOCK_ZONA
INSERT INTO STOCK_ZONA (Cod_Vivero, Cod_Zona, Cod_Producto, Cantidad_Stock) VALUES
(1, 101, 2, 45),
(1, 101, 4, 30),
(2, 201, 1, 100),
(3, 301, 4, 15),
(4, 401, 3, 50),
(5, 501, 5, 20);


-- 5. CLIENTE
INSERT INTO CLIENTE (Cod_Cliente, DNI, Fecha_Registro) VALUES
(1, '12345678A', '2025-01-10'),
(2, '23456789B', '2025-02-15'),
(3, '34567890C', '2025-03-20'),
(4, '45678901D', '2025-04-05'),
(5, '56789012E', '2025-05-12');


-- 6. MIEMBRO_PLUS
INSERT INTO MIEMBRO_PLUS (Cod_Cliente, Fecha_Alta, Fecha_Baja, Puntos, Nombre, Telefono) VALUES
(1, '2025-01-10', NULL, 120, 'Maria Laura Benitez', '600111222'),
(2, '2025-02-15', NULL, 85, 'Carlos Eduardo Gomez', '600222333'),
(3, '2025-03-20', '2025-12-31', 0, 'Ana Sofia Rodriguez', '600333444'),
(4, '2025-04-05', NULL, 210, 'Javier Luis Hernández', '600444555'),
(5, '2025-05-12', NULL, 45, 'Elena Beatriz Morales', '600555666');


-- 7. EMPLEADO
INSERT INTO EMPLEADO (Cod_Empleado, Nombre, Correo, Fecha_Contratacion, DNI) VALUES
(1, 'Juan Perez', 'juan.perez@tajinaste.com', '2022-03-01', '87654321Z'),
(2, 'Laura Santana', 'laura.santana@tajinaste.com', '2023-01-15', '76543210Y'),
(3, 'Pedro Delgado', 'pedro.delgado@tajinaste.com', '2021-06-10', '65432109X'),
(4, 'Sofia Mesa', 'sofia.mesa@tajinaste.com', '2024-02-01', '54321098W'),
(5, 'David Ramos', 'david.ramos@tajinaste.com', '2023-09-20', '43210987V');


-- 8. TAREA
INSERT INTO TAREA (Cod_Tarea, Nombre_Tarea, Descripcion) VALUES
(1, 'Riego y Fumigacion', 'Aplicacion de riego por goteo y tratamiento fitosanitario'),
(2, 'Poda', 'Recorte de ramas secas y moldeado de plantas ornamentales'),
(3, 'Reposicion de Stock', 'Carga de material en estanterias de exposición'),
(4, 'Control de Humedad', 'Medicion de parametros en invernaderos climatizados'),
(5, 'Inventario General', 'Conteo fisico anual de existencias');


-- 9. PEDIDO
INSERT INTO PEDIDO (Cod_Pedido, Cod_Cliente, Cod_Empleado, Fecha_Compra) VALUES
(1, 1, 1, '2026-01-15'),
(2, 2, 2, '2026-02-01'),
(3, 3, 1, '2026-02-10'),
(4, 4, 5, '2026-03-05'),
(5, 5, 3, '2026-03-20');


-- 10. COMPONENTE_PEDIDO
INSERT INTO COMPONENTE_PEDIDO (Cod_Pedido, Cod_Producto, Cantidad, Precio_Venta) VALUES
(1, 1, 2, 12.50),
(1, 4, 1, 29.50),
(2, 2, 1, 24.99),
(3, 3, 2, 18.00),
(4, 5, 3, 15.00),
(5, 1, 4, 12.50);


-- 11. TAREA_EMPLEADO_ZONA
INSERT INTO TAREA_EMPLEADO_ZONA (Cod_Empleado, Cod_Vivero, Cod_Zona, Cod_Tarea, Fecha_Inicio, Fecha_Fin, Productividad, Puesto) VALUES
(1, 1, 101, 1, '2026-01-10', '2026-01-10', 9, 'Tecnico de Riego'),
(2, 2, 201, 3, '2026-01-12', '2026-01-12', 8, 'Operario de Almacen'),
(3, 3, 301, 2, '2026-02-01', '2026-02-01', 10, 'Jardinero Especialista'),
(4, 4, 401, 5, '2026-02-15', '2026-02-16', 7, 'Encargado de Inventario'),
(5, 5, 501, 4, '2026-03-01', '2026-03-01', 9, 'Controlador Ambiental');




-- 5. EJEMPLOS REPRESENTATIVOS DE OPERACIONES DELETE

-- CASO 1: Demostracion de ON DELETE CASCADE
DELETE FROM VIVERO WHERE Cod_Vivero = 5;


-- CASO 2: Demostracion de ON DELETE RESTRICT (Falla intencionalmente si hay referencias)
-- DELETE FROM PRODUCTO WHERE Cod_Producto = 1;


-- CASO 3: Demostracion de ON DELETE SET NULL
DELETE FROM EMPLEADO WHERE Cod_Empleado = 5;