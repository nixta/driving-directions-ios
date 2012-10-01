//
//  ToggleSegmentedControl.m
//  Map
//
//  Created by Scott Sirowy on 12/7/11.
//  Copyright (c) 2011 ESRI. All rights reserved.
//

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

/*-(void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    // Trigger UIControlEventValueChanged even when re-tapping the selected segment.
    if (selectedSegmentIndex==self.selectedSegmentIndex) {
        [super setSelectedSegmentIndex:UISegmentedControlNoSegment]; // notify first
        //[self sendActionsForControlEvents:UIControlEventValueChanged]; // then unset
    } else {
        [super setSelectedSegmentIndex:selectedSegmentIndex]; 
    }
}  */

@end
