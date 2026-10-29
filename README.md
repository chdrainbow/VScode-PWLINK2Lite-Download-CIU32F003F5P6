# VScode-PWLINK2Lite-Download-CIU32F003F5P6
VScode PWLINK2Lite Download CIU32F003F5P6

### 使用方法

__方式 1：在 VS Code 中按 F8__\
配合已修复的 `.vscode/keybindings.json`（`"key": "F8"`），直接按 F8 即可触发烧录。

__方式 2：命令行直接运行__

```powershell
powershell -ExecutionPolicy Bypass -File scripts/flash.ps1
```

__方式 3：临时覆盖速率__（如需回退到 1000 kHz）

```powershell
powershell -ExecutionPolicy Bypass -File scripts/flash.ps1 -Speed 1000
```

脚本会自动检查调试器占用、执行全片擦除、下载 .hex 并验证、最后复位启动固件，整个流程完整且可重复，可作为稳定的烧录方法保留使用。
