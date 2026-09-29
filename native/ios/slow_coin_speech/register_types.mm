#include "register_types.h"
#include "core/config/engine.h"
#include "core/object/class_db.h"
#import <Foundation/Foundation.h>
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

class SlowCoinSpeech;
static SlowCoinSpeech *bridge = nullptr;

@interface SlowCoinRecorder : NSObject <PHPickerViewControllerDelegate>
@property(nonatomic,strong) AVAudioEngine *audio;
@property(nonatomic,strong) SFSpeechRecognizer *recognizer;
@property(nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *request;
@property(nonatomic,strong) SFSpeechRecognitionTask *task;
@property(nonatomic,assign) BOOL active;
@property(nonatomic,assign) BOOL tapped;
@property(nonatomic,assign) NSUInteger generation;
-(void)pickImage;
-(void)listen;
-(void)stop;
@end

class SlowCoinSpeech : public Object {
    GDCLASS(SlowCoinSpeech, Object);
    __strong SlowCoinRecorder *recorder;
protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("pick_image"), &SlowCoinSpeech::pick_image);
        ClassDB::bind_method(D_METHOD("listen"), &SlowCoinSpeech::listen);
        ClassDB::bind_method(D_METHOD("stop"), &SlowCoinSpeech::stop);
        ADD_SIGNAL(MethodInfo("image_selected", PropertyInfo(Variant::STRING,"path")));
        ADD_SIGNAL(MethodInfo("image_failed", PropertyInfo(Variant::STRING,"message")));
        ADD_SIGNAL(MethodInfo("recognized", PropertyInfo(Variant::STRING,"text")));
        ADD_SIGNAL(MethodInfo("failed", PropertyInfo(Variant::STRING,"message")));
    }
public:
    SlowCoinSpeech() { recorder = [SlowCoinRecorder new]; }
    ~SlowCoinSpeech() { [recorder stop]; recorder = nil; }
    void pick_image() { dispatch_async(dispatch_get_main_queue(), ^{ [recorder pickImage]; }); }
    void listen() { dispatch_async(dispatch_get_main_queue(), ^{ [recorder listen]; }); }
    void stop() { dispatch_async(dispatch_get_main_queue(), ^{ [recorder stop]; }); }
};

static void report(const char *signal, NSString *message) {
    if (bridge) bridge->call_deferred("emit_signal", String(signal), String::utf8([message UTF8String]));
}

