//
//  SKScrollingNode.h
//  dragonscave
//
//  Created by Luiz Fernando Ramos Cardozo on 08/04/14.
//  Copyright (c) 2014 Luiz Fernando Ramos Cardozo. All rights reserved.
//



@interface SKScrollingNode : SKSpriteNode

@property (nonatomic) CGFloat scrollingSpeed;

+ (id) scrollingNodeWithImageNamed:(NSString *)name inContainerWidth:(float) width;
- (void) update:(NSTimeInterval)currentTime;

@end
