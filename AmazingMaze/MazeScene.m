//
//  MazeScene.m
//  AmazingMaze
//
//  Created by Megan Potoski on 7/22/13.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "MazeScene.h"

@interface MazeScene ()
@property BOOL contentCreated;
@end

@implementation MazeScene

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor blueColor];
    [self makeBucket];
    SKAction *makePlatforms = [SKAction sequence:@[
                                                   [SKAction performSelector:@selector(makePlatform) onTarget:self],
                                                   [SKAction waitForDuration:0.8]]];
    [self runAction:[SKAction repeatActionForever:makePlatforms]];
    SKAction *makeBalls = [SKAction sequence:@[
                                               [SKAction performSelector:@selector(makeBall) onTarget:self],
                                               [SKAction waitForDuration:3.0]]];
    [self runAction:[SKAction repeatActionForever:makeBalls]];
}

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)makePlatform {
    int random = arc4random() % 2;
    if (random == 0) [self makeLeftPlatform];
    else [self makeRightPlatform];
}

- (void)makeRightPlatform {
    SKSpriteNode *platform = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(80, 10)];
    platform.position = CGPointMake(self.size.width, skRand(100, self.size.height - 100));
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
    platform.physicsBody.dynamic = NO;
    float duration = skRand(1.0, 4.0);
    SKAction *moveLeft = [SKAction moveByX:-400.0 y:0 duration:duration];
    platform.name = @"platform";
    [self addChild:platform];
    [platform runAction:moveLeft];
}

- (void)makeLeftPlatform {
    SKSpriteNode *platform = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(80, 10)];
    platform.position = CGPointMake(0, skRand(100, self.size.height - 100));
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
    platform.physicsBody.dynamic = NO;
    float duration = skRand(1.0, 4.0);
    SKAction *moveRight = [SKAction moveByX:400.0 y:0 duration:duration];
    platform.name = @"platform";
    [self addChild:platform];
    [platform runAction:moveRight];
}

- (void)makeBall {
    SKSpriteNode *ball = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(10, 10)];
    ball.position = CGPointMake(skRand(80, self.size.width - 80), self.size.height);
    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
    ball.name = @"ball";
    [self addChild:ball];
}

- (void)makeBucket {
    SKSpriteNode *bucket = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(50, 25)];
    bucket.position = CGPointMake((self.size.width / 2), 25);
    bucket.name = @"bucket";
    [self addChild:bucket];
}

@end
