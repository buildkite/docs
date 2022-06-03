(function () {
  const tables = Array.from(document.querySelectorAll('table.responsive-table'));

  if (tables.length > 0) {
    const fauxTh = document.createElement('th');
    fauxTh.classList.add('responsive-table__faux-th');
    fauxTh.setAttribute('aria-hidden', 'true');
  
    tables.forEach(table => {
      const trs = Array.from(table.querySelectorAll('tbody tr'));
      const thead_ths = Array.from(table.querySelectorAll('thead th'));

      if (trs.length > 0 && thead_ths.length > 0) trs.forEach(tr => {
        const tds = Array.from(tr.getElementsByTagName('td'));

        if (tds.length > 0) tds.forEach((td, i) => {
          const th = fauxTh;
          th.innerText = thead_ths[i]?.innerText || '';

          td.insertAdjacentHTML('beforebegin', th.outerHTML);
        });
      });
    });
  }
})();
