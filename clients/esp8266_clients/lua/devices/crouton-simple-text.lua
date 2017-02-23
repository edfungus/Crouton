function get_device_crouton_simple_text(device_title)
    localDeviceInfo = {}
    localDeviceInfo["values"] = {}
    localDeviceInfo["values"]["value"] = 100
    localDeviceInfo["card-type"] = "crouton-simple-text"
    localDeviceInfo["title"] = device_title
    print("Called simple text")
    return localDeviceInfo
end

function setup_text(device_config)
   print("No setup required")
end

function text (device_config, msg)
    publish_data("/outbox/"..CLIENTID.."/" .. device_config.name, cjson.encode(msg))
end

function read_text(device_config, result)
    res = {}
    res['values'] = {}
    res['values']['value'] = result
    text(device_config, res)
end
