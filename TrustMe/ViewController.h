//
//  ViewController.h
//  TrustMe
//
//  Created by Marco Simonelli on 10/11/18.
//  Copyright © 2018 Marco Simonelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *URLField;

@property (weak) IBOutlet NSButton *checkButtonOut;
@property (weak) IBOutlet NSTextField *descriptionField;
@property (weak) IBOutlet NSTextField *outputBox;

@property (weak) IBOutlet NSButton *backButtonOut;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *titleLabel;


extern NSMutableArray *returnArray;
extern NSString *returnData;
@end

