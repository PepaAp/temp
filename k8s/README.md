# 🚀 Kubernetes Deployment pro Pepa's Inventory System

## 📦 Docker Images

### Flask Aplikace
- **Image:** `ghcr.io/pepaap/temp:latest`
- **Port:** `8000`
- **Popis:** Hlavní Flask aplikace s Gunicorn serverem

### Nginx Reverse Proxy
- **Image:** `ghcr.io/pepaap/temp-nginx:latest`
- **Port:** `80`
- **Popis:** Nginx pro statické soubory a reverse proxy

### Databáze (volitelná)
- **Image:** `mariadb:latest`
- **Port:** `3306`
- **Popis:** MySQL databáze pro produkční prostředí

---

## 🎯 Jaký image použít?

### Varianta 1: Jen Flask (Jednoduchá - SQLite)
✅ **Použijte:** `ghcr.io/pepaap/temp:latest`
- Port: **8000**
- Ideální pro: testování, development, malé nasazení
- Databáze: SQLite (v kontejneru)

### Varianta 2: Flask + Nginx (Doporučená)
✅ **Použijte:** 
- Flask: `ghcr.io/pepaap/temp:latest` (port 8000)
- Nginx: `ghcr.io/pepaap/temp-nginx:latest` (port 80)
- Ideální pro: produkce, lepší performance statických souborů

### Varianta 3: Full Stack (Produkce)
✅ **Použijte všechny:**
- Flask: `ghcr.io/pepaap/temp:latest`
- Nginx: `ghcr.io/pepaap/temp-nginx:latest`
- Database: `mariadb:latest`
- Ideální pro: plná produkce

---

## 📝 Kubernetes Manifesty

### Rychlý Start (Varianta 1 - Jednoduchá)

```bash
kubectl apply -f k8s/flask-simple-deployment.yaml
```

Toto vytvoří:
- Flask aplikaci na portu **8000**
- Service typu LoadBalancer
- SQLite databáze uvnitř kontejneru

**Přístup:** `http://<EXTERNAL-IP>:8000`

---

### Doporučený Setup (Varianta 2 - s Nginx)

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml
```

Toto vytvoří:
- Flask aplikaci (interní, port 8000)
- Nginx reverse proxy (externí, port 80)
- Service pro komunikaci mezi nimi

**Přístup:** `http://<EXTERNAL-IP>` (port 80)

---

### Full Stack (Varianta 3 - s databází)

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/database-pvc.yaml
kubectl apply -f k8s/database-secret.yaml
kubectl apply -f k8s/mariadb-deployment.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml
```

**Přístup:** `http://<EXTERNAL-IP>` (port 80)

---

## 🔑 Důležité informace

### Porty v Kubernetes:

| Komponenta | Container Port | Service Port | Poznámka |
|------------|----------------|--------------|----------|
| Flask      | 8000          | 8000         | Interní nebo externí |
| Nginx      | 80            | 80           | Externí (LoadBalancer) |
| MariaDB    | 3306          | 3306         | Interní (ClusterIP) |

### Environment Variables pro Flask:

```yaml
env:
  # Pro SQLite (jednoduchá varianta)
  - name: SQLALCHEMY_DATABASE_URI
    value: "sqlite:///app.db"
  
  # Pro MariaDB (produkce)
  - name: SQLALCHEMY_DATABASE_URI
    value: "mysql+pymysql://root:$(MYSQL_ROOT_PASSWORD)@mariadb-service:3306/flask"
```

---

## 🚀 Příkazy pro nasazení

### Zjištění External IP:
```bash
kubectl get services -n flask-app
```

### Sledování podů:
```bash
kubectl get pods -n flask-app -w
```

### Logy Flask aplikace:
```bash
kubectl logs -f deployment/flask-app -n flask-app
```

### Logy Nginx:
```bash
kubectl logs -f deployment/nginx -n flask-app
```

### Scaling:
```bash
# Flask
kubectl scale deployment/flask-app --replicas=3 -n flask-app

# Nginx
kubectl scale deployment/nginx --replicas=2 -n flask-app
```

---

## 📊 Doporučení pro různé použití

### Development / Testing
```bash
kubectl apply -f k8s/flask-simple-deployment.yaml
```
- **Image:** `ghcr.io/pepaap/temp:latest`
- **Port:** 8000
- Rychlé, jednoduché

### Staging / Production
```bash
kubectl apply -f k8s/
```
- **Images:** Flask + Nginx + MariaDB
- **Port:** 80 (Nginx)
- Plná funkcionalita, škálovatelné

---

## 🔍 Ověření

Po nasazení:

```bash
# Zjistěte external IP
kubectl get svc -n flask-app

# Otestujte aplikaci
curl http://<EXTERNAL-IP>

# nebo s Nginx
curl http://<EXTERNAL-IP>:80
```

---

## 📚 Další kroky

1. Vytvořte admin účet:
```bash
kubectl exec -it deployment/flask-app -n flask-app -- flask fab create-admin
```

2. Přihlaste se do aplikace na `http://<EXTERNAL-IP>`

3. Užívejte si **Pepa's Inventory System**! 🎉
