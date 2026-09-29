# 典藏小丑皮肤 Implementation Plan

> **For agentic workers:** Implement task by task, with focused plan review and verification.

**Goal:** 将用户已确认的典藏机台外观接入游戏，在不改变推币碰撞和奖励的条件下改善机柜、嵌入屏幕和代币，并修复空钉板摇晃提示。
**Architecture:** 独立 premium_cabinet.gd 构建装饰与实时屏幕；machine.gd 持有原有物理体，切换视觉。皮肤预览临时应用外观，退出恢复装备皮肤。金币材质使用共享着色器，避免全局共享材质污染其他机台。
**Tech Stack:** Godot 4.6.3 Compatibility, GDScript, generated original art texture, Android/iOS.

## Tasks
- [x] 1. 复现空板摇晃：测试无上方币时不得开启 6 秒出币暂停；只下方有币仍应无清理。保留上方卡币测试。文件 tests/test_controls.gd, game.gd, machine.gd。
- [x] 2. 新增高级皮肤元数据与存档兼容。wallet.gd 从固定 4 个改为 SKINS.size，重复 owned id 拒绝。tests/test_premium.gd 覆盖重复扣款、免费预览和旧档。
- [x] 3. 构建典藏几何与原创纹理。新增 scripts/premium_cabinet.gd；宽侧柱、灯箱、玻璃、镀铬边框、机内实时滚轮。现有物理身体不重建；装饰不参与碰撞。旧外观 mesh 的可见性切换，物理留存。新币继承当前银币外观。屏幕使用同一 bonus 状态渲染。
- [x] 4. HUD 高级外观隐藏外置滚轮面板，增加机台视区高度；用机柜屏幕显示实时开奖。商店预览应用临时外观，返回恢复，不扣款；商品显示实际截图或模型预览而非生成概念图。脚本 hud.gd, game.gd。
- [ ] 5. 截图检查比例和遮挡，验证切换不改币数、坐标、钱包或中奖债务。运行 test_premium, controls, restore, stories, outlet_audio, collision_audio。
- [ ] 6. Android APK 构建、签名、安装启动；iOS 编译；记录实际完成范围。随机金币塔/弹簧/底部需求待用户补充，单独实现，不猜测。

## Verification
`./tools/run.sh --headless --script tests/test_premium.gd` should PASS. Existing controls/restore/story/audio tests should PASS.
Capture actual in-game premium front view, inspect at portrait phone sizes, ensure target not obscured and outlet physically visible.
`./tools/build_android.sh` then apksigner verify; `./tools/build_ios.sh`.

## 审查修订 / 用户补充已确认
- 第 6 项“金币塔待补充”已被本节取代。新增 tower_event.gd：底部盘面触发旋风/迷雾，随后生成 50 枚真实金币的高塔（每层 5 枚，共 10 层）；至少 12 次有效投币且经过随机 60–100 秒再检查。预留 12 枚投币空间，盘满或落点高于安全高度时延期 10 秒。选点位于下方推盘，不能在侧边回收区或扫杆区域生成。事件计时和投币进度跟随机台存档；动画中离开时不提前生成，回到台面继续剩余倒计时，不重复领取。没有单独钱包加币。
- 独立 preview_skin_id，仅供渲染；钱包 equipped_skin 与存档始终保持购买装备值。预览保持暂停，关闭、返回、购买成功后退出预览状态。余额不足也可预览。测试覆盖预览自动存档及退出重启。
- 内嵌屏幕除三滚轮外必须包含四档奖表、练习标记、待落枚数、排队次数、开奖状态。复用 bonus 数据源和 slot_reel，连线高亮。手机实际截图检查最小尺寸的可读性。
- 暂停状态下保存节点 instance_id、transform、linear/angular_velocity、shape RID、mass、bonus.remaining/pending_spins；高级/旧皮肤/预览往返后逐项相同。正式/练习与 classic/split/sweep 均覆盖。
- 新增 tests/test_tower.gd 验证容量不足延期、烟雾先于生成、恢复无重复、前口计奖、摇晃不直接清掉塔。
