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

int init_ffmpeg_config(const char *input_file_name, int format);

void ffmpeg_demuxer_release(void);

#endif /* FFMpegDemuxer_h */
