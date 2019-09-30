#ifndef NV12_TO_RGB_H
#define NV12_TO_RGB_H

typedef unsigned char uchar;

bool nv12_to_rgb(unsigned char *src, unsigned char *dst,int src_width,int src_height, int dst_pitch);

#endif // NV12_TO_RGB_H