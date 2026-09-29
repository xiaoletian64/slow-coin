from pathlib import Path
import shutil, zipfile, os
root=Path(__file__).resolve().parent.parent
build=root/'android/build'
if not (build/'build.gradle').exists():
    template=Path.home()/'Library/Application Support/Godot/export_templates/4.6.3.stable/android_source.zip'
    build.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(template) as z:z.extractall(build)
(build.parent/'.build_version').write_text('4.6.3.stable')
(build/'.gdignore').touch()
source=build/'src/main/java/com/slowcoin/nativebridge'
source.mkdir(parents=True,exist_ok=True)
shutil.copy(root/'native/android/SlowCoinSpeechPlugin.java',source/'SlowCoinSpeechPlugin.java')
p=build/'src/main/AndroidManifest.xml'
s=p.read_text()
if 'org.godotengine.plugin.v2.SlowCoinSpeech' not in s:
    s=s.replace('</application>','<meta-data android:name="org.godotengine.plugin.v2.SlowCoinSpeech" android:value="com.slowcoin.nativebridge.SlowCoinSpeechPlugin" />\n    </application>')
if 'android.permission.RECORD_AUDIO' not in s:
    s=s.replace('<application', '<uses-permission android:name="android.permission.RECORD_AUDIO" />\n    <application',1)
if 'android.speech.RecognitionService' not in s:
    s=s.replace('<application', '<queries><intent><action android:name="android.speech.RecognitionService" /></intent></queries>\n    <application',1)
p.write_text(s)
sdk=os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME') or '/opt/homebrew/share/android-commandlinetools'
(build/'local.properties').write_text('sdk.dir='+sdk+'\n')
os.chmod(build/'gradlew',0o755)
