//
//  DecodingViewController.m
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import "DecodingViewController.h"

@interface DecodingViewController ()

@property (nonatomic, strong) NSURL *inputUrl;

@end

@implementation DecodingViewController

- (instancetype)initWithURL: (NSURL *)url {
    self = [super init];
    if (self) {
        _inputUrl = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
