/*
  InputAlertView.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InputAlertViewDelegate.h"

/*
 Alert View with a built-in mechanism for grabbing input .
 The base alert view actually has a built-in text field,
 but adding it requires using a private API call, so subclassing
 here is necessary
 */
 
@interface InputAlertView : UIAlertView
<UIAlertViewDelegate, UITextFieldDelegate>
{
    UITextField                 *_textField;
    id<InputAlertViewDelegate>  _inputViewDelegate;
    
    BOOL                        _firstTimeLayingOutSubViews;
    UIInterfaceOrientation      _currentOrientation;
}

@property (nonatomic, retain) UITextField                   *textField;
@property (nonatomic, assign) id<InputAlertViewDelegate>    inputViewDelegate;

+(InputAlertView *)inputAlertViewWithTitle:(NSString *)title
                    initialFieldText:(NSString *)text delegate:(id<InputAlertViewDelegate>)delegate;

@end
