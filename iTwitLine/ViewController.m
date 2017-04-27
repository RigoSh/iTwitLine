//
//  ViewController.m
//  iTwitLine
//
//  Created by Rigo on 25.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import "ViewController.h"
#import <STTwitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

static NSString *const kTwitterSegueID = @"TwitterLine_ID";
static NSString *const kRequestExpiredTweets = @"ExpiredTweets";

@interface ViewController () <STTwitterAPIOSProtocol>

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;

@property (weak, nonatomic) IBOutlet UILabel *loginStatusLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
    self.accountStore = [[ACAccountStore alloc] init];
    [self deleteExpiredTweets];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender
{
    _loginStatusLabel.text = @"Autorisation via iOS account in Twitter!";
    
    [self chooseAccount];
}

- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        _loginStatusLabel.text = [NSString stringWithFormat:@"Last autorized in account: @%@ \nid=%@", username, userID];
        
        [self showTwitterLine];
        
    } errorBlock:^(NSError *error) {
        _loginStatusLabel.text = [error localizedDescription];
    }];
    
}

- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO)
            {
                _loginStatusLabel.text = @"Account access in Twitter denied.";
                
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            ACAccount *account = [_iOSAccounts lastObject];
            
            _loginStatusLabel.text = [NSString stringWithFormat:@"Chosen Twitter account: %@", account.username];
            [self loginWithiOSAccount:account];
        }];
    };
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
}

- (void)showTwitterLine
{
    [self performSegueWithIdentifier:kTwitterSegueID sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kTwitterSegueID])
    {
        UIViewController *destController = [segue destinationViewController];
        
        SEL selector = NSSelectorFromString(@"twitter");
        
        if([destController respondsToSelector:selector])
        {
            [destController setValue:_twitter forKey:@"twitter"];
        }
    }
}

- (void)deleteExpiredTweets
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSDictionary *params = @{@"DATE" : [[NSDate date] dateByAddingTimeInterval: -60*60*24*7]};     // 7 days
    NSFetchRequest *request = [appDelegate.persistentContainer.managedObjectModel fetchRequestFromTemplateWithName:kRequestExpiredTweets substitutionVariables:params];
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request
                                              error:&error];
    NSUInteger tweetsCount = results.count;
    
    if(error == nil)
    {
        for (NSManagedObject *object in results)
        {
            [context deleteObject:object];
        }
        
        [appDelegate saveContext];
        
        NSLog(@"Expired tweets deleted: %lu", (unsigned long)tweetsCount);
    }
    else
    {
        NSLog(@"Error fetch request: %@", [error localizedDescription]);
    }
}

#pragma mark [STTwitterAPIOSProtocol]

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount
{
    if(twitterAPI != _twitter) return;
    NSLog(@"-- account was invalidated: %@ | %@", invalidatedAccount, invalidatedAccount.username);
}

@end
