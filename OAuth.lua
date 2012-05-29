-------------------------------------------------------------------------------
--
-- OAuth.lua
-- 
-- extracted from Jeffrey Friedl's Twitter Authentication
-- http://regex.info/code/TwitterAuthentication.lua
-- 
-------------------------------------------------------------------------------

local LrStringUtils = import 'LrStringUtils'
local LrDate = import 'LrDate'
local LrMD5 = import 'LrMD5'

require 'sha1'

OAuth = {}

local function generate_nonce(base)
   return LrStringUtils.encodeBase64(LrMD5.digest(base)
				     .. LrMD5.digest(tostring(math.random()) .. "random")
				     .. tostring(LrDate.currentTime()))
end

-- UnixTime of 978307200 is a CocoaTime of 0
local CocoaTimeShift = 978307200

local function unix_timestamp()
   return tostring(CocoaTimeShift + math.floor(LrDate.currentTime() + 0.5))
end

local function oauth_encode(val)
   return tostring(val:gsub('[^-._~a-zA-Z0-9]', function(letter)
                                                   return string.format("%%%02x", letter:byte()):upper()
                                                end))
   -- The wrapping tostring() above is to ensure that only one item is returned (it's easy to
   -- forget that gsub() returns multiple items
end


-- Given a url endpoint, a GET/POST method, and a table of key/value args, build
-- the query string and sign it, returning the query string (in the case of a
-- POST) or, for a GET, the final url.
--
-- The args should also contain an 'oauth_token_secret' item, except for the
-- initial token request.

function OAuth.sign(url, method, consumer_key, consumer_secret, nonce_base, args)
   assert(method == "GET" or method == "POST")

   local token_secret    = args.oauth_token_secret or ""

   args.oauth_consumer_key = consumer_key
   args.oauth_timestamp = unix_timestamp()
   args.oauth_version = '1.0'
   args.oauth_nonce = generate_nonce(nonce_base)

   --
   -- Remove the token_secret from the args, 'cause we neither send nor sign it.
   -- (we use it for signing which is why we need it in the first place)
   --
   args.oauth_token_secret = nil

   -- Twitter does only HMAC-SHA1
   args.oauth_signature_method = 'HMAC-SHA1'


   --
   -- oauth-encode each key and value, and get them set up for a Lua table sort.
   --
   local keys_and_values = { }

   for key, val in pairs(args) do
      table.insert(keys_and_values,  {
                      key = oauth_encode(key),
                      val = oauth_encode(val)
                   })
   end

   --
   -- Sort by key first, then value
   --
   table.sort(keys_and_values, function(a,b)
                          if a.key < b.key then
                             return true
                          elseif a.key > b.key then
                             return false
                          else
                             return a.val < b.val
                          end
                       end)

   --
   -- Now combine key and value into key=value
   --
   local key_value_pairs = { }
   for _, rec in pairs(keys_and_values) do
      table.insert(key_value_pairs, rec.key .. "=" .. rec.val)
   end

   --
   -- Now we have the query string we use for signing, and, after we add the
   -- signature, for the final as well.
   --
   local query_string_except_signature = table.concat(key_value_pairs, "&")

   --

   -- Don't need it for Twitter, but if this routine is ever adapted for
   -- general OAuth signing, we may need to massage a version of the url to
   -- remove query elements, as described in http://oauth.net/core/1.0#rfc.section.9.1.2
   --
   -- More on signing:
   --   http://www.hueniverse.com/hueniverse/2008/10/beginners-gui-1.html
   --
   local SignatureBaseString = method .. '&' .. oauth_encode(url) .. '&' .. oauth_encode(query_string_except_signature)
   local key = oauth_encode(consumer_secret) .. '&' .. oauth_encode(token_secret)

   --
   -- Now have our text and key for HMAC-SHA1 signing
   --
   local hmac_binary = hmac_sha1_binary(key, SignatureBaseString)

   --
   -- Base64 encode it
   --
   local hmac_b64 = LrStringUtils.encodeBase64(hmac_binary)

   --
   -- Now append the signature to end up with the final query string
   --
   local query_string = query_string_except_signature .. '&oauth_signature=' .. oauth_encode(hmac_b64)

   if method == "GET" then
      -- return the full url
      return url .. "?" .. query_string
   else
      -- for a post, just return the query string, so it can be included in the POST payload
      return query_string
   end
end

return OAuth
