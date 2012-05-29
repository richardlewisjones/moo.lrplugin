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
	 title = "MOO Product",
	 
	 f:row {
	    f:static_text {
	       title = "Make:",
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
		  }, 
		  
	       }
	    }
	 }
      },
      {
	 title = "Orientation",
	 
	 f:row {
	    f:static_text {
	       title = "Cards will be:",
            },
	    f:popup_menu {
	       value = bind 'moo_orientation',
	       items = {
		  {
		     title = 'Landscape',
		     value = 'landscape'
		  }, 
		  {
		     title = 'Portrait',
		     value = 'portrait'
		  }, 
		  {
		     title = 'Oriented Automatically',
		     value = 'automatic'
		  }, 
		  
	       }
	    }
	 }
      }
   }
   
   return result
   
end

return MooExportDialogSections
