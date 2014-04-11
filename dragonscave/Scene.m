//
//  Scene.m
//  dragonscave
//
//  Created by Luiz Fernando Ramos Cardozo on 09/04/14.
//  Copyright (c) 2014 Luiz Fernando Ramos Cardozo. All rights reserved.
//


#import "Scene.h"
#import "SKScrollingNode.h"
#import "DragonNode.h"
#import "Score.h"

#define BACK_SCROLLING_SPEED .5
#define FLOOR_SCROLLING_SPEED 3

// Obstacles
#define VERTICAL_GAP_SIZE 120
#define FIRST_OBSTACLE_PADDING 100
#define OBSTACLE_MIN_HEIGHT 50 //60
#define OBSTACLE_INTERVAL_SPACE 130

@implementation Scene{
    SKScrollingNode * floor;
    SKScrollingNode * back;
    SKLabelNode * scoreLabel;
    DragonNode * dragon;
    
    int nbObstacles;
    NSMutableArray * topPipes;
    NSMutableArray * bottomPipes;
}

static bool wasted = NO;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //self.physicsWorld.contactDelegate = self;
        //self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        [self startGame];
    }
    return self;
}

- (void) startGame {
    // Reinit
    wasted = NO;
    
    [self removeAllChildren];
    
    [self createBackground];
    [self createFloor];
    [self createScore];
    [self createObstacles];
    [self createDragon];
    
    // Floor needs to be in front of tubes
    floor.zPosition = dragon.zPosition + 1;
    
    if([self.delegate respondsToSelector:@selector(eventStart)]) {
        [self.delegate eventStart];
    }
}

#pragma mark - Creations

- (void) createBackground {
    back = [SKScrollingNode scrollingNodeWithImageNamed:@"back1" inContainerWidth:WIDTH(self)];
    [back setScrollingSpeed:BACK_SCROLLING_SPEED];
    [back setAnchorPoint: CGPointZero];
    [back setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    back.physicsBody.categoryBitMask = backBitMask;
    back.physicsBody.contactTestBitMask = dragonBitMask;
    [self addChild:back];
}

- (void) createScore {
    self.score = 0;
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    scoreLabel.text = @"0";
    scoreLabel.fontSize = 150; //500;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    scoreLabel.alpha = 0.2;
    [self addChild:scoreLabel];
}


- (void)createFloor {
    floor = [SKScrollingNode scrollingNodeWithImageNamed:@"floor4" inContainerWidth:WIDTH(self)];
    [floor setScrollingSpeed:FLOOR_SCROLLING_SPEED];
    [floor setAnchorPoint:CGPointZero];
    [floor setName:@"floor"];
    [floor setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:floor.frame]];
    floor.physicsBody.categoryBitMask = floorBitMask;
    floor.physicsBody.contactTestBitMask = dragonBitMask;
    [self addChild:floor];
}

- (void)createDragon {
    dragon = [DragonNode new];
    [dragon setPosition:CGPointMake(100, CGRectGetMidY(self.frame))];
    [dragon setName:@"dragon"];
    [self addChild:dragon];
}

- (void) createObstacles {
    // Calculate how many obstacles we need, the less the better
    nbObstacles = ceil(WIDTH(self)/(OBSTACLE_INTERVAL_SPACE));
    
    CGFloat lastBlockPos = 0;
    bottomPipes = @[].mutableCopy;
    topPipes = @[].mutableCopy;
    for(int i=0;i<nbObstacles;i++){
        
        SKSpriteNode * topPipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe_top"];
        [topPipe setAnchorPoint: CGPointZero];
        [self addChild:topPipe];
        [topPipes addObject:topPipe];
        
        SKSpriteNode * bottomPipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe_bottom"];
        [bottomPipe setAnchorPoint:CGPointZero];
        [self addChild:bottomPipe];
        [bottomPipes addObject:bottomPipe];
        
        // Give some time to the player before first obstacle
        if(0 == i){
            [self place:bottomPipe and:topPipe atX:WIDTH(self)+FIRST_OBSTACLE_PADDING];
        }else{
            [self place:bottomPipe and:topPipe atX:lastBlockPos + WIDTH(bottomPipe) +OBSTACLE_INTERVAL_SPACE];
        }
        lastBlockPos = topPipe.position.x;
    }
}

#pragma mark - Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
         [self.scene.view setPaused:NO];
    if (    self.scene.view.isPaused==NO){
    if(wasted){

        [self startGame];
    } else {
        if(!dragon.physicsBody) {
            [dragon startPlaying];
            if([self.delegate respondsToSelector:@selector(eventPlay)]){
                [self.delegate eventPlay];
            }
        }
        [dragon bounce];
    }
    }
    
   

    
}

