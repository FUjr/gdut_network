# GDUT LOGIN

## 项目介绍

GDUT WIFI LOGIN 是一款用于自动化登录广东工业大学（GDUT）WIFI校园网的工具，具备定时监控登陆状态，自动登录的功能。可以通过桥接WIFI实现网络共享，也可以根据CPE标签进入后台，将wifi的vlan绑定到网口，实现更稳定更高速的上网。
在龙洞校区实测2无线账号+1有线账号（直接pppoe）叠加可达到教育网千兆的效果。其中有线账号需要用ua2f 或者将http标记以避免包含Android/ios的ua被检测导致被共享检测机制断网。
![](imgs/tri_dial_1000M.png)

![gdut wifi自动认证插件](imgs/gdut_wifi.png)

## 使用方法

### 增加feed源

```
echo >> feeds.conf.default
echo 'src-git gdut_network https://github.com/FUjr/gdut_network.git;main' >> feeds.conf.default
./scripts/feeds update gdut_network
./scripts/feeds install -a -p gdut_network
```

### 选择软件包后编译即可

```
make menuconfig
```

## 使用说明

1. **安装插件**：可以自己编译或从release下载，本插件使用脚本作为后端+lua前端，适配绝大部分架构，只需要有curl和jq软件包即可
2. **配置设置**：
   - 启用服务：在设置中勾选“Enable Service”以启用插件。
   - 登录实例：填写用户名、AC IP 和密码等信息。
   - 绑定接口：选择合适的网络接口进行认证。
3. **手动设置 IP**（可选）：如果需要，可以手动输入 IP 地址进行认证。
4. **检查间隔**：设置检查间隔时间，以便插件定期检查网络状态。

## 功能介绍

- **状态监控**：实时监控网络状态，确保用户始终在线。
- **多个接口支持**：支持多种网络接口的绑定，适应不同的网络环境。
- **手动 IP 设置**：允许用户手动设置 IP 地址，以便在特定情况下进行认证。
- **检查频率设置**：用户可以自定义检查网络状态的频率，优化网络连接体验。

通过 GDUT LOGIN，用户可以轻松连接校园网，享受稳定和高效的网络服务。
