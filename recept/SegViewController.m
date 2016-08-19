//
//  SegViewController.m
//  recept
//
//  Created by 徐常璿 on 2016/7/23.
//  Copyright © 2016年 Eric Hsu. All rights reserved.
//

#import "SegViewController.h"

@interface SegViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;


@end

@implementation SegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _firstView.hidden = false;
    _secondView.hidden = true;
    
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
- (IBAction)indexChange:(id)sender {
    switch (_segmentControl.selectedSegmentIndex) {
        case 0:
            _firstView.hidden = false;
            _secondView.hidden = true;
            break;
            case 1:
            _firstView.hidden = true;
            _secondView.hidden = false;
        default:
            break;
    }
}

@end
