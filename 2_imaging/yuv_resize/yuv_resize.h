#ifndef YUV_RESIZE_H
#define YUV_RESIZE_H

typedef unsigned char uchar;

bool host_yuv_resize(unsigned char *src, int src_width, int src_height, unsigned char *dst, int dst_width, int dst_height);

bool nv12_to_rgb(unsigned char *src, unsigned char *dst,int src_width,int src_height, int dst_pitch);


#endif // YUV_RESIZE_H