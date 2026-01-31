let cart = {};

function addToCart(productId, name, price) {
  if (!cart[productId]) {
    cart[productId] = { product_id: productId, name: name, price: price, quantity: 0 };
  }
  cart[productId].quantity += 1;
  renderCart();
}

function decreaseFromCart(productId) {
  if (cart[productId]) {
    cart[productId].quantity -= 1;
    if (cart[productId].quantity <= 0) {
      delete cart[productId];
    }
    renderCart();
  }
}

function renderCart() {
  const cartBody = document.getElementById("cart-body");
  const cartSection = document.getElementById("cart-section");
  const productsSection = document.getElementById("products-section");
  const checkoutBtn = document.getElementById("checkout-btn");
  
  let total = 0;
  let rows = "";

  const items = Object.values(cart);

  if (items.length === 0) {
    // Si está vacío, ocultamos y expandimos productos
    if(cartSection) cartSection.classList.add("d-none");
    if(productsSection) {
        productsSection.classList.remove("col-md-8");
        productsSection.classList.add("col-md-12");
    }
  } else {
    // Si hay items, mostramos carrito
    if(cartSection) cartSection.classList.remove("d-none");
    if(productsSection) {
        productsSection.classList.remove("col-md-12");
        productsSection.classList.add("col-md-8");
    }

    items.forEach(item => {
      let subtotal = item.price * item.quantity;
      total += subtotal;
      rows += `
        <tr>
          <td><small class="fw-bold">${item.name}</small></td>
          <td class="text-center">${item.quantity}</td>
          <td class="text-end">$${subtotal.toLocaleString()}</td>
          <td class="text-end">
            <button class="btn btn-outline-danger btn-sm border-0" onclick="decreaseFromCart(${item.product_id})">
              <i class="bi bi-dash-circle"></i>
            </button>
          </td>
        </tr>
      `;
    });
  }

  if(cartBody) cartBody.innerHTML = rows;
  const totalDisplay = document.getElementById("cart-total");
  if(totalDisplay) totalDisplay.innerHTML = `<strong>Total: $${total.toLocaleString()}</strong>`;
}

document.addEventListener("DOMContentLoaded", () => {
  const checkoutBtn = document.getElementById("checkout-btn");

  if (checkoutBtn) {
    checkoutBtn.addEventListener("click", () => {
      if (Object.keys(cart).length === 0) return alert("El carrito está vacío");

      // OBTENER EL TOKEN DE SEGURIDAD DE RAILS
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

      checkoutBtn.disabled = true;
      checkoutBtn.innerHTML = `<span class="spinner-border spinner-border-sm"></span> Procesando...`;

      fetch("/cart/checkout", {
        method: "POST",
        headers: { 
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken  // <--- Esto es vital en Rails
        },
        body: JSON.stringify({ cart: Object.values(cart) })
      })
      .then(async res => {
        const data = await res.json();
        if (res.ok) {
          alert("✅ " + data.message);
          cart = {};
          renderCart();
          // Redirigir al recibo que ya tienes creado
          window.location.href = `/sales/${data.sale_id}/receipt`;
        } else {
          throw new Error(data.error || "Error desconocido");
        }
      })
      .catch(err => {
        alert("❌ Error: " + err.message);
        checkoutBtn.disabled = false;
        checkoutBtn.innerHTML = `<i class="bi bi-credit-card me-2"></i> Finalizar compra`;
      });
    });
  }

  renderCart(); 
});

window.addToCart = addToCart;
window.decreaseFromCart = decreaseFromCart;