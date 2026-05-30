document.addEventListener('submit', (event) => {
  const form = event.target;
  const message = form.dataset.confirm;

  if (message && !window.confirm(message)) {
    event.preventDefault();
  }
});

document.addEventListener('click', (event) => {
  const target = event.target.closest('[data-confirm]');
  if (!target) return;

  const message = target.dataset.confirm;
  if (message && !window.confirm(message)) {
    event.preventDefault();
  }
});
