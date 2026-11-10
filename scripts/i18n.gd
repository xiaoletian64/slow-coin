extends RefCounted

# 国际化词表：scripts 内所有用户可见中文文案的唯一中文来源。
# t() 在中文设备（zh 系 locale）原样返回，其余设备返回英文；未收录字符串原样透传。
# phrase_list() / match_list() 为全局单一口令词库（不分语言）。

const ZH_EN: = {
	"拾光币社": "Time Coin Parlor",
	"我的金币": "My Coins",
	"+500 / 日": "+500 / day",
	"自动保存 · 放心离开": "Auto-saved · leave anytime",
	"经典双层  ▾": "Classic Deck  ▾",
	"口令补给 · 语音/输入": "Phrase Bonus · Voice/Type",
	"●  自由节奏": "●  Free Rhythm",
	"三同连线奖": "Triple Match Prize",
	"穿过移动靶抽奖": "Hit the moving target to spin",
	"轮盘结算待出金币": "Settle pending coins",
	"自动摆杆": "Auto swing",
	"Ⅱ  停在这里": "Ⅱ  Hold here",
	"前口落币计奖": "Front drops pay",
	"投  一  枚     ↓": "Drop  One     ↓",
	"点按投一枚 · 长按连续投币": "Tap to drop one · hold to keep dropping",
	"◇ 收藏 / 挑战": "◇ Collection / Goals",
	"∞  练习台": "∞  Practice",
	"◈ 换皮肤": "◈ Skins",
	"?  怎么玩": "?  How to Play",
	"↔  继续摆动": "↔  Resume Swinging",
	"称号 · ": "Title · ",
	"练习 · ": "Practice · ",
	"经典双层": "Classic Deck",
	"交错双推板": "Split Pushers",
	"扫杆联动": "Sweeper Combo",
	"↩  正式台": "↩  Main Table",
	"无限免费投币 · 不计金币与收藏": "Unlimited free drops · no coins or collection",
	"练习模式": "Practice Mode",
	"无内购  ·  自动保存  ·  随时歇一会儿": "No IAP  ·  Auto-save  ·  Take a break anytime",
	"逐枚出币中 · 等待 %d 枚": "Paying out · %d coins to go",
	"摆杆自动游走，也可以停在喜欢的位置": "The swing wanders on its own — hold it wherever you like",
	"金币用完啦，去免费练习台继续玩": "Out of coins — free Practice keeps the fun going",
	"歇一会儿": "Take a Break",
	"台面已经暂停，金币和进度都已保存。": "Table paused. Coins and progress are safe.",
	"背景音乐：": "Music: ",
	"游戏音效：": "SFX: ",
	"触感：": "Haptics: ",
	"开启": "On",
	"关闭": "Off",
	"摇一摇 · 只震落上方卡币": "Shake · jars loose only the stuck coins up top",
	"测试：必进中间洞 · ": "Test: always center hole · ",
	"测试：金币塔 · 练习台": "Test: Coin Tower · Practice",
	"重开一局 · 金币保留": "New round · keep your coins",
	"版本更新 · ": "Update · ",
	"继续推金币": "Back to Pushing",
	"随时离开，不会错过任何限时奖励。": "Leave anytime — you won't miss a single timed reward.",
	"一枚一枚，慢慢来": "One Coin at a Time",
	"经典推币机 · 玩法与金币规则": "Classic coin pusher · how to play and coin rules",
	"知道啦，去推金币": "Got It — Let's Push",
	"慢慢攒的小美好": "Small Joys, Kept Forever",
	"永久收藏 · 每投 50 枚，留下一枚纪念章": "Permanent collection · every 50 drops earns one keepsake token",
	"今日挑战 · 收藏印章": "Daily Goals · Keepsake Tokens",
	"称号墙 · 每日 / 永久": "Title Wall · Daily / Permanent",
	"已收藏": "Collected",
	"%d 次投币": "%d drops to go",
	"已投 %d 枚  ·  已收藏 %d / 6": "%d dropped  ·  %d / 6 collected",
	"本局实收": "This run",
	"练习收币": "Practice haul",
	"%s %s 枚\n待出 %s 枚 · 推落才到账": "%s %s coins\n%s pending · credited once pushed out",
	"连抽降档 58 / 388": "Reduced odds 58 / 388",
	"抽奖中 · 出币继续": "Spinning · payouts continue",
	"小猫抓毛球": "Kitten grabs the pom-pom",
	"小狗吃火腿": "Puppy snacks the ham",
	"大奖演出中": "Big prize showtime",
	"派奖中 · 连抽 %d/2": "Paying out · %d/2 bonus spins",
	"练习 · 命中也抽奖": "Practice · hits spin too",
	"命中移动靶抽奖": "Hit the target to spin",
	"待抽 %s 次": "%s spins queued",
	"给机台换件新衣": "Dress Up Your Cabinet",
	"连续登录或金币兑换 · 永久拥有 · 全部可免费预览": "Daily logins or coin trades · yours forever · all free to preview",
	"可用金币  ": "Your coins  ",
	"已连续登录 %d 天 · 中断后进度重计，已获皮肤保留": "%d-day login streak · a missed day resets the count, earned skins stay",
	"定制金币 · 选择自己的图片": "Custom Coin · Pick Your Own Picture",
	"免费预览": "Free Preview",
	"使用中": "In Use",
	"换上这款": "Equip This",
	" 金币兑换": " coins to redeem",
	"继续登录解锁": "Keep Logging In to Unlock",
	"回到推币台": "Back to the Table",
	"口令补给": "Phrase Bonus",
	"点此输入，或用输入法麦克风说口令": "Type here, or say the phrase with your keyboard mic",
	"确认口令 · 领取金币": "Confirm Phrase · Claim Coins",
	"guoan / 各个国家的战斗到底\n余额低于 50 时可领 200 金币。\n两个口令共享每日一次额度，次日恢复。": "guoan / 各个国家的战斗到底\nClaim 200 coins when your balance is under 50.\nBoth phrases share one daily claim — back the next day.",
	"输入法语音：点键盘上的麦克风，识别后确认领取。\n备用麦克风入口需授权和系统识别服务，不保存录音。": "Keyboard voice: tap the mic on your keyboard, confirm the text, then claim.\nThe backup mic needs permission and the system speech service. No recordings are kept.",
	"正在识别…": "Listening…",
	"备用：游戏内麦克风": "Backup: in-game mic",
	"取消 / 回到机台": "Cancel / Back to the Table",
	"选一台，换种手感": "Pick a Table, Feel the Difference",
	"三种真实物理机构 · 各自保留台面与进度": "Three real physics layouts · each keeps its own table and progress",
	"经典双层推板": "Classic dual-deck pusher",
	"左右交错双推板": "Staggered side pushers",
	"推板 + 摆动扫杆": "Pusher + swinging sweeper",
	"整面推板往复，适合观察前沿、精准投币。": "A full pusher glides back and forth — great for reading the edge and dropping with precision.",
	"左右推板错峰推进，抓住两侧不同的时机。": "Side pushers take turns — catch a different rhythm on each side.",
	"前方扫杆来回扫动，与推板一起搅动币堆。": "A front sweeper swings to and fro, stirring the pile along with the pusher.",
	"  ·  当前": "  ·  Current",
	"回到机台": "Back to the Machine",
	"返回商店 · ": "Back to Shop · ",
	"外观预览 · 台面已暂停 · 不扣金币": "Visual preview · table paused · no coins spent",
	"待出金币 · 一把结算": "Pending Coins · Settle in One Go",
	"累计待出 %s 枚 · 另有 %s 次抽奖\n先按原规则结算剩余抽奖，再随机折算 0.01～0.90 倍": "%s coins pending · %s spins left\nRemaining spins settle at the usual odds first, then everything converts at a random 0.01–0.90x",
	"结果直接到账。待出金币、正在开奖和排队机会全部结清。\n钱包现有金币、台面实体币保留。": "Results land right away. Pending coins, running spins and queued chances are all cleared.\nWallet coins and physical coins on the table are kept.",
	"接受折算 · 全部结算": "Accept Conversion · Settle All",
	"继续抽奖和出币": "Keep Spinning and Paying",
	"轮盘结算": "Wheel Settlement",
	"已结算待出 %s 枚": "Settled %s pending coins",
	"轮盘转动中…": "Wheel spinning…",
	"× %.2f · 已到账 %s 枚": "× %.2f · %s coins added",
	"重开一局？": "Start a New Round?",
	"台面金币重新铺设，摆杆和推板回到初始位置。": "Table coins are re-laid; the swing and pushers return to their starting spots.",
	"钱包金币、皮肤、定制币面保留。\n未发奖励与抽奖次数继续，尚未落出的付费投币退回。": "Wallet coins, skins and your custom coin face are kept.\nUnpaid rewards and queued spins carry on; paid drops not yet spawned are refunded.",
	"确认重开": "Confirm New Round",
	"继续当前这局": "Keep This Round",
	"每日称号": "Daily Titles",
	"永久称号": "Permanent Titles",
	"当天解锁，当天佩戴 · 次日重置，与登录皮肤进度独立": "Unlock and wear them the same day · reset next day, separate from login skins",
	"长期累计解锁 · 永久保留": "Earned over time · kept forever",
	"每日称号 · 8": "Daily Titles · 8",
	"永久称号 · 24": "Permanent Titles · 24",
	"正式投币": "Drops",
	"前口实收": "Front Takes",
	"中奖": "Jackpots",
	"单次中奖": "Best Prize",
	"见到金币塔": "Towers Seen",
	"拥有皮肤": "Skins Owned",
	"定制币面": "Custom Faces",
	"重开一局": "New Rounds",
	"佩戴中 · ": "Worn · ",
	"可佩戴 · ": "Ready · ",
	"未解锁 · ": "Locked · ",
	"今日巡场": "Today's Round",
	"完成挑战收集永久印章 · 不额外发金币": "Finish goals to collect permanent stamps · no extra coins",
	"%s  ·  收藏印章 %d": "%s  ·  %d stamps",
	"再集 %d 枚 → %s": "%d more → %s",
	"  ✓ 已完成": "  ✓ Done",
	"%d / %d  ·  完成 +1 印章": "%d / %d  ·  done +1 stamp",
	"累计驱赶 %d 次  ·  被偷 %d 枚": "Thief chased off %d times  ·  %d coins stolen",
	"只有正式台计入挑战。小偷随机出现，不保证每天遇到；次日重置进度，已得印章永久保留。": "Only the main table counts. The thief shows up at random — no daily guarantee; progress resets next day, stamps earned are permanent.",
	"继续巡场": "Keep Going",
	"版本更新": "Update",
	"拾光币社 · 当前版本 ": "Time Coin Parlor · current version ",
	"新版 %s · %.1f MB": "New version %s · %.1f MB",
	"下载更新": "Download Update",
	"安装已校验的更新": "Install Verified Update",
	"取消": "Cancel",
	"重新检查": "Check Again",
	"打开下载页": "Open Download Page",
	"返回游戏": "Back to Game",
	"台面超过 1,000 枚 · 随机消除 %d 枚": "Table passed 1,000 coins · clearing %d at random",
	"幸运彩球！准备砸向推盘": "Lucky rainbow ball! It's diving at the pusher",
	"彩球砸台！前口掉落才到账": "Rainbow ball strike! Only front drops count",
	"旋风带来 %d 枚金币塔 · 推到前口才到账": "A whirlwind brings a %d-coin tower · paid once pushed to the front",
	"发现新版本 · 在暂停菜单查看更新": "New version found · check the pause menu to update",
	"已从备份恢复进度": "Progress restored from backup",
	"今日补给 +%s · 连续登录 %d 天": "Daily refill +%s · %d-day login streak",
	"\n永久解锁：": "\nUnlocked for good: ",
	"、": ", ",
	"投币队列已达上限，请稍后再投": "Drop queue is full — try again in a moment",
	"金币用完啦，免费练习台随时开放": "Out of coins — free Practice is always open",
	"夜行小偷！5 秒内点击驱赶 3 次": "Night thief! Tap 3 times within 5 seconds to shoo it",
	"收藏解锁 · ": "Collection unlocked · ",
	"命中移动靶！": "Target hit!",
	"抽奖已排队": "spin queued",
	"三滚轮启动": "reels are rolling",
	"本轮连抽已达 2 次 · 继续推币收奖": "Bonus spins capped at 2 this round · keep pushing to collect",
	"自由练习 · 无限投币，不计收益": "Free practice · unlimited drops, no payouts counted",
	"已回到正式台，接着慢慢推": "Back on the main table — push away",
	"，投币暂时停用": ", dropping is paused for now",
	"三同中奖！%s 枚，演出结束后开始吐币": "Triple match! %s coins — payout starts after the show",
	"这次未连成三同，继续观察落点": "No triple this time — keep watching the landing spots",
	"小偷逃走了 · 钱包 -%d 金币": "The thief got away · wallet -%d coins",
	"可直接输入，也可用输入法语音。确认文字后领取。": "Type it straight in, or use your keyboard's voice input. Confirm the text to claim.",
	"请先返回正式机台，再领取语音补给。": "Head back to the main table first to claim the voice bonus.",
	"正在请求麦克风，请留意系统权限提示…": "Requesting the mic — watch for the system permission prompt…",
	"识别：%s\n+%s 金币已到账！": "Heard: %s\n+%s coins added!",
	"识别：%s\n口令需匹配，余额低于 %d，且每日只能领取一次。": "Heard: %s\nThe phrase must match, your balance must be under %d, and it's once per day.",
	"测试开启：按投币必进中间洞，奖币也走此路径": "Test on: drops always sink the center hole — prize coins take that path too",
	"测试关闭：恢复真实碰撞": "Test off: real physics restored",
	"上方钉板没有金币需要震落 · 下方推盘照常运行": "No stuck coins up top to shake loose · the lower pusher runs as usual",
	"正在震落上方卡币 · 下方推盘照常运行": "Shaking the stuck coins up top loose · the lower pusher runs as usual",
	"请先返回正式台，再领取口令补给。": "Head back to the main table first to claim the phrase bonus.",
	"练习测试 · 有空位时旋风带来金币塔": "Practice test · a whirlwind brings a tower when there's room",
	"保存失败，本次未结算，请重试": "Save failed — this round wasn't settled, please retry",
	"新一局已开始 · 金币与未发奖励保留": "New round started · coins and pending rewards kept",
	"成功驱赶 · 钱包保住了！": "Chased it off · wallet saved!",
	"\n今日挑战完成 · 收藏印章 +1": "\nDaily goal done · keepsake stamp +1",
	"挑战完成 · %s · 收藏印章 +%d": "Goals done · %s · keepsake stamps +%d",
	"当前版本 ": "Current version ",
	"正在检查更新…": "Checking for updates…",
	"暂时无法连接更新服务器，可稍后重试。": "Can't reach the update server right now — try again later.",
	"请在 Android 版内下载更新，其他设备可打开下载页。": "Please update inside the Android app; on other devices, open the download page.",
	"正在下载更新…": "Downloading update…",
	"下载未能开始，请重试。": "The download didn't start — please retry.",
	"已取消，可以继续游戏。": "Cancelled — you can keep playing.",
	"安装文件已变化，请重新下载。": "The install file changed — download it again.",
	"更新服务暂不可用，游戏可继续离线游玩。": "Update service unavailable — the game keeps working offline.",
	"下载中断或文件不完整，请重试。": "Download interrupted or file incomplete — please retry.",
	"更新信息未通过校验，请稍后重试。": "Update info failed verification — try again later.",
	"发现新版本 ": "New version found: ",
	"已经是最新版本 ": "You're on the latest version: ",
	"安装包校验失败，请重新下载。": "Package verification failed — download it again.",
	"无法保存安装包，请检查可用空间。": "Couldn't save the package — check free space.",
	"安装包已校验，点击安装后由 Android 系统确认。": "Package verified — tap install and Android will take it from there.",
	"正在下载更新 · %d%%": "Downloading update · %d%%",
	"投币练手 · 正式投币 100 枚": "Drop warm-up · 100 real drops",
	"前口丰收 · 实收 40 枚": "Front haul · collect 40 coins",
	"守住钱包 · 驱赶小偷 1 次": "Guard the wallet · chase off 1 thief",
	"新晋挑战者": "New Challenger",
	"街机学徒": "Arcade Apprentice",
	"挑战能手": "Goal Getter",
	"机台守护者": "Table Guardian",
	"街机达人": "Arcade Ace",
	"传奇收藏家": "Legendary Collector",
	"好 运 嘉 奖": "Lucky Reward",
	"金 潮 加 赏": "Gold Tide Bonus",
	"大 奖 时 刻": "Jackpot Moment",
	"至 尊 头 奖": "Grand Jackpot",
	"枚奖励金币 · 待发放": "bonus coins · waiting to drop",
	"演出结束后落币，推入前口后计入余额": "Coins drop after the show — push them out the front to bank them",
	"经 典 小 丑": "CLASSIC CLOWN",
	"经 典 小 丑  ·  典 藏": "CLASSIC CLOWN · DELUXE",
	"小丑连线奖": "Clown Match Prize",
	"投币命中靶\n启动老虎机": "Hit the target\nto start the reels",
	"练习台 · 小丑连线奖": "Practice · Clown Match Prize",
	"连抽降档": "Reduced odds",
	"抽奖中": "Spinning",
	"中了 %s！": "Won %s!",
	"待落 %s 枚": "%s coins to drop",
	"投币命中靶": "Hit the target",
	"\n待抽 %s 次": "\n%s spins queued",
	"拾 光 币 社": "TIME COIN PARLOR",
	"落 日 街 机": "SUNSET ARCADE",
	"量 子 推 币": "QUANTUM PUSH",
	"鎏 金 典 藏": "GILDED ROYALE",
	"极 光 冰 宫": "AURORA PALACE",
	"逐枚吐币": "Coin by coin",
	"连续吐币": "Rapid stream",
	"摆动吐币": "Swing payout",
	"快速吐币": "Fast flood",
	"等待命中奖口": "Waiting on a target hit",
	"无法保存，请检查存储空间": "Can't save — check your storage space",
	"保存未完成，请检查存储空间": "Save didn't finish — check your storage space",
	"备份未完成": "Backup didn't finish",
	"存档写入失败": "Couldn't write the save file",
	"当前设备没有可用的系统语音服务，请使用已安装语音服务的 Android 或 iPhone 真机。": "No system speech service on this device — use an Android or iPhone that has one built in.",
	"夜行小偷靠近": "Night thief approaching",
	"%.1f 秒后偷走最多 %d 枚": "%.1f s left · may steal up to %d coins",
	"点击驱赶   %d / 3": "Tap to shoo   %d / 3",
	"我的定制金币": "My Custom Coin",
	"选择图片 → 圆形裁切 → 简化币面\n仅保存在本机，不上传图片": "Pick a picture → crop to a circle → simplify the face\nSaved on this device only — nothing gets uploaded",
	"选择一张图片": "Choose a Picture",
	"放大": "Zoom",
	"左右": "Horizontal",
	"上下": "Vertical",
	"应用到所有金币": "Apply to Every Coin",
	"恢复默认币面": "Reset to Default Face",
	"返回皮肤商店": "Back to the Skin Shop",
	"*.png,*.jpg,*.jpeg,*.webp;图片": "*.png,*.jpg,*.jpeg,*.webp;Images",
	"图片太大或无法读取，请选择小于 32 MB 的图片": "That picture is too big or can't be read — pick one under 32 MB",
	"这张图片无法读取，请换一张": "Couldn't read this picture — try another one",
	"保存失败，原币面保持不变": "Save failed — your coin face stays unchanged",
	"定制币面已应用 · 新旧金币同步更新": "Custom coin face applied · old and new coins updated together",
	"无法清除定制币面，请重试": "Couldn't clear the custom face — please retry",
	"无法打开图片选择器": "Couldn't open the picture picker",
	"请选择可读取的图片": "Pick a picture that can be read",
	"图片读取失败，请重试": "Couldn't read the picture — please retry",
	"保存图片失败": "Couldn't save the picture",
	"系统中文语音识别暂不可用，请稍后重试。": "System speech recognition is unavailable right now — try again later.",
	"无法启用麦克风，请检查系统录音权限。": "Couldn't enable the microphone — check the recording permission.",
	"没有可用麦克风，请使用 iPhone 真机。": "No microphone available — use a physical iPhone.",
	"没有听清，或系统语音服务不可用，请重试。": "Didn't catch that, or the speech service is unavailable — please retry.",
	"麦克风启动失败，请重试。": "Mic failed to start — please retry.",
	"识别超时，请重新说一次口令。": "Timed out — say the phrase once more.",
	"初见黄铜": "First Brass",
	"海盐薄荷": "Sea Salt Mint",
	"落日珊瑚": "Sunset Coral",
	"午夜星光": "Midnight Starlight",
	"琥珀回声": "Amber Echo",
	"银河漫游": "Galaxy Drift",
	"经典街机": "Classic Arcade",
	"落日樱粉": "Sunset Sakura",
	"经典小丑·典藏": "Classic Clown Deluxe",
	"午夜银河": "Midnight Galaxy",
	"复古街机": "Retro Arcade",
	"未来霓虹": "Neon Future",
	"皇家典藏": "Royal Vault",
	"极光幻彩": "Aurora Dream",
	"初来乍到": "Rookie",
	"试试手气": "Feeling Lucky",
	"街机常客": "Arcade Regular",
	"落币如雨": "Coin Downpour",
	"千投不倦": "Tireless Tosser",
	"第一桶金": "First Haul",
	"百币入袋": "Hundred Club",
	"收币能手": "Coin Collector",
	"万币归仓": "Vault Builder",
	"拾光收藏家": "Time Collector",
	"好运开张": "Lucky Start",
	"好事成双": "Double Luck",
	"中奖专业户": "Jackpot Regular",
	"毛球捕手": "Pom-pom Catcher",
	"火腿搭档": "Ham Buddy",
	"金币车车长": "Coin Train Conductor",
	"金库来客": "Vault Guest",
	"高塔见习生": "Tower Trainee",
	"推塔高手": "Tower Master",
	"换装玩家": "Style Swapper",
	"机台收藏家": "Cabinet Collector",
	"私人铸币师": "Master Minter",
	"再来一局": "One More Run",
	"轮盘体验官": "Wheel Rider",
	"今日开张": "Today's Opener",
	"随手十投": "Easy Ten",
	"今日落币手": "Today's Tosser",
	"今日收币员": "Today's Collector",
	"今日小丰收": "Little Harvest",
	"今日好运": "Lucky Day",
	"今日推塔手": "Tower Spotter",
	"今日铸币师": "Today's Minter",
	"连续登录 %d 天 · 已永久解锁": "%d-day login streak · unlocked for good",
	"连续登录 %d 天 · 当前 %d/%d 天": "%d-day login streak · %d/%d so far",
	"初始免费拥有": "Free from the start",
	"永久兑换 · %s 金币": "Permanent · %s coins",
	"① 双导杆自动左右摆动，币沿两杆之间下滑。\n    点「停在这里」固定，随时恢复摆动。\n② 点按投一枚，长按连续投币，每枚花费 1 金币。\n③ 推板自动来回，把金币推向前沿。\n\n正面掉落：每枚返还 1 金币。\n侧边掉落：不计奖励。\n新账号获得 1,000 金币，每天首次进入补给 500 金币。\n余额低于 50 时，口令每日最多补给一次 200 金币。\n正式投币每满 50 次解锁一枚纪念章。\n今日挑战：正式投币 100 枚、前口实收 40 枚、驱赶小偷 1 次。\n各获 1 枚永久印章，在收藏册查看；不额外发金币。\n夜行小偷：冷却结束且投满 30 枚后，每次有效投币有 3.5% 概率出现。\n5 秒内点击驱赶 3 次，失败偷走出现时钱包的 3%，最多 150 枚。\n余额不足 100 不触发；触发后有 90 秒冷却。\n暂停、离线、练习和中奖演出期间不计偷币倒计时。\n连续登录 3 天解锁复古街机，10 天解锁未来霓虹。\n中断后连续天数重计，已获皮肤永久保留。\n皇家典藏 100,000 金币，极光幻彩 200,000 金币。\n所有皮肤均可免费预览，金币兑换永久拥有。\n经典小丑·典藏：12,000 金币。\n每次有效投币有 1% 概率触发彩球砸台。\n彩球震散附近金币，前口掉落才到账。\n实体币超过 1,000 枚随机消除 50 枚，不计收益。\n每隔 8～12 分钟且累计有效投币 80 次，出现自然金币塔。\n自然塔每层 5 枚、共 10 层。\n落点被占用会延后，塔币也要推出前口才到账。\n\n投币穿过移动靶启动免费老虎机：\n三横线、两斜线：同图案连成线中奖。\n三樱桃 58（2.9%）· 三铃铛 388（0.09%）\n三星星 2,999（0.0099%）· 三个7 29,999（0.0001%）\n其余 97% 不中奖（本游戏暂定概率）。\n正在中奖或派奖时，连抽降为 0.5%：\n58 枚 0.49%，388 枚 0.01%，不出更大档。\n每轮中奖最多新增连抽 2 次，连中也不重置。\n此前累计的待抽次数和待出金币保留。\n每次待抽沿用获得时的概率，轮盘结算同样适用。\n普通奖币从联动短导杆出币口快速落下。\n奖金按枚实际落到推盘，前口推出才到账。\n出币和抽奖同时进行，奖币过靶也可连奖。\n累计待出较多时分批生成 50 枚金币塔。\n累计待出超过 200 枚，演出后提示自选轮盘结算：\n剩余抽奖按原概率算出，再将总待出按 1%～90% 折算到账。\n会结清待出和抽奖机会，钱包及台面币保留。\n\n没有内购或广告。登录奖励自动领取。\n练习台无限投币，不计正式收益。": "① The twin rails swing left and right on their own; coins slide down between them.\n    Tap 'Hold here' to freeze the swing, and resume any time.\n② Tap to drop one coin, hold to drop a stream — each coin costs 1.\n③ The pusher glides back and forth, nudging coins toward the front edge.\n\nFront drop: each coin pays back 1.\nSide drop: no reward.\nNew accounts start with 1,000 coins, and the first visit each day refills 500.\nWhen your balance is under 50, a phrase tops up 200 coins once per day.\nEvery 50 real drops unlocks one keepsake token.\nDaily goals: 100 real drops, 40 coins collected at the front, chase off 1 thief.\nEach grants 1 permanent stamp, viewable in the collection; no extra coins.\nNight thief: after its cooldown ends and you've dropped 30 coins, each valid drop has a 3.5% chance to summon it.\nTap 3 times within 5 seconds to shoo it away, or it steals 3% of the wallet it appeared with, up to 150 coins.\nWon't trigger under a 100 balance; 90-second cooldown after each visit.\nThe theft timer pauses during breaks, offline time, practice and prize shows.\nLog in 3 days in a row to unlock Retro Arcade, 10 days for Neon Future.\nA missed day restarts the streak; skins already earned are yours forever.\nRoyal Vault 100,000 coins, Aurora Dream 200,000 coins.\nEvery skin previews free; trade coins to own it for good.\nClassic Clown Deluxe: 12,000 coins.\nEach valid drop has a 1% chance to send the rainbow ball crashing down.\nIt scatters nearby coins — only front drops count toward your balance.\nPast 1,000 physical coins, 50 are cleared at random; they never pay out.\nEvery 8–12 minutes, after 80 total valid drops, a natural coin tower appears.\nNatural towers stack 5 coins per layer, 10 layers in all.\nA busy landing spot delays it; tower coins pay once pushed out the front too.\n\nDropping a coin through the moving target starts the free slot machine:\nThree rows and two diagonals: match symbols along a line to win.\nThree cherries 58 (2.9%) · three bells 388 (0.09%)\nThree stars 2,999 (0.0099%) · three 7s 29,999 (0.0001%)\nThe other 97% pay nothing (provisional odds for this game).\nWhile a prize is being won or paid out, bonus spins drop to 0.5%:\n58 coins 0.49%, 388 coins 0.01%, and no bigger tiers.\nEach winning round adds at most 2 bonus spins; win streaks never reset it.\nSpins and coins queued earlier are kept.\nEach queued spin keeps the odds it was won at; the wheel settlement works the same way.\nRegular prize coins pour fast from the linked short-rail chute.\nPrize coins count only as they actually land on the pusher and get pushed out the front.\nPaying out and spinning run side by side — prizes crossing the target can chain even more wins.\nWhen the pending pile grows, coin towers of 50 are spawned in batches.\nPast 200 pending coins, you'll be offered the wheel settlement after the show:\nRemaining spins resolve at their usual odds, then the whole pending total converts at 1%–90%.\nIt clears every pending coin and spin; wallet and table coins stay put.\n\nNo in-app purchases or ads. Login rewards claim themselves.\nPractice drops are unlimited and never count toward real payouts."
}

