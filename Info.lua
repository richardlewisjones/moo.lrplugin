-------------------------------------------------------------------------------
--
-- moo.lrplugin/Info.lua
-- 
-- a Lightroom plugin to assist in the creation of MOO Business Cards
-- 
-- (c) MOO Print Ltd 2012
-- 
-------------------------------------------------------------------------------

local info = {
   LrSdkVersion = 3.0,
   LrSdkMinimumVersion = 3.0,
   
   LrToolkitIdentifier = 'com.moo.lightroom.export',
   LrPluginName = 'MOO Export Plugin',
   
   LrExportServiceProvider = {
      title = 'MOO',
      file = 'MooExportServiceProvider.lua',
   },
   
   VERSION = {
      major = 0,
      minor = 1,
      revision = 0,
      build = 0
   }
}

return info