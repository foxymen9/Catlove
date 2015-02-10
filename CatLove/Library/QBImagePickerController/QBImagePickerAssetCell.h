//
//  QBImagePickerAssetCell.h
//  CatLove
//
//  Created by astraea on 6/24/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import <UIKit/UIKit.h>

// Delegate
#import "QBImagePickerAssetCellDelegate.h"
#import "QBImagePickerAssetViewDelegate.h"

@interface QBImagePickerAssetCell : UITableViewCell <QBImagePickerAssetViewDelegate>

@property (nonatomic, assign) id<QBImagePickerAssetCellDelegate> delegate;
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin;

- (void)selectAssetAtIndex:(NSUInteger)index;
- (void)deselectAssetAtIndex:(NSUInteger)index;
- (void)selectAllAssets;
- (void)deselectAllAssets;
- (void)assignAssets:(NSArray *)assets;

@end
