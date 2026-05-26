# Engineered Writing（工程化写作）

把写作当软件工程来做的 AI 写作辅助规则包。

## 它是什么

一套结构化的写作规则和工作流，让 AI 助手在辅助中文叙事写作时：

- **写前回查**：自动读取项目的设定文档（CONTEXT.md、人物小传、写作提示词），避免偏离主线
- **写后自检**：四项门禁（视角纪律 / AI味检测 / 一致性 / 铁律）
- **跨篇校验**：多篇章之间的时间线、人名、设定交叉比对
- **去AI味**：针对中文叙事文体的 AI 痕迹检测和修复（逐句分段、句号过密、大词提升等）

## 适用场景

- 回忆录、散文、非虚构叙事
- 多篇章/系列连载（共享人物和世界观）
- 任何需要"先搭脚手架再写作"的长篇项目

## 六个模式

| 命令 | 模式 | 用途 |
|------|------|------|
| `/scaffold` | 脚手架 | 整理人物小传、写 CONTEXT、写提示词 |
| `/write` | 写作 | 写初稿，自动回查文档 + 写后自检 |
| `/revise` | 修订 | 去AI味诊断 + 逐段修订 |
| `/check` | 跨篇检查 | 扫描所有篇章找冲突 |
| `/deconstruct` | 拆文分析 | 拆解别人的文章，提取可迁移技法 |
| `/expand` | 场景扩写 | 把场景锚点展开为完整叙事 |
| `/illustrate` | 插图提示词 | 为场景生成"手机随手拍"风格的图片提示词 |

## 文件结构

```
engineered-writing/
├── SKILL.md                        # 主规则文件（工作流定义）
├── references/
│   ├── voice-calibration.md        # 语感校准（余华/史铁生/莫言三档）
│   ├── pov-discipline.md           # 视角纪律（严格外部视角）
│   ├── anti-ai-checklist.md        # 去AI味检查清单（叙事专用）
│   ├── deconstruct-template.md     # 拆文分析模板
│   └── illustration-style.md       # 插图风格指南（手机随手拍美学）
├── scripts/
│   └── consistency-check.sh        # 一致性检查脚本（可独立运行）
├── README.md                       # 本文件
└── install.sh                      # 一键安装脚本
```

## 安装

### 方式一：一键安装（推荐）

```bash
# 克隆或下载后，在目录内运行：
bash install.sh
```

脚本会自动检测你的环境并安装到对应位置。

### 方式二：手动安装

#### Claude Code

```bash
cp -r engineered-writing ~/.claude/skills/engineered-writing
```

#### Cursor

将 `SKILL.md` 的内容复制到项目根目录的 `.cursor/rules/engineered-writing.md`，或添加到 `.cursorrules` 文件中。参考文件放到 `.cursor/rules/references/` 下。

#### Windsurf

将 `SKILL.md` 的内容复制到项目根目录的 `.windsurfrules` 文件中，或放到 `.windsurf/rules/` 目录下。

#### Cline / Roo Code

将 `SKILL.md` 内容添加到 `.clinerules` 文件中。

#### 通用方式（任何支持 system prompt 的 AI）

将 `SKILL.md` + `references/` 下的所有文件内容合并为一个 system prompt 或 project context 文件。`install.sh --merged` 可以自动生成合并版本。

### 方式三：作为项目级规则

如果只想在某个写作项目中使用，把整个目录放到项目根目录下：

```
你的写作项目/
├── CONTEXT.md
├── 人物小传.md
├── .engineered-writing/          # 放这里
│   ├── SKILL.md
│   └── references/
└── 01_初稿.md
```

## 项目脚手架文档说明

本 skill 期望你的写作项目中有以下文档（没有的话用 `/scaffold` 模式创建）：

| 文件 | 作用 | 类比 |
|------|------|------|
| `CONTEXT.md` | 铁律、术语、视角规则、语感参照系 | 架构设计文档 |
| `人物小传.md` | 人物设定、时间线、关系 | 需求规格说明 |
| `*_写作提示词.md` | 每篇的场景设计、节奏规划 | 技术方案 |
| `资料收集/` | 背景调查、参考资料 | 调研文档 |
| `修订记录.md` | 已发现的冲突和修复历史 | Changelog |

## 独立使用一致性检查脚本

不需要 AI 也能跑：

```bash
bash scripts/consistency-check.sh /path/to/your/writing/project
```

它会扫描目录下所有 `*_初稿.md` 文件，输出：人名统计、时间线、楼层/空间分布、章节编号、铁律违反、视角越界、AI味结构指标。

## 自定义

这套规则是为余华式叙事散文设计的。如果你的项目风格不同：

1. 修改 `references/voice-calibration.md` 里的语感参照系
2. 修改 `references/pov-discipline.md` 里的视角规则（比如你的项目允许全知视角）
3. 修改 `references/anti-ai-checklist.md` 里的铁律部分（比如你的项目允许比喻）
4. `SKILL.md` 里的"绝对禁止"和"通用规则"按你的项目需求调整

核心工作流（写前回查 → 写作 → 写后自检 → 跨篇校验）是通用的，不需要改。

## License

MIT
