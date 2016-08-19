//
//  ViewController.m
//  recept
//
//  Created by 徐常璿 on 2016/7/20.
//  Copyright © 2016年 Eric Hsu. All rights reserved.
//
#import "ViewController.h"
#import <Ono.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import "Reachability.h"
#import "SegViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
@import GoogleMobileAds;

@interface ViewController ()<UITextFieldDelegate>
{
    NSMutableArray * priceNumber;
    NSString * inputText;
    NSString * newMonth;
    NSString * priceDate;
    Reachability *serverReach;
    int index;
    BOOL isFail;
}

@property (weak, nonatomic) IBOutlet UILabel *monthText;
@property (strong, nonatomic) IBOutlet UITextField *inputTextfield;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self adMob];
    isFail = false;
    index = 0;
    
    inputText = [NSString new];
    _inputTextfield.delegate = self;
    
    // Prepare serverReach
    serverReach = [Reachability reachabilityWithHostName:@"http://invoice.etax.nat.gov.tw/"];
    [serverReach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged) name:kReachabilityChangedNotification object:nil];
    
    [self parseHtml];
    
}

-(void)networkStatusChanged{
    NetworkStatus status = [serverReach currentReachabilityStatus];
    if(status == NotReachable){
        NSLog(@"Network not available");
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"第一次請開啟網路" message:@"請開啟網路功能" preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            NSLog(@"點擊確定按鈕");
        }]];
        
        
        [self presentViewController:alert animated:true completion:nil];
    }else{
        NSLog(@"Network is on");
            [self parseHtml];

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parseHtml {
    
            //*[@id="area1"]/table/tbody/tr[2]/td[1]
            //*[@id="area1"]/table
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    [manager GET:@"http://invoice.etax.nat.gov.tw/" parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {

        ONOXMLElement *postsParentElement= [responseDocument firstChildWithXPath:@"//*[@id='area1']"]; //寻找该 XPath 代表的 HTML 节点,
        //遍历其子节点,
//        NSLog(@"%@",postsParentElement);
        [postsParentElement.children enumerateObjectsUsingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"%@",element);
            
            ONOXMLElement *titleElement= [element firstChildWithXPath:@"tr[2]/td[2]/span"];             NSString * title= [titleElement stringValue];
            
            if(title != nil){
//                NSLog(@"title:%@",title);
                priceNumber = [NSMutableArray new];
                [priceNumber addObject:title];
//                NSLog(@"Array:%@",priceNumber);
            }
            //*[@id="area1"]/table/tbody/tr[3]/td[2]/span
            
            ONOXMLElement *secondElement= [element firstChildWithXPath:@"tr[3]/td[2]/span"];             NSString * secondNumber= [secondElement stringValue];
            
            if(secondNumber != nil){
//                NSLog(@"second:%@",secondNumber);
                [priceNumber addObject:secondNumber];
//                NSLog(@"Array:%@",priceNumber);
            }
            
            //*[@id="area1"]/table/tbody/tr[4]/td[2]/span
            
            ONOXMLElement *thirdElement= [element firstChildWithXPath:@"tr[4]/td[2]/span"];             NSString * thirdNumber= [thirdElement stringValue];
            
            if(thirdNumber != nil){
//                NSLog(@"third:%@",thirdNumber);
                //把陣列裡三個數字拆成三個
                NSArray *strArray = [thirdNumber componentsSeparatedByString:@"、"];
//                NSLog(@"strArray%@",strArray);
                NSString * str1 = strArray[0];
                [priceNumber addObject:str1];
                NSString * str2 = strArray[1];
                [priceNumber addObject:str2];
                NSString * str3 = strArray[2];
                [priceNumber addObject:str3];
//                NSLog(@"Array:%@",priceNumber);
            }
            
            //*[@id="area1"]/table/tbody/tr[10]/td[2]/span
            ONOXMLElement *sixElement= [element firstChildWithXPath:@"tr[10]/td[2]/span"];
            NSString * UltraSix= [sixElement stringValue];
            if (UltraSix != nil) {
//                NSLog(@"UltraSix:%@",UltraSix);
                [priceNumber addObject:UltraSix];
//                NSLog(@"Array:%@",priceNumber);
            }
            
            //*[@id="area1"]/h2[2]
            //*[@id="area1"]/p
            ONOXMLElement * monthElement = [element firstChildWithXPath:@"//*[@id='area1']/h2[2]"];
           newMonth = [monthElement stringValue];
//            NSLog(@"month:%@",month);
            
            ONOXMLElement * priceDate1 = [element firstChildWithXPath:@"//*[@id='area1']/p"];
            priceDate = [priceDate1 stringValue];
//            NSLog(@"priceDate:%@",priceDateString);
        }];
        
        
        NSLog(@"特別獎:%@ 特獎:%@ 頭獎:%@,%@,%@ 增開六獎:%@" ,priceNumber[0],priceNumber[1],priceNumber[2],priceNumber[3],priceNumber[4],priceNumber[5]);
        NSLog(@"month:%@",newMonth);
        NSLog(@"priceDate:%@",priceDate);
        _monthText.text = newMonth;
        
        [self resetDefaults];
        
        NSArray * priceArray = [[NSArray alloc]initWithArray:priceNumber];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:priceArray    forKey:@"priceArray"];
        [userDefaults setObject:newMonth forKey:@"month"];
        [userDefaults synchronize];
        
        NSLog(@"test:%@",priceNumber);
        NSLog(@"NSUserDefault:%@",[userDefaults objectForKey:@"priceArray"]);
        
        } failure:nil];
    
}
- (IBAction)Btn1Pressed:(id)sender {
    NSString * number1 = @"1";
    
    
    [self append:number1];
    [self buttonClickedEvent];
}
- (IBAction)Btn2Pressed:(id)sender {
     NSString * number2 = @"2";
   
    [self append:number2];
    [self buttonClickedEvent];

    
}
- (IBAction)Btn3Pressed:(id)sender {
    NSString * number3 = @"3";
    
    
    [self append:number3];
    [self buttonClickedEvent];

}
- (IBAction)Btn4Pressed:(id)sender {
    NSString * number4 = @"4";
    
    
    [self append:number4];
    [self buttonClickedEvent];

}
- (IBAction)Btn5Pressed:(id)sender {
    NSString * number5 = @"5";
    
    [self append:number5];
    [self buttonClickedEvent];

}
- (IBAction)Btn6Pressed:(id)sender {
    NSString * number6 = @"6";
    

    [self append:number6];
    [self buttonClickedEvent];

}
- (IBAction)Btn7Pressed:(id)sender {
    NSString * number7 = @"7";
    
    
    [self append:number7];
    [self buttonClickedEvent];
}

