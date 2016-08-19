//
//  SecondViewController.m
//  recept
//
//  Created by 徐常璿 on 2016/8/8.
//  Copyright © 2016年 Eric Hsu. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *Price1Label;
@property (weak, nonatomic) IBOutlet UILabel *Price2Label;
@property (weak, nonatomic) IBOutlet UILabel *Price3Label;
@property (weak, nonatomic) IBOutlet UILabel *Price4Label;
@property (weak, nonatomic) IBOutlet UILabel *Price5Label;
@property (weak, nonatomic) IBOutlet UILabel *Price6Label;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * priceArray = [userDefaults objectForKey:@"priceArray"];
    NSString * month = [userDefaults objectForKey:@"month"];
    
    _monthLabel.text = month;
//    NSString * price1 = priceArray[0];
    _Price1Label.text = priceArray[0];
    _Price2Label.text = priceArray[1];
    _Price3Label.text = priceArray[2];
    _Price4Label.text = priceArray[3];
    _Price5Label.text = priceArray[4];
    _Price6Label.text = priceArray[5];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:priceArray[4]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,3)];
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:priceArray[3]];
    [str1 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,3)];
    
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:priceArray[2]];
    [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,3)];
    _Price5Label.backgroundColor = [UIColor clearColor];
    _Price5Label.attributedText = str;
    _Price4Label.attributedText = str1;
    _Price3Label.attributedText = str2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
