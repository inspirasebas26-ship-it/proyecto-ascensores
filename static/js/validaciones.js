// =====================================================================
// validaciones.js - Validaciones del FrontEnd (lado del navegador)
// La idea: revisar los datos ANTES de mandarlos al servidor, para avisarle
// rápido al usuario. Igual el servidor (app.py) vuelve a revisar todo,
// porque el JavaScript se puede desactivar desde el navegador.
// Cada función devuelve true (deje enviar) o false (no envíe el formulario).
// =====================================================================

// Moldes (expresiones regulares) iguales a los que usamos en Python
const PATRON_CORREO = /^[\w.\-]+@[\w\-]+\.[\w.\-]+$/;          // algo@algo.algo
const PATRON_TEXTO = /^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$/;             // Solo letras y espacios
const PATRON_TELEFONO = /^\+?[0-9 ]{7,15}$/;                   // Números con + opcional
const PATRON_MODELO = /^[A-Za-z0-9\-]{2,100}$/;                // Letras, números y guiones

// Función que pinta los errores en la cajita roja "errores-js" (está en _mensajes.html)
function mostrarErrores(errores) {
    const caja = document.getElementById("errores-js");       // Buscamos la cajita por su id
    if (errores.length === 0) {                                // Si no hay errores...
        caja.classList.add("oculto");                          // ...la escondemos
        return true;                                           // ...y dejamos enviar el formulario
    }
    caja.innerHTML = errores.join("<br>");                     // Juntamos los errores con saltos de línea
    caja.classList.remove("oculto");                           // Mostramos la cajita
    caja.scrollIntoView({ behavior: "smooth" });               // Subimos la pantalla para que la vea
    return false;                                              // Y NO dejamos enviar
}

// Validación del login
function validarLogin(form) {
    const errores = [];                                        // Arrancamos sin errores
    if (!PATRON_CORREO.test(form.correo.value.trim())) {       // .test() revisa si el texto cumple el molde
        errores.push("Escribe un correo válido.");
    }
    if (form.contrasena.value.trim() === "") {                 // La contraseña no puede ir vacía
        errores.push("Escribe tu contraseña.");
    }
    return mostrarErrores(errores);                            // Mostramos y decidimos si se envía
}

// Validación del registro
function validarRegistro(form) {
    const errores = [];
    if (!PATRON_TEXTO.test(form.nombre.value.trim())) {
        errores.push("El nombre solo puede tener letras.");
    }
    if (!PATRON_TEXTO.test(form.apellido.value.trim())) {
        errores.push("El apellido solo puede tener letras.");
    }
    if (!PATRON_CORREO.test(form.correo.value.trim())) {
        errores.push("Escribe un correo válido.");
    }
    const telefono = form.telefono.value.trim();               // El teléfono es opcional...
    if (telefono !== "" && !PATRON_TELEFONO.test(telefono)) {  // ...solo lo revisamos si escribieron algo
        errores.push("El teléfono debe tener entre 7 y 15 números.");
    }
    if (form.contrasena.value.length < 6) {                    // .length = cuántos caracteres tiene
        errores.push("La contraseña debe tener mínimo 6 caracteres.");
    }
    if (form.contrasena.value !== form.confirmar.value) {      // Las dos contraseñas iguales
        errores.push("Las contraseñas no coinciden.");
    }
    return mostrarErrores(errores);
}

// Validación del formulario de contacto
function validarContacto(form) {
    const errores = [];
    if (form.nombre.value.trim().length < 3) {
        errores.push("El nombre debe tener mínimo 3 letras.");
    }
    if (!PATRON_CORREO.test(form.correo.value.trim())) {
        errores.push("Escribe un correo válido.");
    }
    if (form.mensaje.value.trim().length < 10) {
        errores.push("El mensaje debe tener mínimo 10 caracteres.");
    }
    return mostrarErrores(errores);
}

// Validación del formulario de productos (crear y editar)
function validarProducto(form) {
    const errores = [];
    if (form.categoria_id.value === "") {                      // Que haya escogido una categoría
        errores.push("Escoge una categoría.");
    }
    if (form.nombre.value.trim().length < 3) {
        errores.push("El nombre debe tener mínimo 3 caracteres.");
    }
    if (!PATRON_MODELO.test(form.modelo.value.trim())) {
        errores.push("El modelo solo puede tener letras, números y guiones.");
    }
    const precio = Number(form.precio.value);                  // Number() convierte el texto en número
    if (isNaN(precio) || precio <= 0) {                        // isNaN = "no es un número"
        errores.push("El precio debe ser un número mayor que cero.");
    }
    const stock = Number(form.stock.value);
    if (form.stock.value === "" || !Number.isInteger(stock) || stock < 0) {  // Entero y no negativo
        errores.push("El stock debe ser un número entero mayor o igual a cero.");
    }
    return mostrarErrores(errores);
}

// Validación del formulario de editar usuario
function validarUsuario(form) {
    const errores = [];
    if (!PATRON_TEXTO.test(form.nombre.value.trim())) {
        errores.push("El nombre solo puede tener letras.");
    }
    if (!PATRON_TEXTO.test(form.apellido.value.trim())) {
        errores.push("El apellido solo puede tener letras.");
    }
    const telefono = form.telefono.value.trim();
    if (telefono !== "" && !PATRON_TELEFONO.test(telefono)) {
        errores.push("El teléfono debe tener entre 7 y 15 números.");
    }
    return mostrarErrores(errores);
}
