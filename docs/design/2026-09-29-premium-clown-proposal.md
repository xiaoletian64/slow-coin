# 经典小丑·典藏机台（高级皮肤设计草案）

状态：用户已确认概念方向；0.5.0 实施中，以游戏截图和安装包实测验收。

## 用户目标
根据用户提供的实体小丑推币机照片重新设计当前模型，让完整机柜、嵌入屏幕、上下推盘和金属代币更接近电玩城实机。新增一款可用游戏金币兑换的高级皮肤。

## 当前差异
现有皮肤仅替换三个材质颜色；柜体侧框较窄，像开放式桌台；老虎机位于独立 HUD；代币正面星形浮雕和厚度观感偏玩具。参考照片主要识别特征是宽幅蓝色彩绘侧柱、玻璃内部屏幕、中央钉板和灯圈、前后两层银色密集币床、白色照明和金属边框。

## 建议方案
名称：经典小丑·典藏机台。价格建议 12,000 游戏金币，永久拥有、免费预览。现有皮肤保留。

- 重做蓝色珐琅机柜外壳，增加顶部灯箱、厚侧柱、前侧小丑面板与镀铬圆角。原创气球、烟花、星星及小丑插画用于独立机柜贴图。
- 拉丝金属上下推盘，清晰可见推板前缘和前方回收槽。实体侧柱在可玩区域外侧，避免挡住边缘金币。
- 银色代币，浅浮雕、滚花币边和轻微磨损，以独立材质和视觉网格实现；沿用原有碰撞外形和质量，避免换皮肤改变收益。
- 将现有实时三滚轮视觉嵌入后方机柜，字号在手机上仍可读；使用同一开奖状态源，不能把随机图案烘焙为假屏幕。
- 保留可读的摆杆、唯一派奖口、命中框和币的真实下落路线。屏幕位于落币区域后方，玻璃反射不能盖住金币。
- 2,999 的地震金币车等四档演出沿用现有逻辑，视觉抖动不能触发清台。手机摇晃仍只处理上方币。

## 技术边界
独立外观节点管理典藏机柜，切换皮肤不重建物理世界、不清空币堆、不改变已排队奖币。复用贴图图集与共享网格，控制透明玻璃层数；Android / iOS 沿用 Compatibility 渲染。商店提供真实机台截图或同模型预览，不能只放配色块。

存档校验目前将 owned_skins 限制为 4 个，需要改为皮肤目录大小并继续校验合法 id、去重、已购和已装备关系。老存档默认当前皮肤，新增皮肤不会让已有进度失效。

## 验收
1. 原参考照片与游戏实拍并排审视机柜轮廓、侧柱、嵌入屏幕和币床；不能将生成概念图宣称为游戏实机。
2. 全部旧皮肤可切回；兑换只扣一次；重启保留购买；预览退出不扣金币、不改变币堆。
3. 正式 / 练习以及三种推板结构都能使用；既有皮肤用户存档可恢复。
4. 抽奖、演出、唯一出币口、连奖、声音及上方摇晃测试继续通过。
5. Android 安装和画面检查、iOS 编译；实际测量帧时后才说明性能结果。

## 图像用途
生成的首张图仅为设计方向参考；后续应制作可用纹理和真实 3D 几何。不能把整张概念图贴在推盘上代替可玩的模型。

## 首张概念图检查
文件：[premium-clown-concept.png](images/premium-clown-concept.png)。使用内置 image_gen，根据用户参考图生成。宽灯柱、嵌入屏幕和金属币床已体现；它是视觉方向参考，具体落地要将图里看起来像第三阶的前托盘明确为回收槽，并理顺顶部投币 / 中央派奖与钉板的路线，不能照图照搬互相遮挡的机构。

### 生成提示词
Use case: stylized-concept / premium mobile game cabinet design. The attached photo is a design REFERENCE ONLY, not an edit target. Create one detailed portrait concept sheet of an original premium clown/circus coin-pusher cabinet inspired by its architecture. Main subject: front-on player view, slightly elevated enough to see the deep lower coin bed, machine fills nearly whole portrait. Realistic manufactured arcade cabinet, rich royal-blue enamel, wide thick rounded illuminated side columns with intricate ORIGINAL clown, balloon, star and firework printed artwork, warm gold trim and real chrome fasteners. Glass enclosure with restrained reflections allowing clear playfield visibility; overhead fluorescent lighting. Central rear wall has an integrated small three-reel slot display showing cherries bells stars, framed into cabinet, not floating mobile UI. Directly below the display a short physical pegboard with one illuminated central target frame and ONE clearly visible central bonus coin outlet. At the top a subtle swinging coin feed guide integrated inside the cabinet. Lower half is deep TWO-LEVEL realistic coin pusher shelf, closely spaced naturally overlapping thin worn silver arcade tokens with occasional warm brass highlights, uneven stacks, authentic milled edges; not giant thick gold stars. Visible metal moving shelf lip, brushed stainless steel lower tray, front return gutter. Main readable top marquee in Chinese: '经典小丑'. Small bottom caption: '高级皮肤 · 概念效果图'. NO people, no livestream overlay, no watermark, no copied branding, no extra adjacent cabinets. Lighting tasteful bright arcade white/cyan, no nightclub purple haze or excessive bloom. This is an achievable polished game art reference, high detail, physically coherent cabinet geometry and original painted circus panels. Background plain dark navy, cabinet silhouette clearly framed. Do not place large menus or big mobile interface buttons over the cabinet.
