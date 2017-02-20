devices_config = {}

dofile("crouton-simple-toggle.lua")

devices_config.simpleToggle = {}
devices_config.simpleToggle.name = "simpleToggle"
devices_config.simpleToggle.method = "crouton-simple-toggle"
devices_config.simpleToggle.title = "MainDoorToggle"
devices_config.simpleToggle.pin = 7
devices_config.simpleToggle.setup = setup_simpleToggle
devices_config.simpleToggle.callback = simpleToggle
