//
//  TimeLineTableViewController.m
//  Twicchar
//
//  Created by mocchan on 2014/06/17.
//  Copyright (c) 2014年 mocchan.com. All rights reserved.
//

#import "TimeLineTableViewController.h"

@interface TimeLineTableViewController ()

@property (nonatomic) dispatch_queue_t mainQueue;
@property (nonatomic) dispatch_queue_t imageQueue;
@property (nonatomic, copy) NSString *httpErrorMessage;
@property (nonatomic, copy) NSArray *timeLineData;




@end

@implementation TimeLineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.mainQueue =dispatch_get_main_queue();
    self.imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //iOS6以降のカスタムセル再利用パターン
    
    [self.tableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"TimeLineCell"];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"@"/1.1/statuses/home_timeline.json"];//タイムライン取得URL
    
    NSDictionary *params = @{@"count": @"100",//以下パラメタ(optionalなら任意)
                             @"trim_user": @"0",
                             @"include_entitles" : @"0"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter//Twitter
                                            requestMethod:SLRequestMethodGET//メソッドはGET
                                                      URL:url//URLセット
                                               parameters:params];//パラメタセット
    request.account =account;
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;//インジケータON
    
    [request performRequestWithHandler:^(NSData *responseData,
     NSHTTPURLResponse *urlResponse,
     NSError *error) {//ここからは別スレッド
         
         if (responseData){
             self.httpErrorMessage = nil;
             if(urlResponse.statusCode >= 200 && urlResponse.statusCode < 300){//200番台は成功
                 NSError *jsonError;
                 self.timeLineData = [NSJSONSerialization JSONObjectWithData:responseData
                     options:NSJSONReadingAllowFragments
                     error:&jsonError];
                 
                
             if (self.timeLineData){
                 NSLog(@"TimeLIne Response: %@\n",self.timeLineData);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }else{//JSONシリアライズエラー発生時
                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);}
             }else{//HTTPエラー発生時
                 self.httpErrorMessage = [NSString stringWithFormat:@"The response status code is %d", urlResponse.statusCode];
                 NSLog(@"HTTP Error: %@", self.httpErrorMessage);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
            
     } else {//リクエスト送信時エラー発生時
         NSLog(@"ERROR: An error occured while requesting: %@", [error localizedDescription]);//リクエスト時の送信エラーメッセージを画面に表示する領域がない。今後の課題。
     }
     dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *application = [UIApplication sharedApplication];
        application.networkActivityIndicatorVisible = NO;//インジケータOFF
    });
    
     }];
}

- (NSAttributedString *)labelAttributedString:(NSString *)labelString//ラベル文字列を属性付きに変換
    {
        //ラベル文字列
        NSString *text = (labelString == nil) ? @"" : labelString;//三項演算子のサンプルとしての　普通のif文で可
        
        //フォント
        UIFont *font = [UIFont fontWithName:@"HirakakuProN-W3" size:13];
        
        
        //カスタムLineHeightを指定
        CGFloat customLineHeight = 19.5f;
        
        //パラグラフスタイルにlineHeightをセット
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = customLineHeight;
        paragraphStyle.maximumLineHeight = customLineHeight;
        
        //属性としてパラグラフスタイルとフォントをセット
        NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:font};
        
        
        //NSAttributedStringを生成して文字列と属性をセット
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
        
        return attributedText;
    }


- (CGFloat)labelHeight:(NSAttributedString *)attributedText;//属性付きテキストからラベルの高さを求める
{
    
    //ラベルの高さ
    CGFloat aHeight = [attributedText boundingRectWithSize:CGSizeMake(257, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    return aHeight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!self.timeLineData) {//レスポンス取得前のtimeLineDataがない
        return 1;
    } else {
        return self.timeLineData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //ios6以降のカスタムセル採用パターン
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLineCell"forIndexPath:indexPath];
{
    // Configure the cell...
    if(self.httpErrorMessage){//このif文は重要
        
        cell.tweetTextLabel.text = @"HTTP Error";//HTTPエラー時にはここにメッセージを表示
        
        cell.tweetTextLabelHeight = 24.0;
        
    } else if (!self.timeLineData){//レスポンス取得前はtimeLineDataがない
        
        cell.tweetTextLabel.text = @"Loading....";
        
        cell.tweetTextLabelHeight = 24.0;
        
    } else {
        
        NSString *tweetText = self.timeLineData[indexPath.row] [@"text"];
                               NSAttributedString *attributedTweetText = [self labelAttributedString:tweetText];
        //ツイート本文を属性付きテキストに変換して表示
                               cell.tweetTextLabel.attributedText = attributedTweetText;
                               cell.nameLabel.text = self.timeLineData[indexPath.row][@"user"][@"screen_name"];
                               cell.profileImageView.image = [UIImage imageNamed:@"black.png"];
                               cell.tweetTextLabelHeight = [self labelHeight:attributedTweetText];//ラベルの高さを計算
        dispatch_async(self.imageQueue, ^{
            NSString *url;
            NSDictionary *tweetDicitionary = [self.timeLineData objectAtIndex:indexPath.row];
            
            if ([[tweetDicitionary allKeys] containsObject:@"retweeted_status"]){
                //リツィートの場合はretweeted_statusキー項目が存在する
                
                url = tweetDicitionary[@"retweeted_status"][@"user"][@"profile_image_url"];
                //リツィート元のユーザーのプロフィール画像URLを表示
                
            } else {
                url = tweetDicitionary[@"user"][@"profile_image_url"];
                //通常は発信者のプロフィール画像URLを取得

            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            //プロフィール画像取得
            
            dispatch_async(self.mainQueue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                UIImage *image =[[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout];
            });
        });
}
    return cell;
}
}

    - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        
        NSString *tweetText = self.timeLineData[indexPath.row][@"text"];
        NSAttributedString *attributedTweetText = [self labelAttributedString:tweetText];
        CGFloat tweetTextLabelHeight = [self labelHeight:attributedTweetText];//ラベルの高さを計算
        
        return tweetTextLabelHeight + 35;//セルのツィート本文ラベル以外の高さが合計で35ピクセル
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    DetailViewController *detailViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.name = cell.nameLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = self.timeLineData[indexPath.row][@"id_str"];
    [self.navigationController pushViewController:detailViewController animated:YES];

    
}


/*

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
@end
