# Docker Container für Mein Raspberry Pi Homelab

Dieses Repository ist meine persönliche Sammlung von Docker-Compose Dateien für mein Raspberry Pi 4 Model B.

## Aufbau
Jedes Verzeichnis enthält nur eine Software. Es lassen sich natürlich auch mehrere Produkte miteinander kombinieren um so die Anzahl an docker-compose.yaml Dateien zu verringern. Sollte eine Software eine Datenbank oder ähnliches benötigten, ist diese natürlich in der entsprechenden compose Datei enthalten.
Es werden keine Docker Volumes verwendet sondern bind mounts! Als Standardverzeichnis wird bei mir ````/home/$USER_FOR_SERVICE/storage/```` genutzt und dementsprechend für jeden Service ein neuer User angelegt.

## Quellen/Sources:
Das ganze Ding besteht aus verschiedensten Forks und meinem eigenen Hinrquark.

* [**Nextcloud**](https://github.com/nextcloud/docker): [Docker Container für dein Homelab von cbirkenbeul](https://github.com/cbirkenbeul/docker-homelab/) (https://github.com/cbirkenbeul/docker-homelab/tree/master/nextcloud)


######   Copyright 2020 KnallbertLp
######
######   Licensed under the Apache License, Version 2.0 (the "License");
######   you may not use this file except in compliance with the License.
######   You may obtain a copy of the License at
######
######       http://www.apache.org/licenses/LICENSE-2.0
######
######   Unless required by applicable law or agreed to in writing, software
######   distributed under the License is distributed on an "AS IS" BASIS,
######   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
######   See the License for the specific language governing permissions and
######   limitations under the License.
######
