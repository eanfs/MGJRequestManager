//
//  DemoDetailViewController.m
//  STRequestManagerDemo
//
//  Created by limboy on 3/20/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "DemoDetailViewController.h"
#import "DemoListViewController.h"
#import "STRequestManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIImageView+AFNetworking.h>

@interface DemoDetailViewController ()
@property (nonatomic) UITextView *resultTextView;
@property (nonatomic) SEL selectedSelector;
@end

@implementation DemoDetailViewController

+ (void)load
{
    DemoDetailViewController *detailViewController = [[DemoDetailViewController alloc] init];
    [DemoListViewController registerWithTitle:@"发送一个 GET 请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(makeGETRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"发送一个 POST 请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(makePOSTRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"发送一个可以缓存 GET 的请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(makeCacheGETRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"设置每次请求都会带上的参数" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(makeBuiltinParametersRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"每次请求都根据参数计算 Token" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(calculateTokenEveryRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"在某些情况下可以不发送请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(preventFromSendingRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"对请求结果做预处理" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(handleResponse);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"对特殊请求做特殊处理" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(handleSpecialRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"串行发送多个请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(chainRequests);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"并行发送多个请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(batchRequests);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"上传图片" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(uploadImage);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"获取正在发送的请求并取消" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(runningRequests);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"取消某个 URL 的请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(cancelRequestByURL);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"模拟用户Token过期并重发之前的请求" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(simulateTokenExpired);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"发送请求时显示 Loading" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(showLoadingWhenSendingRequest);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"统计请求花费的时间" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(calculateRequestTime);
        return detailViewController;
    }];
    
    [DemoListViewController registerWithTitle:@"添加头信息" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(addHeaderValues);
        return detailViewController;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239.f/255 green:239.f/255 blue:244.f/255 alpha:1];
    [self.view addSubview:self.resultTextView];
    // Do any additional setup after loading the view.
}

- (void)appendLog:(NSString *)log
{
    NSString *currentLog = self.resultTextView.text;
    if (currentLog.length) {
        currentLog = [currentLog stringByAppendingString:[NSString stringWithFormat:@"\n----------\n%@", log]];
    } else {
        currentLog = log;
    }
    self.resultTextView.text = currentLog;
    [self.resultTextView sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.resultTextView.subviews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            // 这个是为了去除显示图片时，添加的 imageView
            [obj removeFromSuperview];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [STRequestManager sharedInstance].configuration = nil;
    [self appendLog:@"正在发送请求..."];
    [self.resultTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self performSelector:self.selectedSelector withObject:nil afterDelay:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.resultTextView removeObserver:self forKeyPath:@"contentSize"];
    self.resultTextView.text = @"";
}

- (UITextView *)resultTextView
{
    if (!_resultTextView) {
        NSInteger padding = 20;
        NSInteger viewWith = self.view.frame.size.width;
        NSInteger viewHeight = self.view.frame.size.height - 64;
        _resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, padding + 64, viewWith - padding * 2, viewHeight - padding * 2)];
        _resultTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        _resultTextView.layer.borderWidth = 1;
        _resultTextView.editable = NO;
        _resultTextView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
        _resultTextView.font = [UIFont systemFontOfSize:14];
        _resultTextView.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        _resultTextView.contentOffset = CGPointZero;
    }
    return _resultTextView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSInteger contentHeight = self.resultTextView.contentSize.height;
        NSInteger textViewHeight = self.resultTextView.frame.size.height;
        [self.resultTextView setContentOffset:CGPointMake(0, MAX(contentHeight - textViewHeight, 0)) animated:YES];
    }
}

- (NSString *)md5String:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (uint)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)makeGETRequest
{
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:@{@"foo": @"bar"} startImmediately:YES
 configurationHandler:nil completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
     [self appendLog:result.description];
 }];
}

- (void)makePOSTRequest
{
    [[STRequestManager sharedInstance] POST:@"http://httpbin.org/post" parameters:@{@"foo": @"bar"} startImmediately:YES
 configurationHandler:nil completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
     [self appendLog:result.description];
 }];
}

