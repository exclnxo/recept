//
//  QRCodeViewController.m
//  recept
//
//  Created by 徐常璿 on 2016/8/8.
//  Copyright © 2016年 Eric Hsu. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
}


@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            _label.text = detectionString;
            NSLog(@"detectionString :%@",detectionString);
            NSString *s1 = [detectionString substringToIndex:10];
            NSLog(@"%@" , s1);
            NSString *s2 = [s1 substringFromIndex:7];
            NSLog(@"%@" , s2);
            [self parseQRcode:s2];
            break;
        }
        else
            _label.text = @"(none)";
    }
    
    _highlightView.frame = highlightViewRect;
}

-(void) parseQRcode:(NSString *)QRStr  {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * priceArray = [userDefaults objectForKey:@"priceArray"];
    
    NSString * priceArrayLast3 = [priceArray[2] substringFromIndex:5];
    NSString * priceArray1Last3 = [priceArray[3] substringFromIndex:5];
    NSString * priceArray2Last3 = [priceArray[4] substringFromIndex:5];
    
    if([priceArray[5] isEqualToString:QRStr] ||
       [priceArrayLast3 isEqualToString:QRStr] ||
       [priceArray1Last3 isEqualToString:QRStr] ||
       [priceArray2Last3 isEqualToString:QRStr])
    {

        [self compareSuccess];
        
    }else{
        
        [self compareFail];
        
    }
    
}
-(void) compareSuccess {
 
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Compare" message:@"中獎了！！ 請在時間內領獎～(請確定要是當月份的歐～)" preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSLog(@"點擊確定按鈕");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"點擊取消按鈕");
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}
-(void) compareFail {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"結果" message:@"沒中  在對一張吧" preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSLog(@"點擊確定按鈕");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"點擊取消按鈕");
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}


@end
