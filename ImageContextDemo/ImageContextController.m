//
//  ImageContextController.m
//  ImageContextDemo
//
//  Created by xiangkai yin on 16/5/6.
//  Copyright © 2016年 kuailao_2. All rights reserved.
//
#define max_Width 1224
#define max_Size 300 * 1024

#import "ImageContextController.h"
@interface ImageContextController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    __weak IBOutlet UILabel *beforeLabel;
    __weak IBOutlet UILabel *endLabel;
    __weak IBOutlet UIButton *compressButton;
    __weak IBOutlet UITextView *textView;
    
    UIImage *imageSelect;
    
    NSMutableString *_dictString;
}

@end

@implementation ImageContextController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dictString = [[NSMutableString alloc] init];
    [compressButton addTarget:self action:@selector(onTouchWithUpload:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelectTag:(NSInteger)selectTag {
    NSLog(@"%ld",selectTag);
    _selectTag = selectTag;
}

- (void)onTouchWithUpload:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)onTouchBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    if (data.length < max_Size) {
        NSLog(@"%lu",(unsigned long)data.length);
        return;
    }
    beforeLabel.text = [NSString stringWithFormat:@"%ld",data.length];
    
    if (_selectTag == 0) {
        
        [self compressImage:[self scaleToSize:CGSizeMake(max_Width, max_Width) image:image] toMaxFileSize:max_Size];
    
    } else if (_selectTag == 1) {
        [self compressImage:[self imageByScalingAndCroppingForSize:CGSizeMake(max_Width, max_Width) image:image] toMaxFileSize:max_Size];
    }
}

- (UIImage*)scaleToSize:(CGSize)size image:(UIImage *)picture {
    
    [_dictString appendString:[NSString stringWithFormat:@"当前图片的大小 : %ld ,现在的时间 = %@",UIImagePNGRepresentation(picture).length,[self dateFormatter]]];
    long lTime = CFAbsoluteTimeGetCurrent();
    CGFloat width = CGImageGetWidth(picture.CGImage);
    CGFloat height = CGImageGetHeight(picture.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [picture drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    NSLog(@"scaleToSize %lf",CFAbsoluteTimeGetCurrent() - lTime);
    [_dictString appendString:[NSString stringWithFormat:@"当前图片的大小 : %ld ,现在的时间 = %@",UIImagePNGRepresentation(scaledImage).length,[self dateFormatter]]];
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (NSData *)compressToMaxFileSize:(NSInteger)maxFileSize forSize:(CGSize)targetSize image:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    CGFloat maxWidth = targetSize.width>targetSize.height?targetSize.width:targetSize.height;
    
    long lTime = CFAbsoluteTimeGetCurrent();;
    [_dictString appendString:[NSString stringWithFormat:@"开始时间 = %@",[self dateFormatter]]];
    [_dictString appendString:@"\n"];
     [self compressImage:[self imageByScalingAndCroppingForSize:CGSizeMake(maxWidth, maxWidth) image:image] toMaxFileSize:maxFileSize];
    
    [_dictString appendString:[NSString stringWithFormat:@"结束时的大小 : %ld ,结束时的时间 = %@ ,共耗时 = %f",data.length,[self dateFormatter],CFAbsoluteTimeGetCurrent()- lTime]];
    textView.text = _dictString;
    
    return data;
}

/**
 *  图片压缩到指定大小
 *
 *  @param image       图片
 *  @param maxFileSize 最大值
 *
 *  @return 图片
 */
- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.7f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    if (imageData.length < maxFileSize) {
        endLabel.text = [NSString stringWithFormat:@"%ld",imageData.length];
        return [UIImage imageWithData:imageData];
    }
    long lTime = CFAbsoluteTimeGetCurrent();;
    [_dictString appendString:[NSString stringWithFormat:@"开始时间 = %@",[self dateFormatter]]];
    [_dictString appendString:@"\n"];
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
        [_dictString appendString:[NSString stringWithFormat:@"当前图片的大小 : %ld ,现在的时间 = %@",imageData.length,[self dateFormatter]]];
        [_dictString appendString:@"\n"];
        textView.text = _dictString;
    }
    
    endLabel.text = [NSString stringWithFormat:@"%ld",imageData.length];
    [_dictString appendString:[NSString stringWithFormat:@"结束时的大小 : %ld ,结束时的时间 = %@ ,共耗时 = %f",imageData.length,[self dateFormatter],CFAbsoluteTimeGetCurrent() - lTime]];
    textView.text = _dictString;
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] ;
    if (_selectTag == 0) {
        fullPath = [fullPath stringByAppendingPathComponent:@"t1.jpg"];
    } else if (_selectTag == 1) {
        fullPath = [fullPath stringByAppendingPathComponent:@"t2.jpg"];
    }
    [imageData writeToFile:fullPath atomically:YES];
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

- (NSString *)dateFormatter {
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    return date;
}

- (NSData *)compressImageToMaxFileSize:(NSInteger)maxFileSize image:(UIImage *)image{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    [_dictString appendString:[NSString stringWithFormat:@"当前图片的大小 : %ld ,现在的时间 = %@",imageData.length,[self dateFormatter]]];
    [_dictString appendString:@"\n"];
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
        [_dictString appendString:[NSString stringWithFormat:@"当前图片的大小 : %ld ,现在的时间 = %@",imageData.length,[self dateFormatter]]];
        [_dictString appendString:@"\n"];
    }
    return imageData;
}

/**
 *  改变图片大小
 *
 *  @param targetSize 图片大小
 *
 *  @return 图片
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize image:(UIImage *)image{
    long lTime = CFAbsoluteTimeGetCurrent();
    UIImage *sourceImage = image;
    
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
        
        scaledWidth= width * scaleFactor;
        
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        } else if (widthFactor < heightFactor) {
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
        
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = thumbnailPoint;
    
    thumbnailRect.size.width= scaledWidth;
    
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
        
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    
    UIGraphicsEndImageContext();
    NSLog(@"imageByScalingAndCroppingForSize %lf",CFAbsoluteTimeGetCurrent() - lTime);
    return newImage;
    
}

@end
