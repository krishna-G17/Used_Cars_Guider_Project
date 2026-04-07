/* ============================================================
   UCPP Dashboard — main JS
   Uses Chart.js (loaded via CDN) and wordcloud2.js (CDN)
   ============================================================ */

"use strict";

// ── Chart instances (kept so we can destroy before re-draw) ──
const charts = {};

// ── Colour palette ──
const COLORS = {
  accent:  '#4f8ef7',
  accent2: '#7c5cbf',
  green:   '#2ecf82',
  yellow:  '#f5c842',
  red:     '#f25c5c',
  muted:   '#7a8299',
  gridLine:'#2e3347',
  text:    '#e2e6f0',
};

const CHART_DEFAULTS = {
  color: COLORS.text,
  borderColor: COLORS.gridLine,
  plugins: { legend: { labels: { color: COLORS.text, boxWidth: 12, font: { size: 12 } } } },
  scales: {
    x: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
    y: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
  },
};

// ── Utilities ──
function fmt$(n) {
  if (n == null) return '—';
  return '$' + Number(n).toLocaleString('en-US', { maximumFractionDigits: 0 });
}
function fmtN(n) {
  if (n == null) return '—';
  return Number(n).toLocaleString('en-US', { maximumFractionDigits: 0 });
}
function qs(id) { return document.getElementById(id); }
function setKPI(id, val, sub) {
  qs(id + '-value').textContent = val;
  if (sub !== undefined) qs(id + '-sub').textContent = sub;
}
function destroyChart(key) {
  if (charts[key]) { charts[key].destroy(); delete charts[key]; }
}
function showBanner(msg, isError = false) {
  const b = qs('status-banner');
  b.textContent = msg;
  b.style.display = 'block';
  b.className = isError ? 'error' : '';
}
function hideBanner() { qs('status-banner').style.display = 'none'; }

// ── Build query string from search fields ──
function searchParams() {
  return {
    manufacturer: qs('f-manufacturer').value.trim(),
    model:        qs('f-model').value.trim(),
    year:         qs('f-year').value.trim(),
    state:        qs('f-state').value.trim(),
    city:         qs('f-city').value.trim(),
  };
}

// ── Main search ──
async function runSearch() {
  const btn = qs('btn-search');
  btn.disabled = true;
  btn.textContent = 'Searching…';
  hideBanner();

  const p = searchParams();
  const qs2 = new URLSearchParams(p).toString();

  try {
    const [priceRes, freqRes, condRes, trendRes, radarRes, wcRes, listRes] =
      await Promise.all([
        fetch('/api/price-range?'      + qs2).then(r => r.json()),
        fetch('/api/listing-frequency?'+ qs2).then(r => r.json()),
        fetch('/api/condition-price?'  + qs2).then(r => r.json()),
        fetch('/api/price-trend?'      + new URLSearchParams({
          manufacturer: p.manufacturer, model: p.model }).toString()).then(r => r.json()),
        fetch('/api/nhtsa-radar?'      + qs2).then(r => r.json()),
        fetch('/api/nhtsa-wordcloud?'  + qs2).then(r => r.json()),
        fetch('/api/search?'           + qs2).then(r => r.json()),
      ]);

    renderKPIs(priceRes);
    renderFrequency(freqRes);
    renderCondition(condRes);
    renderTrend(trendRes);
    renderRadar(radarRes);
    renderWordCloud(wcRes);
    renderListings(listRes);

    // Similar cars (uses avg price from price range)
    const avgPrice = priceRes.avg_price || 0;
    const simRes = await fetch('/api/similar-cars?' + new URLSearchParams({
      manufacturer: p.manufacturer, model: p.model, year: p.year, price: avgPrice,
    })).then(r => r.json());
    renderSimilarCars(simRes);

  } catch (err) {
    showBanner('Error fetching data: ' + err.message, true);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Search';
  }
}

// ── KPI cards ──
function renderKPIs(data) {
  if (data.status !== 'ok') return;
  setKPI('kpi-avg',   fmt$(data.avg_price),      `${fmtN(data.listing_count)} listings`);
  setKPI('kpi-min',   fmt$(data.min_price),       'Lowest listed');
  setKPI('kpi-max',   fmt$(data.max_price),       'Highest listed');
  setKPI('kpi-odo',   fmtN(data.avg_odometer) + ' mi', 'Avg odometer');
}

