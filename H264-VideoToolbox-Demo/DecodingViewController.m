//
//  DecodingViewController.m
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import "DecodingViewController.h"
#import "AAPLEAGLLayer.h"
#import "VideoToolboxDecoder.h"

#include "FFMpegDemuxer.h"

@interface DecodingViewController ()

@property (nonatomic, strong) NSURL *inputUrl;
@property (nonatomic, strong) VideoToolboxDecoder *videoToolboxDecoder;
@property (nonatomic, strong) AAPLEAGLLayer *glLayer;

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
    _glLayer = [[AAPLEAGLLayer alloc] initWithFrame:self.view.bounds];
    
    [self initFFMpegConfigWithURL: _inputUrl];
    
    err = [self initVideoToolboxDecoder];
    if (err < 0) {
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view.layer addSublayer:_glLayer];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self runVideoToolboxDecoder];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (int)runVideoToolboxDecoder {
    int err = 0;
    while (1) {
        CVPixelBufferRef pixelBuffer = NULL;
        err = [_videoToolboxDecoder decodeVideo:&pixelBuffer];
        if (err < 0) {
            break;
        }
        
        if (pixelBuffer) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.glLayer.pixelBuffer = pixelBuffer;
            });
            CVPixelBufferRelease(pixelBuffer);
        }
        
        [NSThread sleepForTimeInterval:0.025];
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
    [_videoToolboxDecoder releaseVideoToolboxDecoder];
}

@end
