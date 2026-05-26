---
description: 脚手架模式——整理人物小传、写 CONTEXT、写提示词
argument-hint: [篇章名 或 描述需求]
---

# 脚手架模式（Scaffold）

按 `engineered-writing` skill 的 A 模式执行。

## 工作流

1. 确认当前篇章和需求范围（用户参数：$ARGUMENTS）
2. 读取已有 `CONTEXT.md` 和 `人物小传.md`，建立已知设定边界
3. 追问用户以厘清新设定（最少必要问题，不问能从已有文档推断的）：
   - 人物：姓名、年龄、籍贯、职业、与主角关系、在楼里的位置
   - 时间线：事件发生的绝对时间、与已有事件的先后关系
   - 场景锚点：关键场景的物理环境、在场人物、感官细节
   - 铁律：本篇是否有额外禁区
4. 输出结构化文档（匹配已有格式：人物小传条目 / CONTEXT 补充段 / 写作提示词）
5. 交叉检查：新设定与已有设定是否冲突，冲突则标注并请用户裁决

## 参考

- [完整 skill 定义](../../SKILL.md)
- [语感校准](../../references/voice-calibration.md)
- [视角纪律](../../references/pov-discipline.md)
