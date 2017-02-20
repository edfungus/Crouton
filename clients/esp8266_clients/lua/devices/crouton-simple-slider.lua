function get_device_crouton_simple_slider(device_title)
    localDeviceInfo = {}
    localDeviceInfo["values"] = {}
    localDeviceInfo["values"]["value"] = 100
    localDeviceInfo["min"] = 0
    localDeviceInfo["max"] = 100
    localDeviceInfo["units"] = "percent"
    localDeviceInfo["card-type"] = "crouton-simple-slider"
    localDeviceInfo["title"] = device_title
    print("Called simple slider")
    return localDeviceInfo
end

function setup_pwm(device_config)
    pwm.setup(device_config.pin, device_config.min, device_config.max)
end

function pwm (device_config, msg)
  if msg["value"] then
    pwmValue = (msg["value"]*1023)
    pwmValue = pwmValue/100
    pwm.setduty(device_config.pin, pwmValue)
    publish_data("/outbox/"..CLIENTID.."/" .. device_config.name, cjson.encode(msg))
  end
end
