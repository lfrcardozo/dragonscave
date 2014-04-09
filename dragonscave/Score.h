//
//  Score.h
//  dragonscave
//

#define kBestScoreKey @"BestScore"

@interface Score : NSObject

+ (void) registerScore:(NSInteger) score;
+ (void) setBestScore:(NSInteger) bestScore;
+ (NSInteger) bestScore;

@end
