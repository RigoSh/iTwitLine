//
//  TwitterViewController.m
//  iTwitLine
//
//  Created by Rigo on 25.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import "TwitterViewController.h"
#import <UIImageView+AFNetworking.h>

#import "TweetObject.h"
#import "AppDelegate.h"
#import "TweetCell.h"

static unsigned int tweetsCount = 10;
static NSString *const kTweetCellID = @"TwitCell_ID";

static NSString *const kRequestUserTweets = @"UserTweets";

// Tweet JSON tags
static NSString *const kTweetID         = @"id_str";
static NSString *const kTweetImageURL   = @"user.profile_image_url_https";
static NSString *const kTweetCompany    = @"user.screen_name";
static NSString *const kTweetNickName   = @"user.name";
static NSString *const kTweetCommonText = @"text";
static NSString *const kTweetCreatedAt  = @"created_at";

// Tweet entity CoreData keys
static NSString *const kTweetEntityName         = @"Tweet";
static NSString *const kTweetEntityTweetID      = @"tweetID";
static NSString *const kTweetEntityUserID       = @"userID";
static NSString *const kTweetEntityNickname     = @"nickname";
static NSString *const kTweetEntityCompany      = @"company";
static NSString *const kTweetEntityCreatedDate  = @"createdDate";
static NSString *const kTweetEntityCommonText   = @"commonText";
static NSString *const kTweetEntityImageURL     = @"imageURL";

@interface TwitterViewController ()

@property (strong, nonatomic) IBOutlet UITableView *twitterTableView;

@end

@implementation TwitterViewController
{
    NSString *_lastTwitID;
    UIRefreshControl *_refreshControl;
    NSMutableArray *_tweetsArray;
    NSTimer *_twitterTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _lastTwitID = nil;
    _tweetsArray = [NSMutableArray array];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshTweetsTable:) forControlEvents:UIControlEventValueChanged];
    [_twitterTableView addSubview:_refreshControl];
    
    [self fetchTweets];
    [self loadTweets];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTweets)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    _twitterTimer = [self newTwitterTimer];
    [[NSRunLoop mainRunLoop] addTimer:_twitterTimer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillEnterForeground
{
    if(_twitterTimer == nil)
    {
        _twitterTimer = [self newTwitterTimer];
        [[NSRunLoop mainRunLoop] addTimer:_twitterTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)applicationDidEnterBackground
{
    [_twitterTimer invalidate];
    _twitterTimer = nil;
}

- (NSTimer *)newTwitterTimer
{
    return [NSTimer timerWithTimeInterval:10
                                   target:self
                                 selector:@selector(loadTweets)
                                 userInfo:nil
                                  repeats:YES];
}

- (void)refreshTweetsTable:(id)sender
{
    [self loadTweets];
    [_refreshControl endRefreshing];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_twitterTimer invalidate];
}

- (void)fetchTweets
{
    NSArray *fetchedTweets = [self fetchTweetsWithUserID:self.twitter.userID];
    if(fetchedTweets && fetchedTweets.count > 0)
    {
        for (id tweet in fetchedTweets)
        {
            TweetObject *tweetObj = [[TweetObject alloc] initWithID:[tweet valueForKey:kTweetEntityTweetID]
                                                         WithUserID:[tweet valueForKey:kTweetEntityUserID]
                                                    WithCreatedDate:[tweet valueForKey:kTweetEntityCreatedDate]
                                                       WithImageURL:[tweet valueForKey:kTweetEntityImageURL]
                                                       WithNickname:[tweet valueForKey:kTweetEntityNickname]
                                                        WithCompany:[tweet valueForKey:kTweetEntityCompany]
                                                     WithCommonText:[tweet valueForKey:kTweetEntityCommonText]];
            
            [_tweetsArray insertObject:tweetObj atIndex:0];
        }
        
        _lastTwitID = ((TweetObject *)[_tweetsArray firstObject]).tweetID;
    }
}

- (void)loadTweets
{
    [_twitter getHomeTimelineSinceID:_lastTwitID
                               count:tweetsCount
                        successBlock:^(NSArray *tweets) {
                            if(tweets.count)
                            {
                                NSLog(@"-- twitts got: %lu", (unsigned long)[tweets count]);
                                
                                for (NSDictionary *tweet in tweets)
                                {
                                    NSDateFormatter *df = [NSDateFormatter st_TwitterDateFormatter];
                                    NSString *createdDateString = tweet[kTweetCreatedAt];
                                    NSDate *createdDate = [df dateFromString:createdDateString];
                                    
                                    TweetObject *newTweet = [[TweetObject alloc] initWithID:tweet[kTweetID]
                                                                                 WithUserID:self.twitter.userID
                                                                            WithCreatedDate:createdDate
                                                                               WithImageURL:[tweet valueForKeyPath:kTweetImageURL]
                                                                               WithNickname:[tweet valueForKeyPath:kTweetNickName]
                                                                                WithCompany:[tweet valueForKeyPath:kTweetCompany]
                                                                             WithCommonText:tweet[kTweetCommonText]];
                                    
                                    [_tweetsArray insertObject:newTweet atIndex:0];
                                    [self saveTweet:newTweet];
                                }
                                
                                _lastTwitID = ((TweetObject *)[_tweetsArray firstObject]).tweetID;
                                [_twitterTableView reloadData];
                            }
                            
                        } errorBlock:^(NSError *error) {
                            NSLog(@"Error getting twitts: %@", [error localizedDescription]);
                        }];
}

- (NSArray *)fetchTweetsWithUserID:(NSString *)userID
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSDictionary *params = @{@"USERID" : userID};
    NSFetchRequest *request = [appDelegate.persistentContainer.managedObjectModel fetchRequestFromTemplateWithName:kRequestUserTweets substitutionVariables:params];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kTweetEntityCreatedDate ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error != nil)
    {
        NSLog(@"Error fetch request: %@", [error localizedDescription]);
        return nil;
    }
    
     NSLog(@"Loading %lu saved tweets", (unsigned long)results.count);
    
    return results;
}

- (void)saveTweet:(TweetObject *)tweet
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSManagedObject *newTweetManagedObject = [NSEntityDescription insertNewObjectForEntityForName:kTweetEntityName inManagedObjectContext:context];
    
    [newTweetManagedObject setValue:tweet.tweetID forKey:kTweetEntityTweetID];
    [newTweetManagedObject setValue:tweet.userID forKey:kTweetEntityUserID];
    [newTweetManagedObject setValue:tweet.nickname forKey:kTweetEntityNickname];
    [newTweetManagedObject setValue:tweet.company forKey:kTweetEntityCompany];
    [newTweetManagedObject setValue:tweet.createdDate forKey:kTweetEntityCreatedDate];
    [newTweetManagedObject setValue:tweet.commonText forKey:kTweetEntityCommonText];
    [newTweetManagedObject setValue:tweet.imageURL forKey:kTweetEntityImageURL];
    
    [appDelegate saveContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tweetsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetCellID forIndexPath:indexPath];
    TweetObject *tweet = (TweetObject *)_tweetsArray[indexPath.row];
   
    cell.nickname = tweet.nickname;
    cell.company = [NSString stringWithFormat:@"@%@", tweet.company];
    cell.commonText = tweet.commonText;
    
    NSURL *iconURL = [NSURL URLWithString:tweet.imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:iconURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60];
    
    __weak TweetCell *weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                       weakCell.profileImage = image;
                                       [weakCell setNeedsLayout];
                                   } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                       NSLog(@"Error: %@", [error localizedDescription]);
                                   }];
    
    return cell;
}

@end
