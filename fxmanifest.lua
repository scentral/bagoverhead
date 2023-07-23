fx_version 'cerulean'
name 'Bag overhead'
author 'Scentral (860097417144041472)'
game 'gta5'

ui_page 'source/interface/index.html'

files {
    'source/interface/index.html',
    'source/interface/script.js',
    'source/interface/style.css',
    'source/interface/assets/*.jpg'
}

client_script {
    'source/client.lua'
}

server_script {
    'source/server.lua'
}