# main.py para Raspberry Pi Pico W
import network
import time
import urequests
import machine

# --- Definición de Funciones ---

def load_env(file_path=".env"):
    env_vars = {}
    try:
        with open(file_path) as f:
            for line in f:
                if line.strip() and not line.strip().startswith('#'):
                    key, value = line.strip().split('=', 1)
                    env_vars[key.strip()] = value.strip()
    except OSError:
        print(f"Advertencia: No se pudo encontrar el archivo {file_path}")
    return env_vars

def get_internal_temperature():
    # Sensor de temperatura interno
    sensor_temp_internal = machine.ADC(4)
    ADC_CONVERSION_FACTOR = 3.3 / (65535)
    
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
        if response.status_code == 200 or response.status_code == 201:
            led = machine.Pin("LED", machine.Pin.OUT)
            led.on()
            time.sleep(1)
            led.off()
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

def connect_to_wifi(ssid, password):
    wlan.active(True)
    wlan.connect(ssid, password)

    while not wlan.isconnected() and wlan.status() >= 0:
        print("Conectando a WiFi...")
        time.sleep(1)

    if wlan.isconnected():
        print("Conectado a WiFi!")
        print(f"SSID: {ssid}")
        config = wlan.ifconfig()
        print(f"IP: {config[0]}")
        print(f"Subnet mask: {config[1]}")
        print(f"Gateway: {config[2]}")
        print(f"DNS: {config[3]}")
        test_api_connection()
    else:
        print("No se pudo conectar a la red WiFi.")

# --- Cargar configuración desde .env ---
env = load_env()
WIFI_SSID = env.get("WIFI_SSID", "default_ssid")
WIFI_PASSWORD = env.get("WIFI_PASSWORD", "default_password")
API_URL = env.get("API_URL", "http://localhost:8000")
SLEEP_TIME = int(env.get("SLEEP_TIME", 10))

# --- Conexión WiFi ---
wlan = network.WLAN(network.STA_IF)
connect_to_wifi(WIFI_SSID, WIFI_PASSWORD)

# --- Bucle Principal ---
while True:
    try:
        # Leer temperatura interna
        internal_temp = get_internal_temperature()
        send_to_api("internal_temp", internal_temp)

        print(f"Esperando {SLEEP_TIME} segundos para la próxima lectura...")
        time.sleep(SLEEP_TIME)

    except Exception as e:
        print(f"Error en el bucle principal: {e}")
