require "quake_io"

function init(plugin)
    plugin:newMenuGroup{
        id = "quake_id",
        title = "Quake gfx",
        group = "file_import"
    }

    plugin:newCommand{
        id = "import_lmp",
        title = "Import .lmp image",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "Import .lmp image", notitlebar = false })
            dlg:file{
                id = "import_lmp_f",
                label = "Import .lmp image",
                title = "Import .lmp image",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"lmp"},
                onchange = function()
                    dlg:modify({
                        id = "confirm",
                        enabled = true
                    })
                end
            }
            dlg:combobox{ 
                id = "import_lmp_filetype",
                label="Choose file type: ",
                option="Image", 
                options={"Image", "Palette", "Colormap"},
            }
            dlg:button{ id = "confirm", text = "Import", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            local filetype = dlg.data.import_lmp_filetype
            if data.confirm then
                if filetype == "Image" then
                    importLmp(data.import_lmp_f);
                elseif filetype == "Palette" then
                    importLmpPal(data.import_lmp_f);
                end
            end
        end
    }


    plugin:newCommand{
        id = "export_spr_lmp",
        title = "Export sprite to .lmp image",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "export sprite to .lmp image", notitlebar = false })
            dlg:file{
                id = "export_lmp_f",
                label = "export sprite to .lmp image",
                title = "export sprite to .lmp image",
                open = false,
                save = true,
                filename = "",
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
                exportSprLmp(data.export_lmp_f)
            end
        end
    }

    plugin:newMenuSeparator{ group = "quake_id" }

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
end