/*
 *  GlobalDef.h
 *  iKnow
 *
 *  Created by Cube on 11-7-12.
 *  Copyright 2011 iKnow Team. All rights reserved.
 *
 */

//当前设备的屏幕宽度
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width

//当前设备的屏幕高度
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//iPad文章列表的宽度
#define ARTICLE_AREA_WIDTH_IPAD   568


//iKnow默认背景颜色
#define CELL_BACKGROUND  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]

//导航条文字颜色
#define GUIDE_VIEW_COLOR [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1.0]

//导航条文字颜色
#define NAVIGATION_TEXT_COLOR [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]

//辅助文字颜色
#define LIGHT_TEXT_COLOR [UIColor colorWithRed:101.0/255.0 green:107.0/255.0 blue:101.0/255.0 alpha:1.0]

//蓝色字体颜色
#define BLUE_TEXT_COLOR [UIColor colorWithRed:39.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0]

//用户选中反馈颜色
#define SELECTED_BACKGROUND [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]

//用户选中反馈颜色
#define TAG_SELECTED_BACKGROUND [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0]

//官方回复颜色
#define OFFICIAL_COLOR [UIColor colorWithRed:255.0/255.0 green:155.0/255.0 blue:57.0/255.0 alpha:1.0]

#define NAV_BAR_ITEM_COLOR [UIColor darkGrayColor]

//STYLE
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]


#define ZBSTYLE_font ([UIFont systemFontOfSize:14])
#define ZBSTYLE_font_smaller ([UIFont systemFontOfSize:12])
#define ZBSTYLE_tableFont ([UIFont boldSystemFontOfSize:17])
#define ZBSTYLE_highlightedTextColor ([UIColor whiteColor])
#define ZBSTYLE_tableSubTextColor (RGBCOLOR(79, 89, 105))
#define ZBSTYLE_textColor ([UIColor blackColor])

#define English_font_des ([UIFont fontWithName:@"Georgia" size:15])
#define English_font_title ([UIFont fontWithName:@"Georgia-Bold" size:17])
#define English_font_body ([UIFont fontWithName:@"Georgia" size:15])

#define English_font_des_iPad ([UIFont fontWithName:@"Georgia" size:17])
#define English_font_title_iPad ([UIFont fontWithName:@"Georgia-Bold" size:19])
#define English_font_body_iPad ([UIFont fontWithName:@"Georgia" size:17])

#define kTableCellSmallMargin   6.0f
#define kTableCellSpacing       8.0f
#define kTableCellMargin        10.0f
#define kTableCellHPadding      10.0f
#define kTableCellVPadding      10.0f

//字符串
#define SAFE_STRING(str) ([(str) length] ? (str) : @"")
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define ENABLE_SDWEBIMAGE_DECODER

