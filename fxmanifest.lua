fx_version "cerulean"
game 'rdr3'
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

author 'aes_afkzone'
description 'When you are in the designated zone for the full time, you will receive a prize.'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'config.lua',
    'client/client.lua'
}

server_scripts {
    'config.lua',
    'server/server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}
