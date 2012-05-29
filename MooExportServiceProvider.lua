-------------------------------------------------------------------------------
--
-- moo.lrplugin/MooExportServiceProvider.lua
-- 
-- a Lightroom plugin to assist in the creation of MOO Business Cards
-- 
-- (c) MOO Print Ltd 2012
-- 
-------------------------------------------------------------------------------

require 'MooExportTask'
require 'MooExportDialogSections'

local serviceProvider = {

   hideSections = {'exportLocation', 'fileNaming', 'fileSettings', 'imageSettings',
		   'video', 'metadata', 'outputSharpening', 'watermarking'},
   
   allowFileFormats = {'JPEG', 'TIFF'}, 
   
   allowColorSpaces = nil,
   
   exportPresetFields = {
      {key = 'moo_product', default = 'businesscard'},
      {key = 'moo_orientation', default = 'automatic'}
   },

   sectionsForTopOfDialog = MooExportDialogSections.sectionsForTopOfDialog,
	
   processRenderedPhotos = MooExportTask.processRenderedPhotos,   
}

return serviceProvider
