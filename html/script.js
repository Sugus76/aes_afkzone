document.addEventListener('DOMContentLoaded', () => {
  let countdownInterval = null;
  let remainingSec = 0;

  const pressBox      = document.querySelector('.press-key-box');
  const afkContainer  = document.querySelector('.afk-container');
  const timerEl       = document.getElementById('cooldown-timer');
  const itemsBox      = document.querySelector('.afk-items');

  if (!pressBox || !afkContainer || !timerEl || !itemsBox) {
    console.error('AFK Zone NUI: Missing required elements');
    return;
  }

  function formatTime(sec) {
    const m = Math.floor(sec / 60).toString().padStart(2, '0');
    const s = (sec % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  }

  function showPressBox(keyChar, text) {
    pressBox.innerHTML = `
      <span><b>กดปุ่ม</b></span>
      <div class="key-button"><b>${keyChar}</b></div>
      <span><b>${text}</b></span>
    `;
    pressBox.classList.add('visible');
  }

  function hidePressBox() {
    pressBox.classList.remove('visible');
  }

  function startCountdown() {
    afkContainer.style.display = 'block';
    afkContainer.classList.remove('slide-out');
    afkContainer.classList.add('slide-in');

    timerEl.innerText = formatTime(remainingSec);
    if (countdownInterval) clearInterval(countdownInterval);
    countdownInterval = setInterval(() => {
      if (remainingSec > 0) {
        remainingSec--;
        timerEl.innerText = formatTime(remainingSec);
      } else {
        clearInterval(countdownInterval);
        countdownInterval = null;
      }
    }, 1000);
  }

  function showAFKNotification(message) {
    const containerId = 'afk-toast-container';
    let container = document.getElementById(containerId);
    
    if (!container) {
      container = document.createElement('div');
      container.id = containerId;
      container.className = 'afk-toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = 'afk-toast';
    toast.textContent = message;

    container.appendChild(toast);

    setTimeout(() => {
      toast.classList.add('fadeout');
      setTimeout(() => toast.remove(), 1000);
    }, 3000);
  }

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'notify' && data.message) {
      showAFKNotification(data.message);
    }
  });



  function stopAFK() {
    if (countdownInterval) clearInterval(countdownInterval);
    afkContainer.classList.remove('slide-in');
    afkContainer.classList.add('slide-out');
    setTimeout(() => {
      afkContainer.style.display = 'none';
    }, 600);
  }

  function renderItems(items) {
    itemsBox.innerHTML = '';
    const shouldScroll = items.length > 2;
    const displayItems = shouldScroll ? [...items, ...items] : items;
    const wrapper = document.createElement('div');
    wrapper.className = shouldScroll ? 'afk-items-wrapper scroll' : 'afk-items-wrapper';

    displayItems.forEach(item => {
      const img = document.createElement('img');
      const itemName = item.item || 'default';
      const count    = item.count || 1;

      img.src    = `nui://vorp_inventory/html/img/items/${itemName}.png`;
      img.alt    = itemName;
      img.title  = `${itemName} x${count}`;
      img.onerror = function() {
        this.onerror = null;
        this.src     = 'nui://aes_afkzone/html/img/default.png';
      };

      wrapper.appendChild(img);
    });

    itemsBox.appendChild(wrapper);
  }

  window.addEventListener('message', (event) => {
    switch (event.data.action) {
      case 'showPressStart':
        remainingSec = event.data.cooldown || 60;
        timerEl.innerText = formatTime(remainingSec);
        showPressBox('R', 'เพื่อเริ่ม AFK');
        break;

      case 'hidePressStart':
        hidePressBox();
        break;

      case 'showAFK':
        showPressBox('X', 'เพื่อยกเลิก AFK');
        renderItems(event.data.items || []);
        startCountdown();
        break;

      case 'hideAFK':
        hidePressBox();
        stopAFK();
        break;

      case 'updateTimer':
        if (typeof event.data.time === 'string') {
          timerEl.innerText = event.data.time;
        } else if (typeof event.data.seconds === 'number') {
          remainingSec = event.data.seconds;
          timerEl.innerText = formatTime(remainingSec);
        }
        break;
    }
  });

  document.addEventListener('keydown', (e) => {
    const key = e.key.toUpperCase();
    const promptVisible = pressBox.classList.contains('visible');
    const afkVisible    = afkContainer.style.display === 'block';

    if (key === 'R' && promptVisible) {
      fetch(`https://${GetParentResourceName()}/start`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      });
    }

    if (key === 'X' && (promptVisible || afkVisible)) {
      fetch(`https://${GetParentResourceName()}/cancel`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      });
    }
  });
});
