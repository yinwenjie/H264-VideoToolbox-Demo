//
//  DecodingViewController.m
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import "DecodingViewController.h"

#include "FFMpegDemuxer.h"

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
    
    [self initFFMpegConfigWithURL: _inputUrl];
    [self closeDecoder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - FFMpeg demuxer
- (void)initFFMpegConfigWithURL: (NSURL *)url {
    int err = 0;
    err = init_ffmpeg_config(0);
    if (err < 0) {
        return;
    }
    err = load_input_file([[url absoluteString] UTF8String]);
    if (err < 0) {
        return;
    }
}

- (void)closeDecoder {
    ffmpeg_demuxer_release();
}

@end
