// Teleprompter mode. Turns the whole site into a live demo of the product:
// mirrored text (the app's mirror feature), teleprompter-sized type, reading
// indicator bars framing a reading band, a circular countdown, and an
// auto-scroll engine you can override by scrolling manually -- just like
// TiefPrompt. No-flash bootstrap: custom-head-2.html. Styles: scss/_fun.scss.
(function () {
  var btn = document.getElementById('funToggle');
  if (!btn) return;

  var root = document.documentElement;
  var reduce = window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var SPEED_MIN = 20, SPEED_MAX = 220; // px/sec
  var speed = 70;
  var playing = false;
  var acc = 0;          // sub-pixel scroll accumulator
  var rafId = null;
  var lastTs = null;
  var chrome = null;    // overlay elements, once built

  // --- Auto-scroll loop ---------------------------------------------------
  // We advance by scrollBy each frame rather than driving an absolute
  // position, so the reader can scroll (wheel, touch, keys, scrollbar) at the
  // same time and the auto-scroll just keeps nudging from wherever they are.

  function maxScroll() {
    return Math.max(0, root.scrollHeight - window.innerHeight);
  }

  function frame(ts) {
    if (lastTs == null) lastTs = ts;
    var dt = (ts - lastTs) / 1000;
    lastTs = ts;

    acc += speed * dt;
    var whole = Math.floor(acc);
    if (whole > 0) {
      acc -= whole;
      if (window.scrollY >= maxScroll() - 1) {
        window.scrollTo(0, 0); // reached the end -> loop back and keep rolling
      } else {
        window.scrollBy(0, whole);
      }
    }
    rafId = requestAnimationFrame(frame);
  }

  function startLoop() {
    if (rafId != null) return;
    lastTs = null;
    acc = 0;
    rafId = requestAnimationFrame(frame);
  }

  function stopLoop() {
    if (rafId != null) { cancelAnimationFrame(rafId); rafId = null; }
  }

  function setPlaying(on) {
    playing = on;
    if (chrome) {
      chrome.playBtn.setAttribute('aria-pressed', on ? 'true' : 'false');
      chrome.playBtn.setAttribute('title', on ? 'Pause' : 'Play');
      chrome.playBtn.innerHTML = on ? ICON.pause : ICON.play;
    }
    if (on) startLoop(); else stopLoop();
  }

  // --- Icons (Bootstrap Icons paths) --------------------------------------

  function svg(inner) {
    return '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" ' +
      'fill="currentColor" viewBox="0 0 16 16" aria-hidden="true">' + inner + '</svg>';
  }
  var ICON = {
    play: svg('<path d="m11.596 8.697-6.363 3.692A.5.5 0 0 1 4.5 11.96V4.04a.5.5 0 0 1 .733-.44l6.363 3.692a.5.5 0 0 1 0 .805z"/>'),
    pause: svg('<path d="M5.5 3.5A1.5 1.5 0 0 1 7 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5m5 0A1.5 1.5 0 0 1 12 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5"/>'),
    mirror: svg('<path d="M8 1a.5.5 0 0 1 .5.5v13a.5.5 0 0 1-1 0v-13A.5.5 0 0 1 8 1"/><path d="M6.5 3.5 1 8l5.5 4.5zM9.5 3.5 15 8l-5.5 4.5z" fill-opacity=".6"/>'),
    exit: svg('<path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708"/>'),
  };

  // --- Overlay chrome -----------------------------------------------------

  function makeButton(title, html) {
    var b = document.createElement('button');
    b.type = 'button';
    b.title = title;
    b.setAttribute('aria-label', title);
    b.innerHTML = html;
    return b;
  }

  function buildChrome() {
    var readerTop = document.createElement('div');
    readerTop.className = 'tp-reader-top';
    var readerBottom = document.createElement('div');
    readerBottom.className = 'tp-reader-bottom';

    var margins = document.createElement('div');
    margins.className = 'tp-margins';

    var controls = document.createElement('div');
    controls.className = 'tp-controls';
    controls.setAttribute('role', 'group');
    controls.setAttribute('aria-label', 'Teleprompter controls');

    var playBtn = makeButton('Play', ICON.play);
    playBtn.addEventListener('click', function () { setPlaying(!playing); });

    var slider = document.createElement('input');
    slider.type = 'range';
    slider.min = SPEED_MIN;
    slider.max = SPEED_MAX;
    slider.step = 5;
    slider.value = speed;
    slider.setAttribute('aria-label', 'Scroll speed');

    var speedLabel = document.createElement('span');
    speedLabel.className = 'tp-speed-label';
    speedLabel.textContent = speed + '';
    slider.addEventListener('input', function () {
      speed = +slider.value;
      speedLabel.textContent = speed + '';
    });

    var mirrorBtn = makeButton('Mirror', ICON.mirror);
    mirrorBtn.setAttribute('aria-pressed',
      root.hasAttribute('data-fun-mirror') ? 'true' : 'false');
    mirrorBtn.addEventListener('click', function () {
      var on = !root.hasAttribute('data-fun-mirror');
      if (on) root.setAttribute('data-fun-mirror', '');
      else root.removeAttribute('data-fun-mirror');
      mirrorBtn.setAttribute('aria-pressed', on ? 'true' : 'false');
      try { localStorage.setItem('tp-fun-mirror', on ? 'on' : 'off'); } catch (e) {}
    });

    var exitBtn = makeButton('Exit teleprompter mode', ICON.exit);
    exitBtn.addEventListener('click', function () { disable(); });

    controls.appendChild(playBtn);
    controls.appendChild(slider);
    controls.appendChild(speedLabel);
    controls.appendChild(mirrorBtn);
    controls.appendChild(exitBtn);

    document.body.appendChild(readerTop);
    document.body.appendChild(readerBottom);
    document.body.appendChild(margins);
    document.body.appendChild(controls);

    chrome = {
      nodes: [readerTop, readerBottom, margins, controls],
      playBtn: playBtn,
    };
  }

  function teardownChrome() {
    if (!chrome) return;
    chrome.nodes.forEach(function (n) { n.remove(); });
    chrome = null;
  }

  // --- Circular countdown -------------------------------------------------

  function countdown(seconds, done) {
    var overlay = document.createElement('div');
    overlay.className = 'tp-countdown';

    var R = 54;
    var C = 2 * Math.PI * R;
    overlay.innerHTML =
      '<div class="tp-ring">' +
      '  <svg viewBox="0 0 120 120">' +
      '    <circle class="tp-ring-disc" cx="60" cy="60" r="48"/>' +
      '    <circle class="tp-ring-track" cx="60" cy="60" r="' + R + '"/>' +
      '    <circle class="tp-ring-progress" cx="60" cy="60" r="' + R + '"' +
      '      stroke-dasharray="' + C + '" stroke-dashoffset="0"/>' +
      '  </svg>' +
      '  <div class="tp-ring-num"></div>' +
      '</div>';
    document.body.appendChild(overlay);

    var prog = overlay.querySelector('.tp-ring-progress');
    var num = overlay.querySelector('.tp-ring-num');
    var start = null;

    function step(ts) {
      if (start == null) start = ts;
      var elapsed = (ts - start) / 1000;
      var remaining = Math.max(0, seconds - elapsed);
      num.textContent = Math.ceil(remaining) || 1;
      var frac = remaining / seconds;            // 1 -> 0
      prog.style.strokeDashoffset = C * (1 - frac); // full ring -> empty
      if (elapsed >= seconds) { overlay.remove(); done(); return; }
      requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }

  // --- Enable / disable ---------------------------------------------------

  function enable(withCountdown) {
    root.setAttribute('data-fun', 'on');
    var mirrorPref;
    try { mirrorPref = localStorage.getItem('tp-fun-mirror'); } catch (e) {}
    if (mirrorPref !== 'off') root.setAttribute('data-fun-mirror', '');
    try { localStorage.setItem('tp-fun', 'on'); } catch (e) {}
    btn.setAttribute('aria-pressed', 'true');

    buildChrome();
    window.scrollTo(0, 0);

    if (reduce) { setPlaying(false); return; } // no auto-scroll for reduced motion
    if (withCountdown) countdown(3, function () { setPlaying(true); });
    else setPlaying(true);
  }

  function disable() {
    setPlaying(false);
    teardownChrome();
    root.removeAttribute('data-fun');
    root.removeAttribute('data-fun-mirror');
    try { localStorage.setItem('tp-fun', 'off'); } catch (e) {}
    btn.setAttribute('aria-pressed', 'false');
  }

  btn.addEventListener('click', function () {
    if (root.getAttribute('data-fun') === 'on') disable();
    else enable(true);
  });

  // Already on from a previous page? The head script applied the framing
  // pre-paint; build the controls and start rolling after a short settle.
  if (root.getAttribute('data-fun') === 'on') {
    btn.setAttribute('aria-pressed', 'true');
    buildChrome();
    if (!reduce) setTimeout(function () { setPlaying(true); }, 1200);
  }
})();
