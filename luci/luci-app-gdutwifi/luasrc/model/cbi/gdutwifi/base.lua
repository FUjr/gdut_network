m = Map("gdutwifi")
m.title = translate("GDUT WIFI LOGIN")
s = m:section(NamedSection,"main","main",translate("Global Settings"))
o = s:option(Flag,"Enable",translate("Enable Service"))

o = s:option(Button,"_author_url",translate("Go To Readme page"))
o.inputstyle = "apply"
o.inputtitle = translate("Click to open the readme page")
o.write = function()
    luci.http.redirect("https://github.com/FUjr/gdut_network/blob/main/README.md")
end

s = m:section(TypedSection,"config",translate("Login instance"))
s.addremove = true
s.anonymous = true
o = s:option(Flag,"Enable",translate("Enable Instance"))

o = s:option(ListValue,"Monitor_api",translate("Monitor API"))
o:value("1",translate("Login API"))
o:value("2",translate("Status API"))

o = s:option(Value,"check_interval",translate("Check Interval"))
o.datatype = "uinteger"


o = s:option(Value,"ac_ip",translate("AC IP"))
o.datatype = "ip4addr"
o:value("172.16.254.6","172.16.254.6(" .. translate("GDUT LongDong D/E")..")")

o = s:option(Value,"username",translate("Username"))


o = s:option(Value,"password",translate("Password"))
o.password = true

o = s:option(Value,"bind_interface",translate("Bind Interface"))
o.template = "cbi/network_netlist"
o.nocreate = true
o.unspecified = true
o.description = translate("Select the network interface to bind for authentication. This interface will not only be used to determine the IP address for automatic authentication but also serves as the exit point for the authentication packets.")

o = s:option(Value,"force_ip",translate("Manually Set IP"))
o.datatype="ip4addr"
o.description = translate("Enter the IP address manually for authentication. If this option is specified, the program will use the provided IP address instead of the one associated with the binding interface.")



o = s:option(DummyValue,"_status",translate("Status"))
o.template = "gdutwifi/gdutwifi_status"
return m
