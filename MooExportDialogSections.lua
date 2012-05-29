-------------------------------------------------------------------------------
--
-- moo.lrplugin/MooExportDialogSections.lua
-- 
-- a Lightroom plugin to assist in the creation of MOO Business Cards
-- 
-- (c) MOO Print Ltd 2012
-- 
-------------------------------------------------------------------------------

local LrView = import 'LrView'

MooExportDialogSections = {}

function MooExportDialogSections.sectionsForTopOfDialog(f, propertyTable)
   local f = LrView.osFactory()
   local bind = LrView.bind

   local result = {
      {
         title = "MOO",
         
         f:row {
            f:picture {
	       fill_horizontal = 0.3,
               value = _PLUGIN:resourceId("moo.png"),
            },
            f:column {
               spacing = f:control_spacing(),
               f:row {
                  spacing = f:label_spacing(),
                  f:static_text {
                     title = "Make",
                     alignment = "right",
		     width = LrView.share "label_width"
                  },
                  f:popup_menu {
                     value = bind 'moo_product',
                     items = {
                        {
                           title = 'Business Cards',
                           value = 'businesscard'
                        }, 
                        {
                           title = 'MiniCards',
                           value = 'minicard'
                        }, 
                        {
                           title = 'Postcards',
                           value = 'postcard'
                        }
                     }
                  }
               },
               f:row {
                  spacing = f:label_spacing(),
                  f:static_text {
                     title = "Cards will be",
                     alignment = "right",
		     width = LrView.share "label_width"
                  },
                  f:popup_menu {
                     value = bind 'moo_orientation',
                     items = {
                        {
                           title = 'landscape',
                           value = 'landscape'
                        }, 
                        {
                           title = 'portrait',
                           value = 'portrait'
                        }, 
                        {
                           title = 'oriented automatically',
                           value = 'automatic'
                        }
                     }
                  }
               }
            }
	 }
      }
   }   
   return result
   
end

return MooExportDialogSections
