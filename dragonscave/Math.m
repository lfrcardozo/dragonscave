//
//  Math.m
//  dragonscave
//
//  Created by Luiz Fernando Ramos Cardozo on 08/04/14.
//  Copyright (c) 2014 Luiz Fernando Ramos Cardozo. All rights reserved.
//

#import "Math.h"

static unsigned int _seed = 0;

@implementation Math

+ (void)setRandomSeed:(unsigned int)seed
{
    _seed = seed;
    srand(_seed);
}

+ (float) randomFloatBetween:(float) min and:(float) max{
    
    float random =  ((rand()%RAND_MAX)/(RAND_MAX*1.0))*(max-min)+min;
    return random;
}

@end
