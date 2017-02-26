dofile("config_user.lua")
CLIENTID = name
dofile("utils.lua")
dofile("mqtt_mqtt.lua")

topics = {"/inbox/"..CLIENTID.."/deviceInfo"}
callbacks = {}
setups = {}
devices = {}
pub_sem = 0
current_topic  = 1
current_device = 1
topicsub_delay = 50
deviceJson = build_device_json(devices_config)

setup_mqtt(mqtt_config, deviceJson)

function loop_devices()
    for device, loop in pairs(devices_config.loops) do
        loop(devices_config[device], deviceJson.deviceInfo.endPoints[device])
    end
    print("Publishing device info")
    publish_data("/outbox/"..CLIENTID.."/deviceInfo", cjson.encode(deviceJson))
    print(cjson.encode(deviceJson))
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, loop_devices)
end

tmr.create():alarm(3000, tmr.ALARM_SINGLE, loop_devices)
