//
//  QBImagePickerAssetView.m
//  CatLove
//
//  Created by astraea on 6/24/14.
//  Copyright (c) 2014 Will Han. All rights reserved.
//

#import "QBImagePickerAssetCell.h"
#import "QBImagePickerAssetView.h"

@interface QBImagePickerAssetCell ()

- (void)addAssetViews;

@end

@implementation QBImagePickerAssetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.imageSize = imageSize;
        self.numberOfAssets = numberOfAssets;
        self.margin = margin;
        
        [self addAssetViews];
    }
    
    return self;
}

- (void)assignAssets:(NSArray *)assets
{
    self.assets = assets ;
    
    // Set assets
    for(NSUInteger i = 0; i < self.numberOfAssets; i++) {
        QBImagePickerAssetView *assetView = (QBImagePickerAssetView *)[self.contentView viewWithTag:(1 + i)];
        
        if(i < self.assets.count) {
            assetView.hidden = NO;
            
            [assetView assignAsset:[self.assets objectAtIndex:i]];
        } else {
            assetView.hidden = YES;
        }
    }
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    // Set property
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[QBImagePickerAssetView class]]) {
            [(QBImagePickerAssetView *)subview setAllowsMultipleSelection:self.allowsMultipleSelection];
        }
    }
}

- (void)dealloc
{
}


#pragma mark - Instance Methods

- (void)addAssetViews
{
    // Remove all asset views
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[QBImagePickerAssetView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    // Add asset views
    for(NSUInteger i = 0; i < self.numberOfAssets; i++) {
        // Calculate frame
        CGFloat offset = (self.margin + self.imageSize.width) * i;
        CGRect assetViewFrame = CGRectMake(offset + self.margin, self.margin, self.imageSize.width, self.imageSize.height);
        
        // Add asset view
        QBImagePickerAssetView *assetView = [[QBImagePickerAssetView alloc] initWithFrame:assetViewFrame];
        assetView.delegate = self;
        assetView.tag = 1 + i;
        assetView.autoresizingMask = UIViewAutoresizingNone;
        
        [self.contentView addSubview:assetView];
    }
}

- (void)selectAssetAtIndex:(NSUInteger)index
{
    QBImagePickerAssetView *assetView = (QBImagePickerAssetView *)[self.contentView viewWithTag:(index + 1)];
    assetView.selected = YES;
}

- (void)deselectAssetAtIndex:(NSUInteger)index
{
    QBImagePickerAssetView *assetView = (QBImagePickerAssetView *)[self.contentView viewWithTag:(index + 1)];
    assetView.selected = NO;
}

- (void)selectAllAssets
{
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[QBImagePickerAssetView class]]) {
            if(![(QBImagePickerAssetView *)subview isHidden]) {
                [(QBImagePickerAssetView *)subview setSelected:YES];
            }
        }
    }
}

- (void)deselectAllAssets
{
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[QBImagePickerAssetView class]]) {
            if(![(QBImagePickerAssetView *)subview isHidden]) {
                [(QBImagePickerAssetView *)subview setSelected:NO];
            }
        }
    }
}


#pragma mark - QBImagePickerAssetViewDelegate

- (BOOL)assetViewCanBeSelected:(QBImagePickerAssetView *)assetView
{
    return [self.delegate assetCell:self canSelectAssetAtIndex:(assetView.tag - 1)];
}

- (void)assetView:(QBImagePickerAssetView *)assetView didChangeSelectionState:(BOOL)selected
{
    [self.delegate assetCell:self didChangeAssetSelectionState:selected atIndex:(assetView.tag - 1)];
}

@end
