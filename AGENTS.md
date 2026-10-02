# AGENTS.md

HarmonyOS（ArkTS/ArkUI）TOTP 验证器应用。单模块 `entry`，`compatibleSdkVersion: 26.0.0`，支持 phone / tablet / 2in1。

## 八荣八耻

1. 以暗猜接口为耻，以认真查阅为荣
2. 以模糊执行为耻，以寻求确认为荣
3. 以盲想业务为耻，以人类确认为荣
4. 以创造接口为耻，以复用现有为荣
5. 以跳过验证为耻，以主动测试为荣
6. 以破坏架构为耻，以遵循规范为荣
7. 以假装理解为耻，以诚实无知为荣
8. 以盲目修改为耻，以谨慎重构为荣

## 构建与运行

- 命令行：`devecocli build`（构建）、`devecocli run --skip-build`（部署到设备）
- IDE：DevEco Studio（hvigor 构建）
- 静态检查：`arkts_check`（仅 `.ets` 文件，构建前运行一次）

## 目录结构

```
entry/src/main/ets/
├── entryability/        # EntryAbility（应用入口）
├── entrybackupability/  # 备份扩展（backup extension）
├── pages/               # Index(@Entry 主页) + EditPage/SortPage/SettingsPage
├── components/          # 可复用 UI 组件
├── models/              # 数据层与常量
└── utils/               # 工具（otpauth:// 解析、URL 跳转等）
```

## 架构约定

- **状态管理一律使用 V1**：`@Component` + `@State`/`@Link`/`@Provide`/`@Consume`。禁止混入 V2（`@ComponentV2`/`@Local`/`@ObservedV2`）。
- **导航**：新页面在 `resources/base/profile/router_map.json` 注册，页面 `build()` 根节点必须是 `NavDestination`，通过 `NavDestinationContext.pathStack` 取路由栈和参数。
- **数据层**：RDB 用 `models/RelationalStore.ets`（单例），设置项用 `models/Preferences.ets`；常量放 `PreferenceConstants`/`EventConstants`。
- **OTP**：`models/AuthenticatorClass.ets` 基于 `@ohos.security.cryptoFramework`，支持 TOTP（SHA1/SHA256/SHA512）。

## 代码规范

- ArkTS 严格模式：禁止 `any`/`as` 断言/对象字面量缺类型/动态属性访问。
- UI 字符串必须放入 `resources/base/element/string.json`，并提供 `zh_CN`、`en_US` 译文；禁止硬编码。
- 深色模式颜色定义在 `resources/dark/element/color.json`，通过资源引用，禁止在代码里判断深色模式。
- 修改 `.ets` 后先 `arkts_check`，再 `devecocli build`，全部通过才算完成。

## 安全红线

- **严禁提交签名配置**：`build-profile.json5` 中 `signingConfigs` 必须保持 `[]`。调试签名由各开发者在本机 DevEco Studio（File > Project Structure > Signing Configs）自动生成，相关材料（`*.p12`/`*.cer`/`*.p7b`、`/.ohos`）已被 `.gitignore` 拦截。
- 严禁提交任何密钥、密码、证书路径等机器相关配置。

## Git 约定

- 使用约定式提交 https://www.conventionalcommits.org/zh-hans/，description 和 body 优先用中文，一行标题即可（如 `feat: 新增跳转 URL 方法`、`fix: 修复深色模式显示 bug`）。
- 可视情况进行 Git 提交，但不能主动推送到远程。