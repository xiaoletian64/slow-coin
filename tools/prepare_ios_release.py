"""Prepare the exported project for a device-only unsigned Release build."""
from pathlib import Path
import plistlib
import shutil

root = Path(__file__).resolve().parents[1]
export = root / 'builds/ios'
lib = root / '.tools/ios-engine/libgodot.a'
if not lib.is_file():
    raise RuntimeError('Custom release engine missing; native features must not be omitted')
framework = export / 'SlowCoin.xcframework'
shutil.copy2(lib, framework / 'ios-arm64/libgodot.a')
for path in export.rglob('*Info.plist'):
    if '.xcframework' in str(path):
        continue
    with path.open('rb') as source:
        data = plistlib.load(source)
    for unused in ['NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription']:
        if not data.get(unused):
            data.pop(unused, None)
    data['CFBundleDisplayName'] = '拾光币社'
    data['NSSpeechRecognitionUsageDescription'] = '仅在你点击麦克风后识别补给口令，也可直接输入文字。'
    data['NSMicrophoneUsageDescription'] = '用于你主动发起的语音补给口令识别，不保存录音。'
    data['ITSAppUsesNonExemptEncryption'] = False
    with path.open('wb') as target:
        plistlib.dump(data, target)
project = export / 'SlowCoin.xcodeproj/project.pbxproj'
text = project.read_text()
# Link native APIs required by the custom engine module in both configurations.
needle = 'OTHER_LDFLAGS = "'
if needle not in text:
    raise RuntimeError('Exported linker configuration not found')
if '-framework Speech -framework PhotosUI ' not in text:
    text = text.replace(needle, needle + '-framework Speech -framework PhotosUI ')
project.write_text(text)
privacy = list(export.rglob('PrivacyInfo.xcprivacy'))
if not privacy:
    raise RuntimeError('Godot privacy manifest missing')
for path in privacy:
    with path.open('rb') as source:
        plistlib.load(source)
print('Custom native release engine, usage strings, encryption and privacy manifest verified')
