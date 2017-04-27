//
//  TweetCell.h
//  iTwitLine
//
//  Created by Rigo on 26.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *commonTextView;

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *commonText;
@property (nonatomic, strong) UIImage *profileImage;

@end
