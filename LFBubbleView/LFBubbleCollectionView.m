//  Copyright (c) 2014 Sebastian Hunkeler. All rights reserved.

#import "LFBubbleCollectionView.h"
#import "NHAlignmentFlowLayout.h"

@interface LFBubbleCollectionView ()
@property (nonatomic, strong) NHAlignmentFlowLayout *flowLayout;
@end

@implementation LFBubbleCollectionView
{
    UIMenuController *_menuController;
}

#pragma mark - Memory Management

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (void)configureLayout
{
    self.flowLayout = [[NHAlignmentFlowLayout alloc] init];
    self.flowLayout.alignment = NHAlignmentTopLeftAligned;
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.flowLayout setItemSize:CGSizeMake(100.0, 25.0)];
    [self setCollectionViewLayout:self.flowLayout];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self configureLayout];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        self.bounces = YES;
    }
    
    return  self;
}

-(void)showMenuForBubbleItem:(LFBubbleViewCell *)item
{
    if (item == _activeBubble) return;
    
    NSArray *menuItems = nil;
    
    if ([_bubbleDelegate respondsToSelector:@selector(bubbleView:menuItemsForBubbleItemAtIndex:)])
        menuItems = [_bubbleDelegate bubbleView:self menuItemsForBubbleItemAtIndex:[self indexPathForCell:item].row];
    
    if (menuItems)
        [self showMenuCalloutWthItems:menuItems forBubbleItem:item];
}

#pragma mark - Menu Actions

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
 
-(void)willShowMenuController
{
    self.userInteractionEnabled = NO;
}

-(void)didHideMenuController
{
    self.userInteractionEnabled = YES;
    [_activeBubble setHighlighted:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([_bubbleDelegate respondsToSelector:@selector(bubbleView:didHideMenuForBubbleItemAtIndex:)])
        [_bubbleDelegate bubbleView:self didHideMenuForBubbleItemAtIndex:[self indexPathForCell:_activeBubble].row];
    
    _activeBubble = nil;
}

-(void)showMenuCalloutWthItems:(NSArray *)menuItems forBubbleItem:(LFBubbleViewCell *)item
{
    [self becomeFirstResponder];
    
    _activeBubble = item;
    _menuController = [UIMenuController sharedMenuController];
    _menuController.menuItems = nil;
    _menuController.menuItems = menuItems;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowMenuController) name:UIMenuControllerWillShowMenuNotification object:_menuController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenuController) name:UIMenuControllerDidHideMenuNotification object:_menuController];
    
    [_menuController setTargetRect:item.frame inView:self];
    [_menuController setMenuVisible:YES animated:YES];
}

@end