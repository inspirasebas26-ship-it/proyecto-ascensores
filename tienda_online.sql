CREATE DATABASE IF NOT EXISTS tienda_ascensores;
USE tienda_ascensores;
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    contrasena VARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);
CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    modelo VARCHAR(100) UNIQUE,
    descripcion TEXT,
    precio DECIMAL(12, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    capacidad_carga_kg INT COMMENT 'Para ascensores',
    capacidad_personas INT COMMENT 'Para ascensores',
    imagen_url VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
CREATE TABLE IF NOT EXISTS cotizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    estado ENUM('pendiente', 'en_revision', 'aprobada', 'rechazada') DEFAULT 'pendiente',
    detalles_edificio TEXT NOT NULL COMMENT 'Número de pisos, tipo de edificio, espacio disponible',
    presupuesto_estimado DECIMAL(12, 2),
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id)
);
CREATE TABLE IF NOT EXISTS proyectos_instalacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cotizacion_id INT UNIQUE,
    cliente_id INT NOT NULL,
    tecnico_asignado_id INT,
    direccion_obra VARCHAR(255) NOT NULL,
    estado ENUM('planificacion', 'en_proceso', 'completado', 'suspendido') DEFAULT 'planificacion',
    fecha_inicio_estimada DATE,
    fecha_fin_estimada DATE,
    FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones(id),
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    FOREIGN KEY (tecnico_asignado_id) REFERENCES usuarios(id)
);
CREATE TABLE IF NOT EXISTS pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    estado ENUM('pendiente', 'pagado', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    total DECIMAL(12, 2) NOT NULL,
    direccion_envio VARCHAR(255) NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id)
);
CREATE TABLE IF NOT EXISTS detalle_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);
CREATE TABLE IF NOT EXISTS contratos_mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    ascensor_producto_id INT NOT NULL,
    tipo ENUM('preventivo', 'correctivo', 'integral') NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('activo', 'vencido', 'cancelado') DEFAULT 'activo',
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    FOREIGN KEY (ascensor_producto_id) REFERENCES productos(id)
);
CREATE TABLE IF NOT EXISTS ordenes_servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id INT,
    tecnico_id INT NOT NULL,
    tipo_servicio ENUM('mantenimiento_rutinario', 'emergencia', 'reparacion') NOT NULL,
    descripcion_problema TEXT,
    acciones_realizadas TEXT,
    estado ENUM('programada', 'en_curso', 'finalizada') DEFAULT 'programada',
    fecha_programada DATETIME NOT NULL,
    fecha_realizacion DATETIME,
    FOREIGN KEY (contrato_id) REFERENCES contratos_mantenimiento(id),
    FOREIGN KEY (tecnico_id) REFERENCES usuarios(id)
);
CREATE TABLE IF NOT EXISTS mensajes_contacto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    asunto VARCHAR(150),
    mensaje TEXT NOT NULL,
    estado ENUM('nuevo', 'en_proceso', 'resuelto') DEFAULT 'nuevo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO roles (nombre, descripcion) VALUES
('cliente', 'Usuario final que compra o solicita servicios'),
('administrador', 'Gestor total del sistema'),
('tecnico', 'Personal de campo para instalaciones y mantenimiento'),
('ventas', 'Ejecutivo comercial para cotizaciones');
INSERT IGNORE INTO usuarios (nombre, apellido, correo, telefono, contrasena, rol_id) VALUES
('Juan', 'Pérez', 'cliente@correo.com', '+573001234567', 'cliente123', 1),
('María', 'Gómez', 'admin@correo.com', '+573009876543', 'admin123', 2),
('Carlos', 'Ramírez', 'tecnico@correo.com', '+573005554433', 'tecnico123', 3),
('Ana', 'Torres', 'ventas@correo.com', '+573001112233', 'ventas123', 4);
INSERT IGNORE INTO categorias (nombre, descripcion) VALUES
('Ascensores Residenciales', 'Ascensores compactos para casas y edificios de baja altura'),
('Ascensores Comerciales', 'Sistemas de alta capacidad para oficinas y centros comerciales'),
('Repuestos y Componentes', 'Piezas de recambio, botoneras, cables y motores');
INSERT IGNORE INTO productos (categoria_id, nombre, modelo, descripcion, precio, stock, capacidad_carga_kg, capacidad_personas, activo) VALUES
(1, 'Ascensor Residencial Compacto', 'RES-300', 'Ascensor electromecánico sin cuarto de máquinas para residencias.', 25000.00, 5, 300, 4, TRUE),
(2, 'Ascensor Comercial Alta Velocidad', 'COM-1000', 'Ascensor hidráulico/tracción para edificios corporativos.', 65000.00, 2, 1000, 13, TRUE),
(3, 'Kit de Botoneras para Cabina', 'BOT-LCD', 'Panel de botones digital con pantalla LCD e indicadores de piso.', 1200.00, 20, NULL, NULL, TRUE);
