--dofile("main.lua")
-- Configuration to connect to the MQTT broker.
BROKER = "test.mosquitto.org"   -- Ip/hostname of MQTT broker
BRPORT = 1883             -- MQTT broker port
BRUSER = ""           -- If MQTT authenitcation is used then define the user
BRPWD  = ""            -- The above user password
CLIENTID = "crouton-esp-rgb" ..  node.chipid() -- The MQTT ID.
print("Device name printed below:")
print(CLIENTID)

--deviceJson
-- Getting json from file
file.open("rgb.json", "r")
deviceJsonString = file.read()
-- print(file.list())
file.close()
deviceJson = json.decode(deviceJsonString)


-- MQTT topics to subscribe
topics = {"/inbox/"..CLIENTID.."/deviceInfo",
  "/inbox/"..CLIENTID.."/rgb"} -- Add/remove topics to the array

-- pin stuff
print("Setting up pins")
colors = {}
colors["red"] = 2 -- pin 4
colors["blue"] = 6 -- pin 12
colors["green"] = 5 -- pin 14

pwm.setup(colors["red"], 100, 1023)
pwm.start(colors["red"])
pwm.setduty(colors["red"], 1023 - (1023*deviceJson["deviceInfo"]["endPoints"]["rgb"]["values"]["red"])/255)

pwm.setup(colors["blue"], 100, 1023)
pwm.start(colors["blue"])
pwm.setduty(colors["blue"], 1023 - (1023*deviceJson["deviceInfo"]["endPoints"]["rgb"]["values"]["blue"])/255)

pwm.setup(colors["green"], 100, 1023)
pwm.start(colors["green"])
pwm.setduty(colors["green"], 1023 - (1023*deviceJson["deviceInfo"]["endPoints"]["rgb"]["values"]["green"])/255)

--** MQTT related things below **--

-- Control variables.
pub_sem = 0         --Stops the publishing when the previous hasn't ended
current_topic  = 1
topicsub_delay = 50 -- microseconds between subscription attempts

-- connect to the broker
print "Connecting to MQTT broker. Please wait..."
m = mqtt.Client( CLIENTID, 60)--, BRUSER, BRPWD)
m:connect( BROKER , BRPORT, 0, function(conn) end)
m:on("connect", function(con)
  print ("connected")
  publish_data("/outbox/"..CLIENTID.."/deviceInfo", json.encode(deviceJson))
  mqtt_sub()
end)

--subscribe to the list of topics
function mqtt_sub()
     if table.getn(topics) >= current_topic then
          m:subscribe(topics[current_topic] , 0, function(conn,topic,message)
            print("Subscribed a topic ...")
          end)
          current_topic = current_topic + 1
          tmr.alarm(5, topicsub_delay, 0, mqtt_sub )
     end
end


-- Sample publish functions:
function publish_data(topic, data)
   if pub_sem == 0 then  -- Is the semaphore set=
     pub_sem = 1  -- Nop. Let's block it
     m:publish(topic,data,0,0, function(conn)
        pub_sem = 0  -- Unblock the semaphore
     end)
   end
end

function explode(d,p) -- (separator,string)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true)
      if l~=nil then
        table.insert(t, string.sub(p,ll,l-1))
        ll=l+1
      else
        table.insert(t, string.sub(p,ll))
        break
      end
    end
  return t
end

-- Recieving data
m:on("message", function(conn, topic, msg)
  topicTable = explode("/",topic)

  box = topicTable[2]
  name = topicTable[3]
  address = topicTable[4]

  onMessage(box,name,address,msg)

end )

m:lwt("/outbox/"..CLIENTID.."/lwt", "anythinghere", 0, 0)
m:on("offline", function(con) print ("offline") end)

--** ESP functions below **--

function onMessage(box,name,address,msg)
  if box == "inbox" and address == "deviceInfo" then
    publish_data("/outbox/"..CLIENTID.."/deviceInfo", json.encode(deviceJson))
  end

  if box == "inbox" then
    if address == "rgb" then
      controlColor(msg)
    end
  end
end

function writeToFile()
  -- Getting json from file
  file.open("rgb.json", "w+")
  deviceJsonString = json.encode(deviceJson)
  file.write(deviceJsonString)
  file.close()
end

function controlColor(msg)
  msgObj = json.decode(msg)

  for k,v in pairs(msgObj) do
    pwmValue = (msgObj[k]*1023)
    pwmValue = 1023 - pwmValue/255
    pwm.setduty(colors[k], pwmValue)
    deviceJson["deviceInfo"]["endPoints"]["rgb"]["values"][k] = msgObj[k]
    writeToFile()
    publish_data("/outbox/"..CLIENTID.."/rgb", msg)
  end

end
