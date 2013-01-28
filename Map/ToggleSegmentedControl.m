/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "ToggleSegmentedControl.h"

@implementation ToggleSegmentedControl

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    NSInteger current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (current == self.selectedSegmentIndex){
        [self setSelectedSegmentIndex:UISegmentedControlNoSegment];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
