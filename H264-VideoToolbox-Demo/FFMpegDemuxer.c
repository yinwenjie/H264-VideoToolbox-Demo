//
//  FFMpegDemuxer.c
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#include "FFMpegDemuxer.h"
#include "libavcodec/avcodec.h"

typedef struct FFDemuxer {
    FILE    *input_file;
    FILE    *output_file;
    
    AVCodec                 *codec;
    AVCodecContext          *codec_ctx;
    AVCodecParserContext    *codec_parser_ctx;
} FFDemuxer;
FFDemuxer demuxer = {NULL};

int init_ffmpeg_config_raw(void);

#pragma mark - API Implementation
int init_ffmpeg_config(int format) {
    int err = 0;

    avcodec_register_all();
    switch (format) {
        case 0:
            err = init_ffmpeg_config_raw();
            break;
            
        default:
            break;
    }
    
    if (err < 0) {
        return err;
    }
    
    return 0;
}

int load_input_file(const char *file_name) {
    demuxer.input_file = fopen(file_name, "rb");
    if (!demuxer.input_file) {
        return -1;
    }
    printf("Open input file %s succeeded.\n", file_name);
    return 0;
}

void ffmpeg_demuxer_release(void) {
    if (demuxer.input_file) {
        fclose(demuxer.input_file);
        demuxer.input_file = NULL;
    }
    if (demuxer.output_file) {
        fclose(demuxer.output_file);
        demuxer.output_file = NULL;
    }
    
    if (demuxer.codec_ctx) {
        avcodec_close(demuxer.codec_ctx);
        av_free(demuxer.codec_ctx);
        demuxer.codec_ctx = NULL;
    }
    if (demuxer.codec_parser_ctx) {
        av_parser_close(demuxer.codec_parser_ctx);
        demuxer.codec_parser_ctx = NULL;
    }
    printf("FFMpeg demuxer released.\n");
}

# pragma mark - Raw H.264 stream
int init_ffmpeg_config_raw() {
    demuxer.codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    if (!demuxer.codec) {
        printf("Error: find decoder H.264 failed in libavcodec. Rebuild ffmpeg with H.264 encoder enabled.\n");
        return -1;
    }
    
    demuxer.codec_ctx = avcodec_alloc_context3(demuxer.codec);
    if (!demuxer.codec_ctx) {
        printf("Error: AVCodecContext instance allocation failed.\n");
        return -1;
    }
    
    demuxer.codec_parser_ctx = av_parser_init(AV_CODEC_ID_H264);
    if (!demuxer.codec_parser_ctx) {
        printf("Error: AVCodecContextParser instance allocation failed.\n");
        return -1;
    }
    
    if (avcodec_open2(demuxer.codec_ctx, demuxer.codec, NULL) < 0) {
        printf("Error: Open codec failed.\n");
        return -1;
    }
    
    printf("Configuration for raw H.264 bitstream succeeded.\n");
    return 0;
}
