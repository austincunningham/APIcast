-- This is a hello_world description.

local policy = require('apicast.policy')
local _M = policy.new('hello_world')

local new = _M.new
ngx.log(ngx.NOTICE,"new policy =======================>",_M)
--- Initialize a hello_world
-- @tparam[opt] table config Policy configuration.
function _M.new(config)
  local self = new(config)
  -- new code
  ngx.log(ngx.NOTICE, "============================> secret : ", config.secret," overwrite : ", config.overwrite)
  if config then
    if config.overwrite == nil then
      self.overwrite = true
    else
      self.overwrite = config.overwrite
    end
    self.secret = config.secret
  end
  -- close new code
  return self
end

-- now create or overwrite HTTP headers with url params
local function paramsToHeaders(query_params, overwrite)
  -- ngx.log(ngx.NOTICE,"paramsToHeaders i am here =======================>",overwrite)
  for k, v in pairs(query_params) do
    -- ngx.log(ngx.NOTICE, "============================> k:  " .. k .. " =========================> v: " .. v)
    if overwrite == false and ngx.req.get_headers()[k] ~= nil then
     ngx.log(ngx.NOTICE, "existing header found with name " .. k .. " but not overwritten because of setting overwrite is " .. tostring(overwrite))
    else
     --ngx.log(ngx.NOTICE, "============================> " .. k .. " =========================> " .. tostring(overwrite))
     ngx.req.set_header(k, v)
    end
  end
  ngx.req.set_uri_args = nil
end

-- new function to read url params
function _M:rewrite(context)
  --read HTTP query params as Lua table
  local query_params = ngx.req.get_uri_args()
  -- ngx.log(ngx.NOTICE,"rewrite i am here =================================> query_params: ",query_params," overwrite: ",self.overwrite," ", config.overwrite)
  paramsToHeaders(query_params, self.overwrite)

  local secret_header = ngx.req.get_headers()["secret"]
  context.secret_header = secret_header
end
-- new function to set 403 if the secret header is not sent
function _M:access(context)
  local secret_header = context.secret_header
  -- ngx.log(ngx.NOTICE,"do I get here =======================>",secret_header, " self secret =",self.secret)
  if secret_header ~= self.secret then
   ngx.log(ngx.NOTICE, "request is not authorized, secrets do not match")
   ngx.status = 403
   return ngx.exit(ngx.status)
  else
   ngx.log(ngx.NOTICE, "request is authorized, secrets match")
  end
end

return _M
