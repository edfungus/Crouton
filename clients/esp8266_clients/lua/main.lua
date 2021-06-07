-- pin stuff
print("setting up pins")
ledlightingPin = 1
toggleSwitchCTCPin = 3
toggleSwitchPrusaPin = 5

gpio.mode(ledlightingPin, gpio.OUTPUT)
gpio.write(ledlightingPin, gpio.HIGH)

gpio.mode(toggleSwitchCTCPin, gpio.OUTPUT)
gpio.write(toggleSwitchCTCPin, gpio.HIGH)

gpio.mode(toggleSwitchPrusaPin, gpio.OUTPUT)
gpio.write(toggleSwitchPrusaPin, gpio.HIGH)

-- Configuration to connect to the MQTT broker.
BROKER = "m11.cloudmqtt.com"   -- Ip/hostname of MQTT broker
BRPORT = 22002             -- MQTT broker port
SECURE = 1                  -- 1 YES / 0 NO
BRUSER = "esp8266-12-" ..  node.chipid()           -- If MQTT authenitcation is used then define the user
BRPWD  = node.chipid()            -- The above user password
CLIENTID = "esp8266-12-" ..  node.chipid() -- The MQTT ID. Change to something you like
print("Device name printed below:")
print(CLIENTID)

--deviceJson
deviceInfo = {}
deviceInfo["endPoints"] = {}
deviceInfo["endPoints"]["ledlighting"] = {}
deviceInfo["endPoints"]["ledlighting"]["values"] = {}
deviceInfo["endPoints"]["ledlighting"]["values"]["value"] = true
deviceInfo["endPoints"]["ledlighting"]["labels"] = {}
deviceInfo["endPoints"]["ledlighting"]["labels"]["true"] = "ON"
deviceInfo["endPoints"]["ledlighting"]["labels"]["false"] = "OFF"
deviceInfo["endPoints"]["ledlighting"]["card-type"] = "crouton-simple-toggle"
deviceInfo["endPoints"]["ledlighting"]["title"] = "Iluminação"

deviceInfo["endPoints"]["toggleSwitchCTC"] = {}
deviceInfo["endPoints"]["toggleSwitchCTC"]["values"] = {}
deviceInfo["endPoints"]["toggleSwitchCTC"]["values"]["value"] = true
deviceInfo["endPoints"]["toggleSwitchCTC"]["labels"] = {}
deviceInfo["endPoints"]["toggleSwitchCTC"]["labels"]["true"] = "ON"
deviceInfo["endPoints"]["toggleSwitchCTC"]["labels"]["false"] = "OFF"
deviceInfo["endPoints"]["toggleSwitchCTC"]["card-type"] = "crouton-simple-toggle"
deviceInfo["endPoints"]["toggleSwitchCTC"]["title"] = "CTC-3D"

deviceInfo["endPoints"]["toggleSwitchPrusa"] = {}
deviceInfo["endPoints"]["toggleSwitchPrusa"]["values"] = {}
deviceInfo["endPoints"]["toggleSwitchPrusa"]["values"]["value"] = true
deviceInfo["endPoints"]["toggleSwitchPrusa"]["labels"] = {}
deviceInfo["endPoints"]["toggleSwitchPrusa"]["labels"]["true"] = "ON"
deviceInfo["endPoints"]["toggleSwitchPrusa"]["labels"]["false"] = "OFF"
deviceInfo["endPoints"]["toggleSwitchPrusa"]["card-type"] = "crouton-simple-toggle"
deviceInfo["endPoints"]["toggleSwitchPrusa"]["title"] = "Prusa I3 X"

deviceInfo["endPoints"]["youTubeStreamCTC"] = {}
deviceInfo["endPoints"]["youTubeStreamCTC"]["values"] = {}
deviceInfo["endPoints"]["youTubeStreamCTC"]["values"]["youtubeID"] = "GZnb3jQ2YZo"
deviceInfo["endPoints"]["youTubeStreamCTC"]["card-type"] = "crouton-video-youtube"
deviceInfo["endPoints"]["youTubeStreamCTC"]["title"] = "CTC-3D"