- (void)batchRequests
{
    AFHTTPRequestOperation *operation1 = [[STRequestManager sharedInstance]
                                          GET:@"http://httpbin.org/get"
                                          parameters:@{@"foo": @"bar"}
                                          startImmediately:NO
                                          configurationHandler:nil
                                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                              [self appendLog:result.description];
                                          }];
    
    AFHTTPRequestOperation *operation2 = [[STRequestManager sharedInstance]
                                          GET:@"http://httpbin.org/get"
                                          parameters:@{@"foo": @"bar"}
                                          startImmediately:NO
                                          configurationHandler:nil
                                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                              [self appendLog:result.description];
                                          }];
    
    [[STRequestManager sharedInstance] batchOfRequestOperations:@[operation1, operation2] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        [self appendLog:[NSString stringWithFormat:@"发送完成的请求：%ld/%ld", numberOfFinishedOperations, totalNumberOfOperations]];
    } completionBlock:^() {
        [self appendLog:@"请求发送完成"];
    }];
}

- (void)makeCacheGETRequest
{
    AFHTTPRequestOperation *operation1 = [[STRequestManager sharedInstance]
                                          GET:@"http://httpbin.org/get"
                                          parameters:@{@"foo": @"bar"}
                                          startImmediately:NO
                                          configurationHandler:^(STRequestManagerConfiguration *configuration) {
                                              configuration.resultCacheDuration = 10;
                                          }
                                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                              [self appendLog:[NSString stringWithFormat:@"来自缓存:%@", isFromCache ? @"是" : @"否"]];
                                              [self appendLog:result.description];
                                          }];
    
    AFHTTPRequestOperation *operation2 = [[STRequestManager sharedInstance]
                                          GET:@"http://m.springtour.com/home/AppLaunch/IosIndex"
                                          parameters:@{@"foo": @"bar"}
                                          startImmediately:NO
                                          configurationHandler:^(STRequestManagerConfiguration *configuration) {
                                              configuration.resultCacheDuration = 30;
                                          }
                                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                              [self appendLog:[NSString stringWithFormat:@"来自缓存:%@", isFromCache ? @"是" : @"否"]];
                                              [self appendLog:result.description];
                                          }];
    
    
    [[STRequestManager sharedInstance] addOperation:operation1 toChain:@"cache"];
    [[STRequestManager sharedInstance] addOperation:operation2 toChain:@"cache"];
}

- (void)makeBuiltinParametersRequest
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    configuration.builtinParameters = @{@"t": [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]], @"network": @"1", @"device": @"iphone3,2"};
    [STRequestManager sharedInstance].configuration = configuration;
    
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                 parameters:nil startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              if (error) {
                                  [self appendLog:error.description];
                              } else {
                                  [self appendLog:[NSString stringWithFormat:@"请求结果: %@", result.description]];
                              }
                          }];
}

- (void)calculateTokenEveryRequest
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    configuration.builtinParameters = @{@"t": [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]], @"network": @"1", @"device": @"iphone3,2"};
    [STRequestManager sharedInstance].configuration = configuration;
    
    [STRequestManager sharedInstance].parametersHandler = ^(NSMutableDictionary *builtinParameters, NSMutableDictionary *requestParameters) {
        NSString *builtinValues = [builtinParameters.allValues componentsJoinedByString:@""];
        NSString *requestValues = [requestParameters.allValues componentsJoinedByString:@""];
        NSString *md5Values = [self md5String:[NSString stringWithFormat:@"%@%@", builtinValues, requestValues]];
        requestParameters[@"token"] = md5Values;
    };
    
    NSDictionary *requestParameters = @{@"user_id": @1024};
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                 parameters:requestParameters
                           startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              [self appendLog:result.description];
                          }];
}

