# Docker Container für Mein Homelab

Dieses Repository ist meine persönliche Sammlung von Docker-Compose Dateien für mein Raspberry Pi 4 Model B.

## Aufbau
Jedes Verzeichnis enthält nur eine Software. Es lassen sich natürlich auch mehrere Produkte miteinander kombinieren um so die Anzahl an docker-compose.yaml Dateien zu verringern. Sollte eine Software eine Datenbank oder ähnliches benötigten, ist diese natürlich in der entsprechenden compose Datei enthalten.
Es werden keine Docker Volumes verwendet sondern bind mounts! Als Standardverzeichnis wird bei mir ````/var/docker```` genutzt.

# Quellen/Sources:
Das ganze Ding besteht aus verschiedensten Forks und meinem eigenen Hinrquark.

* [**Nextcloud**](https://github.com/nextcloud/docker): [Docker Container für dein Homelab von cbirkenbeul](https://github.com/cbirkenbeul/docker-homelab/) (https://github.com/cbirkenbeul/docker-homelab/tree/master/nextcloud)
