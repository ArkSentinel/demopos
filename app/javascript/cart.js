// Usamos window.cart para que la variable persista entre navegaciones de Turbo si es necesario
window.cart = window.cart || {};

function addToCart(productId, name, price, availableStock) {
  // Aseguramos que el objeto exista
  if (!window.cart[productId]) {
    window.cart[productId] = { product_id: productId, name: name, price: price, quantity: 0 };
  }

  const currentQty = window.cart[productId].quantity;
  
  if (currentQty >= availableStock) {
    alert("¡No hay más stock disponible!");
    return;
  }

  window.cart[productId].quantity += 1;
  renderCart();
}

function decreaseFromCart(productId) {
  if (window.cart[productId]) {
    window.cart[productId].quantity -= 1;
    if (window.cart[productId].quantity <= 0) {
      delete window.cart[productId];
    }
    renderCart();
  }
}

function clearCart() {
  window.cart = {};
  renderCart();
}

function renderCart() {
  const cartBody = document.getElementById("cart-body");
  const cartSection = document.getElementById("cart-section");
  const productsSection = document.getElementById("products-section");
  
  let total = 0;
  let rows = "";
  const items = Object.values(window.cart);

  if (items.length === 0) {
    if(cartSection) cartSection.classList.add("d-none");
    if(productsSection) {
        productsSection.classList.replace("col-xxl-9", "col-xxl-12");
        productsSection.classList.replace("col-xl-8", "col-xl-12");
    }
  } else {
    if(cartSection) cartSection.classList.remove("d-none");
    if(productsSection) {
        productsSection.classList.replace("col-xxl-12", "col-xxl-9");
        productsSection.classList.replace("col-xl-12", "col-xl-8");
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

  if(cartBody) {
    cartBody.innerHTML = rows || '<tr><td colspan="4" class="text-center py-4 text-muted">Vacio</td></tr>';
  }
  
  const totalDisplay = document.getElementById("cart-total");
  if(totalDisplay) totalDisplay.innerText = `$${total.toLocaleString()}`;
}

// Escuchamos turbo:load para que funcione al navegar y al recargar
document.addEventListener("turbo:load", () => {
  const checkoutBtn = document.getElementById("checkout-btn");

  if (checkoutBtn) {
    // Limpiamos listeners previos para evitar ejecuciones dobles
    checkoutBtn.replaceWith(checkoutBtn.cloneNode(true));
    const newBtn = document.getElementById("checkout-btn");

    newBtn.addEventListener("click", () => {
      const items = Object.values(window.cart);
      if (items.length === 0) return alert("El carrito está vacío");

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

      newBtn.disabled = true;
      newBtn.innerHTML = `<span class="spinner-border spinner-border-sm"></span>...`;

      fetch("/cart/checkout", {
        method: "POST",
        headers: { 
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken 
        },
        body: JSON.stringify({ cart: items })
      })
      .then(async res => {
        const data = await res.json();
        if (res.ok) {
          window.cart = {};
          window.location.href = `/sales/${data.sale_id}/receipt`;
        } else {
          throw new Error(data.error || "Error");
        }
      })
      .catch(err => {
        alert("❌ " + err.message);
        newBtn.disabled = false;
        newBtn.innerHTML = `<i class="bi bi-cash-stack me-2"></i> Finalizar compra`;
      });
    });
  }
  renderCart(); 
});

// Exponer funciones globalmente para los onclick del HTML
window.addToCart = addToCart;
window.decreaseFromCart = decreaseFromCart;
window.clearCart = clearCart;