- (void)preventFromSendingRequest
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    configuration.requestHandler = ^(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing){
        // NSString *requestURL = operation.request.URL.absoluteString;
        // suppose requestURL contains some invalid characters
        *shouldStopProcessing = YES;
    };
    
    [STRequestManager sharedInstance].configuration = configuration;
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                 parameters:nil startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              [self appendLog:error.description];
                          }];
}

- (void)handleResponse
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    configuration.responseHandler = ^(AFHTTPRequestOperation *operation, id userInfo, STResponse *response, BOOL *shouldStopProcessing) {
        // response.result 里包含了原始的 object
        // 如果服务端返回的 result 中包含了 error 信息，可以设置 response.error
        // 这样使用方就可以知道这个请求失败了
        NSDictionary *args = response.result[@"args"];
        if ([args[@"status"] isEqualToString:@"error"]) {
            response.error = [NSError errorWithDomain:args[@"message"] code:403 userInfo:nil];
            response.result = nil;
        }
    };
    
    [STRequestManager sharedInstance].configuration = configuration;
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:@{@"status": @"error", @"message": @"模拟请求失败"} startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        if (error) {
            [self appendLog:error.description];
        }
    }];
}

- (void)handleSpecialRequest
{
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                 parameters:nil
                           startImmediately:YES
                       configurationHandler:^(STRequestManagerConfiguration *configuration) {
                           configuration.requestHandler = ^(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing) {
                               // 假设这是一个特殊请求
                               *shouldStopProcessing = YES;
                           };
                           [self appendLog:@"这个请求不会被发出去，被特殊处理了"];
                       }
                          completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              if (error.code == STResponseCancelError) {
                                  [self appendLog:@"这个请求被取消了"];
                              }
                          }];
}

- (void)chainRequests
{
    AFHTTPRequestOperation *operation1 = [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/3"
                                                                      parameters:@{@"method": @1}
                                                                startImmediately:NO
                                                            configurationHandler:nil
                                                               completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                                                   [self appendLog:result.description];
                                                               }];
    
    AFHTTPRequestOperation *operation2 = [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                                                      parameters:@{@"method": @2}
                                                                startImmediately:NO
                                                            configurationHandler:nil
                                                               completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                                                                   [self appendLog:result.description];
                                                               }];
    [[STRequestManager sharedInstance] addOperation:operation1 toChain:@"chain"];
    [[STRequestManager sharedInstance] addOperation:operation2 toChain:@"chain"];
}

- (void)runningRequests
{
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/3"
                                 parameters:@{@"method": @1}
                           startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              [self appendLog:error.description];
                          }];
    
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get"
                                 parameters:@{@"method": @2}
                           startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              [self appendLog:error.description];
                          }];
    
    [self appendLog:[[STRequestManager sharedInstance] runningRequests].description];
    [[STRequestManager sharedInstance] cancelAllRequest];
}

- (void)cancelRequestByURL
{
    NSString *urlString = @"http://httpbin.org/delay/5";
    [[STRequestManager sharedInstance] GET:urlString
                                 parameters:@{@"method": @1}
                           startImmediately:YES
                       configurationHandler:nil
                          completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                              [self appendLog:error.description];
                          }];
    
    [[STRequestManager sharedInstance] cancelHTTPOperationsWithMethod:@"GET" url:urlString];
}

- (void)simulateTokenExpired
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    configuration.responseHandler = ^(AFHTTPRequestOperation *operation, id userInfo, STResponse *response, BOOL *shouldStopProcessing) {
        static BOOL hasExecuted;
        if (!hasExecuted) {
            hasExecuted = YES;
            *shouldStopProcessing = YES;
            
            static BOOL hasGotRefreshToken = NO;
            
            AFHTTPRequestOperation *refreshTokenRequestOperation = [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:nil startImmediately:NO configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                if (!error) {
                    [self appendLog:@"got refresh token"];
                } else {
                    [self appendLog:[NSString stringWithFormat:@"refresh token fetch failed:%@", error]];
                }
                hasGotRefreshToken = YES;
            }];
            
            AFHTTPRequestOperation *reAssembledOperation = [[STRequestManager sharedInstance] reAssembleOperation:operation];
            
            [[STRequestManager sharedInstance] addOperation:refreshTokenRequestOperation toChain:@"refreshToken"];
            [[STRequestManager sharedInstance] addOperation:reAssembledOperation toChain:@"refreshToken"];
        }
    };
    
    [STRequestManager sharedInstance].configuration = configuration;
    
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/2" parameters:nil startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        [self appendLog:result.description];
    }];
}

