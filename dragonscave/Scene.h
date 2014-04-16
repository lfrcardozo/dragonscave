//
//  MyScene.h
//  dragonscave
//

//  Copyright (c) 2014 Luiz Fernando Ramos Cardozo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
@import AVFoundation;

@protocol SceneDelegate <NSObject>
- (void) eventStart;
- (void) eventPlay;
- (void) eventWasted;
@end

@interface Scene : SKScene<SKPhysicsContactDelegate>

@property (unsafe_unretained,nonatomic) id<SceneDelegate> delegate;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic)	AVAudioPlayer* audioPlayer;

- (void) startGame;

@end


