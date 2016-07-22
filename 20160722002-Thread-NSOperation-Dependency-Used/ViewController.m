//
//  ViewController.m
//  20160722002-Thread-NSOperation-Dependency-Used
//
//  Created by Rainer on 16/7/22.
//  Copyright © 2016年 Rainer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 队列中线程的通讯
//    [self threadSendMessage];
    
    // 使用队列下载两张图片并且合并显示
    [self downloadAndComposedImages];
}

/**
 *  队列间的线程通讯
 */
- (void)threadSendMessage {
    // 创建一个队列（异步），并在队列里添加一个任务
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // 创建图片地址
        NSURL *imageUrl = [NSURL URLWithString:@"http://pic61.nipic.com/file/20150228/7487939_190907874000_2.jpg"];
        
        // 下载图片
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        
        // 回到主队列显示图片
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
}

/**
 *  下载并且合并图片
 */
- (void)downloadAndComposedImages {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    
    __block UIImage *image1 = nil;
    __block UIImage *image2 = nil;
    
    // 1.下载第一张图片
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        // 创建图片地址
        NSURL *imageUrl = [NSURL URLWithString:@"http://pic61.nipic.com/file/20150228/7487939_190907874000_2.jpg"];
        
        // 下载图片
        image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }];
    
    // 2.下载第二张图片
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *imageUrl = [NSURL URLWithString:@"http://img.tuku.cn/file_big/201505/d620f7e86cb84799aa62b8c9ef50d938.jpg"];
        
        image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }];
    
    // 3.合成这两张图片
    NSBlockOperation *composedBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
        // 1.开启一个图形上下文
        UIGraphicsBeginImageContext(self.imageView.bounds.size);
        
        // 2.将图片画入上下文中，并清空图片
        [image1 drawInRect:CGRectMake(0, 0, 150, 300)];
        [image2 drawInRect:CGRectMake(150, 0, 150, 300)];
        
        image1 = nil;
        image2 = nil;
        
        // 3.生成一张新的图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 4.关闭图形上下文
        UIGraphicsEndImageContext();
        
        // 5.回到主队列显示图片
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
    
    // 4.设置任务依赖
    [composedBlockOperation addDependency:blockOperation1];
    [composedBlockOperation addDependency:blockOperation2];
    
    // 5.将任务添加到队列中（开启任务）
    [operationQueue addOperation:blockOperation1];
    [operationQueue addOperation:blockOperation2];
    
    [operationQueue addOperation:composedBlockOperation];
}

@end
