require "quake_io"

function init(plugin)
    plugin:newMenuGroup{
        id = "quake_id",
        title = "Quake gfx",
        group = "file_import"
    }

    plugin:newCommand{
        id = "import_lmp_pal",
        title = "Import .lmp palette",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "Import .lmp palette", notitlebar = false })
            dlg:file{
                id = "import_lmp_pal_f",
                label = "Import .lmp palette",
                title = "Import .lmp palette",
                open = true,
                focus = true,
                filename = "palette",
                filetypes = {"lmp"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }

            dlg:button{ id = "confirm", text = "Import", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            if data.confirm then
                importLmpPal(data.import_lmp_pal_f);
            end
        end
    }
    
    plugin:newCommand{
        id = "export_spr_lmp_pal",
        title = "Export sprite to .lmp palette",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "export sprite to .lmp palette", notitlebar = false })
            dlg:file{
                id = "export_lmp_pal_f",
                label = "export sprite to .lmp palette",
                title = "export sprite to .lmp palette",
                open = false,
                save = true,
                filename = "palette",
                filetypes = {"lmp"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }

            dlg:button{ id = "confirm", text = "Export", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            if data.confirm then
                exportSprLmpPal(data.export_lmp_pal_f)
            end
        end
    }

    plugin:newMenuSeparator{ group = "quake_id" }
end