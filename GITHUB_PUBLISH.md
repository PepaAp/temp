# 🚀 Rychlý návod - Jak publikovat na GitHub

## Metoda 1: Automatická (GitHub Actions) ⭐ Doporučeno

### Krok 1: Commitněte změny
```bash
cd /home/student/pepa/Flask-OS
git add .
git commit -m "Add personalized UI and Docker improvements"
git push origin main
```

### Krok 2: Počkejte na build
- Jděte na https://github.com/petrgru/flask-os/actions
- GitHub Actions automaticky sestaví a publikuje Docker image
- Za 5-10 minut bude image dostupný na: `ghcr.io/petrgru/flask-os:latest`

### Krok 3: Nastavte package jako veřejný
1. Jděte na https://github.com/petrgru?tab=packages
2. Klikněte na `flask-os`
3. Package settings → Change visibility → **Public**

### Krok 4: Použití
```bash
# Stažení
docker pull ghcr.io/petrgru/flask-os:latest

# Spuštění
docker-compose -f docker-compose.prod.yml up -d
```

---

## Metoda 2: Manuální (lokální build)

### Krok 1: Přihlaste se do GHCR
```bash
# Vytvořte Personal Access Token na GitHubu s právy "write:packages"
export CR_PAT=YOUR_GITHUB_TOKEN
echo $CR_PAT | docker login ghcr.io -u petrgru --password-stdin
```

### Krok 2: Použijte deployment script
```bash
cd /home/student/pepa/Flask-OS
./deploy.sh v1.0  # nebo bez parametru pro 'latest'
```

### Krok 3: Nastavte jako veřejný
Viz Metoda 1, Krok 3

---

## Co se stane

Po publikování budou dostupné tyto Docker images:
- `ghcr.io/petrgru/flask-os:latest` - Flask aplikace
- `ghcr.io/petrgru/flask-os-nginx:latest` - Nginx proxy

---

## Použití publikovaných images

### Docker Compose (jednoduchý způsob)
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Docker příkazy (manuální)
```bash
# Jen Flask aplikace s SQLite
docker run -p 8000:8000 \
  -e SQLALCHEMY_DATABASE_URI="sqlite:///app.db" \
  ghcr.io/petrgru/flask-os:latest

# S databází
docker network create flask-network
docker run -d --name db --network flask-network \
  -e MARIADB_ROOT_PASSWORD=example \
  -e MARIADB_DATABASE=flask \
  mariadb:latest

docker run -d --name app --network flask-network \
  -p 8000:8000 \
  -e SQLALCHEMY_DATABASE_URI="mysql+pymysql://root:example@db/flask" \
  ghcr.io/petrgru/flask-os:latest
```

---

## Testování před publikováním

```bash
# Lokální build a test
docker build -f Dockerfile-flask -t flask-os-test .
docker run -p 8000:8000 -e SQLALCHEMY_DATABASE_URI="sqlite:///app.db" flask-os-test

# Test celého stacku
docker-compose up
```

---

## Problém řešení

### "Permission denied" při push
```bash
# Zkontrolujte přihlášení
docker login ghcr.io -u petrgru

# Zkontrolujte token má správná práva (write:packages)
```

### Image není viditelný pro ostatní
```bash
# Nastavte package jako Public na GitHubu
# https://github.com/petrgru?tab=packages
```

### Build selže v GitHub Actions
```bash
# Zkontrolujte logy: https://github.com/petrgru/flask-os/actions
# Ujistěte se, že Dockerfile-flask a Dockerfile-nginx existují
```

---

## Další kroky

Po úspěšném publikování můžete:
1. ✅ Sdílet image s ostatními: `docker pull ghcr.io/petrgru/flask-os:latest`
2. ✅ Nasadit na server nebo cloud (AWS, DigitalOcean, atd.)
3. ✅ Vytvořit různé verze pomocí tagů: `v1.0`, `v1.1`, atd.
4. ✅ Automaticky aktualizovat při každém push na GitHub

---

📚 Více informací v souboru `DOCKER_DEPLOYMENT.md`
