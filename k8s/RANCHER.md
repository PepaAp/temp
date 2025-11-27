# 🎯 Rancher Kubernetes Deployment - Rychlý Návod

## 🔧 Oprava problému "host not found in upstream"

**Problém:** `nginx: [emerg] host not found in upstream "app:8000"`

**Řešení:** ✅ Opraveno! Změněno z `app:8000` na `flask-service:8000`

GitHub Actions nyní sestavuje nový image s opravenou konfigurací.

---

## 📦 Deployment na Rancher

Používáte: https://rancher.kube.sspu-opava.cz/dashboard/c/c-m-7ms9l27s/explorer/apps.deployment

### Varianta A: Pomocí Workload (GUI)

#### 1. Vytvoření Namespace
- Jděte na **Cluster → Projects/Namespaces**
- Klikněte **Create Namespace**
- Název: `flask-app`
- **Create**

#### 2. Deploy Flask aplikace

**Workload → Deployments → Create**

```yaml
Name: flask-app
Namespace: flask-app
Replicas: 2

Container:
  Image: ghcr.io/pepaap/temp:latest
  Port: 8000 (Container Port)
  
Environment Variables:
  SQLALCHEMY_DATABASE_URI = sqlite:///app.db
  
Resources:
  CPU Request: 500m
  Memory Request: 512Mi
  CPU Limit: 1000m
  Memory Limit: 1Gi
```

**Vytvořit Service:**
- Type: ClusterIP
- Port: 8000 → 8000
- Protocol: TCP

#### 3. Deploy Nginx

**Workload → Deployments → Create**

```yaml
Name: nginx
Namespace: flask-app
Replicas: 2

Container:
  Image: ghcr.io/pepaap/temp-nginx:latest
  Port: 80 (Container Port)
  
Resources:
  CPU Request: 100m
  Memory Request: 128Mi
```

**Vytvořit Service:**
- Type: LoadBalancer nebo NodePort
- Port: 80 → 80
- Protocol: TCP

#### 4. Přístup k aplikaci

Po vytvoření nginx service:
- **LoadBalancer:** Použijte External IP
- **NodePort:** Použijte `http://<node-ip>:<nodeport>`

---

### Varianta B: Pomocí YAML (Doporučeno)

#### 1. Import YAML v Rancher

1. Jděte na **Workload → Create from YAML**
2. Vložte obsah z `k8s/namespace.yaml`
3. **Create**

#### 2. Deploy všechny komponenty

Postupně importujte:
1. `k8s/flask-deployment.yaml`
2. `k8s/nginx-deployment.yaml`
3. (Volitelně) `k8s/mariadb-deployment.yaml`

---

## 🔍 Důležité service names pro Kubernetes

| Komponenta | Service Name | Port | Typ |
|------------|--------------|------|-----|
| Flask | `flask-service` | 8000 | ClusterIP |
| Nginx | `nginx-service` | 80 | LoadBalancer |
| MariaDB | `mariadb-service` | 3306 | ClusterIP |

**DŮLEŽITÉ:** Nginx musí odkazovat na `flask-service:8000`, ne `app:8000`!

---

## 📋 Krok za krokem pro Rancher

### Jednoduché nasazení (bez databáze):

1. **Vytvořit Namespace `flask-app`**

2. **Vytvořit Deployment "flask-app":**
   - Image: `ghcr.io/pepaap/temp:latest`
   - Port: 8000
   - Service: ClusterIP, port 8000
   - Env: `SQLALCHEMY_DATABASE_URI=sqlite:///app.db`

3. **Vytvořit Deployment "nginx":**
   - Image: `ghcr.io/pepaap/temp-nginx:latest`
   - Port: 80
   - Service: LoadBalancer nebo NodePort, port 80

4. **Ověřit komunikaci:**
   ```bash
   # Z nginx podu test connectivity
   kubectl exec -it deployment/nginx -n flask-app -- curl flask-service:8000
   ```

5. **Získat přístupovou adresu:**
   - Rancher → Services → nginx-service
   - Podívat se na External IP nebo NodePort

---

## 🐛 Troubleshooting

### Nginx nemůže najít flask-service

**Příznaky:**
```
nginx: [emerg] host not found in upstream "flask-service:8000"
```

**Řešení:**
1. Zkontrolujte, že Flask service existuje:
   ```bash
   kubectl get svc -n flask-app
   ```
   Měli byste vidět `flask-service`

2. Zkontrolujte, že jsou v **stejném namespace**:
   - Flask deployment: `flask-app` namespace
   - Nginx deployment: `flask-app` namespace

3. Pokud jsou v různých namespaces, použijte plný název:
   ```
   server flask-service.flask-app.svc.cluster.local:8000;
   ```

### Pod nechce startovat

```bash
# Zjistěte důvod
kubectl describe pod <pod-name> -n flask-app
kubectl logs <pod-name> -n flask-app
```

### Image pull error

Pokud jsou images private:
1. Vytvořte imagePullSecret v Rancher
2. Přidejte do deploymentu

---

## 🎯 Nejčastější chyby

❌ **Špatně:** `server app:8000;`
✅ **Správně:** `server flask-service:8000;`

❌ **Špatně:** Service name neodpovídá manifestu
✅ **Správně:** Použijte přesně `flask-service` jako v manifestech

❌ **Špatně:** Různé namespaces pro nginx a flask
✅ **Správně:** Oba v namespace `flask-app`

---

## 📞 Rychlá pomoc

**Zjistit services:**
```bash
kubectl get svc -n flask-app
```

**Zjistit pody:**
```bash
kubectl get pods -n flask-app
```

**Test connectivity z nginx:**
```bash
kubectl exec -it deployment/nginx -n flask-app -- sh
# V podu:
curl flask-service:8000
```

**Logy nginx:**
```bash
kubectl logs -f deployment/nginx -n flask-app
```

**Logy flask:**
```bash
kubectl logs -f deployment/flask-app -n flask-app
```

---

## ✅ Checklist po opravě

- [x] app.conf změněn z `app:8000` na `flask-service:8000`
- [x] Commit a push do GitHub
- [ ] Počkat na GitHub Actions build (~5-10 min)
- [ ] V Rancher smazat starý nginx deployment
- [ ] V Rancher vytvořit nový nginx deployment s novým image
- [ ] Ověřit, že nginx startuje bez chyb
- [ ] Otestovat přístup přes external IP

---

## 🔄 Jak aktualizovat na nový image

1. **V Rancher:**
   - Jděte na Workload → Deployments
   - Najděte `nginx` deployment
   - Klikněte na **⋮** → Edit Config
   - V sekci Container Image klikněte na **Refresh** ikonu
   - Nebo ručně změňte tag na aktuální (např. `:main`)
   - **Save**

2. **Nebo použijte kubectl:**
   ```bash
   kubectl rollout restart deployment/nginx -n flask-app
   kubectl rollout status deployment/nginx -n flask-app
   ```

---

## 📚 Reference

- GitHub Repo: https://github.com/PepaAp/temp
- GitHub Actions: https://github.com/PepaAp/temp/actions
- Images: 
  - `ghcr.io/pepaap/temp:latest`
  - `ghcr.io/pepaap/temp-nginx:latest`
