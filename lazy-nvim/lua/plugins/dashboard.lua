-- LazyVim usa snacks.nvim para el dashboard (mini-starter/alpha quedaron
-- deshabilitados en example.lua). Se pisa solo `dashboard.preset.header`
-- (merge de opts, no reemplaza el resto de snacks: bigfile/notifier/etc.)
-- con el mismo ASCII banner de DARKDRAGON que usa el prompt de zsh
-- (startup.zsh), para consistencia de branding.
--
-- Colores del header y de los textos (Desc/Key/Footer/Normal) del
-- dashboard: NO se tocan acá. Los define config/highlights.lua (grupos
-- SnacksDashboard*), que ya resuelve el timing real contra tokyonight y
-- reacciona a cambios de tema — mismo mecanismo que el resto de la paleta
-- custom (Normal/CursorLine/etc.). Ver ese archivo para el detalle.
return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
██████╗  █████╗ ██████╗ ██╗  ██╗██████╗ ██████╗  █████╗  ██████╗  ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗████╗  ██║
██║  ██║███████║██████╔╝█████╔╝ ██║  ██║██████╔╝███████║██║  ███╗██║   ██║██╔██╗ ██║
██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║  ██║██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╗██║
██████╔╝██║  ██║██║  ██║██║  ██╗██████╔╝██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝]],
      },
    },
  },
}
