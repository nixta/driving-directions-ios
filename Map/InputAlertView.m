/*
  InputAlertView.m
  ArcGISMobile

 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import "InputAlertView.h"
#import "ArcGIS+App.h"

//private methods
@interface InputAlertView ()

-(void)prepareWithPlaceholder:(NSString *)placeholder;

@end

@implementation InputAlertView

#define kOKButton 1

@synthesize textField= _textField;
@synthesize inputViewDelegate= _inputViewDelegate;

//class method that returns an autoreleased inputAlerView
+(InputAlertView *)inputAlertViewWithTitle:(NSString *)title
                    initialFieldText:(NSString *)text delegate:(id<InputAlertViewDelegate>)delegate
{
    InputAlertView *_alert = [[[self alloc] 
                            initWithTitle:title 
                            message:@"\n" delegate:nil 
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                            otherButtonTitles:NSLocalizedString(@"OK", nil), nil] 
                            autorelease];

    _alert.delegate = _alert;
    _alert.inputViewDelegate = delegate;
    [_alert prepareWithPlaceholder:text];
    return _alert;
}

//called when device is rotated. The textfield must be adjusted when switched
//to and from landscape
-(void)layoutSubviews
{
    [super layoutSubviews];
        
    self.textField.frame = CGRectMake(12, self.bounds.size.height - 88.0, self.bounds.size.width-24, 28.0);
}

//overridden method that handles calling delegate methods for the input alert view
//if a delegate responds to the methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //they pressed OK
    if (buttonIndex == kOKButton) {
        if([self.inputViewDelegate respondsToSelector:@selector(inputAlerViewDidDismissWithText:)])
        {
            [self.inputViewDelegate inputAlerViewDidDismissWithText:self.textField.text]; 
        }
    }
    //canceled
    else
    {
        if([self.inputViewDelegate respondsToSelector:@selector(inputAlertViewDidCancel)])
        {
            [self.inputViewDelegate inputAlertViewDidCancel];  
        }
    }
}

//Adds the textfield, and sets it properties accordingly
-(void)prepareWithPlaceholder:(NSString *)placeholder;
{
    UITextField *bookmarkField = [[UITextField alloc] initWithFrame:CGRectMake(12.0,45,260.0,28.0)];
    bookmarkField.backgroundColor = [UIColor clearColor];
    bookmarkField.borderStyle = UITextBorderStyleRoundedRect;
    bookmarkField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    bookmarkField.placeholder = placeholder;
    bookmarkField.delegate = self;
    self.textField = bookmarkField;
    [self addSubview:bookmarkField];
    [bookmarkField release];
    
    //on ios 5 devices textfield shows up as clear. Need to explicitly
    //set background color so its viewable
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        self.textField.backgroundColor = [UIColor whiteColor];
    }
    
    //layout subviews will automatically get called, 
    //and boolean is used to alter behavior first time its called
    _firstTimeLayingOutSubViews = YES;
    
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] > 4.0)) {
        //This is for iOS versions below 4.0
        self.transform = CGAffineTransformMakeTranslation(0.0f, 70.0f);
    } else {
        //This is for iOS4.0+
        self.transform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    }
}

//override show method to make the alert views text field
//the first responder
-(void)show
{
    [self.textField becomeFirstResponder];
    [super show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)dealloc
{
    self.textField = nil;
    [super dealloc];
}

@end
