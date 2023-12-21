# Környezet indítása
```
git clone https://github.com/Balazska/cloud-pulse-challenges.git
cd cloud-pulse-challenges
./start.sh
```

# Challenge megoldása:
## Challenge indítása
```
./setup.sh [challenge_id] # e.g. ch1
```

## Megoldás
* Nézd át a konfigurációs fájlokat
* Nézd át a kubernetes objectumokat (`kubernetes get ... , kubernetes describe ...`)
* Nézd át a logokat (`kubernetes logs ...`)
* Ha szükséges hajts végre parancsokat a Pod-ból (`kubectl exec -it ...`)
* Teszteld a szolgáltatást HTTP kérésekkel, load testtel
* Módosítsd a konfigurációt vagy hozz létre új Kubernetes objektumot
* Vannak challenge-ek, ahol megadunk Ellenőrző script-et, ami segít vizsgálni a hibát, illetve ezzel tudjátok megnézni, hogy sikerült-e a javítás.
* stb.

> A kubernetes objektumokat mindig a default namespace-be telepítjük, nektek is elég, ha oda dolgoztok

## Challenge leállítása
```
./destroy.sh [challenge_id]
```
> FONTOS: ha saját Kubernetes objektumokat hozol létre, azt a challenge végén manuálisan kell törölnöd!

## Prometheus, grafana ha kell
Prometheus és grafana elérhető a rendszerben, az alábbi parancsokkal lehet publikusan elérhetővé tenni:

```
# prometheus
../seminar3/deployments/prometheus/forward.sh
```

```
# grafana
../seminar3/deployments/prometheus/forward.sh
```

A fured dashboard-on a megfelelő portokat expose-olni kell, és utána lesz elérhető.

Grafana-hoz a jelszó (ha nem jelentkeztetne be alapból), akkor az alábbi paranccsal szerezhető meg (username: admin):
```
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```


# Challenge-ek

## Challenge 0 (ch0)
### Leírás
Egy kolléga jelzi, hogy nem indul el a Pod, amit telepíteni szeretne. Vizsgáljuk meg mi lehet a gond, és oldjuk meg, hogy elinduljon!


## Challenge 1 (ch1)
### Leírás
A DevOps team az alábbira panaszkodik: telepítenek egy szolgáltatást (egy Service és egy Deployment), de hiába küldenek kérést a Service-nek, connection refused válasz jön.

### Ellenőrzés
```
kubectl run -i --rm cpcv --image=docker.io/balazska/cloud-pulse-challenge-validator:0.0.4 --restart=Never -- curl http://ch1
```

## Challenge 2 (ch2)
### Leírás
A DevOps team az alábbira panaszkodik: telepítenek egy szolgáltatást (egy Service és egy Deployment), de hiába küldenek kérést a Service-nek, connection refused válasz jön.

### Ellenőrzés
```
kubectl run -i --rm cpcv --image=docker.io/balazska/cloud-pulse-challenge-validator:0.0.4 --restart=Never -- curl http://ch2
```


## Challenge 3 (ch3)
### Leírás
Telepítettek egy szolgáltatást Minikube-ba, de nem érhető el a minikube ip címén (`minikube ip`). Oldjuk meg, hogy elérhető legyen a 30033-as porton.

### Ellenőrzés
```
curl http://$(minikube ip):30033
```

## Challenge 4 (ch4)
### Leírás
A DevOps team sírva jön hozzánk, hogy nem tudnak felrakni egy deployment-et a K8s klaszterbe. Két példányt akarnak indítani, de csak 1 pod indul el. Nézzünk utána, oldjuk meg, hogy elinduljon a két példány!

### Ellenőrzés
```
kubectl get pods
```

## Challenge 5 (ch5)
### Leírás
HPA-t beállította a DevOps team, és kb. 2 perc után (amikor a `kubectl get hpa` parancsnál a TARGETS oszlopban már nem \<unknown> volt, azaz a HPA már érzékeli a CPU használatát a podoknak), az alábbi terhelésteszttel nézték, hogy működik-e:
```
kubectl run -i --tty load-generator --rm --image=docker.io/fortio/fortio --restart=Never -- load -keepalive=false -allow-initial-errors -qps 0 -t 120s -connection-reuse 0:0 -c 4 -json - http://ch5:8080 | grep "All done"
```

De nem nagyon skálázott a HPA. Nézzük meg mi lehet a gond, és  javítsuk a beállítást, hogy ennél a tesztnél legyen skálázás.

## Challenge 6 (ch6)
Egy új web szolgáltatást telepít a DevOps team a klaszterbe (egy go nyelven írt programot). A tesztelésnél észrevették, hogy minden HTTP kérés amit a szolgáltatásnak küldenek, hibára fut. Nézzünk utána és oldjuk meg a problémát!

### Ellenőrzés
```
kubectl run --attach --rm cpcv --image=docker.io/balazska/cloud-pulse-challenge-validator:0.0.4 --restart=Never -- curl -s http://ch6
```

## Challenge 7 (ch7)
### Leírás
A management kiadta, hogy a service-nek 100 QPS-t kell teljesíteni, de a DevOps team sehogy sem tudja ezt megugrani. Segítsünk nekik!
A resource requestekhez és limitekhez nem szabad hozzányúlni, nem tudjuk miért, ezt kérte a management :D

Ja még valami, a service-nek a 100 QPS-t mindig ki kell tudni szolgálni, de ha ennél nagyobb a forgalom, ahhoz alkalmazkodnia kell. 

### Ellenőrzés
```
kubectl run -i --tty load-generator --rm --image=docker.io/fortio/fortio --restart=Never -- load -keepalive=false -allow-initial-errors -qps 0 -t 30s -connection-reuse 0:0 -c 4 -json - http://ch7:8080 | grep "All done"
```

## Challenge 8 (ch8)
### Description
Új szolgáltatást telepítünk a rendszerbe (deployment 1 replikával és service). Kíváncsiak vagyunk a Pod indulási idejére (scheduled állapottól ready állapotig eltelt idő).
Csináljunk erre egy prometheus metrikát!
