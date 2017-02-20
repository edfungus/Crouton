Demo Crouton device for ESP8266
-------------------------------


Usage
-----

Read the `nodemcu documentation regarding code uploads <https://nodemcu.readthedocs.io/en/master/en/upload/>_`.

You'll need to upload at least the ``init.lua``, one of:
- auto_config.lua
- config.lua

And one of the "main.lua" files contained in subdirectories.
You'll need to edit config.lua

.. warning:: Auto-config.lua requires the firmware to have been built with ``enduser`` support.

Building and flashing
---------------------

NodeMCU contains a rather complete documentation on how to work with
its firmware `here <http://nodemcu.readthedocs.io/en/master/en/build/>_`
