-------------------------------------------------------------------------------
--
-- moo.lrplugin/MooExportTask.lua
-- 
-- a Lightroom plugin to assist in the creation of MOO Business Cards
-- 
-- (c) MOO Print Ltd 2012
-- 
-------------------------------------------------------------------------------

MooExportTask = {}

local LrPathUtils = import 'LrPathUtils'
local LrHttp = import 'LrHttp'
local LrFileUtils = import 'LrFileUtils'
local LrErrors = import 'LrErrors'

local JSON = require 'JSON'
local OAuth = require 'OAuth'
local MooProducts = require 'MooProducts'

local API_KEY = '61c693ad1b0e2dd34046feaa38ca213304fc4bfe3'
local API_SECRET = '2146175d0684f60309ab2e2f2409af6a' 

local BLEED = 2 -- mm

function JSON.assert(message)
   LrErrors.throwUserError("Could not decode response from MOO.")
end

local function getImageByType(imageBasketItem, type)
   for _, image in ipairs(imageBasketItem.imageItems) do
      if image.type == type then
	 return image
      end      
   end
   
   return nil
end

local function scaleImageDimensions(productWidth, productHeight, imageWidth, imageHeight)
   local productAspect = productWidth / productHeight
   local imageAspect = imageWidth / imageHeight

   if imageAspect > productAspect then
      return productWidth * imageAspect / productAspect, productHeight
   else
      return productWidth, productHeight * productAspect / imageAspect
   end
end
   
local function makeSimplePack(imageBasketItems, product, orientationPreference)
   local sides = {}
      
   for i, imageBasketItem in ipairs(imageBasketItems) do
      local orientation = orientationPreference or 'landscape'
      local image = getImageByType(imageBasketItem, 'print')

      if not image then
	 LrErrors.throwUserError('Could not decode response from MOO.')
      end

      local pw, ph = product.width, product.height

      if orientation == 'automatic' then
	 orientation = image.width > image.height and 'landscape' or 'portrait'	 
      end

      if orientation == 'portrait' then
	 pw, ph = ph, pw
      end      

      local sw, sh = scaleImageDimensions(pw, ph, image.width, image.height)

      local data = {
	 {
	    type = 'imageData',
	    linkId = 'variable_image_front',
	    imageBox = {
	       center = {
		  x = sw / 2 + BLEED,
		  y = sh / 2 + BLEED
	       },
	       width = sw + BLEED * 2,
	       height = sh + BLEED * 2,
	       angle = 0
	    },
	    resourceUri = imageBasketItem.resourceUri,
	    enhance = false
	 }
      }
      
      sides[#sides + 1] = {
	 type = 'image',
	 sideNum = i,
	 templateCode = product.imageTemplates[orientation],
	 data = data
      }
   end

   sides[#sides + 1] = {
      type = 'details',
      sideNum = 0,
      templateCode = product.detailsTemplate,
      data = {}
   }
   
   return {
      numCards = product.items,
      productCode = product.mooName,
      productVersion = 1,
      sides = sides,
      extras = {},
      imageBasket = {
	 items = imageBasketItems
      }
   }
end
   
local function protectHttpCall(f)
   body, headers = f()
   
   if not body then
      LrErrors.throwUserError('Did not get a reply from MOO.')
   elseif not headers.status then
      LrErrors.throwUserError('Could not understand the response from MOO.')
   else
      if headers.status == 200 then
	 return body
      else
	 LrErrors.throwUserError('Communication problems with MOO.')
      end	    
   end   
end
   
local function uploadImage(path) 
   local mimeChunks = {	 
      {name = 'method', value = 'moo.image.uploadImage'},
      {name = 'imageFile', fileName = LrPathUtils.leafName(path), filePath = path, contentType = 'application/octet-stream'}
   }
   
   local response = protectHttpCall(function() 
				       return LrHttp.postMultipart('http://uk.moo.com/api/service/', mimeChunks)
				    end)
   
   local parsedResponse = JSON:decode(response)
   if parsedResponse['imageBasketItem'] then
      return parsedResponse['imageBasketItem']
   else
      LrErrors.throwUserError("Image could no be uploaded.")
   end
end

local function sendPack(pack)   
   local parameters = {
      method = 'moo.pack.createPack',
      product = pack.productCode,
      pack = JSON:encode(pack)
   }
   
   local payload = OAuth.sign('http://uk.moo.com/api/service/', 'POST', API_KEY, API_SECRET, 'com.moo.lightroom.export', parameters)
   local response = protectHttpCall(function()
				       return LrHttp.post('http://uk.moo.com/api/service/', payload, 
							  {
							     {field = 'Content-Type', value = 'application/x-www-form-urlencoded'},
							     {field = 'Content-Length', value = tostring(#payload)}
							  })	
				    end)
   
   
   local parsedResponse = JSON:decode(response)
   if type(parsedResponse.dropIns) == 'table' and parsedResponse.dropIns.crop then
      return parsedResponse.dropIns.crop
   else
      LrErrors.throwUserError('There was a problem with sending the pack to MOO.')
   end
end

function MooExportTask.processRenderedPhotos(functionContext, exportContext)
   local exportSession = exportContext.exportSession
   local exportParams = exportContext.propertyTable
   local product = MooProducts[exportParams.moo_product] or MooProducts[1]
   local orientationPreference = exportParams.moo_orientation or 'landscape'
   local photoCount = exportSession:countRenditions()
   local title = photoCount > 1 and 'Uploading ' .. photoCount .. ' photos to MOO' or 'Uploading one photo to MOO'
   local progress = exportContext:configureProgress {title = title}   
   local imageBasketItems = {}

   for _, rendition in exportContext:renditions {stopIfCanceled = true} do
      local success, path = rendition:waitForRender()
      
      if not progress:isCanceled() then
	 table.insert(imageBasketItems, uploadImage(path))
      end
   end

   if not progress:isCanceled() then   
      progress:setCaption("Assembling pack")      
      local pack = makeSimplePack(imageBasketItems, product, orientationPreference)      

      progress:setCaption("Sending pack")
      local url = sendPack(pack)
      
      progress:setCaption("Opening MOO canvas page")      
      LrHttp.openUrlInBrowser(url)
   end
end

return MooExportTask
