function setup_mqtt(mqtt_config, deviceJson)
    print("Connecting to mqtt " .. mqtt_config.ip .. " port " .. mqtt_config.port)
    if mqtt_config.user ~= false then
        print("Auth enabled")
        m = mqtt.Client(CLIENTID, 60, mqtt_config.user, mqtt_config.password)
    else
        print("Auth disabled")
        m = mqtt.Client(CLIENTID, 60)
    end

    m:connect(mqtt_config.ip, mqtt_config.port, 0, 1,
        function(conn) print("connected") end,
        function(client, reason) print("Conn failed reason: "..reason) end)

    m:on("connect", function(con)
      print("Connected (callback)")
      publish_data("/outbox/"..CLIENTID.."/deviceInfo", cjson.encode(deviceJson))
      print("Subscribing")
      mqtt_sub()
    end)

    -- Recieving data
    m:on("message", function(conn, topic, msg)
      topicTable = explode("/", topic)
      if topicTable[3] == CLIENTID then
         if topicTable[2] == "inbox" then

           if topicTable[4] == "refresh" then
               for device, loop in pairs(devices_config.loops) do
                   loop(devices_config[device], deviceJson.deviceInfo.endPoints[device])
               end
           end

           if topicTable[4] == "deviceInfo" then
               for device, loop in pairs(devices_config.loops) do
                   loop(devices_config[device], deviceJson.deviceInfo.endPoints[device])
               end
               print("Publishing device info")
               publish_data("/outbox/"..CLIENTID.."/deviceInfo", cjson.encode(deviceJson))
               print(cjson.encode(deviceJson))
           else
               print("Calling device " .. topicTable[4])
               callbacks[topicTable[4]](devices_config[topicTable[4]], cjson.decode(msg))
           end
        end
      end
    end )

    m:lwt("/outbox/"..CLIENTID.."/lwt", "anythinghere", 0, 0)
    m:on("offline", function(con) print ("offline") end)

end

--subscribe to the list of topics
function mqtt_sub()
    print("Starting subscription for " .. table.getn(topics) .. " topics")
    for n, topic in ipairs(topics) do
        topicTable = explode("/", topic)
        print("Processing " .. topic)

        m:subscribe(topic , 0, function(conn, _topic, message)
          print("Subscribed topic " .. topic)
        end)

        if topicTable[4] ~= "deviceInfo" then
            print("Calling setups " .. topicTable[4])
            setups[topicTable[4]](devices_config[topicTable[4]])
        end
    end
end

function publish_data(topic, data)
    print("publishing to topic " .. topic)
    if pub_sem == 0 then
        pub_sem = 1
        m:publish(topic, data,0,0, function(conn) pub_sem = 0 end)
    end
end