deviceInfo["endPoints"]["youTubeStreamPrusa"] = {}
deviceInfo["endPoints"]["youTubeStreamPrusa"]["values"] = {}
deviceInfo["endPoints"]["youTubeStreamPrusa"]["values"]["youtubeID"] = "GZnb3jQ2YZo"
deviceInfo["endPoints"]["youTubeStreamPrusa"]["card-type"] = "crouton-video-youtube"
deviceInfo["endPoints"]["youTubeStreamPrusa"]["title"] = "Prusa I3 X"



deviceJson = {}
deviceJson["deviceInfo"] = deviceInfo


-- MQTT topics to subscribe
topics = {
  "/inbox/"..CLIENTID.."/deviceInfo",
  "/inbox/"..CLIENTID.."/ledlighting",
  "/inbox/"..CLIENTID.."/toggleSwitchCTC",
  "/inbox/"..CLIENTID.."/toggleSwitchPrusa",
  "/inbox/"..CLIENTID.."/youTubeStreamCTC",
  "/inbox/"..CLIENTID.."/youTubeStreamPrusa"
} -- Add/remove topics to the array


-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing when the previous hasn't ended
current_topic  = 1  -- variable for one currently being subscribed to
topicsub_delay = 50 -- microseconds between subscription attempts, worked for me (local network) down to 5...YMMV

-- connect to the broker
print "Connecting to MQTT broker. Please wait..."
m = mqtt.Client( CLIENTID, 60, BRUSER, BRPWD)
m:connect( BROKER , BRPORT, SECURE, function(conn) end)
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

  if box == "inbox" then
    if address == "ledlighting" then
      toggleLEDlighting(msg)
    end
    if address == "toggleSwitchCTC" then
      toggleSwitchCTC(msg)
    end
    if address == "toggleSwitchPrusa" then
      toggleSwitchPrusa(msg)
    end
  end

  if box == "inbox" and address == "deviceInfo" then
    deviceJson["deviceInfo"]["endPoints"]["ledlighting"]["values"]["value"] = (gpio.read(ledlightingPin) ~= 0) and true or false
    deviceJson["deviceInfo"]["endPoints"]["toggleSwitchCTC"]["values"]["value"] = (gpio.read(toggleSwitchCTCPin) ~= 0) and true or false
    deviceJson["deviceInfo"]["endPoints"]["toggleSwitchPrusa"]["values"]["value"] = (gpio.read(toggleSwitchPrusaPin) ~= 0) and true or false
    publish_data("/outbox/"..CLIENTID.."/deviceInfo", json.encode(deviceJson))
  end
end )

m:lwt("/outbox/"..CLIENTID.."/lwt", "anythinghere", 0, 0)
m:on("offline", function(con) print ("offline") end)

-------- Should split file but we will later.. above code for mqtt .. below is the esp function

function toggleLEDlighting (msg)
  msgObj = json.decode(msg)

  if msgObj["value"] then
    gpio.write(ledlightingPin, gpio.HIGH)
  else
    gpio.write(ledlightingPin, gpio.LOW)
  end
  publish_data("/outbox/"..CLIENTID.."/ledlighting", msg)
end

function toggleSwitchCTC (msg)
  msgObj = json.decode(msg)

  if msgObj["value"] then
    gpio.write(toggleSwitchCTCPin, gpio.HIGH)
  else
    gpio.write(toggleSwitchCTCPin, gpio.LOW)
  end
  publish_data("/outbox/"..CLIENTID.."/toggleSwitchCTC", msg)
end

function toggleSwitchPrusa (msg)
  msgObj = json.decode(msg)

  if msgObj["value"] then
    gpio.write(toggleSwitchPrusaPin, gpio.HIGH)
  else
    gpio.write(toggleSwitchPrusaPin, gpio.LOW)
  end
  publish_data("/outbox/"..CLIENTID.."/toggleSwitchPrusa", msg)
end