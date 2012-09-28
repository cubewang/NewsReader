//
//  BubbleTableView.h
//  iKnow
//
//  Created by curer on 11-7-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BubbleTableViewDelegate <NSObject>
-(void) BubbleTableViewBeginTouches;
@end

@interface BubbleTableView : UITableView {
}

@end
