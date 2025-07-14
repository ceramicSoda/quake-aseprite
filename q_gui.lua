require "q_lmp"
require "q_spr"

function init(plugin)
    plugin:newMenuGroup{
        id = "quake_id",
        title = "Quake gfx",
        group = "file_import"
    }

    plugin:newCommand{
        id = "import_spr",
        title = "Import .SPR",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "Import .SPR", notitlebar = false })
            dlg:file{
                id = "import_spr_f",
                label = " File: ",
                title = "Import .SPR",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"spr"},
                onchange = function()
                    dlg:modify({ id = "confirm", enabled = true })
                end
            }
            dlg:label{text = string.rep(" ", 60)} 
            dlg:button{ id = "confirm", text = "Import", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            if data.confirm then
                importSpr(data.import_spr_f);
            end
        end
    }

    plugin:newCommand{
        id = "export_spr_spr",
        title = "Export .SPR",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "export .SPR", notitlebar = false })
            dlg:file{
                id = "export_spr_f",
                label = " File: ",
                title = "export .SPR",
                open = false,
                save = true,
                filename = "",
                filetypes = {"spr"},
                onchange = function()
                    dlg:modify({ id = "confirm", enabled = app.sprite ~= nil })
                end
            }
            dlg:label{text = string.rep(" ", 60)}
            dlg:separator{}
            dlg:combobox{
                id = "import_spr_type",
                label = " Type: ",
                option = "0: Vertical, facing camera",
                options = {
                    "0: Facing camera, Vertical",
                    "1: Facing camera, Vertical, Parallel to screen",
                    "2: Facing camera, Parallel to screen",
                    "3: Oriented",
                    "4: Facing camera, Oriented",
                },
            }
            dlg:combobox{
                id = "import_spr_synchtype",
                label = " Animation Sync Type: ",
                option = "0: Synchronous",
                options = {
                    "0: Synchronous",
                    "1: Own for each sprite",
                },
            }
            function showWarning()
                if app.sprite.colorMode ~= ColorMode.INDEXED then
                    return true
                else
                    return false
                end
            end
            dlg:label{ id = "filesize_warning_a", label = "", text = "                    RGB color mode export is experimental ! ", visible = showWarning() }
            dlg:label{ id = "filesize_warning_b", label = "", text = "            Not recommended for sprites bigger than 320x320 ", visible = showWarning() }
            dlg:label{ id = "filesize_warning_c", label = "", text = "                                       Nothing to export :< ", visible = app.sprite == nil }
            dlg:button{ id = "confirm", text = "Export", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            if data.confirm then
                local settings = {
                    type = tonumber(dlg.data.import_spr_type:match("^(%d+):")),
                    synchtype = tonumber(dlg.data.import_spr_synchtype:match("^(%d+):"))
                }
                exportSpr(data.export_spr_f, settings)
            end
        end
    }

    plugin:newMenuSeparator{ group = "quake_id" }

    plugin:newCommand{
        id = "import_lmp",
        title = "Import .LMP",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "Import .LMP", notitlebar = false })
            dlg:file{
                id = "import_lmp_f",
                label = " File: ",
                title = "Import .LMP",
                open = true,
                focus = true,
                filename = "",
                filetypes = {"lmp"},
                onchange = function()
                    dlg:modify({ id = "confirm", enabled = true })
                end
            }
            dlg:label{text = string.rep(" ", 60)} 
            dlg:separator{}
            dlg:combobox{
                id = "import_lmp_filetype",
                label = " Type: ",
                option = "Image",
                options = {"Image", "Palette"},
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
        title = "Export .LMP",
        group = "quake_id",
        onclick = function()
            local dlg = Dialog({ title = "export .LMP", notitlebar = false })
            dlg:file{
                id = "export_lmp_f",
                label = " File: ",
                title = "export .LMP",
                open = false,
                save = true,
                filename = "",
                filetypes = {"lmp"},
                onchange = function()
                    dlg:modify({ id = "confirm", enabled = app.sprite ~= nil })
                end
            }
            dlg:label{text = string.rep(" ", 60)}
            dlg:separator{}
            dlg:combobox{
                id = "export_lmp_filetype",
                label = " Type: ",
                option = "Image",
                options = {"Image", "Palette"},
                onchange = function ()
                    dlg:modify({ id = "filesize_warning_a", visible = showWarning()})
                    dlg:modify({ id = "filesize_warning_b", visible = showWarning()})
                end
            }
            function showWarning()
                if app.sprite ~= nil then
                    if app.sprite.colorMode ~= ColorMode.INDEXED then
                        return dlg.data.export_lmp_filetype == "Image"
                    else 
                        return false
                    end
                else
                    return false
                end
            end
            dlg:label{ id = "filesize_warning_a", label = "", text = "                    RGB color mode export is experimental ! ", visible = showWarning() }
            dlg:label{ id = "filesize_warning_b", label = "", text = "            Not recommended for sprites bigger than 320x320 ", visible = showWarning() }
            dlg:label{ id = "filesize_warning_c", label = "", text = "                                       Nothing to export :< ", visible = app.sprite == nil }
            dlg:button{ id = "confirm", text = "Export", enabled = false}
            dlg:button{ id = "cancel", text = "Cancel" }
            dlg:show()

            local data = dlg.data
            local filetype = dlg.data.export_lmp_filetype
            if data.confirm then
                if filetype == "Image" then
                    exportLmp(data.export_lmp_f)
                elseif filetype == "Palette" then
                    exportLmpPal(data.export_lmp_f)
                end
            end
        end
    }
end