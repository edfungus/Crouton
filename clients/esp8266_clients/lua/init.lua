dofile("config_config.lua")

function user_start()
    if file.open("init.lua") ~= nil then
        print("Running")
        file.close("init.lua")
        dofile("main.lua")
    end
end

function start(config)
    tmr.create():alarm(1000, tmr.ALARM_AUTO, function(cb_timer)
       cb_timer:unregister()
       if config.automatic then
           print("AP UP")
           wifi.setmode(wifi.STATIONAP)
           wifi.ap.config({ssid="ConfigureCrouton", auth=wifi.OPEN})
           enduser_setup.manual(true)
           enduser_setup.start(
             function()
               print("Connected to wifi as:" .. wifi.sta.getip())
             end,
             function(err, str)
               print("Err " .. str)
             end
           );
       else
           print("Connected to WiFi AP (" .. config.essid .. ")")
           print("IP address: " .. config.ip)
           wifi.setmode(wifi.STATION)
           wifi.sta.config(config.essid, config.pass)
           wifi.sta.setip({
             ip = config.ip,
             netmask = "255.255.255.0",
             gateway = config.gateway,
           })
       end

       print("You have 3 seconds to abort")

       tmr.create():alarm(3000, tmr.ALARM_SINGLE, user_start)

    end)
end

start(config)
