//
//  CATPetDetailScene.h
//  CatLove
//
//  Created by astraea on 9/12/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CATPetDetailScene : SKScene

@property (nonatomic, strong) SKAction *spriteAnimation;
@property (nonatomic, strong) SKSpriteNode *sprite;
@property (nonatomic, strong) SKSpriteNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *petNode;

- (void) loadPetImage:(UIImage *) petImage;

@end
