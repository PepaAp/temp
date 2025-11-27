# ⚡ RYCHLÝ NÁVOD - Kubernetes Deployment

## 🎯 Odpovědi na vaše otázky:

### Které image použít?
- **Flask aplikace:** `ghcr.io/pepaap/temp:latest`
- **Nginx proxy:** `ghcr.io/pepaap/temp-nginx:latest`

### Jaké porty?
- **Flask:** port `8000` (interní service)
- **Nginx:** port `80` (externí LoadBalancer)

---

## 🚀 Rychlé nasazení

### Varianta A: Jednoduchá (jen Flask)
```bash
cd /home/student/pepa/Flask-OS
./k8s/k8s-deploy.sh simple
```
**Výsledek:**
- Flask aplikace přímo dostupná na portu **8000**
- SQLite databáze
- Rychlý test

### Varianta B: Plná (Flask + Nginx + DB)
```bash
cd /home/student/pepa/Flask-OS
./k8s/k8s-deploy.sh full
```
**Výsledek:**
- Nginx na portu **80** (veřejný)
- Flask na portu 8000 (interní)
- MariaDB databáze
- Produkční setup

---

## 📊 Srovnání variant

| Co               | Simple (A) | Full (B) |
|------------------|------------|----------|
| **Image**        | temp:latest | temp:latest + temp-nginx:latest |
| **Externí port** | 8000       | 80 |
| **Databáze**     | SQLite     | MariaDB |
| **Složitost**    | ⭐         | ⭐⭐⭐ |
| **Pro**          | Test, dev  | Produkce |

---

## 🔍 Zjištění přístupu

Po nasazení zjistěte external IP:

```bash
# Pro Simple:
kubectl get svc flask-app-simple

# Pro Full:
kubectl get svc nginx-service -n flask-app
```

Výstup bude něco jako:
```
NAME                TYPE           EXTERNAL-IP     PORT(S)
flask-app-simple    LoadBalancer   34.123.45.67    8000:30123/TCP
```

**Přístup:** http://34.123.45.67:8000 (Simple) nebo http://34.123.45.67 (Full)

---

## 🛠️ Užitečné příkazy

### Sledování podů
```bash
kubectl get pods                    # Simple
kubectl get pods -n flask-app       # Full
```

### Logy
```bash
kubectl logs -f deployment/flask-app-simple              # Simple
kubectl logs -f deployment/flask-app -n flask-app        # Full - Flask
kubectl logs -f deployment/nginx -n flask-app            # Full - Nginx
```

### Scaling
```bash
kubectl scale deployment/flask-app-simple --replicas=3   # Simple
kubectl scale deployment/flask-app --replicas=3 -n flask-app  # Full
```

### Vytvoření admin účtu
```bash
# Simple
kubectl exec -it deployment/flask-app-simple -- flask fab create-admin

# Full
kubectl exec -it deployment/flask-app -n flask-app -- flask fab create-admin
```

---

## 🧹 Smazání

```bash
./k8s/k8s-deploy.sh cleanup
```

---

## 💡 Doporučení

**Pro vaši situaci:**

1. **Testování:** Použijte **Simple** (jednodušší, rychlejší)
   ```bash
   ./k8s/k8s-deploy.sh simple
   ```
   ✅ Port: **8000**
   ✅ Image: `ghcr.io/pepaap/temp:latest`

2. **Produkce:** Použijte **Full** (lepší performance)
   ```bash
   ./k8s/k8s-deploy.sh full
   ```
   ✅ Port: **80**
   ✅ Images: `ghcr.io/pepaap/temp:latest` + `ghcr.io/pepaap/temp-nginx:latest`

---

## 📝 Poznámky

- Images jsou automaticky stahovány z GitHub Container Registry
- Pro privátní images potřebujete vytvořit `imagePullSecret`
- LoadBalancer typ funguje na GKE, EKS, AKS (cloud providers)
- Pro Minikube použijte `minikube tunnel` v jiném terminálu