const PHRASES: = ["guoan", "各个国家的战斗到底"]
const PHRASE_VARIANTS: = ["国安", "各个国家战斗到底"]

static func t(s: String, lang: = "") -> String :
	var code: = OS.get_locale_language() if lang == "" else lang
	if code.begins_with("zh"): return s
	return ZH_EN.get(s, s)

static func phrase_list(_lang: = "") -> Array :
	return PHRASES.duplicate()

static func match_list() -> Array :
	var out: = PHRASES.duplicate()
	out.append_array(PHRASE_VARIANTS)
	return out

# ---- 通用 ----
static func list_join(items, lang: = "") -> String :
	return t("、", lang).join(items)

# ---- hud.gd ----
static func app_title(lang: = "") -> String : return t("拾光币社", lang)
static func daily_tag(lang: = "") -> String : return t("+500 / 日", lang)
static func my_coins(lang: = "") -> String : return t("我的金币", lang)
static func autosave_hint(lang: = "") -> String : return t("自动保存 · 放心离开", lang)
static func stage_default(lang: = "") -> String : return t("经典双层  ▾", lang)
static func voice_button_label(lang: = "") -> String : return t("口令补给 · 语音/输入", lang)
static func free_rhythm(lang: = "") -> String : return t("●  自由节奏", lang)
static func triple_bonus(lang: = "") -> String : return t("三同连线奖", lang)
static func slot_idle_hint(lang: = "") -> String : return t("穿过移动靶抽奖", lang)
static func settle_button_label(lang: = "") -> String : return t("轮盘结算待出金币", lang)
static func auto_swing(lang: = "") -> String : return t("自动摆杆", lang)
static func aim_hold(lang: = "") -> String : return t("Ⅱ  停在这里", lang)
static func front_pays(lang: = "") -> String : return t("前口落币计奖", lang)
static func drop_one(lang: = "") -> String : return t("投  一  枚     ↓", lang)
static func tap_or_hold(lang: = "") -> String : return t("点按投一枚 · 长按连续投币", lang)
static func collection_button(lang: = "") -> String : return t("◇ 收藏 / 挑战", lang)
static func practice_button(lang: = "") -> String : return t("∞  练习台", lang)
static func skins_button(lang: = "") -> String : return t("◈ 换皮肤", lang)
static func help_button(lang: = "") -> String : return t("?  怎么玩", lang)
static func aim_resume(lang: = "") -> String : return t("↔  继续摆动", lang)
static func title_prefix(lang: = "") -> String : return t("称号 · ", lang)
static func practice_prefix(lang: = "") -> String : return t("练习 · ", lang)
static func stage_name(id: String, lang: = "") -> String :
	return t({"classic": "经典双层", "split": "交错双推板", "sweep": "扫杆联动"}.get(id, ""), lang)
