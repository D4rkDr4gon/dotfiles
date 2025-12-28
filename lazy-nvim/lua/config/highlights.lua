-- Importamos nuestra paleta
local c = require("config.colors")

-- Activamos el colorscheme base
vim.cmd("colorscheme tokyonight-night")

-- Función para cambiar colores
local hl = vim.api.nvim_set_hl
