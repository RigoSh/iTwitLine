//
//  TweetObject.m
//  iTwitLine
//
//  Created by Михаил on 26.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import "TweetObject.h"

@implementation TweetObject

- (id)initWithID:(NSString *)tweetID WithUserID:(NSString *)userID WithCreatedDate:(NSDate *)createdDate WithImageURL:(NSString *)imageURL WithNickname:(NSString *)nickname WithCompany:(NSString *)company WithCommonText:(NSString *)commonText
{
    if(self = [super init])
    {
        _tweetID = tweetID;
        _userID = userID;
        _createdDate = createdDate;
        _imageURL = imageURL;
        _nickname = nickname;
        _company = company;
        _commonText = commonText;
    }
    
    return self;
}

@end
