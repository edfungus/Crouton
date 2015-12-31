import paho.mqtt.client as mqtt
import time
import json
import random
import os
import threading

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    global device
    return "crouton-demo ... <b>" + connectionStatus + "</b><br><br>The current JSON used is:<br>" + json.dumps(device)

def updateValue(endpoint,value):
    global device
    device["deviceInfo"]["endPoints"][endpoint]["values"]["value"] = value

#callback when we recieve a connack
def on_connect(client, userdata, flags, rc):
    global connectionStatus
    connectionStatus = "should be up and running :)"
    print("Connected with result code " + str(rc))
    startup()

#callback when we receive a published message from the server
def on_message(client, userdata, msg):
    # print(msg.topic + ": " + str(msg.payload))
    box = msg.topic.split("/")[1]
    name = msg.topic.split("/")[2]
    address = msg.topic.split("/")[3]

    if box == "inbox" and str(msg.payload) == "get" and address == "deviceInfo":
        global device
        global json
        newJson = json.dumps(device)
        client.publish("/outbox/"+clientName+"/deviceInfo", newJson)

    if box == "inbox" and address != "deviceInfo": # and (address == "discoLights" or address == "light2"):
        #currently only echoing to simulate turning on the lights successfully
        #turn on light here and if success, do the following..
        client.publish("/outbox/"+clientName+"/"+address, str(msg.payload))
        newValue = json.loads(msg.payload)["value"]
        updateValue(address,newValue)


    if box == "inbox" and address == "reset":
        #initial values
        global crouton
        global barDoor
        global barDoorDelay
        global drinks
        global drinksDelay
        global deviceJson
        global counter

        counter = 0
        barDoor = 34
        barDoorDelay = 5
        drinks = 0
        drinksDelay = int(random.random()*5)
        deviceJson = json.dumps(device)
        client.publish("/outbox/"+clientName+"/drinks", '{"value":0}')
        client.publish("/outbox/"+clientName+"/barDoor", '{"value":34}')
        client.publish("/outbox/"+clientName+"/danceLights", '{"value":true}')
        client.publish("/outbox/"+clientName+"/backDoorLock", '{"value":false}')
        client.publish("/outbox/"+clientName+"/barLightLevel", '{"value":30}')
        client.publish("/outbox/"+clientName+"/customMessage", '{"value":"Happy Hour is NOW!"}')
        updateValue("drinks",0)
        updateValue("barDoor",34)
        updateValue("danceLights",True)
        updateValue("backDoorLock",False)
        updateValue("barLightLevel",30)
        updateValue("customMessage","Happy Hour is NOW!")
        print "Reseting values...."

def startup():
    global client
    global device
    global clientName
    global deviceJson

    client.will_set('/outbox/'+clientName+'/lwt', 'anythinghere', 0, False)

    client.subscribe("/inbox/"+clientName+"/deviceInfo")
    client.publish("/outbox/"+clientName+"/deviceInfo", deviceJson) #for autoreconnect

    for key in device["deviceInfo"]["endPoints"]:
        #print key
        client.subscribe("/inbox/"+clientName+"/"+str(key))


def on_disconnect(client, userdata, rc):
    global connectionStatus
    if rc != 0:
        print("Broker disconnection")
        connectionStatus = "is currently Down :(. Download the local python version instead!"
    time.sleep(10)
    client.reconnect()

def update_values():
    global clientName
    global deviceJson
    global crouton
    global barDoor
    global barDoorDelay
    global drinks
    global drinksDelay
    global client
    global connectionStatus
    global counter

    #barDoor
    if(counter >= barDoorDelay):
        barDoor = barDoor + 1 #increment value by one
        client.publish("/outbox/"+clientName+"/barDoor", '{"value":'+str(barDoor)+'}')
        barDoorDelay = counter + 5 #wait 5 seconds for next increment
        updateValue("barDoor",barDoor)
        # print "barDoor is now: " + str(barDoor)

    #drinks
    if(counter >= drinksDelay):
        drinks = drinks + 1 #increment value by one
        client.publish("/outbox/"+clientName+"/drinks", '{"value":'+str(drinks)+'}')
        drinksDelay = counter + int(random.random()*5) #wait 5 seconds for next increment
        updateValue("drinks",drinks)
        # print "drinks is now: " + str(drinks)

    counter = counter + 1
    if counter > 5000:
        counter = 0
        barDoor = 34
        barDoorDelay = 5
        drinks = 0
        drinksDelay = int(random.random()*5)

    threading.Timer(1, update_values).start()


if __name__ == '__main__':
    port = int(os.getenv("PORT", 8888))

    global clientName
    global deviceJson
    global crouton
    global barDoor
    global barDoorDelay
    global drinks
    global drinksDelay
    global client
    global connectionStatus
    global counter

    clientName = "crouton-demo"

    #device setup
    j = """
    {
        "deviceInfo": {
            "status": "good",
            "color": "#4D90FE",
            "endPoints": {
                "barDoor": {
                    "units": "people entered",
                    "values": {
                        "value": 34
                    },
                    "card-type": "crouton-simple-text",
                    "title": "Bar Main Door"
                },
                "drinks": {
                    "units": "drinks",
                    "values": {
                        "value": 0
                    },
                    "card-type": "crouton-simple-text",
                    "title": "Drinks Ordered"
                },
                "danceLights": {
                    "values": {
                        "value": true
                    },
                    "labels":{
                        "true": "ON",
                        "false": "OFF"
                    },
                    "card-type": "crouton-simple-toggle",
                    "title": "Dance Floor Lights"
                },
                "backDoorLock": {
                    "values": {
                        "value": false
                    },
                    "labels":{
                        "true": "Locked",
                        "false": "Unlocked"
                    },
                    "icons": {
                        "true": "lock",
                        "false": "lock"
                    },
                    "card-type": "crouton-simple-toggle",
                    "title": "Employee Door"
                },
                "lastCall": {
                    "values": {
                        "value": true
                    },
                    "icons": {
                        "icon": "bell"
                    },
                    "card-type": "crouton-simple-button",
                    "title": "Last Call Bell"
                },
                "reset": {
                    "values": {
                        "value": true
                    },
                    "icons": {
                        "icon": "cutlery"
                    },
                    "card-type": "crouton-simple-button",
                    "title": "Reset Cards"
                },
                "customMessage": {
                    "values": {
                        "value": "Happy Hour is NOW!"
                    },
                    "card-type": "crouton-simple-input",
                    "title": "Billboard Message"
                },
                "barLightLevel": {
                    "values": {
                        "value": 30
                    },
                    "min": 0,
                    "max": 100,
                    "units": "percent",
                    "card-type": "crouton-simple-slider",
                    "title": "Bar Light Brightness"
                }
            },
            "description": "Kroobar's IOT devices"
        }
    }

    """

    device = json.loads(j)
    device["deviceInfo"]["name"] = clientName
    deviceJson = json.dumps(device)

    print "Client Name is: " + clientName

    client = mqtt.Client(clientName)
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    client.username_pw_set("","")
    client.will_set('/outbox/'+clientName+'/lwt', 'anythinghere', 0, False)


    # client.connect("localhost", 1883, 60)
    client.connect("test.mosquitto.org", 1883, 60)
    # client.connect("192.168.99.100", 1883, 60)



    ### Simulated device logic below

    #initial values
    counter = 0
    barDoor = 34
    barDoorDelay = 5
    drinks = 0
    drinksDelay = int(random.random()*5)

    client.loop_start()
    update_values()
    app.run(host='0.0.0.0',port=port)

    # while True:
    #     time.sleep(1)




    #client.loop_forever()
