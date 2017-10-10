//
//  ViewController.m
//  SiriDemo
//
//  Created by Bharat Mahajan on 9/11/17.
//  Copyright © 2017 Collabera. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    audioEngine = [[AVAudioEngine alloc] init];
    self.btnRecord.enabled = false;
    self.txtView.text = @"Say something, I'm listening";

    speechRecognizer.delegate = self;

    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isButtonEnabled;
        
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
            {
                isButtonEnabled = true;
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
            {
                isButtonEnabled = false;
                NSLog(@"User denied access to speech recognition");
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
            {
                isButtonEnabled = false;
                NSLog(@"Speech recognition restricted on this device");
            }
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            {
                isButtonEnabled = false;
                NSLog(@"Speech recognition not yet authorized");
            }
                break;
            default:
                break;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.btnRecord.enabled = isButtonEnabled;
        }];
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnRecordClicked:(UIButton *)sender {
    if ([audioEngine isRunning]) {
        [audioEngine stop];
        [recognitionRequest endAudio];
        self.btnRecord.enabled = false;
        [self.btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
    }
    else{
        [self startRecording];
        [self.btnRecord setTitle:@"Stop Recording" forState:UIControlStateNormal];
    }
}


-(void)startRecording {
    if (recognitionTask!=nil) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
        @try {
            [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
            [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
            [audioSession setActive:TRUE withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        }
    
        @catch (NSException *exception) {
            NSLog(@"audioSession properties weren't set because of an error.");
        }
    
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    id inputNode = audioEngine.inputNode;
    
    if (inputNode == nil) {
        [NSException raise:@"Audio Engine issue" format:@"Audio engine has no input node"];
    }
    
    if (recognitionRequest == nil) {
        [NSException raise:@"Recognition request issue" format:@"Unable to create an SFSpeechAudioBufferRecognitionRequest object"];
    }
    
    [recognitionRequest setShouldReportPartialResults:TRUE];
    
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = FALSE;
        if (result!=nil) {
            NSLog(@"%@",result.bestTranscription.formattedString);
            NSString *strSpeech = result.bestTranscription.formattedString.lowercaseString;
            if ([strSpeech containsString:@"clear text"]) {
                self.txtView.text = @"";
            }
            
            else
            {
            self.txtView.text = result.bestTranscription.formattedString;
            }
            isFinal = result.isFinal;
        }
        
        if (error!=nil || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            
            recognitionRequest = nil;
            recognitionTask = nil;
            
            self.btnRecord.enabled = true;
        }
    }];
    
    id recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [audioEngine prepare];
    
    @try {
        [audioEngine startAndReturnError:nil];
    } @catch (NSException *exception) {
        [NSException raise:@"Audio Engine issue" format:@"Audio engine could not start because of error."];
    }
    
    self.txtView.text = @"Say something, I'm listening";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
