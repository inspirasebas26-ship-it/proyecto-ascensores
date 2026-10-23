
 Script de la base de datos de nuestra tienda de ascensores (proyecto SENA)
Aquí creamos todas las tablas y metemos unos datos de prueba para arrancar.
 * En el PC (XAMPP): se pega completo en la pestaña SQL de phpMyAdmin.
 * En la nube (Aiven): NO hay que correrlo a mano. Cuando la página arranca,
app.py revisa si faltan las tablas y corre este archivo solito
(se salta las dos primeras órdenes, porque allá la base ya existe y se llama defaultdb).


-- Creamos la base de datos solo si no existe todavía (así no explota si la corremos dos veces)
CREATE DATABASE IF NOT EXISTS tienda_ascensores;
-- Le decimos a MySQL: "oiga, de aquí pa'bajo trabaje en esta base"
USE tienda_ascensores;

-- ---------------------------------------------------------------------
-- Tabla de roles: aquí guardamos los "tipos" de usuario (cliente, admin, etc.)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- El id se pone solito y va sumando de a uno
    nombre VARCHAR(50) NOT NULL UNIQUE,         -- Nombre del rol, obligatorio y no se puede repetir
    descripcion VARCHAR(255)                    -- Una explicación cortica del rol (opcional)
);

-- ---------------------------------------------------------------------
-- Tabla de usuarios: todos los que se pueden loguear en la página
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático del usuario
    nombre VARCHAR(100) NOT NULL,               -- Nombre, obligatorio
    apellido VARCHAR(100) NOT NULL,             -- Apellido, también obligatorio
    correo VARCHAR(150) NOT NULL UNIQUE,        -- Correo, no se puede repetir (con esto se loguean)
    telefono VARCHAR(20),                       -- Teléfono, opcional
    contrasena VARCHAR(255) NOT NULL,           -- La contraseña (la guardamos tal cual, es proyecto de clase)
    rol_id INT NOT NULL,                        -- Qué rol tiene, apunta a la tabla roles
    activo BOOLEAN DEFAULT TRUE,                -- Si está en FALSE el usuario no puede entrar
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- La fecha se pone sola al registrarse
    FOREIGN KEY (rol_id) REFERENCES roles(id)   -- Llave foránea: el rol tiene que existir sí o sí
);

-- ---------------------------------------------------------------------
-- Tabla de categorías: para agrupar los productos
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    nombre VARCHAR(100) NOT NULL UNIQUE,        -- Nombre de la categoría, sin repetir
    descripcion TEXT                            -- Descripción larga, opcional
);

