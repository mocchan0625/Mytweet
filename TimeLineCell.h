//
//  TimeLineCell.h
//  Twicchar
//
//  Created by mocchan on 2014/06/17.
//  Copyright (c) 2014年 mocchan.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineCell : UITableViewCell

@property (nonatomic, strong) UILabel *tweetTextLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic) CGFloat tweetTextLabelHeight;

@end
