//
//  ViewController.h
//  SiriDemo
//
//  Created by Bharat Mahajan on 9/11/17.
//  Copyright © 2017 Collabera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Speech/Speech.h>

@interface ViewController : UIViewController<SFSpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;

@end

