# ScrollSwitch

**鼠标像 Windows，触控板还是 Mac。**

一个免费的 macOS 菜单栏小工具：只反转外接鼠标的滚轮方向，触控板保持 macOS 原生的自然滚动。两者互不干扰。

> 不联网 · 不改系统滚动设置 · 不需要密码 · 随包脚本一键卸载

## 为什么需要它

macOS 只有一个全局的「自然滚动」开关，鼠标和触控板共用。关掉它，鼠标顺了，触控板却变成反的；打开它，触控板对了，鼠标又反了。系统设置里没有"分设备"选项。

ScrollSwitch 只处理传统鼠标发出的离散滚轮事件，触控板产生的连续手势事件原样放行。所以：

- **外接鼠标**：按 Windows 习惯滚动
- **触控板**：保持 macOS 自然滚动，完全不受影响

## 安装

1. 从 [Releases](../../releases) 下载 `ScrollSwitch-1.0.0.zip` 并解压
2. 双击 `安装.command`
   - 若被 Gatekeeper 拦截：到「系统设置 › 隐私与安全性」点「仍要打开」，再运行一次
3. 点击菜单栏新出现的图标 →「打开「辅助功能」设置」→ 勾选 **ScrollSwitch**

图标变成鼠标样式即生效。想确认它真的在工作：滚动几下，菜单里的「已反转 N 次滚轮」会增加，而「已放行 N 次触控板」只在用触控板时增加。

**系统要求**：macOS 13.0+，Apple Silicon / Intel（通用二进制）。

## 卸载

双击随包的 `卸载.command`，或在菜单栏图标里点「卸载 ScrollSwitch…」。

两种都会删除应用本体、登录启动项、偏好设置、缓存、日志和辅助功能授权记录，并逐项打印残留检查结果。
**不要只把 App 拖进废纸篓**——那样登录项和授权记录会留下。

## 它不会做什么

- **不联网**：二进制里没有网络框架、没有 socket 符号、没有网络地址；运行时不打开端口
- **不改系统设置**：不碰 `com.apple.swipescrolldirection`，只在自己的进程里翻转滚轮事件的符号
- **不需要管理员密码**
- **不记录输入内容**：只订阅 `scrollWheel` 事件，不读取按键、不读屏幕
- **不做平滑滚动**：那是 Mos 的强项，本工具刻意只做一件事

## 安全与隐私（可自行核验）

本工具是 **ad-hoc 签名、未经 Apple 公证**，也没有上架 App Store——这是零预算决定的，不是因为代码有问题。源码与构建脚本全部公开，欢迎审阅。

下载后建议先校验：

```bash
shasum -a 256 ScrollSwitch-1.0.0.zip
# 期望：be77a23f997867a7ae73e95edc69ed428a1e9dd6c0d1a5bbd0c771b391f01a81
```

启动程序后，可验证它没有网络行为：

```bash
# 1) 无网络框架依赖（应无输出）
otool -L /Applications/ScrollSwitch.app/Contents/MacOS/ScrollSwitch | grep -Ei 'CFNetwork|Network\.framework|libcurl'

# 2) 无 socket 符号（应无输出）
nm -u /Applications/ScrollSwitch.app/Contents/MacOS/ScrollSwitch | grep -Ei 'socket|connect|URLSession'

# 3) 运行时无网络连接/监听（应无输出）
lsof -nP -a -p "$(pgrep -x ScrollSwitch | head -1)" -i
```

## 与其他工具的关系

| | ScrollSwitch | Mos | Scroll Reverser | 系统开关 |
|---|---|---|---|---|
| 滚轮方向 | 只反转传统鼠标滚轮 | 可反转 + 平滑滚动 | 可按设备分别设置 | 全局联动 |
| 触控板 | 完全不碰 | 可单独配置 | 可单独配置 | 一并反转 |
| 联网 | **无** | 本地为主 | 不联网 | 无 |
| 体积 | **568 KB** | 较大 | 约 1.8 MB | 0 |
| 卸载 | 脚本清全部 | 常规 | 需手动删 plist | 无需 |

Scroll Reverser 和 Mos 都是免费开源的好工具，功能更全。如果你需要平滑滚动或精细的逐设备控制，它们更合适。ScrollSwitch 的定位是：**只想让鼠标方向对、别的都不想动**。

**请勿与同类工具同时运行**，否则可能叠加反转。

## 已知限制

- 带触摸表面的鼠标（如 Magic Mouse）和开启平滑滚动的驱动会产生连续事件，会被当作触控板放行
- 升级版本会改变签名，系统可能要求重新勾选辅助功能授权；程序首次未授权启动会自动清理旧记录并重新申请
- 少数 BLE 鼠标在从休眠唤醒后的第一格滚动可能被系统吞掉，与滚动方向无关

## 构建

```bash
./build.sh        # 需要 Xcode Command Line Tools
./package.sh      # 生成 dist/ScrollSwitch-1.0.0.zip
bash tests/test_all.sh
bash tests/test_security.sh
```

## 反馈

Bug、设备兼容问题、功能建议，请提 [GitHub Issue](../../issues)，包含鼠标型号、macOS 版本和复现步骤。

## 许可

MIT — 见 [LICENSE](LICENSE)。按「现状」提供，不附带任何担保。
