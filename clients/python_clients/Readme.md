
#### Demo Crouton device with Python

Use venv as a Python virtual environment to run a local demo/test client all.py

Using <http://test.mosquitto.org> as the broker which is defualt on Crouton

```bash
source env/bin/activate
python all.py
```

#### Cloud Foundry Client

cf_demo_client folder has the code to run the demo on a Cloud Foundry server. This is the code used to run the demo. Note, the reason why it is so much more complicated is because Cloud Foundry requires port 80 to be active aka must be a server of some sort. Therefore a Python Flask server is running along with the MQTT client

Visit <http://crouton-demo-client.mybluemix.net/> to see the real status of the client running on Cloud Foundry servers.
