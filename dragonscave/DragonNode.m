//
//  DragonNode.m
//  spritybird
//
//  Created by Alexis Creuzot on 16/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "DragonNode.h"

#define VERTICAL_SPEED 1
#define VERTICAL_DELTA 5.0

@interface DragonNode ()
@property (strong,nonatomic) SKAction * flap;
@property (strong,nonatomic) SKAction * flapForever;
@end

@implementation DragonNode

static CGFloat deltaPosY = 0;
static bool goingUp = false;

- (id)init
{
    if(self = [super init]){
        
        // TODO : use texture atlas
        SKTexture* dragonTexture1 = [SKTexture textureWithImageNamed:@"dragon_1"];
        dragonTexture1.filteringMode = SKTextureFilteringNearest;
        SKTexture* dragonTexture2 = [SKTexture textureWithImageNamed:@"dragon_2"];
        dragonTexture2.filteringMode = SKTextureFilteringNearest;
        SKTexture* dragonTexture3 = [SKTexture textureWithImageNamed:@"dragon_3"];
        dragonTexture3.filteringMode = SKTextureFilteringNearest;
        SKTexture* dragonTexture4 = [SKTexture textureWithImageNamed:@"dragon_2"];
        dragonTexture4.filteringMode = SKTextureFilteringNearest;

        self = [DragonNode spriteNodeWithTexture:dragonTexture1];
        
        self.flap = [SKAction animateWithTextures:@[dragonTexture1, dragonTexture2,dragonTexture3,dragonTexture2] timePerFrame:0.2];
        self.flapForever = [SKAction repeatActionForever:self.flap];
        
        [self setTexture:dragonTexture1];
        [self runAction:self.flapForever withKey:@"flapForever"];
    }
    return self;
}

- (void) update:(NSUInteger) currentTime
{
    if(!self.physicsBody){
        if(deltaPosY > VERTICAL_DELTA){
            goingUp = false;
        }
        if(deltaPosY < -VERTICAL_DELTA){
            goingUp = true;
        }
        
        float displacement = (goingUp)? VERTICAL_SPEED : -VERTICAL_SPEED;
        self.position = CGPointMake(self.position.x, self.position.y + displacement);
        deltaPosY += displacement;
    }
    
    // Rotate body based on Y velocity (front toward direction)
    self.zRotation = (M_PI/2) * self.physicsBody.velocity.dy * 0.0005; 
    
}

- (void) startPlaying
{
    deltaPosY = 0;
    [self setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(26, 18)]];
    self.physicsBody.categoryBitMask = dragonBitMask;
    self.physicsBody.dynamic = YES; //testeeeee
    self.physicsBody.mass = 0.1;
    [self removeActionForKey:@"flapForever"];
}

- (void) bounce
{
    [self.physicsBody setVelocity:CGVectorMake(0, 0)];
    [self.physicsBody applyImpulse:CGVectorMake(0, 40)];
    [self runAction:self.flap];
}

@end
