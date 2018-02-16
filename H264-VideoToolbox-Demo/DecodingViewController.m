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
    int err = 0, total_frames = 0;
    self.view.backgroundColor = [UIColor lightGrayColor];
    _glLayer = [[AAPLEAGLLayer alloc] initWithFrame:self.view.bounds];
    [self.view.layer addSublayer:_glLayer];
    
    [self initFFMpegConfigWithURL: _inputUrl];
    
    err = [self initVideoToolboxDecoder];
    if (err < 0) {
        return;
    }
    
    total_frames = [self runVideoToolboxDecoder];
    
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
    CVPixelBufferRef pixelBuffer = NULL;
    [_videoToolboxDecoder decodeVideo:&pixelBuffer];

    if (pixelBuffer) {
        self.glLayer.pixelBuffer = pixelBuffer;
        CVPixelBufferRelease(pixelBuffer);
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