-- ---------------------------------------------------------------------
-- Tabla de productos: los ascensores y repuestos que vendemos (esta es la del CRUD)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático del producto
    categoria_id INT NOT NULL,                  -- A qué categoría pertenece
    nombre VARCHAR(150) NOT NULL,               -- Nombre del producto
    modelo VARCHAR(100) UNIQUE,                 -- Código del modelo, no se repite
    descripcion TEXT,                           -- Descripción del producto
    precio DECIMAL(12, 2) NOT NULL,             -- Precio con dos decimales
    stock INT NOT NULL DEFAULT 0,               -- Cuántos hay en bodega
    capacidad_carga_kg INT COMMENT 'Para ascensores',   -- Cuántos kilos aguanta (solo ascensores)
    capacidad_personas INT COMMENT 'Para ascensores',   -- Cuántas personas caben (solo ascensores)
    imagen_url VARCHAR(255),                    -- Link de una imagen, opcional
    activo BOOLEAN DEFAULT TRUE,                -- Si está en FALSE no sale en el catálogo
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) -- La categoría tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla de cotizaciones: cuando un cliente pide precio para su edificio
-- (por ahora no tiene pantalla, queda lista para una siguiente fase)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cotizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    cliente_id INT NOT NULL,                    -- Quién pidió la cotización
    estado ENUM('pendiente', 'en_revision', 'aprobada', 'rechazada') DEFAULT 'pendiente', -- Solo puede tener uno de estos valores
    detalles_edificio TEXT NOT NULL COMMENT 'Número de pisos, tipo de edificio, espacio disponible', -- Info del edificio
    presupuesto_estimado DECIMAL(12, 2),        -- Plata aproximada
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Se pone sola
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) -- El cliente tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla de proyectos de instalación: cuando la cotización se aprueba y toca montar el ascensor
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS proyectos_instalacion (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    cotizacion_id INT UNIQUE,                   -- De qué cotización salió (una sola vez)
    cliente_id INT NOT NULL,                    -- El cliente dueño de la obra
    tecnico_asignado_id INT,                    -- El técnico que va a ir (puede estar vacío al inicio)
    direccion_obra VARCHAR(255) NOT NULL,       -- Dónde queda la obra
    estado ENUM('planificacion', 'en_proceso', 'completado', 'suspendido') DEFAULT 'planificacion', -- Cómo va la obra
    fecha_inicio_estimada DATE,                 -- Cuándo se piensa empezar
    fecha_fin_estimada DATE,                    -- Cuándo se piensa terminar
    FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones(id),   -- La cotización tiene que existir
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id),          -- El cliente tiene que existir
    FOREIGN KEY (tecnico_asignado_id) REFERENCES usuarios(id)  -- El técnico también es un usuario
);

-- ---------------------------------------------------------------------
-- Tabla de pedidos: las compras que hacen los clientes
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    cliente_id INT NOT NULL,                    -- Quién compró
    estado ENUM('pendiente', 'pagado', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente', -- Cómo va el pedido
    total DECIMAL(12, 2) NOT NULL,              -- Cuánto fue la compra
    direccion_envio VARCHAR(255) NOT NULL,      -- Para dónde se manda
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Se pone sola
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) -- El cliente tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla detalle de pedidos: qué productos iban en cada pedido
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    pedido_id INT NOT NULL,                     -- A qué pedido pertenece
    producto_id INT NOT NULL,                   -- Qué producto se llevó
    cantidad INT NOT NULL,                      -- Cuántos se llevó
    precio_unitario DECIMAL(12, 2) NOT NULL,    -- A cómo estaba cada uno en ese momento
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),       -- El pedido tiene que existir
    FOREIGN KEY (producto_id) REFERENCES productos(id)    -- El producto tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla de contratos de mantenimiento: para los clientes que pagan mantenimiento
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS contratos_mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    cliente_id INT NOT NULL,                    -- El cliente del contrato
    ascensor_producto_id INT NOT NULL,          -- Qué ascensor se le mantiene
    tipo ENUM('preventivo', 'correctivo', 'integral') NOT NULL, -- Tipo de mantenimiento
    fecha_inicio DATE NOT NULL,                 -- Desde cuándo
    fecha_fin DATE NOT NULL,                    -- Hasta cuándo
    estado ENUM('activo', 'vencido', 'cancelado') DEFAULT 'activo', -- Cómo está el contrato
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id),              -- El cliente tiene que existir
    FOREIGN KEY (ascensor_producto_id) REFERENCES productos(id)    -- El ascensor tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla de órdenes de servicio: cada visita que hace un técnico
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ordenes_servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    contrato_id INT,                            -- De qué contrato sale (puede ser vacío si es emergencia)
    tecnico_id INT NOT NULL,                    -- Qué técnico va
    tipo_servicio ENUM('mantenimiento_rutinario', 'emergencia', 'reparacion') NOT NULL, -- Tipo de visita
    descripcion_problema TEXT,                  -- Qué estaba fallando
    acciones_realizadas TEXT,                   -- Qué hizo el técnico
    estado ENUM('programada', 'en_curso', 'finalizada') DEFAULT 'programada', -- Cómo va la orden
    fecha_programada DATETIME NOT NULL,         -- Cuándo se programó la visita
    fecha_realizacion DATETIME,                 -- Cuándo se hizo de verdad
    FOREIGN KEY (contrato_id) REFERENCES contratos_mantenimiento(id), -- El contrato tiene que existir
    FOREIGN KEY (tecnico_id) REFERENCES usuarios(id)                  -- El técnico tiene que existir
);

