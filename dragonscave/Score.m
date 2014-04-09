//
//  Score.m
//  dragonscave
//

#import "Score.h"

@implementation Score

+ (void)registerScore:(NSInteger)score
{
    if(score > [Score bestScore]){
        [Score setBestScore:score];
    }
}

+ (void) setBestScore:(NSInteger) bestScore
{
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:kBestScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) bestScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBestScoreKey];
}

@end
