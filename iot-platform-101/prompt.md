# Especificaciones del desarrollo

## Sensoreo
Tengo una Raspberry Pi Pico W que estoy programando con MicroPython y tiene conectados tres sensores:
- Uno interno de temperatura del micro del RP2040
- Otro externo de temperatura y humedad relativa DHT11 que comunica los datos por protocolo 1-Wire
La Raspberry Pi Pico W esta alimentada y conectada a una red WiFi.
Una vez que obtengo el dato lo quiero comunicar a una plataforma IoT via HTTP.

## Plataforma
La plataforma de IoT tiene tres componentes:
- Una API.
- Una base de datos temporal.
- Un herramienta de visualizacion.

La API tiene que contar con:
- Tres endpoints para cada tipo de sensor.
- Tiene que validar la data que viene en tipo de dato entero y envuelta en JSON.
- Tiene que estar escrita en FastAPI.
- Tiene que notificar cuando la recepcion es correcta con el codigo HTTP 200

La base de datos temporal:
- Tiene que guardar lo que la API recibe en un registro historico.
- Tiene que ser InfluxDB.

La herramienta de visualizacion:
- Tiene que ser Grafana.
- Tiene que ir a leer la base de datos temporal.
- Tiene que permitir que el usuario vea las tres variables al mismo tiempo en un tablero, lo antes posible.
- El usuario lo va a acceder de forma web.
- Quiero tenga un usuario por defecto configurado que se llama itbaiot y la contraseña sea certificacion2025

## Infraestructura
Los tres componentes deberian ser microservicios que forman parte de un cluster de Docker Compose que me facilite probarlo local y, posteriormente desplegarlo en una instancia simple de Azure.
El despliegue en Azure quiero que sea con Terraform, con una sola instancia que exponga el Grafana para el usuario y la API para la Raspberry Pi Pico.
Tenemos que esperar que toda la infraestructura este desplegada antes de subir el codigo y levantar los microservicios.