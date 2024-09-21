//
//  QDLayouterViewController.m
//  qmuidemo
//
//  Created by molice on 2024/1/4.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QDLayouterViewController.h"
#import "QMUIInteractiveDebugger.h"

@interface QDLayouterView : UIControl
@property(nonatomic, strong) QMUILayouterItem *item;
@end

@implementation QDLayouterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [QDCommonUI.randomThemeColor colorWithAlphaComponent:.5];
        self.qmui_sizeThatFitsBlock = ^CGSize(__kindof UIView * _Nonnull view, CGSize size, CGSize superResult) {
            return CGSizeMake(48, 48);
        };
    }
    return self;
}

- (QMUILayouterItem *)item {
    if (!_item) {
        _item = [QMUILayouterItem itemWithView:self margin:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return _item;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? UIControlHighlightedAlpha : 1;
}

@end

@interface QDLayouterViewController ()
@property(nonatomic, strong) NSMutableArray<QDLayouterView *> *horizontalViews;
@property(nonatomic, strong) QMUIInteractiveDebugPanelViewController *vc;
@end

@implementation QDLayouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.horizontalViews = NSMutableArray.new;
    for (NSInteger i = 0; i < 3; i++) {
        QDLayouterView *view = [[QDLayouterView alloc] init];
        [view addTarget:self action:@selector(handleViewEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:view];
        [self.horizontalViews addObject:view];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    QMUILayouterLinearHorizontal *h = [QMUILayouterLinearHorizontal itemWithChildItems:[self.horizontalViews qmui_mapWithBlock:^id _Nonnull(QDLayouterView * _Nonnull view, NSInteger index) {
        return view.item;
    }] spacingBetweenItems:0];
    [h showDebugBorderRecursivelyInView:self.view];
    h.frame = CGRectMake(32 + self.view.safeAreaInsets.left, 32 + self.qmui_navigationBarMaxYInViewCoordinator, self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(self.view.safeAreaInsets) - 32 * 2, QMUIViewSelfSizingHeight);
}

- (void)itemDidChange {
    [self.view setNeedsLayout];
}

- (void)handleViewEvent:(QDLayouterView *)view {
    __weak __typeof(self)weakSelf = self;
    QMUILayouterItem *item = view.item;
    if (self.vc) {
        [self.vc.view removeFromSuperview];
        self.vc = nil;
    }
    QMUIInteractiveDebugPanelViewController *vc = [QDUIHelper generateDebugViewControllerWithTitle:@"配置 Item" items:@[
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"width" minValue:0 maxValue:201.0 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = view.qmui_width;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            CGFloat v = actionView.value > 200 ? 99999 : actionView.value;
            CGSize s = view.qmui_sizeThatFitsBlock(view, CGSizeZero, CGSizeZero);
            view.qmui_sizeThatFitsBlock = ^CGSize(__kindof UIView * _Nonnull view, CGSize size, CGSize superResult) {
                return CGSizeMake(ceil(v), s.height);
            };
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"height" minValue:0 maxValue:201.0 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = view.qmui_height;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            CGFloat v = actionView.value > 200 ? 99999 : actionView.value;
            CGSize s = view.qmui_sizeThatFitsBlock(view, CGSizeZero, CGSizeZero);
            view.qmui_sizeThatFitsBlock = ^CGSize(__kindof UIView * _Nonnull view, CGSize size, CGSize superResult) {
                return CGSizeMake(s.width, ceil(v));
            };
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"minimumWidth" minValue:0 maxValue:200 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.minimumSize.width;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            item.minimumSize = CGSizeMake(ceil(actionView.value), item.minimumSize.height);
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"maximumWidth" minValue:0 maxValue:201.0 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.maximumSize.width;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            CGFloat v = actionView.value > 200 ? CGFLOAT_MAX : actionView.value;
            item.maximumSize = CGSizeMake(ceil(v), item.maximumSize.height);
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"minimumHeight" minValue:0 maxValue:200 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.minimumSize.height;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            item.minimumSize = CGSizeMake(item.minimumSize.width, ceil(actionView.value));
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"maximumHeight" minValue:0 maxValue:201.0 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.maximumSize.height;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            CGFloat v = actionView.value > 200 ? CGFLOAT_MAX : actionView.value;
            item.maximumSize = CGSizeMake(item.maximumSize.width, ceil(v));
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"margin" minValue:0 maxValue:40 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.margin.left;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            CGFloat v = ceil(actionView.value);
            item.margin = UIEdgeInsetsMake(v, v, v, v);
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"grow" minValue:0 maxValue:100 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.grow;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            item.grow = actionView.value;
            [weakSelf itemDidChange];
        }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"shrink" minValue:0 maxValue:100 valueGetter:^(UISlider * _Nonnull actionView) {
            actionView.value = item.shrink;
        } valueSetter:^(UISlider * _Nonnull actionView) {
            item.shrink = actionView.value;
            [weakSelf itemDidChange];
        }],
    ]];
    self.vc = vc;
    vc.view.layer.borderWidth = 0;
    CGSize size = [vc contentSizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
    vc.view.frame = CGRectMakeWithSize(CGSizeMake(300, size.height));
    QMUIPopupContainerView *popup = [[QMUIPopupContainerView alloc] init];
    popup.automaticallyHidesWhenUserTap = YES;
    popup.contentEdgeInsets = UIEdgeInsetsZero;
    [popup.contentView addSubview:vc.view];
    popup.contentViewSizeThatFitsBlock = ^CGSize(CGSize aSize) {
        return size;
    };
    popup.sourceView = view;
    [popup showWithAnimated:YES];
}

@end
