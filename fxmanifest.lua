fx_version("cerulean")
game("rdr3")
rdr3_warning(
	"I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
)

lua54("yes")

author("https://github.com/viktormelin")
description("All in One Character handler")

client_scripts({
	"client/main.lua",
})

server_scripts({
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
})

shared_scripts({
	"shared/config.lua",
	"shared/cloth_hash_names.lua",
})

ui_page("web/build/index.html")
files({
	"web/build/index.html",
	"web/build/**/*",
})
