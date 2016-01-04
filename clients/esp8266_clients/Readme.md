
#### How to use

To flash use:

```
python luatool.py --port /dev/cu.usbserial --src file.lua --dest file.lua
```

*Flash init.lua as init.lua and anther file as main.lua. Ignore old-functions.lua*

demo.lua - Has boolean light on 14 and dimmable light on 12

rgb-multi - Has rgb on 4,14,12 respectively on 3 separate slider dashboard card

rgb-new - Has rgb on 4,14,12 respectively on one rgb slider dashboard card

#### Extras

To use nodemcu firmware (only need to do once):

```
esptool.py write_flash 0x00000 firmware.bin
```


#### Sources
nodemcu firmare <https://github.com/nodemcu/nodemcu-firmware/releases>
luatool <https://github.com/4refr0nt/luatool>
esptool <https://github.com/themadinventor/esptool>
