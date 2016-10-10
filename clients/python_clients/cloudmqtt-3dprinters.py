# -*- coding: iso-8859-15 -*-

import paho.mqtt.client as mqtt
import time
import json
import random



clientPassword = "password"
clientName = "esp8266-12-"+clientPassword
mqttBrokerName = "m11.cloudmqtt.com"
mqttBrokerPort = "12002"

#device setup
j = """
{
    "deviceInfo": {
        "status": "good",
        "color": "#4D90FE",
        "endPoints": {
            "ledlighting": {
                "values": {
                    "value": true
                },
                "labels":{
                    "true": "ON",
                    "false": "OFF"
                },
                "card-type": "crouton-simple-toggle",
                "title": "Iluminação"
            },
            "toggleSwitchCTC": {
                "values": {
                    "value": true
                },
                "labels":{
                    "true": "ON",
                    "false": "OFF"
                },
                "card-type": "crouton-simple-toggle",
                "title": "CTC-3D"
            },
            "toggleSwitchPrusa": {
                "values": {
                    "value": true
                },
                "labels":{
                    "true": "ON",
                    "false": "OFF"
                },
                "card-type": "crouton-simple-toggle",
                "title": "Prusa I3 X"
            },
            "youTubeStreamCTC": {
                "values": {
                    "youtubeID": "GZnb3jQ2YZo"
                },
                "card-type": "crouton-video-youtube",
                "title": "CTC-3D"
            },
            "youTubeStreamPrusa": {
                "values": {
                    "youtubeID": "GZnb3jQ2YZo"
                },
                "card-type": "crouton-video-youtube",
                "title": "Prusa I3 X"
            }
        },
        "description": "Impressão 3D"
    }
}

"""

device = json.loads(j)
device["deviceInfo"]["name"] = clientName
deviceJson = json.dumps(device)

print "Client Name is: " + clientName

#callback when we recieve a connack
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))

#callback when we receive a published message from the server
def on_message(client, userdata, msg):
    print(msg.topic + ": " + str(msg.payload))
    box = msg.topic.split("/")[1]
    name = msg.topic.split("/")[2]
    address = msg.topic.split("/")[3]

    if box == "inbox" and str(msg.payload) == "get" and address == "deviceInfo":
        client.publish("/outbox/"+clientName+"/deviceInfo", deviceJson)

    if box == "inbox":
        #currently only echoing to simulate turning on the lights successfully
        #turn on light here and if success, do the following..
        client.publish("/outbox/"+clientName+"/"+address, str(msg.payload))

    if box == "inbox" and address == "reset":
        #initial values
        global crouton
        global barDoor
        global barDoorDelay
        global drinks
        global drinksDelay
        global deviceJson
        global occup
        global occupDelay
        global temp
        global tempDelay

        counter = 0
        barDoor = 34
        barDoorDelay = 5
        drinks = 0
        drinksDelay = int(random.random()*5)
        occup = 76
        occupDelay = int(random.random()*30)
        deviceJson = json.dumps(device)
        temp = 0
        tempDelay = 3
        client.publish("/outbox/"+clientName+"/drinks", '{"value":0}')
        client.publish("/outbox/"+clientName+"/barDoor", '{"value":34}')
        client.publish("/outbox/"+clientName+"/danceLights", '{"value":true}')
        client.publish("/outbox/"+clientName+"/backDoorLock", '{"value":false}')
        client.publish("/outbox/"+clientName+"/barLightLevel", '{"value":30}')
        client.publish("/outbox/"+clientName+"/customMessage", '{"value":"Happy Hour is NOW!"}')
        client.publish("/outbox/"+clientName+"/discoLights", '{"red":0,"green":0,"blue":0}')
        print "Reseting values...."



def on_disconnect(client, userdata, rc):
    if rc != 0:
        print("Broker disconnection")
    time.sleep(10)
    client.username_pw_set(clientName, clientPassword)
    client.connect(mqttBrokerName, mqttBrokerPort, 60)

client = mqtt.Client(clientName,clientPassword)
client.on_connect = on_connect
client.on_message = on_message
client.on_disconnect = on_disconnect
client.username_pw_set("","")
client.will_set('/outbox/'+clientName+'/lwt', 'anythinghere', 0, False)


# client.connect("localhost", 1883, 60)
# client.connect("test.mosquitto.org", 1883, 60)
# client.connect("192.168.99.100", 1883, 60)
client.username_pw_set(clientName, clientPassword)
client.connect(mqttBrokerName, mqttBrokerPort, 60)


client.subscribe("/inbox/"+clientName+"/deviceInfo")
client.publish("/outbox/"+clientName+"/deviceInfo", deviceJson) #for autoreconnect

for key in device["deviceInfo"]["endPoints"]:
    #print key
    client.subscribe("/inbox/"+clientName+"/"+str(key))


### Simulated device logic below

#initial values
counter = 0
barDoor = 34
barDoorDelay = 5
drinks = 0
drinksDelay = int(random.random()*5)
occup = 76
occupDelay = int(random.random()*30)
temp = 0
tempDelay = 3
tempArray = [60,62,61,62,63,65,68,67,68,71,69,65,66,62,61]

client.loop_start()
while True:
    time.sleep(1)

    #barDoor
    if(counter >= barDoorDelay):
        barDoor = barDoor + 1 #increment value by one
        client.publish("/outbox/"+clientName+"/barDoor", '{"value":'+str(barDoor)+'}')
        barDoorDelay = counter + 5 #wait 5 seconds for next increment

    #drinks
    if(counter >= drinksDelay):
        drinks = drinks + 1 #increment value by one
        client.publish("/outbox/"+clientName+"/drinks", '{"value":'+str(drinks)+'}')
        drinksDelay = counter + int(random.random()*5) #wait 5 seconds for next increment

    #temperature
    if(counter >= tempDelay):
        if(temp == 15):
            temp = 0
        client.publish("/outbox/"+clientName+"/temperature", '{"update": {"labels":['+str(counter)+'],"series":[['+str(tempArray[temp])+']]}}')
        tempDelay = counter + 1 #wait 5 seconds for next increment
        temp = temp + 1

    #occupancy
    if(counter >= occupDelay):
        if(occup == 76):
            occup = 78
        else:
            occup = 76
        client.publish("/outbox/"+clientName+"/occupancy", '{"series":['+str(occup)+']}')
        occupDelay = counter + int(random.random()*30) #wait 5 seconds for next increment

    counter = counter + 1
    if counter > 5000:
        counter = 0
        barDoor = 34
        barDoorDelay = 5
        drinks = 0
        drinksDelay = int(random.random()*5)
        occup = 76
        occupDelay = int(random.random()*30)
        temp = 3
        tempDelay = 3


#client.loop_forever()
