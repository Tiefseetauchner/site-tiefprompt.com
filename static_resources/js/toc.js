// "On this page" sidebar: scrollspy + responsive toggle. The markup itself
// (.docs-layout / .docs-content / .docs-toc-toggle / .docs-toc) is emitted
// server-side by toc_filter.lua; this just drives the interactive bits that
// have no build-time equivalent. Styles: scss/_toc.scss.
(function () {
  var toc = document.querySelector('.docs-toc');
  if (!toc) return;

  var toggle = document.querySelector('.docs-toc-toggle');
  var links = Array.prototype.slice.call(toc.querySelectorAll('a[href^="#"]'));
  var root = document.documentElement;

  // --- Sticky offset: the navbar has no fixed height (it toggles shape via
  // .is-floating), so measure it instead of hardcoding a value. ------------
  function updateTocTop() {
    var nav = document.querySelector('nav.navbar');
    var height = nav ? nav.getBoundingClientRect().height : 0;
    root.style.setProperty('--toc-top', (height + 16) + 'px');
  }

  updateTocTop();
  window.addEventListener('resize', updateTocTop);

  // --- Toggle (collapsed dropdown below the lg breakpoint) ----------------
  if (toggle) {
    toggle.addEventListener('click', function () {
      var open = toc.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });

    links.forEach(function (link) {
      link.addEventListener('click', function () {
        toc.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // --- Scrollspy -----------------------------------------------------------
  if (!('IntersectionObserver' in window)) return;

  var linkById = {};
  var headings = [];
  links.forEach(function (link) {
    var id = link.getAttribute('href').slice(1);
    var heading = document.getElementById(id);
    if (heading) {
      linkById[id] = link;
      headings.push(heading);
    }
  });

  var active = null;

  function setActive(id) {
    if (active) active.classList.remove('active');
    active = id ? linkById[id] : null;
    if (active) active.classList.add('active');
  }

  var observer = new IntersectionObserver(
    function (entries) {
      var visible = entries.filter(function (entry) { return entry.isIntersecting; });
      if (visible.length === 0) return;

      // Multiple headings can be in the observed band at once; pick the one
      // closest to the top of the viewport as the "current" section.
      visible.sort(function (a, b) {
        return a.boundingClientRect.top - b.boundingClientRect.top;
      });
      setActive(visible[0].target.id);
    },
    { rootMargin: '-' + (parseInt(getComputedStyle(root).getPropertyValue('--toc-top')) || 80) + 'px 0px -70% 0px' }
  );

  headings.forEach(function (heading) { observer.observe(heading); });
})();
