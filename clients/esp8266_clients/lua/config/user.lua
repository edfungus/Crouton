devices_config = {}
name = "room" -- Device name

dofile("crouton-simple-text.lua")

function read_dsp()
    device_config = devices_config.tempSensor
    ds_sensor=require("ds18b20")
    ds_sensor.setup(device_config.pin)
    addrs=ds_sensor.addrs()
    return ds_sensor.readNumber(addrs[1], ds_sensor.C)
end

function dsp_loop(device, result)
    data = string.format("%.2f", read_dsp())
    -- read_text(device, data)
    result.values.value = data
end

devices_config.tempSensor = {}
devices_config.tempSensor.name = "tempSensor"
devices_config.tempSensor.method = "crouton-simple-text"
devices_config.tempSensor.title = "RoomTemperature"
devices_config.tempSensor.pin = 5
devices_config.tempSensor.setup = setup_text
devices_config.tempSensor.callback = text

devices_config.loops = {}
devices_config.loops["tempSensor"] = dsp_loop
