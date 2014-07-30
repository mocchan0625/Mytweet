//
//  ViewController.m
//  Twicchar
//
//  Created by mocchan on 2014/06/17.
//  Copyright (c) 2014年 mocchan.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *accountDisplayLabel;

@property (weak, nonatomic) IBOutlet UIButton *tweetActionButton;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray *twitterAccounts;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:^(BOOL granted, NSError *error){
        if (granted){ //認証成功時
            self.twitterAccounts = [self.accountStore accountsWithAccountType:twitterType];
            if(self.twitterAccounts.count > 0){//アカウントが一つ以上あれば
                ACAccount *account = self.twitterAccounts[0];//とりあえず先頭のアカウントをセット
                self.identifier = account.identifier;//このidentifierを持ち出す
                dispatch_async(dispatch_get_main_queue(), ^{self.accountDisplayLabel.text = account.username;//UI処理はメインキューで
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.accountDisplayLabel.text = @"アカウントなし";
                });
            }
        } else { //認証失敗時
            NSLog(@"Account Error: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.accountDisplayLabel.text = @"アカウント認証エラー";
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (IBAction)tweet:(id)sender {
    //最小限のtweet
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){//利用チェック
        NSString *serviceType = SLServiceTypeTwitter;
        SLComposeViewController *composeCtl = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeCtl setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone){
                //投稿時の処理
                NSLog(@"投稿成功");
             }
        }];
        [self presentViewController:composeCtl animated:YES completion:nil];
    }
}
- (IBAction)setAccountAction:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    
    sheet.title = @"選択してください";
    for (ACAccount *account in self.twitterAccounts){//アカウントの数だけ繰り返す（高速列挙）
        [sheet addButtonWithTitle:account.username];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
    sheet.cancelButtonIndex = self.twitterAccounts.count;//アカウントの数が最後のボタンのindex
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.twitterAccounts.count > 0){//アカウントが一つ以上あれば
        if (buttonIndex != self.twitterAccounts.count){//キャンセルボタンのindexでなければ
            ACAccount *account = self.twitterAccounts[buttonIndex];//ボタンのindexアカウント
            self.identifier = account.identifier;//identifierをセット
            self.accountDisplayLabel.text = account.username;
            NSLog(@"Account set! %@", account.username);//デバック用の表示
        }else{
            NSLog(@"cancel!");//デバック用の表示
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"timeLineSegue"]){//セグエのidを確認
        TimeLineTableViewController *timeLineVC = segue.destinationViewController;
        if ([timeLineVC isKindOfClass:[TimeLineTableViewController class]]){
            timeLineVC.identifier = self.identifier;//アカウントidを持ち出す
        }
    }
}

@end