static func main_table_button(lang: = "") -> String : return t("↩  正式台", lang)
static func free_play_hint(lang: = "") -> String : return t("无限免费投币 · 不计金币与收藏", lang)
static func practice_mode(lang: = "") -> String : return t("练习模式", lang)
static func footer_tagline(lang: = "") -> String : return t("无内购  ·  自动保存  ·  随时歇一会儿", lang)
static func dispensing_wait(queued: int, lang: = "") -> String : return t("逐枚出币中 · 等待 %d 枚", lang) % queued
static func swing_hint(lang: = "") -> String : return t("摆杆自动游走，也可以停在喜欢的位置", lang)
static func broke_practice_hint(lang: = "") -> String : return t("金币用完啦，去免费练习台继续玩", lang)
static func pause_title(lang: = "") -> String : return t("歇一会儿", lang)
static func pause_subtitle(lang: = "") -> String : return t("台面已经暂停，金币和进度都已保存。", lang)
static func music_label(lang: = "") -> String : return t("背景音乐：", lang)
static func sound_label(lang: = "") -> String : return t("游戏音效：", lang)
static func haptic_label(lang: = "") -> String : return t("触感：", lang)
static func on_off(enabled: bool, lang: = "") -> String : return t("开启" if enabled else "关闭", lang)
static func shake_clear_button(lang: = "") -> String : return t("摇一摇 · 只震落上方卡币", lang)
static func test_target_button(lang: = "") -> String : return t("测试：必进中间洞 · ", lang)
static func test_tower_button(lang: = "") -> String : return t("测试：金币塔 · 练习台", lang)
static func restart_keep_button(lang: = "") -> String : return t("重开一局 · 金币保留", lang)
static func update_menu_button(lang: = "") -> String : return t("版本更新 · ", lang)
static func resume_button(lang: = "") -> String : return t("继续推金币", lang)
static func leave_note(lang: = "") -> String : return t("随时离开，不会错过任何限时奖励。", lang)
static func help_title(lang: = "") -> String : return t("一枚一枚，慢慢来", lang)
static func help_subtitle(lang: = "") -> String : return t("经典推币机 · 玩法与金币规则", lang)
static func help_done_button(lang: = "") -> String : return t("知道啦，去推金币", lang)
static func collection_title(lang: = "") -> String : return t("慢慢攒的小美好", lang)
static func collection_subtitle(lang: = "") -> String : return t("永久收藏 · 每投 50 枚，留下一枚纪念章", lang)
static func daily_goals_button(lang: = "") -> String : return t("今日挑战 · 收藏印章", lang)
static func title_wall_button(lang: = "") -> String : return t("称号墙 · 每日 / 永久", lang)
static func collected_tag(lang: = "") -> String : return t("已收藏", lang)
static func drops_needed(total: int, lang: = "") -> String : return t("%d 次投币", lang) % total
static func collection_stats(inserted: int, count: int, lang: = "") -> String : return t("已投 %d 枚  ·  已收藏 %d / 6", lang) % [inserted, count]
static func award_run_label(practice: bool, lang: = "") -> String : return t("练习收币" if practice else "本局实收", lang)
static func award_status_line(run_label: String, collected: String, pending: String, lang: = "") -> String : return t("%s %s 枚\n待出 %s 枚 · 推落才到账", lang) % [run_label, collected, pending]
static func reduced_odds_status(lang: = "") -> String : return t("连抽降档 58 / 388", lang)
static func spinning_status(lang: = "") -> String : return t("抽奖中 · 出币继续", lang)
static func prize_show_name(reward: int, lang: = "") -> String :
	if reward == 58: return t("小猫抓毛球", lang)
	if reward == 388: return t("小狗吃火腿", lang)
	return t("大奖演出中", lang)
