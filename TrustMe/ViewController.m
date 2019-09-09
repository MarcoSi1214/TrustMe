//
//  ViewController.m
//  TrustMe
//
//  Created by Marco Simonelli on 10/11/18.
//  Copyright © 2018 Marco Simonelli. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/CAGradientLayer.h>
@implementation ViewController
@synthesize URLField;
@synthesize checkButtonOut;
@synthesize descriptionField;
@synthesize backButtonOut;
@synthesize progressIndicator;
@synthesize titleLabel;

NSMutableArray *returnArray;
NSString *returnData;

int i = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _outputBox.alphaValue = 0;
    _outputBox.hidden = true;
    
    backButtonOut.enabled = false;
    backButtonOut.alphaValue = 0;
    
    progressIndicator.alphaValue = 0;
    
    
    // Do any additional setup after loading the view.
}

- (IBAction)checkButton:(NSButton *)sender {
    
    
    NSString *URL = [URLField stringValue];
    
    checkButtonOut.enabled = false;
    URLField.enabled = false;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.5;
        self->checkButtonOut.animator.alphaValue = 0;
        self->URLField.animator.alphaValue = 0;
        self->descriptionField.animator.alphaValue = 0;
        self->progressIndicator.animator.alphaValue = 1;
        self->titleLabel.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self->checkButtonOut.alphaValue = 0;
                            self->URLField.alphaValue = 0;
                            self->descriptionField.alphaValue = 0;
                            self->progressIndicator.alphaValue = 1;
                            self->titleLabel.alphaValue = 0;

                        }];
    [self.progressIndicator startAnimation:nil];
    
    if ([URL hasPrefix:@"https://"]) {
        
        URL = [URL substringFromIndex:8];
        
    } else if ([URL hasPrefix:@"http://"]) {
        
        URL = [URL substringFromIndex:7];
    }
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *handler = pipe.fileHandleForReading;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"trustcheck" ofType:@"sh"];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[path, URL];
    task.standardOutput = pipe;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thereIsData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:handler];


    
    [handler waitForDataInBackgroundAndNotify];
    [task launch];
        
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (void)thereIsData:(NSNotification *)notification {
    /*const CGFloat fontSize = 19;
    NSDictionary *attrs = @{
     
     NSFontAttributeName:[NSFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName:[NSColor blueColor]
                            };
    NSDictionary *subAttrs = @{
                               NSFontAttributeName:[NSFont systemFontOfSize:fontSize]
                               };*/
    if (i == 5) {
        returnData = [[NSString alloc] initWithData:[notification.object availableData] encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", returnData);
        
        
       /*
        NSRange range1 = [returnData rangeOfString:@"You requested a site from the following organisation:"];
        NSRange range2 = [returnData rangeOfString:@"You received a site from the following organisations:"];
        NSRange range3 = [returnData rangeOfString:@"You requested a site from the following location:"];
        NSRange range4 = [returnData rangeOfString:@"You received a site from the following location:"];
        
        NSUInteger returnLength = returnData.length;
        
        NSMutableAttributedString *attributedText;
        
        unichar buffer[returnLength+1];
        
        [returnData getCharacters:buffer range:NSMakeRange(0, returnLength)];
        
        NSLog(@"%d,%d,%d,%d",(int)range1.location,(int)range2.location,(int)range3.location,(int)range4.location);
        for (int i = 0; i < returnLength; i++) {
            if (((i > range1.location ) && (i < range1.location + 53 ))
                || ((i > range2.location ) && (i < range2.location + 53 ))
                || ((i > range3.location ) && (i < range3.location + 49 ))
                || ((i > range4.location ) && (i < range4.location + 48 ))) {
                NSLog(@"%d", i);
                [attributedText beginEditing];
                attributedText =
                [[NSMutableAttributedString alloc] initWithString:returnData
                                                       attributes:attrs];
                [attributedText setAttributes:attrs range:NSMakeRange(i, 1)];
                [attributedText endEditing];

            } else {
                [attributedText beginEditing];
                attributedText =
                [[NSMutableAttributedString alloc] initWithString:returnData
                                                       attributes:subAttrs];
                [attributedText setAttributes:attrs range:NSMakeRange(i, 1)];
                [attributedText endEditing];

            }
        }*/
        
        //_outputBox.attributedStringValue = attributedText;
        _outputBox.stringValue = returnData;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.2;
            self->progressIndicator.animator.alphaValue = 0;
        }
                            completionHandler:^{
                                self->progressIndicator.animator.alphaValue = 0;
                            }];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.5;
            self->_outputBox.animator.alphaValue = 1;
            self->_outputBox.hidden = false;
            self->backButtonOut.enabled = true;
            self->backButtonOut.animator.alphaValue = 1;
        }
                            completionHandler:^{
                                self->_outputBox.alphaValue = 1;
                                self->_outputBox.hidden = false;
                                self->backButtonOut.enabled = true;
                                self->backButtonOut.alphaValue = 1;
                                self->progressIndicator.animator.alphaValue = 0;
                            }];
        
        
        [notification.object readToEndOfFileInBackgroundAndNotify];
        i--;
    }

    
    return;
}
- (IBAction)backButton:(NSButton *)sender {
    
    checkButtonOut.enabled = true;
    URLField.enabled = true;
    
    URLField.stringValue = @"";
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.5;
        self->_outputBox.animator.alphaValue = 0;
        self->_outputBox.hidden = true;
        self->backButtonOut.enabled = false;
        self->backButtonOut.animator.alphaValue = 0;
        self->checkButtonOut.animator.alphaValue = 1;
        self->URLField.animator.alphaValue = 1;
        self->descriptionField.animator.alphaValue = 1;
        self->titleLabel.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self->_outputBox.alphaValue = 0;
                            self->_outputBox.hidden = true;
                            self->backButtonOut.enabled = false;
                            self->backButtonOut.alphaValue = 0;
                            self->checkButtonOut.alphaValue = 1;
                            self->URLField.alphaValue = 1;
                            self->descriptionField.alphaValue = 1;
                            self->titleLabel.alphaValue = 1;
                        }];
    i = 5;
}

@end
