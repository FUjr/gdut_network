# GDUT LOGIN

## 项目介绍

GDUT LOGIN 是一款用于自动化登录广东工业大学（GDUT）校园网的工具。该插件旨在简化用户的网络认证过程，提供便捷的校园网络连接，帮助用户以更低的成本享受校园网络服务。

## 使用说明

1. **安装插件**：可以自己编译或从release下载，本插件使用脚本作为后端+lua前端，适配绝大部分架构，只需要有curl和jq软件包即可
2. **配置设置**：
   - 启用服务：在设置中勾选“Enable Service”以启用插件。
   - 登录实例：填写用户名、和密码等信息。
   - 绑定接口：如果你需要自动认证的接口就在路由器上，且没有特殊的需求，直接选择需要认证的接口即可
   - 手动设置：如果你需要自动认证其他设备，可以将其他设备的ip填写到实例里
   - 监控API：目前登陆状态监控有两种实现，分别是通过 校园网认证登录接口 和 校园网登录状态查询接口，使用 校园网登录状态查询接口 只能查询路由器上的接口的登陆状态，无法获取其他设备的登陆状态
   - AC IP: 不同校区、不同区域可能不同，目前仅测试了龙洞校区D/E栋宿舍楼的AC IP，可能需要自己获取。 获取方法：在未登录状态 ```curl http://9.9.9.9``` 查看返回的nexturl里的wlan_ac_ip参数
   - 认证服务器IP: 不同校区可能不同，目前写死在 ```luci/luci-app-gdutwifi/root/usr/share/gdutwifi/try_login.sh``` 中，获取方法: 在未登录状态连接校园网wifi，看自动跳转的网页ip是多少，填入前述脚本即可
3. **检查间隔**：暂不清楚是否有副作用，建议频率不要太高。
4. **使用建议**: 
   - 简单版本：使用wifi桥接校园网的ap，认证后nat给后端的设备使用
   - 进阶版本：使用宿舍CPE（光猫）贴纸上的默认密码进入后台，改成三层接口或vlan转换后接网线使用，更稳定 可多拨（已测试）

## 编译进插件的方法
```
echo >> feeds.conf.default
echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
./scripts/feeds update modem
./scripts/feeds install -a -p modem
make menuconfig
make -j16
```
