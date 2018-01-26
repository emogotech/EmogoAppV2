//
//  UIImage+ImageCompress.m
//  UIIImageCompressExample
//
//  Created by Abraham Kuri on 12/12/13.
//  Copyright (c) 2013 Icalia Labs. All rights reserved.
//

#import "UIImage+ImageCompress.h"

#define ORIGINAL_MAX_WIDTH [[UIScreen mainScreen] bounds].size.width


@implementation UIImage (ImageCompress)

- (UIImage *)compressImage:(UIImage *)image
             compressRatio:(CGFloat)ratio
{
    return [self compressImage:image compressRatio:ratio maxCompressRatio:0.1f];
}

- (UIImage *)compressImage:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio
{
    
    //We define the max and min resolutions to shrink to
    int MIN_UPLOAD_RESOLUTION = 1136 * 640;
    int MAX_UPLOAD_SIZE = 50;
    
    float factor;
    float currentResolution = image.size.height * image.size.width;
    
    //We first shrink the image a little bit in order to compress it a little bit more
    if (currentResolution > MIN_UPLOAD_RESOLUTION) {
        factor = sqrt(currentResolution / MIN_UPLOAD_RESOLUTION) * 2;
        image = [self scaleDown:image withSize:CGSizeMake(image.size.width / factor, image.size.height / factor)];
    }
    
    //Compression settings
    CGFloat compression = ratio;
    CGFloat maxCompression = maxRatio;
    
    //We loop into the image data to compress accordingly to the compression ratio
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxCompression) {
        compression -= 0.10;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //Retuns the compressed image
    return [[UIImage alloc] initWithData:imageData];
}


- (UIImage *)compressRemoteImage:(NSString *)url
                   compressRatio:(CGFloat)ratio
                maxCompressRatio:(CGFloat)maxRatio
{
    //Parse the URL
    NSURL *imageURL = [NSURL URLWithString:url];
    
    //We init the image with the rmeote data
    UIImage *remoteImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    
    //Returns the remote image compressed
    return [self compressImage:remoteImage compressRatio:ratio maxCompressRatio:maxRatio];
    
}

- (UIImage *)compressRemoteImage:(NSString *)url compressRatio:(CGFloat)ratio
{
    return [self compressRemoteImage:url compressRatio:ratio maxCompressRatio:0.1f];
}

- (UIImage*)scaleDown:(UIImage*)image withSize:(CGSize)newSize
{
    
    //We prepare a bitmap with the new size
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    
    //Draws a rect for the image
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //We set the scaled image from the context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}



CGContextRef MyCreateBitmapContextTemp(int pixelsWide, int pixelsHigh)
{
    CGContextRef    context=NULL;
    CGColorSpaceRef    colorSpace;
    void *            bitmapData;
    int                bitmapByteCount;
    int                bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc(bitmapByteCount);
    
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
    
}

- (UIImage *)copyWithSize:(CGSize)newSize
             cornerRadius:(CGFloat)radius
               borderSize:(CGFloat)borderSize
              borderColor:(CGColorRef)borderColor
{
    CGRect rect = CGRectMake(0,0, newSize.width, newSize.height);
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        rect.size.height *= [[UIScreen mainScreen] scale];
        rect.size.width *= [[UIScreen mainScreen] scale];
        
        borderSize *= [[UIScreen mainScreen] scale];
        radius *= [[UIScreen mainScreen] scale];
    }
    
    CGContextRef context = MyCreateBitmapContextTemp(rect.size.width, rect.size.height);
    CGContextClearRect(context, rect);
    
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    CGContextClip(context);
    
    CGContextDrawImage(context, rect, [self CGImage]);
    
    if ((borderSize > 0) && (borderColor != NULL)) {
        [self drawBorderInRect:rect context:context cornerRadius:radius borderSize:borderSize borderColor:borderColor];
    }
    
    CGImageRef myRef=CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

- (UIImage *)copyWithSize:(CGSize)newSize cornerRadius:(CGFloat)radius
{
    return [self copyWithSize:newSize cornerRadius:radius borderSize:0 borderColor:NULL];
}

- (UIImage *)shadowedImageWithColor:(UIColor *)shadowColor offset:(CGSize)shadowOffset
{
    CGSize resizedShadowOffset = shadowOffset;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        resizedShadowOffset.height *= [[UIScreen mainScreen] scale];
        resizedShadowOffset.width *= [[UIScreen mainScreen] scale];
    }
    
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             self.size.width + 2 * fabsf(resizedShadowOffset.width),
                             self.size.height + 2 * fabsf(resizedShadowOffset.height));
    
    CGContextRef context = MyCreateBitmapContextTemp(rect.size.width, rect.size.height);
    CGContextSetShadowWithColor(context, resizedShadowOffset, 3.0f, [shadowColor CGColor]);
    
    CGContextDrawImage(context, CGRectMake(fabsf(resizedShadowOffset.width),
                                           fabsf(resizedShadowOffset.height),
                                           self.size.width,
                                           self.size.height), [self CGImage]);
    
    CGImageRef myRef = CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

- (void)drawBorderInRect:(CGRect)rect
                 context:(CGContextRef)context
            cornerRadius:(CGFloat)radius
              borderSize:(CGFloat)borderSize
             borderColor:(CGColorRef)borderColor
{
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    CGContextSetLineWidth(context, borderSize);
    CGContextSetStrokeColorWithColor(context, borderColor);
    CGContextStrokePath(context);
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                 cornerRadius:(CGFloat)radius
                                   borderSize:(CGFloat)borderSize
                                  borderColor:(CGColorRef)borderColor
{
    UIImage *resizedImage = [self imageByScalingAndCroppingForSize:targetSize];
    
    CGRect rect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    
    CGContextRef context = MyCreateBitmapContextTemp(targetSize.width, targetSize.height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, [resizedImage CGImage]);
    
    if ((borderSize > 0) && (borderColor != NULL)) {
        [self drawBorderInRect:rect context:context cornerRadius:radius borderSize:borderSize borderColor:borderColor];
    }
    
    CGImageRef myRef=CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

- (UIImage *)scaleAndRotateImage {
    UIImage *image = self;
    int kMaxResolution = (ORIGINAL_MAX_WIDTH); // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        
        case UIImageOrientationUp: //EXIF = 1
        transform = CGAffineTransformIdentity;
        break;
        
        case UIImageOrientationUpMirrored: //EXIF = 2
        transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
        break;
        
        case UIImageOrientationDown: //EXIF = 3
        transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
        
        case UIImageOrientationDownMirrored: //EXIF = 4
        transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        break;
        
        case UIImageOrientationLeftMirrored: //EXIF = 5
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
        transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        break;
        
        case UIImageOrientationLeft: //EXIF = 6
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
        transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        break;
        
        case UIImageOrientationRightMirrored: //EXIF = 7
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeScale(-1.0, 1.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        break;
        
        case UIImageOrientationRight: //EXIF = 8
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        break;
        
        default:
        [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
        
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    
        if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
        CGFloat btWidth = 0.0f;
        CGFloat btHeight = 0.0f;
        if (sourceImage.size.width > sourceImage.size.height) {
            btHeight = ORIGINAL_MAX_WIDTH;
            btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
        } else {
            btWidth = ORIGINAL_MAX_WIDTH;
            btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
        }
        CGSize targetSize = CGSizeMake(btWidth, btHeight);
        return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}
    
- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
        scaleFactor = widthFactor; // scale to fit height
        else
        scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

    

@end
