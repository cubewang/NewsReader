//
//  BubbleTableView.m
//  iKnow
//
//  Created by curer on 11-7-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "BubbleTableView.h"


@implementation BubbleTableView


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event]; 
    
    if ([self.delegate respondsToSelector:@selector(BubbleTableViewBeginTouches)]) {
       [self.delegate BubbleTableViewBeginTouches]; 
    }
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    
    [super dealloc];
}


@end
