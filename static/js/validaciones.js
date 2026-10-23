const PATRON_CORREO = /^[\w.\-]+@[\w\-]+\.[\w.\-]+$/;
const PATRON_TEXTO = /^[A-Za-zÁÉÍÓÚáéíóúÑñÜü ]+$/;
const PATRON_TELEFONO = /^\+?[0-9 ]{7,15}$/;
const PATRON_MODELO = /^[A-Za-z0-9\-]{2,100}$/;

function mostrarErrores(errores) {
    const caja = document.getElementById("errores-js");
    if (errores.length === 0) {
        caja.classList.add("oculto");
        return true;
    }
    caja.innerHTML = errores.join("<br>");
    caja.classList.remove("oculto");
    caja.scrollIntoView({ behavior: "smooth" });
    return false;
}

function validarLogin(form) {
    const errores = [];
    if (!PATRON_CORREO.test(form.correo.value.trim())) {
        errores.push("Escribe un correo válido.");
    }
    if (form.contrasena.value.trim() === "") {
        errores.push("Escribe tu contraseña.");
    }
    return mostrarErrores(errores);
}

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
    const telefono = form.telefono.value.trim();
    if (telefono !== "" && !PATRON_TELEFONO.test(telefono)) {
        errores.push("El teléfono debe tener entre 7 y 15 números.");
    }
    if (form.contrasena.value.length < 6) {
        errores.push("La contraseña debe tener mínimo 6 caracteres.");
    }
    if (form.contrasena.value !== form.confirmar.value) {
        errores.push("Las contraseñas no coinciden.");
    }
    return mostrarErrores(errores);
}

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

function validarProducto(form) {
    const errores = [];
    if (form.categoria_id.value === "") {
        errores.push("Escoge una categoría.");
    }
    if (form.nombre.value.trim().length < 3) {
        errores.push("El nombre debe tener mínimo 3 caracteres.");
    }
    if (!PATRON_MODELO.test(form.modelo.value.trim())) {
        errores.push("El modelo solo puede tener letras, números y guiones.");
    }
    const precio = Number(form.precio.value);
    if (isNaN(precio) || precio <= 0) {
        errores.push("El precio debe ser un número mayor que cero.");
    }
    const stock = Number(form.stock.value);
    if (form.stock.value === "" || !Number.isInteger(stock) || stock < 0) {
        errores.push("El stock debe ser un número entero mayor o igual a cero.");
    }
    return mostrarErrores(errores);
}

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
