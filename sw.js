// ═══════════════════════════════════════════════════════════════
// Service Worker — ERP Compostos Engenharia
// Estratégia: offline de LEITURA (casco do app em cache).
// NUNCA cacheia chamadas ao Supabase — dados são sempre online/frescos.
// ═══════════════════════════════════════════════════════════════

// IMPORTANTE: ao publicar uma nova versão do sistema, troque o número
// abaixo (v1 -> v2 -> v3...). Isso força o app a baixar o código novo
// e descartar o antigo — evita duplicidade/código velho em cache.
const CACHE_VERSION = 'erp-compostos-v3';

// Arquivos do "casco" do app (interface). NÃO inclui dados do Supabase.
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png'
];

// Domínios que NUNCA devem ser cacheados (dados dinâmicos / APIs)
function ehRedeDinamica(url){
  return url.includes('supabase.co') ||      // banco de dados
         url.includes('supabase.in') ||
         url.includes('brasilapi.com.br') ||  // consulta de CNPJ
         url.includes('googleapis.com') ||    // fontes
         url.includes('cdn.jsdelivr.net') ||  // libs externas (deixa o browser cachear)
         url.includes('cdnjs.cloudflare.com');
}

// Instala: faz cache do casco do app
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting()) // ativa a nova versão imediatamente
  );
});

// Ativa: remove caches de versões antigas (evita acumular código velho)
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(chaves =>
      Promise.all(
        chaves.filter(k => k !== CACHE_VERSION)
              .map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// Intercepta requisições
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Só lida com GET. POST/PUT/PATCH/DELETE (gravações) passam direto pra rede.
  if (req.method !== 'GET') return;

  const url = req.url;

  // Dados dinâmicos (Supabase, APIs): SEMPRE rede, nunca cache.
  // Se offline, deixa falhar normalmente — o app trata o erro e avisa o usuário.
  if (ehRedeDinamica(url)) {
    return; // não intercepta: o navegador faz a requisição normal à rede
  }

  // Casco do app (HTML, ícones, manifest): network-first com fallback ao cache.
  // Assim, online sempre pega a versão mais nova; offline usa a última salva.
  event.respondWith(
    fetch(req)
      .then(resp => {
        // Atualiza o cache com a versão fresca
        const copia = resp.clone();
        caches.open(CACHE_VERSION).then(cache => cache.put(req, copia));
        return resp;
      })
      .catch(() => caches.match(req).then(c => c || caches.match('./index.html')))
  );
});

// Permite que a página peça atualização imediata do SW
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
