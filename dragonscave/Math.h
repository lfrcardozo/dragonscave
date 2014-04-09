//
//  Math.h
//  dragonscave
//
//  Created by Luiz Fernando Ramos Cardozo on 08/04/14.
//  Copyright (c) 2014 Luiz Fernando Ramos Cardozo. All rights reserved.


#import <Foundation/Foundation.h>

@interface Math : NSObject

+ (void) setRandomSeed:(unsigned int) seed;
+ (float) randomFloatBetween:(float) min and:(float) max;

@end
