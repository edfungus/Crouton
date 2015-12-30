tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...")
   else
      print('IP: ',wifi.sta.getip())
      tmr.stop(0)
   end
end)



--temp stuf

function debounce (func)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function btnLeft(level)
  if level == 1 then
    publish_data("/sensors/esp1","message from esp1 " .. level .. "/" .. counter)
    if gpio.read(outputPins[0]) == gpio.HIGH then
      gpio.write(outputPins[0], gpio.LOW)
    else
      gpio.write(outputPins[0], gpio.HIGH)
    end
    counter = counter + 1
  end
end

function btnRight(level)
  publish_data("/sensors/esp1","uhhhhh hit right ")
end

for i, input in ipairs(inputPins) do
  gpio.mode(input, gpio.INT)
  gpio.trig(input, 'up', debounce(btnLeft))
end
for i, output in ipairs(outputPins) do
  gpio.mode(output, gpio.OUTPUT)
end
gpio.write(outputPins[1], gpio.HIGH)

print("setting up pins")
inputPins = {2,1} --pin4,5
intrpFuncs = {btnLeft,btnRight}
outputPins = {6,5} --pin12,14
counter = 0
lastNumber = 0
