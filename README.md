# Mapeamento da Rede

Ferramenta pra mapear rede de contatos em municípios do interior durante ligações telefônicas. HTML único + Supabase (auth via magic link + tabela `fichas` com RLS).

## Estrutura

- `index.html` — a aplicação inteira (HTML + CSS + JS inline)
- `schema.sql` — schema Postgres pra rodar no SQL Editor do Supabase

## Configuração local

Não precisa build. Servir estático:

```bash
python -m http.server 8765
# http://localhost:8765
```

Anon key e URL do Supabase estão hardcoded em `index.html` — é seguro (anon key é pública por design; RLS protege os dados via `auth.uid() = user_id`).

## Auth

Magic link no email cadastrado. Sem senha, sem signup. O redirect precisa estar no allowlist do Supabase (Authentication → URL Configuration → Redirect URLs).

## Deploy

Vercel serve o `index.html` na raiz sem configuração adicional.