static func paying_chain(used: int, lang: = "") -> String : return t("派奖中 · 连抽 %d/2", lang) % used
static func practice_spin_status(lang: = "") -> String : return t("练习 · 命中也抽奖", lang)
static func hit_target_status(lang: = "") -> String : return t("命中移动靶抽奖", lang)
static func pending_spins(count: String, lang: = "") -> String : return t("待抽 %s 次", lang) % count
static func shop_title(lang: = "") -> String : return t("给机台换件新衣", lang)
static func shop_subtitle(lang: = "") -> String : return t("连续登录或金币兑换 · 永久拥有 · 全部可免费预览", lang)
static func coins_available(lang: = "") -> String : return t("可用金币  ", lang)
static func login_streak_line(streak: int, lang: = "") -> String : return t("已连续登录 %d 天 · 中断后进度重计，已获皮肤保留", lang) % streak
static func custom_coin_button(lang: = "") -> String : return t("定制金币 · 选择自己的图片", lang)
static func preview_button(lang: = "") -> String : return t("免费预览", lang)
static func in_use(lang: = "") -> String : return t("使用中", lang)
static func equip_this(lang: = "") -> String : return t("换上这款", lang)
static func coins_to_redeem(lang: = "") -> String : return t(" 金币兑换", lang)
static func login_locked_button(lang: = "") -> String : return t("继续登录解锁", lang)
static func back_to_table_button(lang: = "") -> String : return t("回到推币台", lang)
static func phrase_bonus_title(lang: = "") -> String : return t("口令补给", lang)
static func phrase_input_hint(lang: = "") -> String : return t("点此输入，或用输入法麦克风说口令", lang)
static func confirm_phrase_button(lang: = "") -> String : return t("确认口令 · 领取金币", lang)
static func voice_help(lang: = "") -> String : return t("guoan / 各个国家的战斗到底\n余额低于 50 时可领 200 金币。\n两个口令共享每日一次额度，次日恢复。", lang)
static func voice_privacy_note(lang: = "") -> String : return t("输入法语音：点键盘上的麦克风，识别后确认领取。\n备用麦克风入口需授权和系统识别服务，不保存录音。", lang)
static func listening_label(lang: = "") -> String : return t("正在识别…", lang)
static func backup_mic_button(lang: = "") -> String : return t("备用：游戏内麦克风", lang)
static func cancel_back_button(lang: = "") -> String : return t("取消 / 回到机台", lang)
static func mechanism_title(lang: = "") -> String : return t("选一台，换种手感", lang)
static func mechanism_subtitle(lang: = "") -> String : return t("三种真实物理机构 · 各自保留台面与进度", lang)
static func mechanism_name(id: String, lang: = "") -> String :
	return t({"classic": "经典双层推板", "split": "左右交错双推板", "sweep": "推板 + 摆动扫杆"}.get(id, ""), lang)