- (void)showLoadingWhenSendingRequest
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.frame = CGRectMake(self.view.frame.size.width / 2 - 8, self.view.frame.size.height / 2 - 8, 16, 16);
    [self.view addSubview:indicatorView];
    
    configuration.requestHandler = ^(AFHTTPRequestOperation *operation, id userInfo, BOOL *shouldStopProcessing) {
        if (userInfo[@"showLoading"]) {
            [indicatorView startAnimating];
        }
    };
    
    configuration.responseHandler = ^(AFHTTPRequestOperation *operation, id userInfo, STResponse *response, BOOL *shouldStopProcessing) {
        if (userInfo[@"showLoading"]) {
            [indicatorView stopAnimating];
        }
    };
    
    [STRequestManager sharedInstance].configuration = configuration;
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/2"
                                 parameters:nil
                           startImmediately:YES
                       configurationHandler:^(STRequestManagerConfiguration *configuration){
                           configuration.userInfo = @{@"showLoading": @YES};
                           configuration.resultCacheDuration = 30;
                       } completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
                           [self appendLog:result.description];
                           [self appendLog:[NSString stringWithFormat:@"来自缓存:%@", isFromCache ? @"是" : @"否"]];
                       }];
}

- (void)calculateRequestTime
{
    STRequestManagerConfiguration *configuration = [[STRequestManagerConfiguration alloc] init];
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    configuration.responseHandler = ^(AFHTTPRequestOperation *operation, id userInfo, STResponse *response, BOOL *shouldStopProcessing) {
        [self appendLog:[NSString stringWithFormat:@"此次请求花费了:%f秒", [[NSDate date] timeIntervalSince1970] - startTime]];
    };
    
    [STRequestManager sharedInstance].configuration = configuration;
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/2" parameters:nil startImmediately:YES configurationHandler:^(STRequestManagerConfiguration *configuration){
        // 这里还可以再加一些自定义的 userInfo
    } completionHandler:^(NSError *error, id<NSObject> result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        [self appendLog:result.description];
    }];
}

- (void)uploadImage
{
    UIImage *image = [UIImage imageNamed:@"warren.jpg"];
    NSInteger positionX = self.resultTextView.frame.size.width / 2 - 121;
    NSInteger positionY = self.resultTextView.frame.size.height / 2 - 80;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, positionY, 242, 160)];
    [self.resultTextView addSubview:imageView];
    
    // 为了这个 Demo 特地去申请一个 APIKey···
    NSDictionary *parameters = @{
                                 @"key": @"03CFKLSU25b1dddc62545683bad52f8796bb110c",
                                 @"format": @"json",
                                 };
    
    [[STRequestManager sharedInstance] POST:@"https://post.imageshack.us/upload_api.php" parameters:parameters startImmediately:YES constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.75) name:@"fileupload" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    } configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        if (!error) {
            [self appendLog:@"图片上传成功，正在下载显示..."];
            [imageView setImageWithURL:[NSURL URLWithString:result[@"links"][@"image_link"]]];
        } else {
            [self appendLog:error.description];
        }
    }];
}

- (void)addHeaderValues
{
    STRequestManagerConfiguration *configuration = [STRequestManager sharedInstance].configuration;
    configuration.builtinParameters = @{@"operationSys":@"ios",@"requestTool":@"ST"};
    
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:nil startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        if (!error) {
            [self appendLog:[result description]];
        } else {
            [self appendLog:error.description];
        }
    }];

}

@end
