import os
from fastapi import FastAPI
from pydantic import BaseModel
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

# --- InfluxDB Configuration ---
INFLUXDB_URL = os.getenv("INFLUXDB_URL", "http://localhost:8086")
INFLUXDB_TOKEN = os.getenv("INFLUXDB_TOKEN", "CHANGEME")
INFLUXDB_ORG = os.getenv("INFLUXDB_ORG", "my-org")
INFLUXDB_BUCKET = os.getenv("INFLUXDB_BUCKET", "my-bucket")

# --- InfluxDB Client ---
influx_client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

# --- FastAPI App ---
app = FastAPI()

# --- Pydantic Models ---
class SensorData(BaseModel):
    value: int

# --- API Endpoints ---
@app.get("/", status_code=200)
def read_root():
    return {"message": "Hello World"}

@app.post("/sensors/internal_temp", status_code=201)
def record_internal_temp(data: SensorData):
    point = Point("internal_temp").field("value", data.value)
    write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
    return {"message": "Internal temperature recorded successfully"}

@app.post("/sensors/external_temp", status_code=201)
def record_external_temp(data: SensorData):
    point = Point("external_temp").field("value", data.value)
    write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
    return {"message": "External temperature recorded successfully"}

@app.post("/sensors/humidity", status_code=201)
def record_humidity(data: SensorData):
    point = Point("humidity").field("value", data.value)
    write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
    return {"message": "Humidity recorded successfully"}