#pragma mark - Update & Core logic
- (void)update:(NSTimeInterval)currentTime {
    if(wasted) {
        return;
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    // ScrollingNodes
    [back update:currentTime];
    [floor update:currentTime];
    
    // Other
    [dragon update:currentTime];
    [self updateObstacles:currentTime];
    [self updateScore:currentTime];
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void) updateObstacles:(NSTimeInterval)currentTime {
    if(!dragon.physicsBody) {
        return;
    }
    
    for(int i=0;i<nbObstacles;i++) {
        // Get pipes bby pairs
        SKSpriteNode * topPipe = (SKSpriteNode *) topPipes[i];
        SKSpriteNode * bottomPipe = (SKSpriteNode *) bottomPipes[i];
        
        // Check if pair has exited screen, and place them upfront again
        if (X(topPipe) < -WIDTH(topPipe)) {
            SKSpriteNode * mostRightPipe = (SKSpriteNode *) topPipes[(i+(nbObstacles-1))%nbObstacles];
            [self place:bottomPipe and:topPipe atX:X(mostRightPipe)+WIDTH(topPipe)+OBSTACLE_INTERVAL_SPACE];
        }

        // Move according to the scrolling speed
        topPipe.position = CGPointMake(X(topPipe) - FLOOR_SCROLLING_SPEED, Y(topPipe));
        bottomPipe.position = CGPointMake(X(bottomPipe) - FLOOR_SCROLLING_SPEED, Y(bottomPipe));
    }
}

- (void) place:(SKSpriteNode *) bottomPipe and:(SKSpriteNode *) topPipe atX:(float) xPos {
    // Maths
    float availableSpace = HEIGHT(self) - HEIGHT(floor);
    float maxVariance = availableSpace - (2*OBSTACLE_MIN_HEIGHT) - VERTICAL_GAP_SIZE;
    float variance = [Math randomFloatBetween:0 and:maxVariance];
    
    // Bottom pipe placement
    float minBottomPosY = HEIGHT(floor) + OBSTACLE_MIN_HEIGHT - HEIGHT(self);
    float bottomPosY = minBottomPosY + variance - 200;
    bottomPipe.position = CGPointMake(xPos,bottomPosY);
    bottomPipe.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0,0, WIDTH(bottomPipe) ,HEIGHT(bottomPipe))];
    bottomPipe.physicsBody.categoryBitMask = blockBitMask;
    bottomPipe.physicsBody.contactTestBitMask = dragonBitMask;
    
    // Top pipe placement
    topPipe.position = CGPointMake(xPos,bottomPosY + HEIGHT(bottomPipe) + VERTICAL_GAP_SIZE);
    topPipe.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0,0, WIDTH(topPipe), HEIGHT(topPipe))];
    
    topPipe.physicsBody.categoryBitMask = blockBitMask;
    topPipe.physicsBody.contactTestBitMask = dragonBitMask;
}

- (void) updateScore:(NSTimeInterval) currentTime {
    for(int i=0;i<nbObstacles;i++) {
        SKSpriteNode * topPipe = (SKSpriteNode *) topPipes[i];

        // Score, adapt font size
        if(X(topPipe) + WIDTH(topPipe)/2 > dragon.position.x &&
           X(topPipe) + WIDTH(topPipe)/2 < dragon.position.x + FLOOR_SCROLLING_SPEED) {
            self.score +=1;
            scoreLabel.text = [NSString stringWithFormat:@"%lu",(long)self.score];
            if(self.score>=10) {
                scoreLabel.fontSize = 340;
                scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 120);
            }
        }
    }
}

- (void)addMonster {
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"medal_gold"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

/*
 - (void)addMonster {
 // Create sprite
 SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"medal_gold"];
 
 // Determine where to spawn the monster along the Y axis
 int minY = monster.size.height / 2;
 int maxY = self.frame.size.height - monster.size.height / 2;
 int rangeY = maxY - minY;
 int actualY = (arc4random() % rangeY) + minY;
 
 // Create the monster slightly off-screen along the right edge,
 // and along a random position along the Y axis as calculated above
 monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
 monster.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-monster.size.width/2,-monster.size.height/2, monster.size.width ,monster.size.height)]; // funcionando[SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0,0, monster.size.width ,monster.size.height)];//
 monster.physicsBody.dynamic = YES; // 2
 monster.physicsBody.categoryBitMask = monsterCategory; // 3
 monster.physicsBody.contactTestBitMask = projectileCategory; // 4
 monster.physicsBody.collisionBitMask = 0; // 5
 
 [self addChild:monster];
 
 // Determine speed of the monster
 int minDuration = 2.0;
 int maxDuration = 4.0;
 int rangeDuration = maxDuration - minDuration;
 int actualDuration = (arc4random() % rangeDuration) + minDuration;
 
 // Create the actions
 SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
 SKAction * actionMoveDone = [SKAction removeFromParent];
 [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
 
 }
 */

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    if(!dragon.physicsBody) {
        return;
    }
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 3) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

#pragma mark - Physic
- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(wasted){ return; }
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    //3
    if ((firstBody.categoryBitMask & dragonBitMask) != 0 &&
        (secondBody.categoryBitMask & blockBitMask) !=0) {
        wasted = true;
        [Score registerScore:self.score];
        [self.delegate eventWasted];
    }
    
    if ((firstBody.categoryBitMask & dragonBitMask) != 0 &&
        (secondBody.categoryBitMask & floorBitMask) !=0) {
        wasted = true;
        [Score registerScore:self.score];
        [self.delegate eventWasted];
    }
    
    if ((firstBody.categoryBitMask & backBitMask) != 0 &&
        (secondBody.categoryBitMask & dragonBitMask) !=0) {
        wasted = true;
        [Score registerScore:self.score];
        [self.delegate eventWasted];
    }
    
    if ((firstBody.categoryBitMask & dragonBitMask) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) !=0) {
        wasted = true;
        [Score registerScore:self.score];
        [self.delegate eventWasted];
    }
}

//ATIRAR FOGO
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"fogo2"];
    projectile.position = CGPointMake((dragon.position.x + 40), (dragon.position.y - 5));//dragon.position + (dragon.size.width);
    projectile.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-projectile.size.width/2,-projectile.size.height/2, projectile.size.width ,projectile.size.height)]; //[SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0,0, projectile.size.width ,projectile.size.height)];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/3.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Hit");
    [projectile removeFromParent];
    [monster removeFromParent];
}

@end
