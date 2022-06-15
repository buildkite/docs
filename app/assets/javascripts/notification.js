(function () {
  const NotificationNode = document.getElementById('Notification');
  
  initNotification();
  bindDismiss();

  function initNotification () {
    const isDismissed = localStorage.getItem('isNotificationDismissed');

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
      localStorage.setItem('isNotificationDismissed', true);
    }
  }
})();
