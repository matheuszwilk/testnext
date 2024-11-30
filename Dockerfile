# Stage 1: Dependências e build
FROM oven/bun:1 AS builder
WORKDIR /app

# Instalar dependências
COPY package*.json ./
RUN bun install

# Copiar código fonte e construir
COPY . .
RUN bun run build

# Stage 2: Imagem de produção
FROM oven/bun:1
WORKDIR /app

# Criar usuário não-root
RUN addgroup --system --gid 1001 bunjs
RUN adduser --system --uid 1001 nextjs

# Copiar arquivos do builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Configurar permissões
RUN chown -R nextjs:bunjs /app

USER nextjs

EXPOSE 3003

ENV NODE_ENV production
ENV PORT 3003

CMD ["bun", "start"]