fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
description "React JS PAUSEMENU UI made by Code After S*x"
author "Code After Sex"
version '1.0.0'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

ui_page 'web/build/index.html'


client_scripts {
  "config/locale.lua",
  "config/client_config.lua",
  "config/shared_config.lua",
  "client/utils.lua",
  "client/*.lua",
}
server_script {
  "@oxmysql/lib/MySQL.lua",
  "config/locale.lua",
  "config/server_config.lua",
  "config/shared_config.lua",
  "server/utils.lua",
  "server/*.lua",
}

files {
	'web/build/index.html',
	'web/build/**/*',
}


-- escrow_ignore {
--   "config/*.lua",
--   "client/**/*",
--   "server/**/*",
-- }



escrow_ignore {
  "config/*.lua",
  "client/client_variables.lua",
  "client/utils.lua",
  "server/utils.lua",
}

-- local isEscrowed = false
-- if isEscrowed then
--   escrow_ignore {
--     "config/*.lua",
--     "client/editable.lua",
--     "server/editable.lua",
--   }
-- else
--   escrow_ignore {
--     "config/*.lua",
--     "client/**/*",
--     "server/**/*",
--   }
-- end

