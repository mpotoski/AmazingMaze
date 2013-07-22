//
//  MAPViewController.m
//  AmazingMaze
//
//  Created by Megan Potoski on 7/22/13.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "MAPViewController.h"
#import "MazeScene.h"
#import <SpriteKit/SpriteKit.h>

@interface MAPViewController ()

@end

@implementation MAPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    MazeScene *maze = [[MazeScene alloc] initWithSize:self.view.bounds.size];
    SKView *spriteView = (SKView *)self.view;
    [spriteView presentScene:maze];
}

@end
