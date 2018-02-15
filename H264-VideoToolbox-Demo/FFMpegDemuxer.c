//
//  FFMpegDemuxer.c
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#include "FFMpegDemuxer.h"
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"

typedef struct FFDemuxer {
    FILE    *output_file;
    int     video_stream_index;
    AVCodec                 *codec;
    AVCodecContext          *codec_ctx;
    AVFormatContext         *fmt_ctx;
} FFDemuxer;
FFDemuxer demuxer = {NULL};

int init_ffmpeg_config_mp4(const char *input_file_name);

#pragma mark - API Implementation
int init_ffmpeg_config(const char *input_file_name, int format) {
    int err = 0;
    av_register_all();
    err = init_ffmpeg_config_mp4(input_file_name);
    if (err < 0) {
        return err;
    }
    
    return 0;
}

AVCodecParameters* get_codec_paramaters(void) {
    AVCodecParameters *codecpar = avcodec_parameters_alloc();
    if (avcodec_parameters_from_context(codecpar, demuxer.codec_ctx)) {
        return NULL;
    }
    return codecpar;
}

void ffmpeg_demuxer_release(void) {
    if (demuxer.fmt_ctx) {
        avformat_close_input(&demuxer.fmt_ctx);
        demuxer.fmt_ctx = NULL;
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

    printf("FFMpeg demuxer released.\n");
}

# pragma mark - MP4 format
int init_ffmpeg_config_mp4(const char *input_file_name) {
    if (avformat_open_input(&demuxer.fmt_ctx, input_file_name, NULL, NULL) < 0) {
        printf("Error: Open input file failed.\n");
        return -1;
    }
    
    if (avformat_find_stream_info(demuxer.fmt_ctx, NULL)) {
        printf("Error: Find stream info error.\n");
        return -1;
    }
    
    for (int idx = 0; idx < demuxer.fmt_ctx->nb_streams; idx++) {
        if (demuxer.fmt_ctx->streams[idx]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            demuxer.video_stream_index = idx;
            break;
        }
    }
    
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
    
    if (avcodec_open2(demuxer.codec_ctx, demuxer.codec, NULL) < 0) {
        printf("Error: Open codec failed.\n");
        return -1;
    }
    
    printf("Configuration for H.264 MP4 succeeded.\n");
    return 0;
}