static func mechanism_description(id: String, lang: = "") -> String :
	return t({"classic": "整面推板往复，适合观察前沿、精准投币。", "split": "左右推板错峰推进，抓住两侧不同的时机。", "sweep": "前方扫杆来回扫动，与推板一起搅动币堆。"}.get(id, ""), lang)
static func current_tag(lang: = "") -> String : return t("  ·  当前", lang)
static func back_machine_button(lang: = "") -> String : return t("回到机台", lang)
static func back_shop_prefix(lang: = "") -> String : return t("返回商店 · ", lang)
static func preview_note(lang: = "") -> String : return t("外观预览 · 台面已暂停 · 不扣金币", lang)
static func settle_title(lang: = "") -> String : return t("待出金币 · 一把结算", lang)
static func settle_subtitle(owed: String, chances: String, lang: = "") -> String : return t("累计待出 %s 枚 · 另有 %s 次抽奖\n先按原规则结算剩余抽奖，再随机折算 0.01～0.90 倍", lang) % [owed, chances]
static func settle_body(lang: = "") -> String : return t("结果直接到账。待出金币、正在开奖和排队机会全部结清。\n钱包现有金币、台面实体币保留。", lang)
static func settle_accept_button(lang: = "") -> String : return t("接受折算 · 全部结算", lang)
static func settle_keep_button(lang: = "") -> String : return t("继续抽奖和出币", lang)
static func wheel_title(lang: = "") -> String : return t("轮盘结算", lang)
static func wheel_subtitle(owed: String, lang: = "") -> String : return t("已结算待出 %s 枚", lang) % owed
static func wheel_spinning(lang: = "") -> String : return t("轮盘转动中…", lang)
static func wheel_result(percent: float, received: String, lang: = "") -> String : return t("× %.2f · 已到账 %s 枚", lang) % [percent / 100.0, received]
static func restart_title(lang: = "") -> String : return t("重开一局？", lang)
static func restart_subtitle(lang: = "") -> String : return t("台面金币重新铺设，摆杆和推板回到初始位置。", lang)
static func restart_body(lang: = "") -> String : return t("钱包金币、皮肤、定制币面保留。\n未发奖励与抽奖次数继续，尚未落出的付费投币退回。", lang)
static func restart_confirm_button(lang: = "") -> String : return t("确认重开", lang)
static func restart_stay_button(lang: = "") -> String : return t("继续当前这局", lang)
static func titles_title(daily: bool, lang: = "") -> String : return t("每日称号" if daily else "永久称号", lang)
static func titles_subtitle(daily: bool, lang: = "") -> String : return t("当天解锁，当天佩戴 · 次日重置，与登录皮肤进度独立" if daily else "长期累计解锁 · 永久保留", lang)
static func daily_titles_tab(lang: = "") -> String : return t("每日称号 · 8", lang)
static func permanent_titles_tab(lang: = "") -> String : return t("永久称号 · 24", lang)
static func category_label(key: String, lang: = "") -> String :
	return t({"inserted": "正式投币", "collected": "前口实收", "jackpots": "中奖", "best_prize": "单次中奖", "towers": "见到金币塔", "skins": "拥有皮肤", "custom": "定制币面", "restarts": "重开一局", "roulette": "轮盘结算"}.get(key, ""), lang)
