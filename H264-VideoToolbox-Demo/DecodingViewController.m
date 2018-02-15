//
//  DecodingViewController.m
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import "DecodingViewController.h"
#import "VideoToolboxDecoder.h"

#include "FFMpegDemuxer.h"

@interface DecodingViewController ()

@property (nonatomic, strong) NSURL *inputUrl;

@property (nonatomic, strong) VideoToolboxDecoder *videoToolboxDecoder;

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
    int err = 0;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self initFFMpegConfigWithURL: _inputUrl];
    
    err = [self initVideoToolboxDecoder];
    
    [self closeDecoder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - VideoToolbox
- (int)initVideoToolboxDecoder {
    _videoToolboxDecoder = [[VideoToolboxDecoder alloc] initWithExtradata];
    if (!_videoToolboxDecoder) {
        NSLog(@"Error: VideoToolbox decoder initialization failed.");
        return -1;
    }
    return 0;
}

# pragma mark - FFMpeg demuxer
- (void)initFFMpegConfigWithURL: (NSURL *)url {
    int err = 0;
    err = init_ffmpeg_config([[url absoluteString] UTF8String], 0);
    if (err < 0) {
        return;
    }
    
}

- (void)closeDecoder {
    ffmpeg_demuxer_release();
}

@end
