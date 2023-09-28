-- Tech Development
-- Join our discord for support: https://discord.gg/2mXXhQy

fx_version 'bodacious'
lua54 'yes' 
game 'gta5' 

author 'R1CKY®#2220'
description 'Report System - Tech Development'
version '1.0'


client_scripts {
    'client.lua'
}

shared_scripts {
    'config.lua',
}
server_scripts {
   '@mysql-async/lib/MySQL.lua',
   'server_config.lua',
    'server.lua'
}

ui_page 'web/index.html'

files {
    'web/*.html',
    'web/css/*.css',
    'web/js/*.js',
    'web/fonts/*.otf',
    'web/img/*.png',
}
