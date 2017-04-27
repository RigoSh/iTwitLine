//
//  TweetCell.m
//  iTwitLine
//
//  Created by Rigo on 26.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNickname:(NSString *)nickname
{
    _nicknameLabel.text = nickname;
}

- (void)setCompany:(NSString *)company
{
    _companyLabel.text = company;
}

- (void)setCommonText:(NSString *)commonText
{
    _commonTextView.text = commonText;
}

- (void)setProfileImage:(UIImage *)profileImage
{
    _profileImageView.image = profileImage;
}

@end
