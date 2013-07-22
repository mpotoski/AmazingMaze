//
//  MazeScene.m
//  AmazingMaze
//
//  Created by Megan Potoski on 7/22/13.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "MazeScene.h"

const uint32_t BALL     = 0x1 << 0;
const uint32_t PLATFORM = 0x1 << 1;
const uint32_t BUCKET   = 0x1 << 2;
const uint32_t SPIKES   = 0x1 << 3;

@interface MazeScene ()
@property BOOL contentCreated;
@property BOOL canMakeBall;
@end

@implementation MazeScene

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}


#pragma mark - Create scene

- (void)createSceneContents {
    self.backgroundColor = [SKColor blueColor];
    self.physicsWorld.contactDelegate = self;
    [self makeBucket];
    [self makeSpikes];
    SKAction *makePlatforms = [SKAction sequence:@[
                                                   [SKAction performSelector:@selector(makePlatform) onTarget:self],
                                                   [SKAction waitForDuration:0.3]]];
    [self runAction:[SKAction repeatActionForever:makePlatforms]];
    self.canMakeBall = YES;
    [self makeBall];
}

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}


#pragma mark - Node creation

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
    SKAction *moveLeft = [SKAction moveByX:-600.0 y:0 duration:duration];
    platform.name = @"platform";
    platform.physicsBody.categoryBitMask = PLATFORM;
    platform.physicsBody.collisionBitMask = BALL;
    platform.physicsBody.contactTestBitMask = BALL;
    [self addChild:platform];
    [platform runAction:moveLeft];
}

- (void)makeLeftPlatform {
    SKSpriteNode *platform = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(80, 10)];
    platform.position = CGPointMake(0, skRand(100, self.size.height - 100));
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
    platform.physicsBody.dynamic = NO;
    float duration = skRand(1.0, 4.0);
    SKAction *moveRight = [SKAction moveByX:600.0 y:0 duration:duration];
    platform.name = @"platform";
    platform.physicsBody.categoryBitMask = PLATFORM;
    platform.physicsBody.collisionBitMask = BALL;
    platform.physicsBody.contactTestBitMask = BALL;
    [self addChild:platform];
    [platform runAction:moveRight];
}

- (void)makeBall {
    SKSpriteNode *ball = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(12, 12)];
    ball.position = CGPointMake(skRand(80, self.size.width - 80), self.size.height);
    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
    ball.physicsBody.categoryBitMask = BALL;
    ball.physicsBody.collisionBitMask = PLATFORM | BUCKET | SPIKES;
    ball.physicsBody.contactTestBitMask = PLATFORM | BUCKET | SPIKES;
    ball.name = @"ball";
    [self addChild:ball];
}

- (void)checkForBall {
    bool ballExists __block = NO;
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        ballExists = YES;
    }];
    NSLog(@"Ball exists: %i", ballExists);
    if (!ballExists) {
        [self makeBall];
    }
}

- (void)makeBucket {
    SKSpriteNode *bucket = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(50, 25)];
    bucket.position = CGPointMake((self.size.width / 2), bucket.size.height / 2);
    bucket.name = @"bucket";
    bucket.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bucket.size];
    bucket.physicsBody.dynamic = NO;
    bucket.physicsBody.categoryBitMask = BUCKET;
    bucket.physicsBody.collisionBitMask = BALL;
    bucket.physicsBody.contactTestBitMask = BALL;
    [self addChild:bucket];
}

- (void)makeSpikes {
    SKSpriteNode *spikes = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(135, 25)];
    spikes.position = CGPointMake(spikes.size.width / 2, spikes.size.height / 2);
    spikes.name = @"spikes";
    spikes.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spikes.size];
    spikes.physicsBody.dynamic = NO;
    spikes.physicsBody.categoryBitMask = SPIKES;
    spikes.physicsBody.collisionBitMask = BALL;
    spikes.physicsBody.contactTestBitMask = BALL;
    [self addChild:spikes];
    spikes = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(135, 25)];
    spikes.position = CGPointMake(self.size.width - spikes.size.width / 2, spikes.size.height / 2);
    spikes.name = @"spikes";
    spikes.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spikes.size];
    spikes.physicsBody.dynamic = NO;
    spikes.physicsBody.categoryBitMask = SPIKES;
    spikes.physicsBody.collisionBitMask = BALL;
    spikes.physicsBody.contactTestBitMask = BALL;
    [self addChild:spikes];
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:@"platform" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < -80 || node.position.x > self.size.width + 80) {
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < 0 || node.position.x > self.size.width) {
            [node removeFromParent];
            [self checkForBall];
        }
    }];
}


#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node.name isEqualToString:@"ball"] && [contact.bodyB.node.name isEqualToString:@"bucket"]) {
        [contact.bodyA.node removeFromParent];
        NSLog(@"SCORE ++");
        [self checkForBall];
    } else if ([contact.bodyB.node.name isEqualToString:@"ball"] && [contact.bodyA.node.name isEqualToString:@"bucket"]) {
        [contact.bodyB.node removeFromParent];
        NSLog(@"SCORE ++");
        [self checkForBall];
    } else if ([contact.bodyA.node.name isEqualToString:@"ball"] && [contact.bodyB.node.name isEqualToString:@"spikes"]) {
        [contact.bodyA.node removeFromParent];
        NSLog(@"SCORE --");
        [self checkForBall];
    } else if ([contact.bodyB.node.name isEqualToString:@"ball"] && [contact.bodyA.node.name isEqualToString:@"spikes"]) {
        [contact.bodyB.node removeFromParent];
        NSLog(@"SCORE --");
        [self checkForBall];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

@end
