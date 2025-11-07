# MQTT con Mosquito

## Iniciar un broker MQTT con Docker
`docker run -it -p 1883:1883 -v ${PWD}/mosquitto.conf:/mosquitto/config/mosquitto.conf eclipse-mosquitto`

## Suscribirse con el cliente de CLI
`mosquitto_sub -h 192.168.1.14 -p 1883 -t RPicoW/Temperatura -v`

## Publicar con el cliente de CLI
`mosquitto_pub -d -q 1 -h 192.168.1.14 -p 1883 -t RPicoW/Temperatura -m 25`  
`mosquitto_sub -h broker.hivemq.com -t "RPicoW/Temperatura" -v`