// ── Listing frequency bar chart ──
function renderFrequency(data) {
  if (data.status !== 'ok') return;
  const items = (data.data || []).slice(0, 15);
  destroyChart('freq');
  const ctx = qs('chart-freq').getContext('2d');
  charts.freq = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: items.map(d => d.state || '?'),
      datasets: [{
        label: 'Listings',
        data:  items.map(d => d.count),
        backgroundColor: COLORS.accent,
        borderRadius: 4,
      }],
    },
    options: {
      ...CHART_DEFAULTS,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
        y: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
      },
    },
  });
}

// ── Condition vs price bar chart ──
function renderCondition(data) {
  if (data.status !== 'ok') return;
  const items = data.data || [];
  destroyChart('cond');
  const ctx = qs('chart-cond').getContext('2d');
  charts.cond = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: items.map(d => d.condition || 'unknown'),
      datasets: [{
        label: 'Avg Price ($)',
        data:  items.map(d => d.avg_price),
        backgroundColor: [COLORS.green, COLORS.accent, COLORS.yellow, COLORS.red, COLORS.accent2],
        borderRadius: 4,
      }],
    },
    options: {
      ...CHART_DEFAULTS,
      indexAxis: 'y',
      plugins: { legend: { display: false } },
      scales: {
        x: {
          ticks: { color: COLORS.muted, callback: v => '$' + v.toLocaleString() },
          grid:  { color: COLORS.gridLine },
        },
        y: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
      },
    },
  });
}

// ── Price trend / depreciation line chart ──
function renderTrend(data) {
  if (data.status !== 'ok') return;
  const items = data.data || [];
  destroyChart('trend');
  const ctx = qs('chart-trend').getContext('2d');
  charts.trend = new Chart(ctx, {
    type: 'line',
    data: {
      labels: items.map(d => d.year),
      datasets: [{
        label: 'Avg Listed Price ($)',
        data:  items.map(d => d.avg_price),
        borderColor: COLORS.accent,
        backgroundColor: COLORS.accent + '22',
        fill: true,
        tension: 0.35,
        pointRadius: 4,
        pointBackgroundColor: COLORS.accent,
      }],
    },
    options: {
      ...CHART_DEFAULTS,
      scales: {
        x: { ticks: { color: COLORS.muted }, grid: { color: COLORS.gridLine } },
        y: {
          ticks: { color: COLORS.muted, callback: v => '$' + v.toLocaleString() },
          grid:  { color: COLORS.gridLine },
        },
      },
    },
  });
}

// ── NHTSA radar / spider chart ──
function renderRadar(data) {
  if (data.status !== 'ok' || !data.data) return;
  const scores = data.data.scores || {};
  const labels = Object.keys(scores);
  const values = Object.values(scores);

  destroyChart('radar');
  const ctx = qs('chart-radar').getContext('2d');
  charts.radar = new Chart(ctx, {
    type: 'radar',
    data: {
      labels,
      datasets: [{
        label: 'Complaint score (normalised)',
        data:  values,
        backgroundColor: COLORS.accent2 + '44',
        borderColor:     COLORS.accent2,
        pointBackgroundColor: COLORS.accent2,
        pointRadius: 4,
      }],
    },
    options: {
      plugins: {
        legend: { labels: { color: COLORS.text, font: { size: 12 } } },
        tooltip: {
          callbacks: {
            label: ctx2 => {
              const raw = data.data.raw || {};
              const cat = labels[ctx2.dataIndex];
              return `${ctx2.formattedValue}  (${raw[cat] || 0} complaints)`;
            },
          },
        },
      },
      scales: {
        r: {
          min: 0, max: 100,
          ticks:       { color: COLORS.muted, backdropColor: 'transparent', font: { size: 10 } },
          grid:        { color: COLORS.gridLine },
          pointLabels: { color: COLORS.text, font: { size: 11 } },
          angleLines:  { color: COLORS.gridLine },
        },
      },
    },
  });

  // Show total complaint count
  const total = data.data.total || 0;
  qs('radar-total').textContent = total
    ? `Based on ${fmtN(total)} NHTSA complaints (1995–2023)`
    : '';
}

