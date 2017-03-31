# <img src="https://github.com/OwnYourData/app-room/raw/master/www/app_logo.png" width="92"> Raumklima

In Häusern und Wohnungen gibt es immer öfter verschiedene Sensoren zum Messen von Temperatur, Feuchtigkeit und anderen Umweltdaten. Zusätzlich werden Aktoren eingesetzt die unterschiedlichste Aktionen durchführen wie zB Fenster öffnen/schließen oder Geräte ein-/ausschalten. Beim Einsatz solcher Sensoren und Aktoren werden aber immer wieder Privatsphären-Bedenken geäußert und daher bietet die Raumklima-App ein autonomes System, dass zB auf einem Raspberry Pi unabhängig vom Internet betrieben werden kann.

Mehr Infos, Screenshots und Demo: https://www.ownyourdata.eu/apps/room/

### Dein Datentresor
Die Raumklima-App wird in einem sicheren Datentresor installiert. Üblicherweise musst du deine Daten an die Betreiber von Webservices und Apps weitergeben, um diese nutzen zu können. OwnYourData dreht den Spieß jedoch um: Du behältst all deine Daten und du verwahrst sie in deinem eigenen Datentresor. Apps (Datensammlung, Algorithmen und Visualisierung) holst du zu dir, in den Datentresor hinein.

Mehr Infos und Demo: https://www.ownyourdata.eu  
Hintergrund-Infos für Entwickler: https://www.ownyourdata.eu/developer/

&nbsp;    

## Installation

Du kannst entscheiden wo du deinen Datentresor einrichten und deine Apps installieren möchtest: auf deinem persönlichen OwnYourData-Server, auf einem anderen Cloud-Dienst deiner Wahl, auf deinem eigenen Computer oder auf einem Raspberry Pi bei dir daheim.

### Installation am OwnYourData-Server

Diese Installation ist am einfachsten: Fordere deinen Datentresor an: https://www.ownyourdata.eu, öffne den Datentresor und klicke im *OwnYourData App Store* bei der Raumklima-App auf "Install".

### Installation bei Cloud Diensten

Verschiedene Cloud Dienste bieten das Hosting von [Docker](https://www.docker.com) Containern an, z.B. https://sloppy.io oder https://elastx.se. Die Raumklima-App steht als Docker-Image unter dem Namen `oydeu/app-room` auf Dockerhub hier zur Verfügung: https://hub.docker.com/r/oydeu/app-room/. (Da die Raumklima-App auch in einer Variante für Smartphones zur Verfügung steht, soll auch das Image `oydeu/app-room-mobile` verwendet werden.)  
Starte den Container und verbinde dich im Konfigurations-Dialog mit deinem Datentresor.

### Installation am eigenen Computer/Laptop

Um die Raumklima-App am eigenen Computer auszuführen, musst du zuerst [eine aktuelle Version von Docker installieren](https://www.docker.com/community-edition#/download). Starte dann die Raumklima-App mit folgendem Befehl:  
`docker run -p 3838:3838 oydeu/app-room`  
Du kannst dann auf die Raumklima-App mit deinem Browser unter folgender Adresse zugreifen:  
`http://192.168.99.100:3838`  
  
*Anmerkungen:*  
* wenn du mehrere Apps verwendest, musst du unterschiedliche Ports verwenden  
  `docker run -p 1234:3838 oydeu/app-room` und `http://192.168.99.100:1234`
* Docker vergibt die IP-Adresse auf deinem Computer unter der du auf die Container zugreifen kannst. Verwende folgenden Befehl, um die tatsächliche IP-Adresse festzustellen: `docker-machine ip`  
* in diesem Blog-Artikel wird ausführlich die Installation einer App am eigenen PC beschrieben: [Ein Container voller Daten](https://www.ownyourdata.eu/2016/09/26/ein-container-voller-daten/)

### Installation am Raspberry Pi

Die Raumklima-App steht auch für die Architektur armhf zur Verfügung. Die Installation erfolgt dann wie am Computer/Laptop jedoch unter Verwendung des Docker Image `oydeu/app-room_armhf`.  
  
*Anmerkungen:*  
* Raumklima-App auf Dockerhub: https://hub.docker.com/r/oydeu/app-room_armhf/  
* zur einfachen Installation von Docker am Raspberry empfehlen wir die SD-Card Images von Hypriot: http://blog.hypriot.com/downloads/
* Befehl zum Start des Containers am Raspberry: `docker run -p 3838:3838 oydeu/app-room_armhf`

&nbsp;    

## Datenstruktur

Die folgenden Listen werden von der Raumklima-App verwendet:

* NAGIOS Import    
    - `name`: Sensorbezeichnung    
    - `nagiosUrl`: Adresse unter der die Sensordaten als JSON zur Verfügung gestellt werden    
        üblicherweise hat die Adresse die Form: `http://myserver.eu/mysite/pnp4nagios/xport/json?host=cli_room_12AB&srv=temp&view=3`    
    - `user`: Benutzername zum Zugriff auf die unter `nagiosUrl` verfügbaren Daten    
    - `password`: Passwort zum Zugriff auf die unter `nagiosUrl` verfügbaren Daten    
    - `repo`: Liste die zur Speicherung verwendet werden soll; muss mit `eu.ownyourdat.room.` beginnen    
    - `active`: boolscher Wert, nur bei TRUE wird der Datensatz verwendet
* [Sensordaten]    
    - `timestamp`: Zeistempel in Millisekunden seit 1.1.1970 UTC       
    - `value`: gemessener Sensorwert    
* Raumklima-Skript - R Skripts zum Import der Sensordaten und Ansteuerung von Aktoren    
    - `name`: eindeutiger Name    
    - `script`: base64 enkodiertes R Skript    
* Scheduler, Scheduler Verlauf und Scheduler Status  - siehe [service-scheduler](https://github.com/OwnYourData/service-scheduler)  
* Info - Informationen zum Datentresor

&nbsp;    

## Verbessere die Raumklima-App

Bitte melde Fehler oder Vorschläge für neue Features / UX-Verbesserungen im [GitHub Issue-Tracker](https://github.com/OwnYourData/app-room/issues) und halte dich dabei an die [Contributor Guidelines](https://github.com/twbs/ratchet/blob/master/CONTRIBUTING.md).

Wenn du selbst an der App mitentwickeln möchtest, folge diesen Schritten:

1. Fork it!
2. erstelle einen Feature Branch: `git checkout -b my-new-feature`
3. Commit deine Änderungen: `git commit -am 'Add some feature'`
4. Push in den Branch: `git push origin my-new-feature`
5. Sende einen Pull Request

&nbsp;    

## Lizenz

[MIT Lizenz 2017 - OwnYourData.eu](https://raw.githubusercontent.com/OwnYourData/app-room/master/LICENSE)
