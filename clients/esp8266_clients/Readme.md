
### Demo Crouton device for ESP8266


#### How to use

To flash use:

```
python luatool.py --port /dev/cu.usbserial --src file.lua --dest file.lua
```

*Flash init.lua as init.lua and anther file as main.lua. Ignore old-functions.lua*

Make sure to change wifi ssid/password in init.lua

Main files to choose form:

* demo.lua - Has boolean light on 14 and dimmable light on 12
* rgb-multi.lua - Has rgb on 4,14,12 respectively on 3 separate slider dashboard card
* rgb-new.lua - Has rgb on 4,14,12 respectively on one rgb slider dashboard card ([DIY guide here](http://adventureswithedmund.com/post/136520173664/rgb-led-esp8266-with-crouton))
* rgb-save.lua - Like the above but saves values of RGB so that the card and LED will reflect the right values on Crouton connecting AND if power-loss on ESP8266. Requires rgb.json to be pushed to ESP8266 as rgb.json

#### Extras

To flash nodemcu firmware (only need to do once):

```
esptool.py --port /dev/cu.usbserial write_flash 0x00000 firmware.bin
```


#### Sources
nodemcu firmare <https://github.com/nodemcu/nodemcu-firmware/releases>
luatool <https://github.com/4refr0nt/luatool>
esptool <https://github.com/themadinventor/esptool>
