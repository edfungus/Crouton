CLIENTID = "crouton-esp-rgb" ..  node.chipid()
dofile("config_user.lua")
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