-- ---------------------------------------------------------------------
-- Tabla de mensajes de contacto: lo que la gente escribe en el formulario "Contáctanos"
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mensajes_contacto (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- Id automático
    nombre VARCHAR(100) NOT NULL,               -- Quién escribió
    correo VARCHAR(150) NOT NULL,               -- Su correo para responderle
    telefono VARCHAR(20),                       -- Teléfono, opcional
    asunto VARCHAR(150),                        -- De qué se trata, opcional
    mensaje TEXT NOT NULL,                      -- El mensaje como tal
    estado ENUM('nuevo', 'en_proceso', 'resuelto') DEFAULT 'nuevo', -- El admin le va cambiando el estado
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Se pone sola
);

-- =====================================================================
-- DATOS DE PRUEBA
-- Usamos INSERT IGNORE: si el dato ya existe (porque el nombre o correo es UNIQUE),
-- MySQL simplemente lo salta y no saca error. Así el script se puede correr varias veces.
-- =====================================================================

-- Metemos los cuatro roles del sistema
INSERT IGNORE INTO roles (nombre, descripcion) VALUES
('cliente', 'Usuario final que compra o solicita servicios'),          -- El que compra
('administrador', 'Gestor total del sistema'),                          -- El que manda en todo
('tecnico', 'Personal de campo para instalaciones y mantenimiento'),    -- El que va a la obra
('ventas', 'Ejecutivo comercial para cotizaciones');                    -- El que vende

-- Metemos un usuario de prueba por cada rol (las contraseñas son para probar, nada más)
INSERT IGNORE INTO usuarios (nombre, apellido, correo, telefono, contrasena, rol_id) VALUES
('Juan', 'Pérez', 'cliente@correo.com', '+573001234567', 'cliente123', 1),    -- Cliente de prueba
('María', 'Gómez', 'admin@correo.com', '+573009876543', 'admin123', 2),       -- Admin de prueba
('Carlos', 'Ramírez', 'tecnico@correo.com', '+573005554433', 'tecnico123', 3),-- Técnico de prueba
('Ana', 'Torres', 'ventas@correo.com', '+573001112233', 'ventas123', 4);      -- Vendedora de prueba

-- Metemos las tres categorías de productos
INSERT IGNORE INTO categorias (nombre, descripcion) VALUES
('Ascensores Residenciales', 'Ascensores compactos para casas y edificios de baja altura'),     -- Para casas
('Ascensores Comerciales', 'Sistemas de alta capacidad para oficinas y centros comerciales'),   -- Para empresas
('Repuestos y Componentes', 'Piezas de recambio, botoneras, cables y motores');                -- Repuestos

-- Metemos tres productos para que el catálogo no salga vacío
INSERT IGNORE INTO productos (categoria_id, nombre, modelo, descripcion, precio, stock, capacidad_carga_kg, capacidad_personas, activo) VALUES
(1, 'Ascensor Residencial Compacto', 'RES-300', 'Ascensor electromecánico sin cuarto de máquinas para residencias.', 25000.00, 5, 300, 4, TRUE),   -- Ascensor pequeño
(2, 'Ascensor Comercial Alta Velocidad', 'COM-1000', 'Ascensor hidráulico/tracción para edificios corporativos.', 65000.00, 2, 1000, 13, TRUE),  -- Ascensor grande
(3, 'Kit de Botoneras para Cabina', 'BOT-LCD', 'Panel de botones digital con pantalla LCD e indicadores de piso.', 1200.00, 20, NULL, NULL, TRUE); -- Repuesto
