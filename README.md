# TicketsFoundry - POS System

Sistema de Punto de Venta (POS) moderno, rápido y minimalista desarrollado con **Ruby on Rails 8**. Diseñado para la gestión eficiente de ventas e inventario en tiempo real.

## Características
- **Arquitectura de Alto Rendimiento:** Optimizado para despliegues en contenedores y arquitectura Apple Silicon (M4).
- **Carrito Reactivo:** Interfaz de ventas dinámica desarrollada con Vanilla JavaScript integrada con Turbo.
- **Gestión de Roles:** Niveles de acceso para `Admin` (Inventario/Reportes) y `Empleado` (Ventas).
- **Diseño Moderno:** Interfaz basada en Bootstrap 5 con sidebar colapsable y modo responsivo.

## Stack Tecnológico
- **Framework:** Ruby on Rails 8.0.x
- **Frontend:** Turbo, Hotwire, Bootstrap 5 & Icons.
- **Base de Datos:** SQLite (Desarrollo) / PostgreSQL (Producción).
- **PDFs:** WickedPDF para generación de boletas de venta.

## Instalación Local (Mac M4)
1. **Clonar repositorio:**
   ```bash
   git clone [https://github.com/tu-usuario/pos-system.git](https://github.com/tu-usuario/pos-system.git)
   cd pos-system