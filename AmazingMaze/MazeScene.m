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
@property int score;
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
    self.backgroundColor = [SKColor whiteColor];
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGPointMake(0, -5);
    self.score = 0;
    [self makeBucket];
    [self makeSpikes];
    [self makeScoreLabel];
    SKAction *makePlatforms = [SKAction sequence:@[
                                                   [SKAction performSelector:@selector(makePlatform) onTarget:self],
                                                   [SKAction waitForDuration:0.3]]];
    [self runAction:[SKAction repeatActionForever:makePlatforms]];
    [self makeBall];
}

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}


#pragma mark - Node creation

- (void)makeScoreLabel {
    SKLabelNode *scoreLabel = [[SKLabelNode alloc] init];
    scoreLabel.text = @"Score: 0";
    scoreLabel.fontSize = 18;
    scoreLabel.fontColor = [SKColor blackColor];
    scoreLabel.position = CGPointMake(50, self.size.height - 50);
    scoreLabel.name = @"score";
    [self addChild:scoreLabel];
}

- (void)makePlatform {
    int random = arc4random() % 2;
    if (random == 0) [self makeLeftPlatform];
    else [self makeRightPlatform];
}

- (void)makeRightPlatform {
    SKSpriteNode *platform = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(80, 10)];
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
    SKSpriteNode *platform = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(80, 10)];
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

- (void)makeBucket {
    SKSpriteNode *bucket = [[SKSpriteNode alloc] initWithColor:[SKColor greenColor] size:CGSizeMake(30, 20)];
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
    SKSpriteNode *spikes = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(145, 20)];
    spikes.position = CGPointMake(spikes.size.width / 2, spikes.size.height / 2);
    spikes.name = @"spikes";
    spikes.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spikes.size];
    spikes.physicsBody.dynamic = NO;
    spikes.physicsBody.categoryBitMask = SPIKES;
    spikes.physicsBody.collisionBitMask = BALL;
    spikes.physicsBody.contactTestBitMask = BALL;
    [self addChild:spikes];
    spikes = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(145, 20)];
    spikes.position = CGPointMake(self.size.width - spikes.size.width / 2, spikes.size.height / 2);
    spikes.name = @"spikes";
    spikes.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spikes.size];
    spikes.physicsBody.dynamic = NO;
    spikes.physicsBody.categoryBitMask = SPIKES;
    spikes.physicsBody.collisionBitMask = BALL;
    spikes.physicsBody.contactTestBitMask = BALL;
    [self addChild:spikes];
}


#pragma mark - Game play

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    if (location.x < self.size.width / 2) {
        // touch on left half of screen
        [self handleLeftTouch];
    } else {
        // touch on right half of screen
        [self handleRightTouch];
    }
}

- (void)handleLeftTouch {
    NSLog(@"touch on left");
    SKSpriteNode *ball = (SKSpriteNode *)[self childNodeWithName:@"ball"];
    SKAction *moveLeft = [SKAction moveByX:-30.0 y:0 duration:0.2];
    [ball runAction:moveLeft];
}

- (void)handleRightTouch {
    NSLog(@"touch on right");
    SKSpriteNode *ball = (SKSpriteNode *)[self childNodeWithName:@"ball"];
    SKAction *moveRight = [SKAction moveByX:30.0 y:0 duration:0.2];
    [ball runAction:moveRight];
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
            [self downScore];
            [self checkForBall];
        }
    }];
}

- (void)upScore {
    self.score++;
    SKLabelNode *scoreLabel = (SKLabelNode *)[self childNodeWithName:@"score"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %i", self.score];
}

- (void)downScore {
    self.score--;
    SKLabelNode *scoreLabel = (SKLabelNode *)[self childNodeWithName:@"score"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %i", self.score];
}

- (void)checkForBall {
    SKNode *ball = [self childNodeWithName:@"ball"];
    if (ball == nil) [self makeBall];
}


#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node.name isEqualToString:@"ball"] && [contact.bodyB.node.name isEqualToString:@"bucket"]) {
        [contact.bodyA.node removeFromParent];
        [self upScore];
        [self checkForBall];
    } else if ([contact.bodyB.node.name isEqualToString:@"ball"] && [contact.bodyA.node.name isEqualToString:@"bucket"]) {
        [contact.bodyB.node removeFromParent];
        [self upScore];
        [self checkForBall];
    } else if ([contact.bodyA.node.name isEqualToString:@"ball"] && [contact.bodyB.node.name isEqualToString:@"spikes"]) {
        [contact.bodyA.node removeFromParent];
        [self downScore];
        [self checkForBall];
    } else if ([contact.bodyB.node.name isEqualToString:@"ball"] && [contact.bodyA.node.name isEqualToString:@"spikes"]) {
        [contact.bodyB.node removeFromParent];
        [self downScore];
        [self checkForBall];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
}

@end