- (IBAction)Btn8Pressed:(id)sender {
    NSString * number8 = @"8";
    
    
    [self append:number8];
    [self buttonClickedEvent];
}
- (IBAction)Btn9Pressed:(id)sender {
    NSString * number9 = @"9";
    
   
    [self append:number9];
    [self buttonClickedEvent];
}
- (IBAction)Btn0Pressed:(id)sender {
    NSString * number0 = @"0";
    
    
    [self append:number0];
    [self buttonClickedEvent];
    
}
- (IBAction)BtnBackPressed:(id)sender {
    if ([inputText length] != 0) {
        inputText = [inputText substringToIndex:([inputText length]-1)];
        _inputTextfield.text = inputText;
        if (index <=0){
        index = 0;
        }else{
            index -= 1;
        }
    }
    
   }

- (IBAction)BtnClearPressed:(id)sender {
    inputText = [inputText substringToIndex:([inputText length] == 1)];
    _inputTextfield.text = inputText;
    index = 0;
    
}

- (IBAction)BtnComparePressed:(id)sender {
    
    NSLog(@"number:%@",priceNumber[5]);
    NSLog(@"inputtext :%@",inputText);
    
    NSString * priceNumberLast3 = [priceNumber[2] substringFromIndex:5];
    NSString * priceNumber1Last3 = [priceNumber[3] substringFromIndex:5];
    NSString * priceNumber2Last3 = [priceNumber[4] substringFromIndex:5];
    NSLog(@"priceNumberLast3 :%@,%@,%@",priceNumberLast3,priceNumber1Last3,priceNumber2Last3);
    
    
    
    if([priceNumber[5] isEqualToString:inputText] || [priceNumberLast3 isEqualToString:inputText]
       || [priceNumber1Last3 isEqualToString:inputText] || [priceNumber2Last3 isEqualToString:inputText]){
        
        [self compareSuccess];
    }
    
        [self compareFail];
}
- (void) append :(NSString*)number {
    
    
    
    if (!inputText){
        if (isFail == true) {
            inputText = [inputText substringToIndex:([inputText length] == 1)];
            _inputTextfield.text = inputText;
            index = 0;
            isFail = false;
        }
        inputText =number;
        _inputTextfield.text =  inputText;
        NSLog(@"false %@",inputText);
    }else{
        if (isFail == true) {
            inputText = [inputText substringToIndex:([inputText length] == 1)];
            _inputTextfield.text = inputText;
            index = 0;
            isFail = false;
        }
        inputText = [inputText stringByAppendingString:number];
        _inputTextfield.text =  inputText;
        NSLog(@"ture %@",inputText);
    }
}
-(void) compare {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * priceArray = [userDefaults objectForKey:@"priceArray"];
    
    NSString * priceArrayLast3 = [priceArray[2] substringFromIndex:5];
    NSString * priceArray1Last3 = [priceArray[3] substringFromIndex:5];
    NSString * priceArray2Last3 = [priceArray[4] substringFromIndex:5];
    
        if([priceArray[5] isEqualToString:inputText] ||
       [priceArrayLast3 isEqualToString:inputText] ||
       [priceArray1Last3 isEqualToString:inputText] ||
       [priceArray2Last3 isEqualToString:inputText])
    {
        
//        inputText = [inputText substringToIndex:([inputText length] == 1)];
//        _inputTextfield.text = inputText;
        [self compareSuccess];
        
    }else{
        
//        inputText = [inputText substringToIndex:([inputText length] == 1)];
//        _inputTextfield.text = inputText;
        [self compareFail];
        
    }
    
}
-(void) compareSuccess {
    inputText = [inputText substringToIndex:([inputText length] == 1)];
    _inputTextfield.text = inputText;
    index = 0;

    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Compare" message:@"中獎了！！ 請在時間內領獎～" preferredStyle:UIAlertControllerStyleAlert];

    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSLog(@"點擊確定按鈕");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"點擊取消按鈕");
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}
-(void) compareFail {

    NSString * fail = @"沒中：";
     NSString * failText = [fail stringByAppendingString:_inputTextfield.text];
    _inputTextfield.text = failText;
    isFail = true;
}
-(void)buttonClickedEvent{
    
    
    index += 1;
    NSLog(@"index:%d",index);
    if (index == 3) {
        [self compare];
        index = 0;
    }
   
}


- (IBAction)doRefresh:(id)sender {
    [self parseHtml];
}
-(void)adMob{
    //準備 google adunitID
//    self.adMobView.adUnitID=@"ca-app-pub-8522466967239344~8969173711";
    
    self.adMobView.rootViewController = self;
    //準備 google ad request
    self.adMobView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";

    //請 bannerview 加載
    [self.adMobView loadRequest:[GADRequest request]];

}
- (void)resetDefaults {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * priceArray = [userDefaults objectForKey:@"priceArray"];
    priceArray = nil;
    NSString * month = [userDefaults objectForKey:@"month"];
    month = nil;
    NSLog(@"resetDefaultes:%@",priceArray);
}
@end
