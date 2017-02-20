function get_device_crouton_simple_toggle(device_title)
    localDeviceInfo = {}
    localDeviceInfo["values"] = {}
    localDeviceInfo["values"]["value"] = false
    localDeviceInfo["labels"] = {}
    localDeviceInfo["labels"]["true"] = "ON"
    localDeviceInfo["labels"]["false"] = "OFF"
    localDeviceInfo["card-type"] = "crouton-simple-toggle"
    localDeviceInfo["title"] = device_title
    print("Called simple toggle")
    return localDeviceInfo
end


function setup_simpleToggle(device_config)
    print("Setting up toggle at pin " .. device_config.pin)
    gpio.mode(device_config.pin, gpio.OUTPUT)
end

function simpleToggle(device_config, msg)
  if msg["value"] then
    gpio.write(device_config.pin, gpio.HIGH)
  else
    gpio.write(device_config.pin, gpio.LOW)
  end
  publish_data("/outbox/"..CLIENTID.."/"..device_config.name, cjson.encode(msg))
end


