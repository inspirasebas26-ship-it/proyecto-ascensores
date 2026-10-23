const botonMenu = document.getElementById("boton-menu");
const listaEnlaces = document.getElementById("menu-enlaces");

if (botonMenu && listaEnlaces) {
    botonMenu.addEventListener("click", function () {
        listaEnlaces.classList.toggle("abierto");
    });
}