static func worn_prefix(lang: = "") -> String : return t("佩戴中 · ", lang)
static func ready_prefix(lang: = "") -> String : return t("可佩戴 · ", lang)
static func locked_prefix(lang: = "") -> String : return t("未解锁 · ", lang)
static func challenges_title(lang: = "") -> String : return t("今日巡场", lang)
static func challenges_subtitle(lang: = "") -> String : return t("完成挑战收集永久印章 · 不额外发金币", lang)
static func rank_stamp_line(rank: String, total: int, lang: = "") -> String : return t("%s  ·  收藏印章 %d", lang) % [rank, total]
static func next_rank_line(need: int, rank: String, lang: = "") -> String : return t("再集 %d 枚 → %s", lang) % [need, rank]
static func completed_tag(lang: = "") -> String : return t("  ✓ 已完成", lang)
static func stamp_progress(progress: int, target: int, lang: = "") -> String : return t("%d / %d  ·  完成 +1 印章", lang) % [progress, target]
static func thief_stats_line(repelled: int, stolen: int, lang: = "") -> String : return t("累计驱赶 %d 次  ·  被偷 %d 枚", lang) % [repelled, stolen]
static func challenges_note(lang: = "") -> String : return t("只有正式台计入挑战。小偷随机出现，不保证每天遇到；次日重置进度，已得印章永久保留。", lang)
static func challenges_resume_button(lang: = "") -> String : return t("继续巡场", lang)
static func update_title(lang: = "") -> String : return t("版本更新", lang)
static func update_subtitle(version: String, lang: = "") -> String : return t("拾光币社 · 当前版本 ", lang) + version
static func new_version_line(version: String, size_mb: float, lang: = "") -> String : return t("新版 %s · %.1f MB", lang) % [version, size_mb]
static func download_button(lang: = "") -> String : return t("下载更新", lang)
static func install_button(lang: = "") -> String : return t("安装已校验的更新", lang)
static func cancel_button(lang: = "") -> String : return t("取消", lang)
static func recheck_button(lang: = "") -> String : return t("重新检查", lang)
static func download_page_button(lang: = "") -> String : return t("打开下载页", lang)
static func back_game_button(lang: = "") -> String : return t("返回游戏", lang)

