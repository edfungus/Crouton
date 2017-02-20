function explode(d,p) -- (separator,string)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

function build_device(device_config)
    device_method = 'get_device_' .. device_config.method:gsub('-', '_')
    device_name = device_config.name

    print("Creating device " .. device_name .. " with method " .. device_method )

    print("Loading device configuration")
    dofile(device_config.method .. ".lua")

    print("Creating table " .. "/inbox/".. CLIENTID .. "/" .. device_name)
    table.insert(topics, "/inbox/".. CLIENTID .. "/" .. device_name)

    print("Configuring callback for " .. device_name)
    callbacks[device_name] = device_config.callback

    print("Configuring setup for " .. device_name)
    setups[device_name] = device_config.setup

    return _G[device_method](device_config.title)
end

function build_device_json(devices_config)
    deviceJson = {}
    deviceJson["deviceInfo"] = {}
    deviceJson["deviceInfo"]["endPoints"] = {}

    print("Building device json")
    for name, value in pairs(devices_config) do
        print("Creating json for " .. name)
        deviceJson["deviceInfo"]["endPoints"][name] = build_device(value)
    end
    print("Got " .. cjson.encode(deviceJson))
    return cjson.encode(deviceJson)
end

