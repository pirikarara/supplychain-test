#!/usr/bin/env bash
set -euo pipefail

# ========== npm: package-lock.json ==========
cid=$(docker create -it --name lock-npm node:22-bullseye /bin/bash)
docker start lock-npm >/dev/null
docker exec lock-npm bash -lc 'mkdir -p /w && chown -R node:node /w'
docker cp npm/package.json lock-npm:/w/
docker exec -u node -w /w lock-npm bash -lc 'npm install --package-lock-only'
docker cp lock-npm:/w/package-lock.json npm/package-lock.json
docker rm -f lock-npm >/dev/null

# ========== pnpm: pnpm-lock.yaml ==========
cid=$(docker create -it --name lock-pnpm node:22-bullseye /bin/bash)
docker start lock-pnpm >/dev/null
docker exec lock-pnpm bash -lc 'mkdir -p /w && chown -R node:node /w'
docker exec lock-pnpm bash -lc 'corepack enable'
docker exec -u node lock-pnpm bash -lc 'corepack prepare pnpm@9 --activate'
docker cp pnpm/package.json lock-pnpm:/w/
docker exec -u node -w /w lock-pnpm bash -lc 'pnpm install --lockfile-only'
docker cp lock-pnpm:/w/pnpm-lock.yaml pnpm/pnpm-lock.yaml
docker rm -f lock-pnpm >/dev/null

# ========== yarn (classic v1): yarn.lock ==========
cid=$(docker create -it --name lock-yarn node:22-bullseye /bin/bash)
docker start lock-yarn >/dev/null
docker exec lock-yarn bash -lc 'mkdir -p /w && chown -R node:node /w'
docker exec lock-yarn bash -lc 'corepack enable'
docker exec -u node lock-yarn bash -lc 'corepack prepare yarn@1.22.22 --activate'
docker cp yarn/package.json lock-yarn:/w/
docker exec -u node -w /w lock-yarn bash -lc 'yarn install --ignore-scripts --non-interactive --silent'
docker cp lock-yarn:/w/yarn.lock yarn/yarn.lock
docker rm -f lock-yarn >/dev/null

echo "✅ Done:
- npm/package-lock.json
- pnpm/pnpm-lock.yaml
- yarn/yarn.lock"
