local fs = require "nixio.fs"
local json = require "luci.jsonc"

module("luci.controller.gdutwifi", package.seeall)
function index()
	entry({"admin", "services", "gdutwifi"}, cbi("gdutwifi/base"), translate("GDUT LOGIN"), 20)
    entry({"admin", "services", "gdutwifi","get_status"}, call("get_status"))
end
function get_status()
    local login_log = "/tmp/gdutwifi/%s_login"
    local status_log = "/tmp/gdutwifi/%s_status"
    cfg = luci.http.formvalue("cfg")
    r = {}
    r["login_log"] = {}
    r["status_log"] = {}
    if cfg == nil then
        r["error_code"] = "1"
        luci.http.prepare_content("application/json")
        luci.http.write_json(r)
        return
    end
    login_log = string.format(login_log,cfg)
    status_log = string.format(status_log,cfg)
    if fs.stat(login_log) then
        r["login_log"] = json.parse(fs.readfile(login_log))
    end
    if fs.stat(status_log) then
        r["status_log"] = json.parse(fs.readfile(status_log))
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json(r)

end
