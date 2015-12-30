-- Configuration to connect to the MQTT broker.
BROKER = "test.mosquitto.org"   -- Ip/hostname of MQTT broker
BRPORT = 1883             -- MQTT broker port
BRUSER = ""           -- If MQTT authenitcation is used then define the user
BRPWD  = ""            -- The above user password
CLIENTID = "crouton-esp1-" ..  node.chipid() -- The MQTT ID. Change to something you like
print("Device name printed below:")
print(CLIENTID)

--deviceJson
deviceInfo = {}
deviceInfo["endPoints"] = {}
deviceInfo["endPoints"]["booleanLight"] = {}
deviceInfo["endPoints"]["booleanLight"]["values"] = {}
deviceInfo["endPoints"]["booleanLight"]["values"]["value"] = false
deviceInfo["endPoints"]["booleanLight"]["labels"] = {}
deviceInfo["endPoints"]["booleanLight"]["labels"]["true"] = "ON"
deviceInfo["endPoints"]["booleanLight"]["labels"]["false"] = "OFF"
deviceInfo["endPoints"]["booleanLight"]["card-type"] = "crouton-simple-toggle"
deviceInfo["endPoints"]["booleanLight"]["title"] = "IMMA LIGHT!"

deviceInfo["endPoints"]["dimLight"] = {}
deviceInfo["endPoints"]["dimLight"]["values"] = {}
deviceInfo["endPoints"]["dimLight"]["values"]["value"] = 100
deviceInfo["endPoints"]["dimLight"]["min"] = 0
deviceInfo["endPoints"]["dimLight"]["max"] = 100
deviceInfo["endPoints"]["dimLight"]["units"] = "percent"
deviceInfo["endPoints"]["dimLight"]["card-type"] = "crouton-simple-slider"
deviceInfo["endPoints"]["dimLight"]["title"] = "Dim me?"

deviceJson = {}
deviceJson["deviceInfo"] = deviceInfo


-- MQTT topics to subscribe
topics = {"/inbox/"..CLIENTID.."/deviceInfo","/inbox/"..CLIENTID.."/booleanLight","/inbox/"..CLIENTID.."/dimLight"} -- Add/remove topics to the array

-- pin stuff
print("setting up pins")
booleanLightPin = 5 -- pin14
gpio.mode(booleanLightPin, gpio.OUTPUT)

dimLightPin = 6 -- pin 12
pwm.setup(dimLightPin, 100, 1023)
pwm.start(dimLightPin)


-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing when the previous hasn't ended
current_topic  = 1  -- variable for one currently being subscribed to
topicsub_delay = 50 -- microseconds between subscription attempts, worked for me (local network) down to 5...YMMV

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
          current_topic = current_topic + 1  -- Goto next topic
          --set the timer to rerun the loop as long there is topics to subscribe
          tmr.alarm(5, topicsub_delay, 0, mqtt_sub )
     end
end


-- Sample publish functions:
function publish_data(topic, data)
   if pub_sem == 0 then  -- Is the semaphore set=
     pub_sem = 1  -- Nop. Let's block it
     m:publish(topic,data,0,0, function(conn)
        -- Callback function. We've sent the data
        -- print("Sending: " .. data .." to " .. topic)
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
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
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

  if box == "inbox" and address == "deviceInfo" then
    publish_data("/outbox/"..CLIENTID.."/deviceInfo", json.encode(deviceJson))
  end

  if box == "inbox" then
    if address == "booleanLight" then
      toggleLight(msg)
    end
    if address == "dimLight" then
      dimLight(msg)
    end
  end
end )

m:lwt("/outbox/"..CLIENTID.."/lwt", "anythinghere", 0, 0)
m:on("offline", function(con) print ("offline") end)

gpio.write(booleanLightPin, gpio.LOW)

-------- Should split file but we will later.. above code for mqtt .. below is the esp function

function toggleLight (msg)
  msgObj = json.decode(msg)

  if msgObj["value"] then
    gpio.write(booleanLightPin, gpio.HIGH)
  else
    gpio.write(booleanLightPin, gpio.LOW)
  end
  publish_data("/outbox/"..CLIENTID.."/booleanLight", msg)
end

function dimLight (msg)
  msgObj = json.decode(msg)

  if msgObj["value"] then
    print(msgObj["value"])
    pwmValue = (msgObj["value"]*1023)
    pwmValue = pwmValue/100
    pwm.setduty(dimLightPin, pwmValue)
    publish_data("/outbox/"..CLIENTID.."/dimLight", msg)
  end
end
