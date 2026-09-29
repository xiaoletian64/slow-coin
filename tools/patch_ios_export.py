from pathlib import Path
import plistlib, shutil
root=Path(__file__).resolve().parents[1]
export=root/'builds/ios'
for p in export.glob('**/*Info.plist'):
    if '.xcframework' in str(p):continue
    with p.open('rb') as f:data=plistlib.load(f)
    data['NSSpeechRecognitionUsageDescription']='仅在你点击麦克风后识别补给口令。'
    data['NSMicrophoneUsageDescription']='用于你主动发起的语音补给口令识别。'
    with p.open('wb') as f:plistlib.dump(data,f)
p=export/'SlowCoin.xcodeproj/project.pbxproj'
s=p.read_text()
s=s.replace('$(LD_CLASSIC_$(XCODE_VERSION_ACTUAL))  ', '$(LD_CLASSIC_$(XCODE_VERSION_ACTUAL)) -framework Speech -framework PhotosUI ')
p.write_text(s)
lib=root/'.tools/godot-4.6.3-stable/bin/libgodot.ios.template_debug.arm64.a'
if lib.exists():shutil.copy2(lib,export/'SlowCoin.xcframework/ios-arm64/libgodot.a')
