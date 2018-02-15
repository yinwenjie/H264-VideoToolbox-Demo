//
//  FFMpegDemuxer.h
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/13.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#ifndef FFMpegDemuxer_h
#define FFMpegDemuxer_h

#include <stdio.h>

typedef struct {
    uint8_t *nal_buf;
    int nal_size;
} NAL_UNIT;

int init_ffmpeg_config(const char *input_file_name, int format);

typedef struct AVCodecParameters AVCodecParameters;
AVCodecParameters* get_codec_paramaters(void);

int get_video_packet(NAL_UNIT *nalu);

void ffmpeg_demuxer_release(void);

#endif /* FFMpegDemuxer_h */
