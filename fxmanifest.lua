
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
    "html/images/*.png",
}

shared_script 'config.lua'