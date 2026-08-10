# xiaozhi-ios · 小智 iOS 客户端

[English](#english) · [中文](#中文)

一个基于 SwiftUI 的「小智」AI 助手 iOS 客户端，集成 Live2D 虚拟形象、实时语音对话、MCP 工具调用与多模态交互（视觉、地图、小红书、抖音、本地音乐等）。

A SwiftUI-based iOS client for the "xiaozhi" AI assistant, featuring a Live2D avatar, real-time voice conversation, MCP tool-calling, and multimodal interaction (vision, maps, Xiaohongshu, Douyin, local music, and more).

---

## 中文

### 功能特性

- **实时语音对话** —— 通过 WebSocket 与小智服务端低延迟通信，支持语音采集、流式播放与口型同步。
- **Live2D 虚拟形象** —— 基于 Live2D Cubism SDK（Metal 渲染），内置多款模型，支持表情、动作与嘴型联动。
- **MCP 工具调用** —— 内置 MCP（Model Context Protocol）管理器，允许 AI 调用设备端工具。
- **视觉识别** —— 调用相机拍照，进行 AI 视觉分析、识别周围物体、生成小红书文案。
- **小红书集成** —— 浏览笔记详情、生成并发布图文内容。
- **地图与导航** —— 基于高德地图的 POI 搜索、路线规划与定位服务。
- **抖音联动** —— 通过本地 WebSocket 与抖音交互。
- **本地音乐** —— 访问 Apple 音乐资料库播放本地音乐。
- **HTML 内容渲染** —— 动态渲染 AI 生成的网页内容。
- **设备身份管理** —— 基于 Keychain 的稳定设备标识，用于 OTA 激活与会话管理。

### 技术栈

- **UI**：SwiftUI
- **虚拟形象**：Live2D Cubism SDK（Native Framework + Metal 渲染）
- **通信**：WebSocket、Bonjour（局域网设备发现）
- **协议**：MCP（Model Context Protocol）
- **多媒体**：AVFoundation（音频采集 / 播放 / 语音合成）、Camera
- **位置**：CoreLocation + 高德地图
- **最低部署**：iOS 17.6

### 项目结构

```
.
├── xiaozhi/                # 主源码（Swift + Live2DManager.mm + Bridging Header）
│   ├── xiaozhiApp.swift    # App 入口
│   ├── ChatViewModel.swift # 核心会话状态机
│   ├── LockScreenView.swift# 主界面
│   ├── Live2D*             # Live2D 视图与配置
│   ├── MCPManager.swift    # MCP 工具管理
│   ├── WebSocketManager.swift
│   ├── AudioService.swift
│   ├── DouyinManager.swift
│   ├── NetworkServices.swift
│   └── ...
├── Framework/src/          # Live2D Cubism Framework 源码
├── Core/
│   ├── include/            # Live2D Cubism Core 头文件
│   └── lib/ios/            # libLive2DCubismCore.a 静态库
├── Metal/                  # Live2D Cubism Metal 渲染相关
├── Asset/                  # Live2D 模型资源（Hiyori / Haru / Rice / Mao 等）
├── Media.xcassets/         # App 图标与资源
└── Launch Screen.storyboard
```

### 环境要求

- Xcode 16 及以上
- iOS 17.6+ 的真机或模拟器
- Apple Developer 账号（用于真机签名）

### 构建与运行

1. **克隆仓库**

   ```bash
   git clone <repo-url>
   cd xiaozhi-ios
   ```

2. **配置签名** —— 在 Xcode 的 Signing & Capabilities 中：
   - 勾选 Automatically manage signing
   - 选择你的 Team
   - 将 Bundle Identifier 改为你自己的（如 `com.yourname.xiaozhi`）

3. **配置后端地址** —— 见下方 [配置说明](#配置说明)。

4. **构建运行** —— 选择目标设备，`⌘R` 运行。

> Live2D Cubism Core 静态库（`Core/lib/ios/libLive2DCubismCore.a`）已随仓库提供，无需额外下载即可编译。

### 配置说明

| 配置项 | 位置 | 说明 |
| --- | --- | --- |
| OTA 服务 | `xiaozhi/APIService.swift` | 默认指向 `https://api.tenclass.net/`，小智官方 OTA 服务。 |
| 业务后端 | `xiaozhi/AppConfig.swift` | `localIP` 指向高德 / 中间层 / 微信 / 小红书 / 视觉等自建服务，**需替换为你自己的服务地址**。 |

部分功能依赖自建后端服务（地图、视觉、小红书、抖音等）。若你尚未部署这些服务，对应功能将不可用，但不影响核心语音对话与 Live2D 展示。

### 第三方资源与许可

本项目使用了以下第三方资源，其版权归各自所有者所有，受各自的许可协议约束，**不在本项目的 MIT 许可范围内**：

| 资源 | 目录 | 许可 |
| --- | --- | --- |
| Live2D Cubism Core | `Core/lib/`、`Core/include/` | Live2D Proprietary License |
| Live2D Cubism Framework | `Framework/src/` | Live2D Open Software License |
| Live2D Metal 渲染示例 | `Metal/` | Live2D Cubism SDK 许可 |
| Live2D 模型素材 | `Asset/` | Live2D Free Material License（各模型独立） |
| stb_image | `Metal/thirdParty/stb/` | MIT / Public Domain |

使用、再分发上述资源前，请务必阅读并遵守 [Live2D 官方许可条款](https://www.live2d.com/en/sdk/license/)。商用前请特别确认是否符合 Live2D 的商用授权条件。

### 许可证

本项目自身的源代码（除上述第三方资源外）基于 **MIT License** 开源，详见 [LICENSE](./LICENSE)。

### 致谢

- [xiaozhi-esp32](https://github.com/78/xiaozhi-esp32) —— 小智 AI 硬件开源生态
- [Live2D](https://www.live2d.com/) —— Cubism SDK 与示例模型

---

## English

### Features

- **Real-time voice conversation** — Low-latency WebSocket communication with the xiaozhi server; supports audio capture, streaming playback, and lip-sync.
- **Live2D avatar** — Built on the Live2D Cubism SDK (Metal renderer) with multiple bundled models, expressions, motions, and mouth-sync.
- **MCP tool-calling** — A built-in MCP (Model Context Protocol) manager lets the AI invoke on-device tools.
- **Vision** — Camera capture for AI visual analysis, object recognition, and Xiaohongshu (RED) post generation.
- **Xiaohongshu integration** — Browse note details and generate / publish image-text posts.
- **Maps & navigation** — Amap-based POI search, route planning, and location services.
- **Douyin integration** — Interacts with Douyin via a local WebSocket.
- **Local music** — Plays local music from the Apple Music library.
- **HTML rendering** — Dynamically renders AI-generated web content.
- **Device identity** — Keychain-based stable device identifier for OTA activation and session management.

### Tech Stack

- **UI**: SwiftUI
- **Avatar**: Live2D Cubism SDK (Native Framework + Metal rendering)
- **Communication**: WebSocket, Bonjour (LAN device discovery)
- **Protocol**: MCP (Model Context Protocol)
- **Multimedia**: AVFoundation (audio capture / playback / speech synthesis), Camera
- **Location**: CoreLocation + Amap
- **Minimum deployment**: iOS 17.6

### Project Structure

```
.
├── xiaozhi/                # Main source (Swift + Live2DManager.mm + Bridging Header)
│   ├── xiaozhiApp.swift    # App entry
│   ├── ChatViewModel.swift # Core session state machine
│   ├── LockScreenView.swift# Main UI
│   ├── Live2D*             # Live2D views & config
│   ├── MCPManager.swift    # MCP tool manager
│   ├── WebSocketManager.swift
│   ├── AudioService.swift
│   ├── DouyinManager.swift
│   ├── NetworkServices.swift
│   └── ...
├── Framework/src/          # Live2D Cubism Framework source
├── Core/
│   ├── include/            # Live2D Cubism Core headers
│   └── lib/ios/            # libLive2DCubismCore.a static library
├── Metal/                  # Live2D Cubism Metal rendering
├── Asset/                  # Live2D models (Hiyori / Haru / Rice / Mao, etc.)
├── Media.xcassets/         # App icon & assets
└── Launch Screen.storyboard
```

### Requirements

- Xcode 16 or later
- An iOS 17.6+ device or simulator
- An Apple Developer account (for device signing)

### Build & Run

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd xiaozhi-ios
   ```

2. **Configure signing** — In Xcode's Signing & Capabilities:
   - Enable *Automatically manage signing*
   - Select your Team
   - Change the Bundle Identifier to your own (e.g. `com.yourname.xiaozhi`)

3. **Configure backends** — See [Configuration](#configuration) below.

4. **Build & run** — Select a target device and press `⌘R`.

> The Live2D Cubism Core static library (`Core/lib/ios/libLive2DCubismCore.a`) is bundled with the repository, so no extra download is required to compile.

### Configuration

| Setting | Location | Description |
| --- | --- | --- |
| OTA service | `xiaozhi/APIService.swift` | Defaults to `https://api.tenclass.net/`, the official xiaozhi OTA service. |
| Business backend | `xiaozhi/AppConfig.swift` | `localIP` points to self-hosted services for Amap / middle-layer / WeChat / Xiaohongshu / vision — **replace with your own server address**. |

Some features depend on self-hosted backend services (maps, vision, Xiaohongshu, Douyin, etc.). If you haven't deployed these services, the corresponding features will be unavailable, but core voice conversation and Live2D display still work.

### Third-Party Assets & Licenses

This project includes third-party assets whose copyrights belong to their respective owners and are governed by their own licenses — **they are NOT covered by this project's MIT license**:

| Asset | Directory | License |
| --- | --- | --- |
| Live2D Cubism Core | `Core/lib/`, `Core/include/` | Live2D Proprietary License |
| Live2D Cubism Framework | `Framework/src/` | Live2D Open Software License |
| Live2D Metal rendering samples | `Metal/` | Live2D Cubism SDK license |
| Live2D model materials | `Asset/` | Live2D Free Material License (per model) |
| stb_image | `Metal/thirdParty/stb/` | MIT / Public Domain |

Before using or redistributing these assets, please read and comply with the [Live2D license terms](https://www.live2d.com/en/sdk/license/). Verify commercial-use eligibility before any commercial deployment.

### License

This project's own source code (excluding the third-party assets above) is released under the **MIT License** — see [LICENSE](./LICENSE).

### Acknowledgements

- [xiaozhi-esp32](https://github.com/78/xiaozhi-esp32) — The open-source xiaozhi AI hardware ecosystem
- [Live2D](https://www.live2d.com/) — Cubism SDK and sample models
