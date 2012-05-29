-------------------------------------------------------------------------------
--
-- moo.lrplugin/MooProducts.lua
-- 
-- a Lightroom plugin to assist in the creation of MOO Business Cards
-- 
-- (c) MOO Print Ltd 2012
-- 
-------------------------------------------------------------------------------

local products = {
   businesscard = {
      name = "Business Card",
      mooName = "businesscard",
      imageTemplates = {
	 landscape = "businesscard_full_image_landscape",
	 portrait = "businesscard_full_image_portrait"
      },
      detailsTemplate = "businesscard_full_text_landscape",
      width = 84, --mm
      height = 55, --mm
      items = 50 
   },
   minicard = {
      name = "MiniCard",
      mooName = "minicard",
      imageTemplates = {
	 landscape = "minicard_full_image_landscape",
	 portrait = "minicard_full_image_portrait"
      },
      detailsTemplate = "minicard_full_text_landscape",
      width = 70, --mm
      height = 28, --mm
      items = 100
   },
   postcard = {
      name = "Postcard",
      mooName = "postcard",
      imageTemplates = {
	 landscape = "postcard_full_image_landscape",
	 portrait = "postcard_full_image_portrait"
      },
      detailsTemplate = "postcard_blank",
      width = 148, --mm
      height = 105, --mm
      items = 20
   }
}

return products
