package com.slowcoin.nativebridge;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;
import java.util.Set;
import java.util.HashSet;
import java.util.ArrayList;

/** One explicit recording session; never saves audio or listens in background. */
public final class SlowCoinSpeechPlugin extends GodotPlugin {
    private static final int REQUEST = 1992;
    private static final int IMAGE_REQUEST = 5801;
    private final Handler main = new Handler(Looper.getMainLooper());
    private SpeechRecognizer recognizer;
    private boolean pending, askingPermission;
    private int generation;
    private Runnable timeout;
    public SlowCoinSpeechPlugin(Godot godot) { super(godot); }
    @Override public String getPluginName() { return "SlowCoinSpeech"; }
    @Override public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new HashSet<>();
        signals.add(new SignalInfo("recognized", String.class));
        signals.add(new SignalInfo("failed", String.class));
        signals.add(new SignalInfo("status", String.class));
        signals.add(new SignalInfo("image_selected", String.class));
        signals.add(new SignalInfo("image_failed", String.class));
        return signals;
    }
    @UsedByGodot public void pick_image() { main.post(() -> {
        Activity activity=getActivity();
        if (activity==null) { emitSignal("image_failed","界面尚未准备好"); return; }
        try {
            Intent intent=new Intent(Intent.ACTION_OPEN_DOCUMENT);
            intent.setType("image/*");
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            activity.startActivityForResult(intent,IMAGE_REQUEST);
        } catch (RuntimeException error) { emitSignal("image_failed","无法打开系统图片选择器"); }
    }); }
    @Override public void onMainActivityResult(int requestCode,int resultCode,Intent data) {
        if (requestCode!=IMAGE_REQUEST) return;
        if (resultCode!=Activity.RESULT_OK || data==null || data.getData()==null) { emitSignal("image_failed",""); return; }
        final android.net.Uri uri=data.getData();
        final Activity activity=getActivity();
        new Thread(() -> {
            try {
                android.graphics.Bitmap bitmap;
                if (android.os.Build.VERSION.SDK_INT>=28) {
                    bitmap=android.graphics.ImageDecoder.decodeBitmap(android.graphics.ImageDecoder.createSource(activity.getContentResolver(),uri),(decoder,info,source) -> {
                        int w=info.getSize().getWidth(),h=info.getSize().getHeight();
                        float scale=Math.min(1f,1024f/Math.max(w,h));
                        decoder.setTargetSize(Math.max(1,(int)(w*scale)),Math.max(1,(int)(h*scale)));
                        decoder.setAllocator(android.graphics.ImageDecoder.ALLOCATOR_SOFTWARE);
                    });
                } else {
                    android.graphics.BitmapFactory.Options options=new android.graphics.BitmapFactory.Options();
                    options.inJustDecodeBounds=true;
                    try(java.io.InputStream in=activity.getContentResolver().openInputStream(uri)){android.graphics.BitmapFactory.decodeStream(in,null,options);}
                    options.inSampleSize=1;
                    while(Math.max(options.outWidth,options.outHeight)/options.inSampleSize>1024)options.inSampleSize*=2;
                    options.inJustDecodeBounds=false;
                    try(java.io.InputStream in=activity.getContentResolver().openInputStream(uri)){bitmap=android.graphics.BitmapFactory.decodeStream(in,null,options);}
                    int rotation=0;
                    try(java.io.InputStream in=activity.getContentResolver().openInputStream(uri)){
                        android.media.ExifInterface exif=new android.media.ExifInterface(in);
                        int orientation=exif.getAttributeInt(android.media.ExifInterface.TAG_ORIENTATION,1);
                        rotation=orientation==6?90:orientation==3?180:orientation==8?270:0;
                    } catch(Exception ignored) {}
                    if(bitmap!=null && rotation!=0){android.graphics.Matrix matrix=new android.graphics.Matrix();matrix.postRotate(rotation);bitmap=android.graphics.Bitmap.createBitmap(bitmap,0,0,bitmap.getWidth(),bitmap.getHeight(),matrix,true);}
                }
                if(bitmap==null)throw new java.io.IOException("invalid image");
                java.io.File file=new java.io.File(activity.getCacheDir(),"coin-image.png");
                try(java.io.FileOutputStream out=new java.io.FileOutputStream(file)){bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG,100,out);}
                bitmap.recycle();
                emitSignal("image_selected",file.getAbsolutePath());
            } catch(Exception | OutOfMemoryError error){emitSignal("image_failed","图片读取失败，请选择另一张图片");}
        },"CoinImageImport").start();
    }
    @UsedByGodot public void listen() { main.post(() -> {
        if (pending) return;
        Activity activity = getActivity();
        if (activity == null) { emitSignal("failed", "界面尚未准备好，请重试。"); return; }
        pending = true;
        generation++;
        if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            askingPermission = true;
            emitSignal("status", "请允许麦克风权限，授权后开始识别。");
            activity.requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, REQUEST);
        } else startRecognition();
    }); }
    @Override public void onMainRequestPermissionsResult(int code, String[] permissions, int[] results) {
        if (code != REQUEST) return;
        main.post(() -> {
            if (!pending || !askingPermission) return;
            askingPermission = false;
            if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED) startRecognition();
            else fail("麦克风权限未开启。请在手机设置 → 应用 → 权限中允许麦克风后重试。");
        });
    }
    private void startRecognition() {
        Activity activity = getActivity();
        if (activity == null || !SpeechRecognizer.isRecognitionAvailable(activity)) {
            fail("麦克风已授权，但手机未安装兼容的系统语音识别服务。仅有录音权限还不能转成文字。"); return;
        }
        final int session = generation;
        try {
            recognizer = SpeechRecognizer.createSpeechRecognizer(activity);
            recognizer.setRecognitionListener(new RecognitionListener() {
                private boolean active() { return pending && generation == session; }
                public void onReadyForSpeech(Bundle p) { if (active()) emitSignal("status", "麦克风已开启，正在听…请说口令。"); }
                public void onBeginningOfSpeech() {}
                public void onRmsChanged(float level) {}
                public void onBufferReceived(byte[] b) {}
                public void onEndOfSpeech() { if (active()) emitSignal("status", "已听到，正在识别…"); }
                public void onPartialResults(Bundle b) {}
                public void onEvent(int type, Bundle b) {}
                public void onError(int error) {
                    if (!active()) return;
                    String message;
                    switch (error) {
                        case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS: message="录音权限不足，请允许麦克风。"; break;
                        case SpeechRecognizer.ERROR_NETWORK:
                        case SpeechRecognizer.ERROR_NETWORK_TIMEOUT: message="系统语音服务网络异常，请检查网络或安装离线中文语音包。"; break;
                        case SpeechRecognizer.ERROR_AUDIO: message="麦克风无法使用，可能正被其他应用占用。"; break;
                        case SpeechRecognizer.ERROR_NO_MATCH:
                        case SpeechRecognizer.ERROR_SPEECH_TIMEOUT: message="没有听清，请点麦克风再说一次。"; break;
                        default: message="系统语音识别失败（"+error+"），请检查中文语音服务。";
                    }
                    fail(message);
                }
                public void onResults(Bundle results) {
                    if (!active()) return;
                    ArrayList<String> words=results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                    if (words==null || words.isEmpty()) { fail("没有听清，请重试。"); return; }
                    String result=words.get(0);
                    cleanup();
                    emitSignal("recognized",result);
                }
            });
            Intent intent=new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
            intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
            intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE,"zh-CN");
            intent.putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE,true);
            intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,1);
            emitSignal("status","正在开启麦克风…");
            recognizer.startListening(intent);
            timeout=() -> { if (pending && generation==session) fail("识别超时，麦克风已关闭，请重试。"); };
            main.postDelayed(timeout,15000);
        } catch (RuntimeException error) { fail("无法启动录音或系统语音服务，请检查权限后重试。"); }
    }
    private void cleanup() {
        pending=false; askingPermission=false; generation++;
        if (timeout!=null) { main.removeCallbacks(timeout); timeout=null; }
        if (recognizer!=null) { recognizer.cancel(); recognizer.destroy(); recognizer=null; }
    }
    private void fail(String message) { cleanup(); emitSignal("failed",message); }
    @UsedByGodot public void stop() { main.post(this::cleanup); }
    @Override public void onMainPause() { main.post(() -> {
        if (pending && !askingPermission) fail("已暂停录音，返回后可重新点击麦克风。");
    }); }
    @Override public void onMainDestroy() { main.post(this::cleanup); }
}