@implementation SlowCoinRecorder
-(void)pickImage {
    UIWindow *window=nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class] && scene.activationState==UISceneActivationStateForegroundActive) {
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) if (candidate.isKeyWindow) window=candidate;
        }
    }
    UIViewController *presenter=window.rootViewController;
    while (presenter.presentedViewController) presenter=presenter.presentedViewController;
    if (!presenter) { report("image_failed",@"无法打开图片选择器"); return; }
    PHPickerConfiguration *configuration=[PHPickerConfiguration new];
    configuration.filter=PHPickerFilter.imagesFilter;
    configuration.selectionLimit=1;
    PHPickerViewController *picker=[[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate=self;
    [presenter presentViewController:picker animated:YES completion:nil];
}
-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!results.count) { report("image_failed",@""); return; }
    NSItemProvider *provider=results.firstObject.itemProvider;
    if (![provider canLoadObjectOfClass:UIImage.class]) { report("image_failed",@"请选择可读取的图片"); return; }
    [provider loadObjectOfClass:UIImage.class completionHandler:^(id<NSItemProviderReading> object,NSError *error) {
        if (error || ![object isKindOfClass:UIImage.class]) { report("image_failed",@"图片读取失败，请重试"); return; }
        UIImage *image=(UIImage *)object;
        CGFloat ratio=MIN(1.0,1024.0/MAX(image.size.width,image.size.height));
        CGSize size=CGSizeMake(MAX(1,image.size.width*ratio),MAX(1,image.size.height*ratio));
        UIGraphicsImageRendererFormat *format=[UIGraphicsImageRendererFormat defaultFormat];
        format.scale=1;
        UIGraphicsImageRenderer *renderer=[[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
        UIImage *resized=[renderer imageWithActions:^(UIGraphicsImageRendererContext *context){[image drawInRect:(CGRect){CGPointZero,size}];}];
        NSString *path=[NSTemporaryDirectory() stringByAppendingPathComponent:@"coin-image.png"];
        if (![UIImagePNGRepresentation(resized) writeToFile:path atomically:YES]) { report("image_failed",@"保存图片失败"); return; }
        report("image_selected",path);
    }];
}

-(void)stop {
    self.generation++;
    self.active = NO;
    [self.audio stop];
    if (self.tapped) { [[self.audio inputNode] removeTapOnBus:0]; self.tapped=NO; }
    [self.request endAudio];
    [self.task cancel];
    self.task=nil; self.request=nil; self.audio=nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}
-(void)beginRecording:(NSUInteger)generation {
    if (generation != self.generation) return;
    self.recognizer=[[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    if (!self.recognizer.isAvailable) { [self stop]; report("failed",@"系统中文语音识别暂不可用，请稍后重试。"); return; }
    AVAudioSession *session=[AVAudioSession sharedInstance];
    NSError *error=nil;
    [session setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    [session setActive:YES error:&error];
    if (error) { [self stop]; report("failed",@"无法启用麦克风，请检查系统录音权限。"); return; }
    self.audio=[AVAudioEngine new];
    self.request=[SFSpeechAudioBufferRecognitionRequest new];
    self.request.shouldReportPartialResults=NO;
    if (self.recognizer.supportsOnDeviceRecognition) self.request.requiresOnDeviceRecognition=YES;
    AVAudioInputNode *input=self.audio.inputNode;
    AVAudioFormat *format=[input outputFormatForBus:0];
    if (format.sampleRate<=0 || format.channelCount==0) { [self stop]; report("failed",@"没有可用麦克风，请使用 iPhone 真机。"); return; }
    __weak SlowCoinRecorder *weakSelf=self;
    [input installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer *buffer, AVAudioTime *time) {
        [weakSelf.request appendAudioPCMBuffer:buffer];
    }];
    self.tapped=YES;
    self.active=YES;
    self.task=[self.recognizer recognitionTaskWithRequest:self.request resultHandler:^(SFSpeechRecognitionResult *result, NSError *recognitionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SlowCoinRecorder *owner=weakSelf;
            if (!owner || !owner.active || owner.generation!=generation) return;
            if (result.isFinal) {
                NSString *text=result.bestTranscription.formattedString;
                [owner stop]; report("recognized",text);
            } else if (recognitionError) {
                [owner stop]; report("failed",@"没有听清，或系统语音服务不可用，请重试。");
            }
        });
    }];
    [self.audio prepare];
    if (![self.audio startAndReturnError:&error]) { [self stop]; report("failed",@"麦克风启动失败，请重试。"); return; }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6*NSEC_PER_SEC),dispatch_get_main_queue(),^{
        if (weakSelf.generation==generation && weakSelf.active) { [weakSelf.audio stop]; [weakSelf.request endAudio]; }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 12*NSEC_PER_SEC),dispatch_get_main_queue(),^{
        if (weakSelf.generation==generation && weakSelf.active) { [weakSelf stop]; report("failed",@"识别超时，请重新说一次口令。"); }
    });
}
-(void)listen {
    [self stop];
    NSUInteger generation=self.generation;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation!=self.generation) return;
            if (status!=SFSpeechRecognizerAuthorizationStatusAuthorized) { report("failed",@"请在系统设置中允许语音识别。"); return; }
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (generation!=self.generation) return;
                    if (!granted) { report("failed",@"请在系统设置中允许麦克风权限。"); return; }
                    [self beginRecording:generation];
                });
            }];
        });
    }];
}
@end

void initialize_slow_coin_speech_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    GDREGISTER_CLASS(SlowCoinSpeech);
    bridge=memnew(SlowCoinSpeech);
    Engine::get_singleton()->add_singleton(Engine::Singleton("SlowCoinSpeech",bridge));
}
void uninitialize_slow_coin_speech_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    Engine::get_singleton()->remove_singleton("SlowCoinSpeech");
    memdelete(bridge); bridge=nullptr;
}
