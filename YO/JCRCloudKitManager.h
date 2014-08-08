//
//  JCRCloudKitManager.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCRCloudKitManager : NSObject

+ (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock;

@end
