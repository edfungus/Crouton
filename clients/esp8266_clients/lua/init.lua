print('init.lua ver 1.2')
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())

--include json encoder/decoder
json = require "cjson"

-- wifi config start
wifi.sta.config("SSID","PASSWORD")
-- wifi config end

print('Starting up in 5 seconds!')

function startup()
    print('Starting up...')
    dofile('main.lua')
    end

tmr.alarm(0,5000,0,startup)
