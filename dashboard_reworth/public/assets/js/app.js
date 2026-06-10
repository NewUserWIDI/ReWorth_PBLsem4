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

(() => {
  const shell = document.querySelector('.dashboard-shell');
  if (!shell) return;

  const toggleButton = document.querySelector('[data-sidebar-toggle]');
  const overlay = document.querySelector('[data-sidebar-overlay]');
  const mobileQuery = window.matchMedia('(max-width: 1100px)');

  const syncOverlay = () => {
    if (!overlay) return;
    overlay.hidden = !shell.classList.contains('sidebar-open') || !mobileQuery.matches;
  };

  const closeSidebar = () => {
    shell.classList.remove('sidebar-open');
    if (toggleButton) {
      toggleButton.setAttribute('aria-expanded', 'false');
    }
    syncOverlay();
  };

  const toggleSidebar = () => {
    const isOpen = shell.classList.toggle('sidebar-open');
    if (toggleButton) {
      toggleButton.setAttribute('aria-expanded', String(isOpen));
    }
    syncOverlay();
  };

  if (toggleButton) {
    toggleButton.setAttribute('aria-expanded', 'false');
    toggleButton.addEventListener('click', (event) => {
      event.preventDefault();
      toggleSidebar();
    });
  }

  if (overlay) {
    overlay.addEventListener('click', closeSidebar);
  }

  document.addEventListener('click', (event) => {
    if (!mobileQuery.matches) return;
    const link = event.target.closest('.sidebar a');
    if (!link) return;
    closeSidebar();
  });

  mobileQuery.addEventListener('change', () => {
    if (!mobileQuery.matches) {
      closeSidebar();
    } else {
      syncOverlay();
    }
  });

  syncOverlay();
})();
