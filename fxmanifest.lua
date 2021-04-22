
fx_version 'adamant'
game 'gta5'
server_script 'server.lua'

client_scripts {
    'client.lua',
    'functions.lua',
    'nui-c.lua'
}

ui_page "html/index.html"

files{
    "html/index.html",
    "html/style.css",
    "html/reset.css",
    "html/listener.js",
    "html/FWMS-Full.png",
    "html/FWMS-3-4.png",
    "html/FWMS-1-2.png",
    "html/FWMS-1-3.png",
    "html/FWMS-Empty.png"
}

shared_script 'config.lua'