# ---- game.gd ----
static func trim_toast(count: int, lang: = "") -> String : return t("台面超过 1,000 枚 · 随机消除 %d 枚", lang) % count
static func rainbow_soon_toast(lang: = "") -> String : return t("幸运彩球！准备砸向推盘", lang)
static func rainbow_hit_toast(lang: = "") -> String : return t("彩球砸台！前口掉落才到账", lang)
static func tower_toast(count: int, lang: = "") -> String : return t("旋风带来 %d 枚金币塔 · 推到前口才到账", lang) % count
static func update_toast(lang: = "") -> String : return t("发现新版本 · 在暂停菜单查看更新", lang)
static func restore_toast(lang: = "") -> String : return t("已从备份恢复进度", lang)
static func daily_bonus_toast(amount: String, streak: int, lang: = "") -> String : return t("今日补给 +%s · 连续登录 %d 天", lang) % [amount, streak]
static func unlock_prefix(lang: = "") -> String : return t("\n永久解锁：", lang)
static func queue_full_toast(lang: = "") -> String : return t("投币队列已达上限，请稍后再投", lang)
static func broke_practice_toast(lang: = "") -> String : return t("金币用完啦，免费练习台随时开放", lang)
static func thief_alert_toast(lang: = "") -> String : return t("夜行小偷！5 秒内点击驱赶 3 次", lang)
static func collection_unlocked_prefix(lang: = "") -> String : return t("收藏解锁 · ", lang)
static func target_hit_toast(lang: = "") -> String : return t("命中移动靶！", lang)
static func spin_queued_text(lang: = "") -> String : return t("抽奖已排队", lang)
static func reels_start_text(lang: = "") -> String : return t("三滚轮启动", lang)
static func chain_capped_toast(lang: = "") -> String : return t("本轮连抽已达 2 次 · 继续推币收奖", lang)
static func practice_enter_toast(lang: = "") -> String : return t("自由练习 · 无限投币，不计收益", lang)
static func practice_exit_toast(lang: = "") -> String : return t("已回到正式台，接着慢慢推", lang)
static func save_paused_suffix(lang: = "") -> String : return t("，投币暂时停用", lang)
static func triple_win_toast(prize: String, lang: = "") -> String : return t("三同中奖！%s 枚，演出结束后开始吐币", lang) % prize
static func triple_miss_toast(lang: = "") -> String : return t("这次未连成三同，继续观察落点", lang)
static func thief_stole_toast(lost: int, lang: = "") -> String : return t("小偷逃走了 · 钱包 -%d 金币", lang) % lost
static func voice_intro_message(lang: = "") -> String : return t("可直接输入，也可用输入法语音。确认文字后领取。", lang)
static func voice_practice_block(lang: = "") -> String : return t("请先返回正式机台，再领取语音补给。", lang)
static func mic_request_message(lang: = "") -> String : return t("正在请求麦克风，请留意系统权限提示…", lang)
static func voice_success_message(text: String, amount: String, lang: = "") -> String : return t("识别：%s\n+%s 金币已到账！", lang) % [text, amount]
static func voice_fail_message(text: String, limit: int, lang: = "") -> String : return t("识别：%s\n口令需匹配，余额低于 %d，且每日只能领取一次。", lang) % [text, limit]
static func test_target_on_toast(lang: = "") -> String : return t("测试开启：按投币必进中间洞，奖币也走此路径", lang)
static func test_target_off_toast(lang: = "") -> String : return t("测试关闭：恢复真实碰撞", lang)
static func shake_nothing_toast(lang: = "") -> String : return t("上方钉板没有金币需要震落 · 下方推盘照常运行", lang)
static func shake_running_toast(lang: = "") -> String : return t("正在震落上方卡币 · 下方推盘照常运行", lang)
static func phrase_practice_block(lang: = "") -> String : return t("请先返回正式台，再领取口令补给。", lang)
static func tower_test_toast(lang: = "") -> String : return t("练习测试 · 有空位时旋风带来金币塔", lang)
static func settle_save_fail_toast(lang: = "") -> String : return t("保存失败，本次未结算，请重试", lang)
static func round_started_toast(lang: = "") -> String : return t("新一局已开始 · 金币与未发奖励保留", lang)
static func repel_success_toast(lang: = "") -> String : return t("成功驱赶 · 钱包保住了！", lang)
static func repel_stamp_suffix(lang: = "") -> String : return t("\n今日挑战完成 · 收藏印章 +1", lang)
static func challenge_done_toast(titles: String, count: int, lang: = "") -> String : return t("挑战完成 · %s · 收藏印章 +%d", lang) % [titles, count]

# ---- app_update.gd ----
static func upd_current_version(lang: = "") -> String : return t("当前版本 ", lang)
static func upd_checking(lang: = "") -> String : return t("正在检查更新…", lang)
static func upd_no_server(lang: = "") -> String : return t("暂时无法连接更新服务器，可稍后重试。", lang)
static func upd_need_android(lang: = "") -> String : return t("请在 Android 版内下载更新，其他设备可打开下载页。", lang)
static func upd_downloading(lang: = "") -> String : return t("正在下载更新…", lang)
static func upd_dl_failed(lang: = "") -> String : return t("下载未能开始，请重试。", lang)
static func upd_cancelled(lang: = "") -> String : return t("已取消，可以继续游戏。", lang)
static func upd_file_changed(lang: = "") -> String : return t("安装文件已变化，请重新下载。", lang)
static func upd_service_down(lang: = "") -> String : return t("更新服务暂不可用，游戏可继续离线游玩。", lang)
static func upd_dl_incomplete(lang: = "") -> String : return t("下载中断或文件不完整，请重试。", lang)
static func upd_verify_later(lang: = "") -> String : return t("更新信息未通过校验，请稍后重试。", lang)
static func upd_found_new(version: String, lang: = "") -> String : return t("发现新版本 ", lang) + version
static func upd_latest(version: String, lang: = "") -> String : return t("已经是最新版本 ", lang) + version
static func upd_pkg_verify_failed(lang: = "") -> String : return t("安装包校验失败，请重新下载。", lang)
static func upd_pkg_save_failed(lang: = "") -> String : return t("无法保存安装包，请检查可用空间。", lang)
static func upd_pkg_ready(lang: = "") -> String : return t("安装包已校验，点击安装后由 Android 系统确认。", lang)
static func upd_progress(percent: int, lang: = "") -> String : return t("正在下载更新 · %d%%", lang) % percent

# ---- daily_challenges.gd ----
static func challenge_title(kind: String, lang: = "") -> String :
	return t({"inserted": "投币练手 · 正式投币 100 枚", "collected": "前口丰收 · 实收 40 枚", "chased": "守住钱包 · 驱赶小偷 1 次"}.get(kind, ""), lang)
static func challenge_list(kinds: Array, lang: = "") -> String :
	var parts: = []
	for kind in kinds: parts.append(challenge_title(kind, lang))
	return list_join(parts, lang)
static func rank_title(index: int, lang: = "") -> String :
	var names: = ["新晋挑战者", "街机学徒", "挑战能手", "机台守护者", "街机达人", "传奇收藏家"]
	return t(names[index], lang) if index >= 0 and index < names.size() else ""

# ---- jackpot_fx.gd ----
static func jackpot_caption(tier: int, lang: = "") -> String :
	var names: = ["好 运 嘉 奖", "金 潮 加 赏", "大 奖 时 刻", "至 尊 头 奖"]
	return t(names[tier], lang) if tier >= 0 and tier < names.size() else ""
static func jackpot_unit(lang: = "") -> String : return t("枚奖励金币 · 待发放", lang)
static func jackpot_payout_hint(lang: = "") -> String : return t("演出结束后落币，推入前口后计入余额", lang)

# ---- premium_cabinet.gd ----
static func clown_marquee(lang: = "") -> String : return t("经 典 小 丑", lang)
static func clown_plaque(lang: = "") -> String : return t("经 典 小 丑  ·  典 藏", lang)
static func clown_screen_title(lang: = "") -> String : return t("小丑连线奖", lang)
static func clown_screen_idle(lang: = "") -> String : return t("投币命中靶\n启动老虎机", lang)
static func clown_practice_title(lang: = "") -> String : return t("练习台 · 小丑连线奖", lang)
static func clown_reduced(lang: = "") -> String : return t("连抽降档", lang)
static func clown_spinning(lang: = "") -> String : return t("抽奖中", lang)
static func clown_won(reward: String, lang: = "") -> String : return t("中了 %s！", lang) % reward
static func clown_to_drop(count: String, lang: = "") -> String : return t("待落 %s 枚", lang) % count
static func clown_hit_target(lang: = "") -> String : return t("投币命中靶", lang)
static func clown_spins_left(count: String, lang: = "") -> String : return t("\n待抽 %s 次", lang) % count

# ---- arcade_cabinet.gd ----
static func marquee_title(style: String, lang: = "") -> String :
	return t({"classic": "拾 光 币 社", "retro": "落 日 街 机", "future": "量 子 推 币", "royal": "鎏 金 典 藏", "aurora": "极 光 冰 宫"}.get(style, "拾 光 币 社"), lang)

