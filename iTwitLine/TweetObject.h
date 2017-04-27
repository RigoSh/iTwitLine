//
//  TweetObject.h
//  iTwitLine
//
//  Created by Михаил on 26.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetObject : NSObject

@property (nonatomic, copy) NSString *tweetID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *commonText;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSDate   *createdDate;

- (id)initWithID:(NSString *)tweetID WithUserID:(NSString *)userID WithCreatedDate:(NSDate *)createdDate WithImageURL:(NSString *)imageURL WithNickname:(NSString *)nickname WithCompany:(NSString *)company WithCommonText:(NSString *)commonText;

@end
