(function () {
  const NotificationNode = document.getElementById('Notification');
  const lastUpdated = NotificationNode.dataset.lastUpdated;
  const dismissNotificationFrom = localStorage.getItem('dismissNotificationFrom');
  
  initNotification();
  bindDismiss();

  function initNotification () {
    const isDismissed = !!dismissNotificationFrom && dismissNotificationFrom === lastUpdated;

    if (!isDismissed) {
      NotificationNode.classList.add('Notification--show');
    }
  }

  function bindDismiss () {
    NotificationNode.querySelector('.Notification__dismiss').onclick = () => {
      NotificationNode.style.opacity = 0;
      setTimeout(() => {
        NotificationNode.remove();
      }, 300);
      localStorage.setItem('dismissNotificationFrom', lastUpdated);
    }
  }
})();