# ---- bonus.gd ----
static func pattern_name(tier: int, lang: = "") -> String :
	var names: = ["逐枚吐币", "连续吐币", "摆动吐币", "快速吐币"]
	return t(names[tier], lang) if tier >= 0 and tier < names.size() else t("等待命中奖口", lang)

# ---- save_store.gd ----
static func save_error(kind: String, lang: = "") -> String :
	return t({"open": "无法保存，请检查存储空间", "write": "保存未完成，请检查存储空间", "backup": "备份未完成", "rename": "存档写入失败"}.get(kind, ""), lang)

# ---- speech.gd ----
static func no_speech_error(lang: = "") -> String : return t("当前设备没有可用的系统语音服务，请使用已安装语音服务的 Android 或 iPhone 真机。", lang)

# ---- thief_view.gd ----
static func thief_panel_title(lang: = "") -> String : return t("夜行小偷靠近", lang)
static func thief_detail(remaining: float, loss: int, lang: = "") -> String : return t("%.1f 秒后偷走最多 %d 枚", lang) % [remaining, loss]
static func thief_repel_button(taps: int, lang: = "") -> String : return t("点击驱赶   %d / 3", lang) % taps

# ---- coin_designer.gd ----
static func designer_title(lang: = "") -> String : return t("我的定制金币", lang)
static func designer_subtitle(lang: = "") -> String : return t("选择图片 → 圆形裁切 → 简化币面\n仅保存在本机，不上传图片", lang)
static func pick_picture_button(lang: = "") -> String : return t("选择一张图片", lang)
static func slider_label(key: String, lang: = "") -> String :
	return t({"zoom": "放大", "panx": "左右", "pany": "上下"}.get(key, ""), lang)
static func apply_coins_button(lang: = "") -> String : return t("应用到所有金币", lang)
static func reset_face_button(lang: = "") -> String : return t("恢复默认币面", lang)
static func designer_back_button(lang: = "") -> String : return t("返回皮肤商店", lang)
static func image_filter(lang: = "") -> String : return t("*.png,*.jpg,*.jpeg,*.webp;图片", lang)
static func picture_too_big(lang: = "") -> String : return t("图片太大或无法读取，请选择小于 32 MB 的图片", lang)
static func picture_unreadable(lang: = "") -> String : return t("这张图片无法读取，请换一张", lang)
static func face_save_failed(lang: = "") -> String : return t("保存失败，原币面保持不变", lang)
static func face_applied(lang: = "") -> String : return t("定制币面已应用 · 新旧金币同步更新", lang)
static func face_clear_failed(lang: = "") -> String : return t("无法清除定制币面，请重试", lang)

# ---- wallet.gd ----
static func collection_name(index: int, lang: = "") -> String :
	var names: = ["初见黄铜", "海盐薄荷", "落日珊瑚", "午夜星光", "琥珀回声", "银河漫游"]
	return t(names[index], lang) if index >= 0 and index < names.size() else ""
static func skin_name(id: String, lang: = "") -> String :
	return t({"classic": "经典街机", "mint": "海盐薄荷", "sakura": "落日樱粉", "clown_deluxe": "经典小丑·典藏", "galaxy": "午夜银河", "retro": "复古街机", "future": "未来霓虹", "royal": "皇家典藏", "aurora": "极光幻彩"}.get(id, ""), lang)
static func title_name(index: int, lang: = "") -> String :
	var daily: = ["今日开张", "随手十投", "今日落币手", "今日收币员", "今日小丰收", "今日好运", "今日推塔手", "今日铸币师"]
	var permanent: = ["初来乍到", "试试手气", "街机常客", "落币如雨", "千投不倦", "第一桶金", "百币入袋", "收币能手", "万币归仓", "拾光收藏家", "好运开张", "好事成双", "中奖专业户", "毛球捕手", "火腿搭档", "金币车车长", "金库来客", "高塔见习生", "推塔高手", "换装玩家", "机台收藏家", "私人铸币师", "再来一局", "轮盘体验官"]
	if index >= 100: return t(daily[index - 100], lang) if index < 100 + daily.size() else ""
	return t(permanent[index], lang) if index >= 0 and index < permanent.size() else ""
static func skin_login_text(required: int, unlocked: bool, streak: int, lang: = "") -> String :
	if unlocked: return t("连续登录 %d 天 · 已永久解锁", lang) % required
	return t("连续登录 %d 天 · 当前 %d/%d 天", lang) % [required, mini(streak, required), required]
static func skin_price_text(price: int, lang: = "") -> String :
	if price == 0: return t("初始免费拥有", lang)
	return t("永久兑换 · %s 金币", lang) % str(price)

static func help_body(lang: = "") -> String :
	return t("① 双导杆自动左右摆动，币沿两杆之间下滑。\n    点「停在这里」固定，随时恢复摆动。\n② 点按投一枚，长按连续投币，每枚花费 1 金币。\n③ 推板自动来回，把金币推向前沿。\n\n正面掉落：每枚返还 1 金币。\n侧边掉落：不计奖励。\n新账号获得 1,000 金币，每天首次进入补给 500 金币。\n余额低于 50 时，口令每日最多补给一次 200 金币。\n正式投币每满 50 次解锁一枚纪念章。\n今日挑战：正式投币 100 枚、前口实收 40 枚、驱赶小偷 1 次。\n各获 1 枚永久印章，在收藏册查看；不额外发金币。\n夜行小偷：冷却结束且投满 30 枚后，每次有效投币有 3.5% 概率出现。\n5 秒内点击驱赶 3 次，失败偷走出现时钱包的 3%，最多 150 枚。\n余额不足 100 不触发；触发后有 90 秒冷却。\n暂停、离线、练习和中奖演出期间不计偷币倒计时。\n连续登录 3 天解锁复古街机，10 天解锁未来霓虹。\n中断后连续天数重计，已获皮肤永久保留。\n皇家典藏 100,000 金币，极光幻彩 200,000 金币。\n所有皮肤均可免费预览，金币兑换永久拥有。\n经典小丑·典藏：12,000 金币。\n每次有效投币有 1% 概率触发彩球砸台。\n彩球震散附近金币，前口掉落才到账。\n实体币超过 1,000 枚随机消除 50 枚，不计收益。\n每隔 8～12 分钟且累计有效投币 80 次，出现自然金币塔。\n自然塔每层 5 枚、共 10 层。\n落点被占用会延后，塔币也要推出前口才到账。\n\n投币穿过移动靶启动免费老虎机：\n三横线、两斜线：同图案连成线中奖。\n三樱桃 58（2.9%）· 三铃铛 388（0.09%）\n三星星 2,999（0.0099%）· 三个7 29,999（0.0001%）\n其余 97% 不中奖（本游戏暂定概率）。\n正在中奖或派奖时，连抽降为 0.5%：\n58 枚 0.49%，388 枚 0.01%，不出更大档。\n每轮中奖最多新增连抽 2 次，连中也不重置。\n此前累计的待抽次数和待出金币保留。\n每次待抽沿用获得时的概率，轮盘结算同样适用。\n普通奖币从联动短导杆出币口快速落下。\n奖金按枚实际落到推盘，前口推出才到账。\n出币和抽奖同时进行，奖币过靶也可连奖。\n累计待出较多时分批生成 50 枚金币塔。\n累计待出超过 200 枚，演出后提示自选轮盘结算：\n剩余抽奖按原概率算出，再将总待出按 1%～90% 折算到账。\n会结清待出和抽奖机会，钱包及台面币保留。\n\n没有内购或广告。登录奖励自动领取。\n练习台无限投币，不计正式收益。", lang)
