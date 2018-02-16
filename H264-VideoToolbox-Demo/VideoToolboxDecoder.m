//
//  VideoToolboxDecoder.m
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/15.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import "VideoToolboxDecoder.h"
#import <VideoToolbox/VideoToolbox.h>

#include "FFMpegDemuxer.h"
#include "libavcodec/avcodec.h"

@implementation VideoToolboxDecoder {
    AVCodecParameters *codecpar;
    CMFormatDescriptionRef formatDecsription;
    VTDecompressionSessionRef decompressSession;
}

- (instancetype)initWithExtradata {
    self = [super init];
    if (self) {
        codecpar = get_codec_paramaters();
        [self createVideoToolboxDecoder];
    }
    return self;
}

- (int)decodeVideo {
    NAL_UNIT nal_unit = { NULL, 0 };
    get_video_packet(&nal_unit);
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, (void *)nal_unit.nal_buf, nal_unit.nal_size, kCFAllocatorNull, NULL, 0, nal_unit.nal_size, 0, &blockBuffer);
    if (status != kCMBlockBufferNoErr) {
        NSLog(@"Error: Creating block buffer failed.");
        return -1;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    const size_t sampleSizeArray[] = { nal_unit.nal_size };
    status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                       blockBuffer,
                                       formatDecsription,
                                       1,
                                       0,
                                       NULL,
                                       1,
                                       sampleSizeArray,
                                       &sampleBuffer);
    if (status != kCMBlockBufferNoErr || !sampleBuffer) {
        NSLog(@"Error: Creating sample buffer failed.");
        return -1;
    }
    
    VTDecodeFrameFlags flags = 0;
    VTDecodeInfoFlags flagOut = 0;
    status = VTDecompressionSessionDecodeFrame(decompressSession, sampleBuffer, flags, &outputPixelBuffer, &flagOut);
    switch (status) {
        case noErr:
            NSLog(@"Decoding one frame succeeded.");
            break;
        case kVTInvalidSessionErr:
            NSLog(@"Error: Invalid session, reset decoder session");
            break;
        case kVTVideoDecoderBadDataErr:
            NSLog(@"Error: decode failed status=%d(Bad data)", status);
            break;
        default:
            NSLog(@"Error: decode failed status=%d", status);
            break;
    }
    
    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);

    if (status == noErr) {
        return 0;
    } else {
        return -1;
    }
}

#pragma mark - VideoToolbox Activity
static void didDecompress(void *decompressionOutputRefCon,
                          void *sourceFrameRefCon,
                          OSStatus status,
                          VTDecodeInfoFlags infoFlags,
                          CVImageBufferRef pixelBuffer,
                          CMTime presentationTimeStamp,
                          CMTime presentationDuration )
{
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

- (int)createVideoToolboxDecoder {
    int width = codecpar->width;
    int height = codecpar->height;
    int extradata_size = codecpar->extradata_size;
    uint8_t *extradata = codecpar->extradata;
    OSStatus status;
    
    CFMutableDictionaryRef par = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef atoms = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef extensions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSLog(@"Frame width: %d, height: %d", width, height);
    
    /* CVPixelAspectRatio dict */
    dict_set_i32(par, CFSTR ("HorizontalSpacing"), 0);
    dict_set_i32(par, CFSTR ("VerticalSpacing"), 0);
    /* SampleDescriptionExtensionAtoms dict */
    dict_set_data(atoms, CFSTR ("avcC"), (uint8_t *)extradata, extradata_size);
    /* Extensions dict */
    dict_set_string(extensions, CFSTR ("CVImageBufferChromaLocationBottomField"), "left");
    dict_set_string(extensions, CFSTR ("CVImageBufferChromaLocationTopField"), "left");
    dict_set_boolean(extensions, CFSTR("FullRangeVideo"), FALSE);
    dict_set_object(extensions, CFSTR ("CVPixelAspectRatio"), (CFTypeRef *) par);
    dict_set_object(extensions, CFSTR ("SampleDescriptionExtensionAtoms"), (CFTypeRef *) atoms);
    
    status = CMVideoFormatDescriptionCreate(NULL, kCMVideoCodecType_H264, width, height, extensions, &(formatDecsription));
    
    CFRelease(extensions);
    CFRelease(atoms);
    CFRelease(par);
    
    if (status != 0) {
        NSError* error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: creating format description failed. Description: %@", [error description]);
        return -1;
    }
    
    CFMutableDictionaryRef destinationPixelBufferAttributes;
    VTDecompressionOutputCallbackRecord outputCallback;
    
    destinationPixelBufferAttributes = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferPixelFormatTypeKey, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferWidthKey, width);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferHeightKey, height);
    dict_set_boolean(destinationPixelBufferAttributes, kCVPixelBufferOpenGLESCompatibilityKey, YES);
    
    outputCallback.decompressionOutputCallback = didDecompress;
    outputCallback.decompressionOutputRefCon = NULL;
    status = VTDecompressionSessionCreate(kCFAllocatorDefault, formatDecsription, NULL, destinationPixelBufferAttributes, &outputCallback, &(decompressSession));
    if (status != noErr) {
        NSError* error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: Creating decompression session failed.Description: %@", [error description]);
        return -1;
    }
    return 0;
}

#pragma mark - Utils
static void dict_set_i32(CFMutableDictionaryRef dict, CFStringRef key, int32_t value)
{
    CFNumberRef number;
    number = CFNumberCreate(NULL, kCFNumberSInt32Type, &value);
    CFDictionarySetValue(dict, key, number);
    CFRelease(number);
}

static void dict_set_data(CFMutableDictionaryRef dict, CFStringRef key, uint8_t * value, uint64_t length)
{
    CFDataRef data;
    data = CFDataCreate(NULL, value, (CFIndex)length);
    CFDictionarySetValue(dict, key, data);
    CFRelease(data);
}

static void dict_set_string(CFMutableDictionaryRef dict, CFStringRef key, const char * value)
{
    CFStringRef string;
    string = CFStringCreateWithCString(NULL, value, kCFStringEncodingASCII);
    CFDictionarySetValue(dict, key, string);
    CFRelease(string);
}

static void dict_set_boolean(CFMutableDictionaryRef dict, CFStringRef key, BOOL value)
{
    CFDictionarySetValue(dict, key, value ? kCFBooleanTrue: kCFBooleanFalse);
}

static void dict_set_object(CFMutableDictionaryRef dict, CFStringRef key, CFTypeRef *value)
{
    CFDictionarySetValue(dict, key, value);
}

@end