// ── Word cloud ──
function renderWordCloud(data) {
  const container = qs('wc-container');
  const empty     = qs('wc-empty');

  container.innerHTML = '';

  if (data.status !== 'ok' || !data.data || data.data.length === 0) {
    empty.style.display = 'block';
    container.appendChild(empty);
    return;
  }

  empty.style.display = 'none';

  const words = data.data.map(d => [d.text, d.value]);
  const canvas = document.createElement('canvas');
  canvas.width  = container.offsetWidth  || 500;
  canvas.height = container.offsetHeight || 260;
  container.appendChild(canvas);

  WordCloud(canvas, {
    list:            words,
    gridSize:        8,
    weightFactor:    n => Math.max(12, n * 0.36),
    fontFamily:      'Inter, Segoe UI, sans-serif',
    color:           () => {
      const palette = ['#4f8ef7','#7c5cbf','#2ecf82','#f5c842','#f25c5c','#5bc8d9'];
      return palette[Math.floor(Math.random() * palette.length)];
    },
    backgroundColor: 'transparent',
    rotateRatio:     0.3,
    minRotation:     -Math.PI / 6,
    maxRotation:      Math.PI / 6,
    shuffle:         true,
  });
}

// ── Listings table ──
function renderListings(data) {
  const tbody = qs('listings-body');
  tbody.innerHTML = '';
  if (data.status !== 'ok' || !data.data.length) {
    tbody.innerHTML = '<tr><td colspan="8" style="color:var(--muted);text-align:center;padding:20px">No listings found</td></tr>';
    return;
  }
  data.data.forEach(row => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${row.Manufacturer || '—'}</td>
      <td>${row.Model || '—'}</td>
      <td>${row.Year || '—'}</td>
      <td>${fmt$(row.Price)}</td>
      <td>${fmtN(row.Odometer)} mi</td>
      <td>${row.City || '—'}, ${row.State || '—'}</td>
      <td>${row['title status'] || '—'}</td>
      <td>${row.URL ? `<a href="${row.URL}" target="_blank">View</a>` : '—'}</td>
    `;
    tbody.appendChild(tr);
  });
}

// ── Similar cars ──
function renderSimilarCars(data) {
  const grid = qs('similar-grid');
  grid.innerHTML = '';
  if (data.status !== 'ok' || !data.data.length) {
    grid.innerHTML = '<p style="color:var(--muted);font-size:13px">No similar listings found.</p>';
    return;
  }
  data.data.forEach(car => {
    const div = document.createElement('div');
    div.className = 'sim-card';
    div.innerHTML = `
      <div class="sim-title">${car.Year || ''} ${car.Manufacturer || ''} ${car.Model || ''}</div>
      <div class="sim-price">${fmt$(car.Price)}</div>
      <div class="sim-meta">
        ${fmtN(car.Odometer)} mi &nbsp;·&nbsp; ${car.City || ''}, ${car.State || ''}<br>
        Title: ${car['title status'] || '—'}
      </div>
      ${car.URL ? `<a class="sim-link" href="${car.URL}" target="_blank">View listing →</a>` : ''}
    `;
    grid.appendChild(div);
  });
}

// ── Price prediction ──
async function runPredict() {
  const btn = qs('btn-predict');
  btn.disabled = true;
  const result = qs('predict-result');
  result.textContent = 'Predicting…';

  const sp = searchParams();
  const body = {
    manufacturer: sp.manufacturer,
    model:        sp.model,
    year:         sp.year,
    odometer:     qs('p-odometer').value,
    state:        sp.state,
    transmission: qs('p-transmission').value,
    cylinders:    qs('p-cylinders').value,
    drive:        qs('p-drive').value,
    fuel:         qs('p-fuel').value,
    title_status: qs('p-title-status').value,
  };

  try {
    const res = await fetch('/api/predict-price', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    }).then(r => r.json());

    if (res.status === 'ok') {
      result.textContent = `Estimated Price: ${fmt$(res.predicted_price)}`;
    } else {
      result.textContent = 'Error: ' + res.message;
      result.style.color = 'var(--red)';
    }
  } catch (err) {
    result.textContent = 'Request failed: ' + err.message;
    result.style.color = 'var(--red)';
  } finally {
    btn.disabled = false;
  }
}

// ── Wire up events ──
document.addEventListener('DOMContentLoaded', () => {
  qs('btn-search').addEventListener('click', runSearch);
  qs('btn-predict').addEventListener('click', runPredict);

  // Allow Enter key in search fields
  ['f-manufacturer','f-model','f-year','f-state','f-city'].forEach(id => {
    qs(id).addEventListener('keydown', e => { if (e.key === 'Enter') runSearch(); });
  });
});
