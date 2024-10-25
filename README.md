# GDUT LOGIN 项目介绍

GDUT LOGIN 是一款用于自动化登录广东工业大学（GDUT）校园网的工具。该插件旨在简化用户的网络认证过程，提供便捷的校园网络连接，帮助用户以更低的成本享受校园网络服务。

## 使用说明

### 安装插件

- 可以选择自己编译或从 release 下载。
- 本插件使用脚本作为后端，Lua 作为前端，适配绝大部分架构。
- 依赖软件包：`curl` 和 `jq`。

#### 编译进插件的方法

如果选择自己编译，请按照以下步骤操作：

```bash
echo >> feeds.conf.default
echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
./scripts/feeds update modem
./scripts/feeds install -a -p modem
make menuconfig
make -j16
```

### 配置设置

1. **启用服务**：
   - 在设置中勾选“Enable Service”以启用插件。

2. **登录实例**：
   - 填写用户名和密码等信息。

3. **绑定接口**：
   - 如果需要自动认证的接口在路由器上，直接选择需要认证的接口即可。

4. **手动设置**：
   - 若需要自动认证其他设备，可以将其他设备的 IP 填写到实例里。

5. **监控 API**：
   - 目前登录状态监控有两种实现：
     - 校园网认证登录接口
     - 校园网登录状态查询接口
   - 使用校园网登录状态查询接口只能查询路由器上的接口的登录状态，无法获取其他设备的登录状态。

6. **AC IP**：
   - 不同校区、不同区域可能不同，目前仅测试了龙洞校区 D/E 栋宿舍楼的 AC IP，可能需要自己获取。
   - 获取方法：在未登录状态下执行 `curl http://9.9.9.9`，查看返回的 `nexturl` 中的 `wlan_ac_ip` 参数。

7. **认证服务器 IP**：
   - 不同校区可能不同，目前写死在 `luci/luci-app-gdutwifi/root/usr/share/gdutwifi/try_login.sh` 中。
   - 获取方法：在未登录状态连接校园网 WiFi，查看自动跳转的网页 IP。

8. **检查间隔**：
   - 暂不清楚是否有副作用，建议频率不要太高。

## 使用建议

- **简单版本**：
  - 使用 WiFi 桥接校园网的 AP，认证后 NAT 给后端的设备使用。

- **进阶版本**：
  - 使用宿舍 CPE（光猫）贴纸上的默认密码进入后台，改成三层接口或 VLAN 转换后接网线使用，更稳定，可多拨（已测试，不提供支持）。
