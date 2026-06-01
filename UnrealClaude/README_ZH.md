# UnrealClaude

![Unreal Engine](https://img.shields.io/badge/Unreal%20Engine-5.7-313131?style=flat&logo=unrealengine&logoColor=white)
![C++](https://img.shields.io/badge/C%2B%2B-20-00599C?style=flat&logo=c%2B%2B&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Win64%20%7C%20Linux%20%7C%20Mac-0078D6?style=flat&logo=windows&logoColor=white)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Integration-D97757?style=flat&logo=anthropic&logoColor=white)
![MCP](https://img.shields.io/badge/MCP-20%2B%20Tools-8A2BE2)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

**Claude Code CLI 整合 for Unreal Engine** — 提供 UE 內建的即時 AI 編碼輔助，配備完整的 UE 5.7 API 文件。

> 🎓 **作品集說明**：此專案基於 [UnrealClaude](https://github.com/Natfii/UnrealClaude) 開發，增加了自動化建構腳本、多語言支持（EMIHERE）和企業級部署流程。
> 
> 原始作者：[Natali Caggiano](https://github.com/Natfii)

---

## 功能特色

- **原生編輯器整合** — 停靠在編輯器中的聊天面板，支援串流回應、工具調用分組、程式碼塊渲染
- **MCP 伺服器** — 超過 20+ 的 Model Context Protocol 工具，用於演員操作、Blueprint 編輯、等級管理、素材管理等
- **動態 UE API 文件** — MCP bridge 包含動態文件載入器，可按需提供準確的 UE API 文件
- **Blueprint 編輯** — 建立和修改 Blueprints、Animation Blueprints、狀態機
- **等級管理** — 透過程式設計方式開啟、建立和管理等級及地圖模板
- **素材管理** — 搜尋素材、查詢依賴和引用者
- **非同步任務佇列** — 長時運行的操作不會逾時
- **腳本執行** — Claude 可以編寫、編譯（透過即時編碼）和執行腳本
- **對話持續性** — 對話歷史保存在各編輯器工作階段之間
- **專案感知** — 自動收集專案上下文（模組、啟用的外掛、專案設定）
- **使用 Claude Code Auth** — 無需单独管理 API 金鑰

## 前置需求

### 1. 安裝 Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. 驗證 Claude Code

```bash
claude --version
claude -p "Hello, can you see me?"
```

### 3. 安裝依賴

```bash
cd UnrealClaude/Resources/mcp-bridge
npm install
```

---

## 安裝方式

### 方法一：使用自動化腳本（推薦）

```bash
# 自動偵測 UE 版本並建構
.\Build.ps1

# 或者指定版本
.\Build.ps1 -Version 5.7

# 部署到引擎
.\Deploy.ps1 -Target Engine
```

### 方法二：手動建構

**Windows：**
```bash
Engine\Build\BatchFiles\RunUAT.bat BuildPlugin -Plugin="PATH\TO\UnrealClaude\UnrealClaude.uplugin" -Package="OUTPUT\PATH" -TargetPlatforms=Win64
```

**Linux：**
```bash
Engine/Build/BatchFiles/RunUAT.sh BuildPlugin -Plugin="/path/to/UnrealClaude/UnrealClaude.uplugin" -Package="/output/path" -TargetPlatforms=Linux
```

### 方法三：從原始碼建構

1. 複製外掛到你的專案 `Plugins/` 目錄：
   ```
   YourProject/
   ├── Content/
   ├── Source/
   └── Plugins/
       └── UnrealClaude/
           ├── Binaries/
           ├── Source/
           ├── Resources/
           ├── Config/
           └── UnrealClaude.uplugin
   ```

2. 在 Unreal Editor 中建構： **File → Package Project → Plugin**

---

## 使用方式

### 開啟 Claude 面板

**Menu → Tools → Claude Assistant**

![Claude Panel](https://github.com/user-attachments/assets/5eff6f0d-8900-485c-b692-141bfb45d397)

### 範例提示

```
如何在 C++ 中建立自定義 Actor Component？

實施健康系統的最佳方式是什麼？

解釋 World Partition 以及如何為開放世界設置串流？

编写一個可召喚粒子的 BlueprintCallable 函數。

如何正確使用 TObjectPtr<> vs 原始指標？
```

### MCP 工具列表

| 工具類別 | 可用工具 |
|----------|----------|
| **演員工具** | spawn_actor, move_actor, delete_actors, get_level_actors, set_property |
| **等級管理** | open_level, new_level, list_templates |
| **Blueprint 工具** | blueprint_query, blueprint_modify |
| **動畫Blueprint工具** | anim_blueprint_modify |
| **素材工具** | asset_search, asset_dependencies, asset_referencers |
| **角色工具** | character, character_data |
| **材質工具** | material |
| **輸入工具** | enhanced_input |
| **公用程式** | console_command, output_log, viewport_capture, script_execute |

---

## 配置選項

### 專案設定

在 **Project Settings → Plugins → Unreal Claude** 中：

- **Auto-approve script execution** （預設：關閉）— 啟用時，所有通過 MCP bridge 執行的 Python/C++/Console/Editor Utility 腳本會立即執行，無需顯示許可對話方塊。

### 自定義系統提示

在專案根目錄建立 `CLAUDE.md` 檔案來擴展內建的 UE 上下文：

```markdown
# 我的專案上下文

## 架構
- 這是一款多人生存遊戲
- 使用專用伺服器模型
- 所有能力使用 GAS

## 編碼標準
- 始终使用 UPROPERTY 來 Blueprint 存取
- 前綴介面為 I（例如 IInteractable）
- 使用 GameplayTags 來識別能力
```

---

## 故障排除

### 「找不到 Claude CLI」

1. 驗證已安裝：`claude --version`
2. 檢查 PATH：`where claude`
3. 安裝後重啟 Unreal Editor

### 回應緩慢

Claude Code 在你的專案目錄中執行，可能會讀取檔案獲取上下文，大型專案初始回應可能較慢。

### 外掛無法編譯

確保使用 Unreal Engine 5.7。支持的平台為 Windows (Win64)、Linux 和 macOS。

### MCP 伺服器未啟動

檢查連接埠 3000 是否可用。MCP 伺服器日誌記錄在 `LogUnrealClaude`。

### MCP tools 不可用

最常見的原因是缺少 npm 套件：
```bash
cd YourProject/Plugins/UnrealClaude/Resources/mcp-bridge
npm install
```

---

## 版本資訊

| 版本 | 日期 | 變更 |
|------|------|------|
| 1.5.0 | 2026-05-14 | 域操作奇偶校驗 + 參數別名 |
| 1.4.5 | 2026-xx-xx | 錯誤修復 |

---

## 著作權

大部分代碼版權所有 © Natali Caggiano。

此版本由 Barry Huang 定制，增加了：
- 自動化建構腳本（Build.ps1, Deploy.ps1）
- 繁体中文文件  
- UE 5.6/5.7 兼容性

---

## 授權

MIT 授權 - 詳見 [LICENSE](LICENSE) 檔案

## 參考資源

- [原始專案 UnrealClaude](https://github.com/Natfii/UnrealClaude)
- [Claude Code 文件](https://docs.anthropic.com/claude-code)
- [Unreal Engine 文件](https://docs.unrealengine.com)