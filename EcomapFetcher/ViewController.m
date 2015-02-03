//
//  ViewController.m
//  EcomapFetcher
//
//  Created by Vasya on 2/1/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://itunes.apple.com/search?term=apple&media=software"]
//                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", json);
//    }];
//    
//    [dataTask resume];
    
//    NSURLSessionConfiguration *conifiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:conifiguration delegate:self delegateQueue:nil];
//    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:@"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"]];
//    [downloadTask resume];
    [self sendHTTPPost];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setHidden:YES];
        [self.imageView setImage:[UIImage imageWithData:data]];
    });
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
    });
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~
-(void) sendHTTPPost
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    [defaultConfigObject setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject];
    
    NSURL * url = [NSURL URLWithString:@"http://176.36.11.25/api/login"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSDictionary *loginData = @{@"email" : @"admin@.com", @"password" : @"admin"};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:&error];
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [defaultSession uploadTaskWithRequest:urlRequest
                                                                          fromData:data
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             NSLog(@"In response");
             
             NSDictionary *JSONResponse = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             NSString *token = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] valueForKey:@"token"];
             NSLog(@"Token: %@", token);
         }];
        
        [uploadTask resume];
    }
    
    
    
}

@end
