# main.py para Raspberry Pi Pico W
import network
import time
import urequests
import machine
import dht

# --- Configuración ---
WIFI_SSID = "CHANGEME"
WIFI_PASSWORD = "CHANGEME"
API_URL = "http://iot-platform-101.eastus.cloudapp.azure.com:8000"  # E.g., "http://192.168.1.100:8000"

# --- Conexión WiFi ---
wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect(WIFI_SSID, WIFI_PASSWORD)

while not wlan.isconnected() and wlan.status() >= 0:
    print("Conectando a WiFi...")
    time.sleep(1)

print("Conectado a WiFi:", wlan.ifconfig())

# --- Sensores ---
# Sensor de temperatura interno
sensor_temp_internal = machine.ADC(4)
ADC_CONVERSION_FACTOR = 3.3 / (65535)

# Sensor DHT11 (temperatura externa y humedad)
# Asegúrate de que el sensor DHT11 esté conectado al pin GPIO 28
d = dht.DHT11(machine.Pin(28))

# --- Funciones ---
def read_internal_temp():
    reading = sensor_temp_internal.read_u16() * ADC_CONVERSION_FACTOR
    temperature = 27 - (reading - 0.706) / 0.001721
    return int(temperature)

def send_to_api(endpoint, value):
    url = f"{API_URL}/sensors/{endpoint}"
    headers = {'Content-Type': 'application/json'}
    data = {"value": value}
    try:
        response = urequests.post(url, json=data, headers=headers)
        print(f"Enviando a {url}: {data}, Status: {response.status_code}")
        response.close()
    except OSError as e:
        print(f'Error de socket', e)
        print('Conectado?', wlan.isconnected(), wlan.status())

def test_api_connection():
    url = f"{API_URL}/"
    try:
        print('Conectado?', wlan.isconnected(), wlan.status())
        response = urequests.get(url)
        # response.close()
        print(response.status_code, response.text)
    except OSError as e:
        print(f'Error de socket', e)
        print('Conectado?', wlan.isconnected(), wlan.status())

test_api_connection()

# --- Bucle Principal ---
while True:
    try:
        # Leer temperatura interna
        internal_temp = read_internal_temp()
        send_to_api("internal_temp", internal_temp)
        time.sleep(2)

        # Leer DHT11
        d.measure()
        external_temp = d.temperature()
        humidity = d.humidity()
        
        send_to_api("external_temp", external_temp)
        time.sleep(2)
        
        send_to_api("humidity", humidity)

        print("Esperando 5 segundos para la próxima lectura...")
        time.sleep(5)

    except Exception as e:
        print(f"Error en el bucle principal: {e}")
