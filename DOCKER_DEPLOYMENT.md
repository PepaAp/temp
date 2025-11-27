# 🐋 Návod na publikování Docker image na GitHub

## Možnost 1: GitHub Container Registry (GHCR) - Automatické ✅

Váš projekt už má připravený GitHub Actions workflow, který automaticky buildí a publikuje Docker image při push do main větve.

### Krok 1: Upravit workflow pro vaše Dockerfile

Aktuální workflow používá výchozí Dockerfile. Upravte `.github/workflows/docker-publish.yml` pro Dockerfile-flask:

```yaml
# V sekci "Build and push Docker image" změňte:
with:
  context: .
  file: ./Dockerfile-flask  # Přidejte tuto řádku
  push: ${{ github.event_name != 'pull_request' }}
  tags: ${{ steps.meta.outputs.tags }}
```

### Krok 2: Push do GitHubu

```bash
git add .
git commit -m "Update Docker configuration and UI"
git push origin main
```

### Krok 3: Image bude dostupný na:
```
ghcr.io/petrgru/flask-os:latest
ghcr.io/petrgru/flask-os:main
```

### Krok 4: Použití image

```bash
# Stažení
docker pull ghcr.io/petrgru/flask-os:latest

# Spuštění
docker run -p 8000:8000 -e SQLALCHEMY_DATABASE_URI="sqlite:///app.db" ghcr.io/petrgru/flask-os:latest
```

---

## Možnost 2: Docker Hub (Manuální)

### Krok 1: Přihlášení do Docker Hub

```bash
docker login
```

### Krok 2: Build image

```bash
cd /home/student/pepa/Flask-OS
docker build -f Dockerfile-flask -t petrgru/flask-os:latest .
```

### Krok 3: Push na Docker Hub

```bash
docker push petrgru/flask-os:latest
```

### Krok 4: Použití

```bash
docker pull petrgru/flask-os:latest
docker run -p 8000:8000 petrgru/flask-os:latest
```

---

## Možnost 3: GitHub Container Registry (Manuální)

### Krok 1: Vytvoření Personal Access Token (PAT)

1. Jděte na GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Vytvořte nový token s právy: `write:packages`, `read:packages`, `delete:packages`
3. Zkopírujte token

### Krok 2: Přihlášení

```bash
export CR_PAT=YOUR_TOKEN_HERE
echo $CR_PAT | docker login ghcr.io -u petrgru --password-stdin
```

### Krok 3: Build a tag image

```bash
cd /home/student/pepa/Flask-OS

# Build Flask image
docker build -f Dockerfile-flask -t ghcr.io/petrgru/flask-os:latest .
docker build -f Dockerfile-flask -t ghcr.io/petrgru/flask-os:v1.0 .

# Build Nginx image
docker build -f Dockerfile-nginx -t ghcr.io/petrgru/flask-os-nginx:latest .
```

### Krok 4: Push na GHCR

```bash
docker push ghcr.io/petrgru/flask-os:latest
docker push ghcr.io/petrgru/flask-os:v1.0
docker push ghcr.io/petrgru/flask-os-nginx:latest
```

### Krok 5: Nastavení viditelnosti (volitelné)

1. Jděte na https://github.com/petrgru?tab=packages
2. Klikněte na váš package
3. Package settings → Change visibility → Public

---

## Možnost 4: Upravený docker-compose.yml pro GHCR

Vytvořte `docker-compose.prod.yml`:

```yaml
version: '3.1'

services:
  app:
    image: ghcr.io/petrgru/flask-os:latest
    ports:
      - 8000:8000
    depends_on:
      - db
    environment:
      SQLALCHEMY_DATABASE_URI: 'mysql+pymysql://root:example@db/flask'

  db:
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: example
      MARIADB_DATABASE: flask

  nginx:
    image: ghcr.io/petrgru/flask-os-nginx:latest
    ports:
      - 8888:80
    depends_on:
      - app
```

Spuštění:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📋 Doporučený postup

**Pro automatizaci (nejlepší):**
1. Upravte `.github/workflows/docker-publish.yml` (viz Možnost 1)
2. Pushnete změny na GitHub
3. GitHub Actions automaticky sestaví a publikuje image
4. Image bude dostupný na `ghcr.io/petrgru/flask-os:latest`

**Pro rychlý test:**
1. Použijte Možnost 3 (manuální GHCR)
2. Build a push lokálně
3. Otestujte stažení a spuštění

---

## 🔍 Ověření

Po publikování ověřte, že image je dostupný:

```bash
# Pro GHCR
docker pull ghcr.io/petrgru/flask-os:latest

# Pro Docker Hub
docker pull petrgru/flask-os:latest

# Zkontrolujte lokální images
docker images | grep flask-os
```

---

## 📚 Další informace

- GHCR dokumentace: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- Docker Hub: https://hub.docker.com/
- GitHub Actions: https://docs.github.com/en/actions
