(() => {
    const url = 'https://i.imgur.com/n6ipka6.png';
  
    let style = document.getElementById('strudel-bg-style');
    if (!style) {
      style = document.createElement('style');
      style.id = 'strudel-bg-style';
      style.textContent = `
        #strudel-bg {
          position: fixed; inset: 0;
          background-image: url(${JSON.stringify(url)});
          background-size: cover;
          background-position: center;
          background-repeat: no-repeat;
          z-index: 0;
          pointer-events: none;
        }
        #root, #app, body > div { position: relative; z-index: 1; }
      `;
      document.head.appendChild(style);
    }
  
    if (!document.getElementById('strudel-bg')) {
      const bg = document.createElement('div');
      bg.id = 'strudel-bg';
      document.body.prepend(bg);
    } else {
      document.getElementById('strudel-bg').style.backgroundImage = `url(${url})`;
    }
  })();