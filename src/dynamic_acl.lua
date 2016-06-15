
json = require('json')

local dynamicACL = {
    _DESCRIPTION        = 'Dynamic ACL for Nginx written in Lua.',
    _URL                = 'https://github.com/ConnectHolland/nginx-dynamic-acl'
}

-- Authorizes authenticated users for specific configured paths.
function dynamicACL.authorize(authorizationsFile)
    local username = ngx.var.remote_user
    ngx.log(ngx.DEBUG, role)

    local authorizations = dynamicACL.loadAuthorizations(authorizationsFile)

    local userGroup = authorizations.userGroups[username]
    if userGroup == nil then
        return dynamicACL.denyAccess("Unknown user [" .. username .. "]")
    end

    local authorizations = authorizations.groupAuthorizations[userGroup]
    if authorizations == nil then
        return dynamicACL.denyAccess("User [" .. username .. "] is member of an unknown group [" .. userGroup .. "]")
    end

    -- Get request URI and method
    local requestUri = ngx.var.uri
    local requestMethod = ngx.req.get_method()
    ngx.log(ngx.DEBUG, requestMethod .. " " .. requestUri)

    local allowed = false

    for path, methods in pairs(authorizations) do

        local pathMatches = string.match(requestUri, path)
        local methodMatches = nil

        for _, _method in pairs(methods) do
            methodMatches = methodMatches and methodMatches or string.match(requestMethod, _method)
        end

        if pathMatches and methodMatches then
            allowed = true
            ngx.log(ngx.NOTICE, requestMethod .. " " .. requestUri .. " matched: " .. tostring(m) .. " " .. tostring(path) .. " for " .. username)
            break
        end
    end

    if not allowed then
        return dynamicACL.denyAccess("User [" .. username .. "] of group [" .. userGroup .. "] not allowed to access the resource [" .. requestMethod .. " " .. requestUri .. "]")
    end
end

-- Loads the users and groups from a file.
function dynamicACL.loadAuthorizations(authorizationsFile)
    local file = io.open(authorizationsFile, 'r')
    if not file then
        return nil
    end

    local contents = file:read('*all')
    file:close()

    return json.decode(contents)
end

-- Logs the logMessage returns forbidden to Nginx.
function dynamicACL.denyAccess(logMessage)
    ngx.header.content_type = 'text/plain'
    ngx.log(ngx.WARN, logMessage)
    ngx.status = 403
    ngx.say("403 Forbidden: You don\'t have access to this resource.")

    return ngx.exit(403)
end

return dynamicACL
