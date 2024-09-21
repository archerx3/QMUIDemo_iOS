//
//  QDSheetPresentationViewController.m
//  qmuidemo
//
//  Created by molice on 2024/2/28.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QDSheetPresentationViewController.h"
#import "QMUIInteractiveDebugger.h"
#import "QDComponentsViewController.h"

@interface QDSheetPresentationViewController ()

@property(nonatomic, strong) QMUIButton *presentButton;
@property(nonatomic, strong) QMUIInteractiveDebugPanelViewController *asViewController;
@property(nonatomic, strong) QDComponentsViewController *testVc;
@property(nonatomic, assign) BOOL shouldInvalidateLayout;
@end

@implementation QDSheetPresentationViewController

- (void)initSubviews {
    [super initSubviews];
    
    self.testVc = [[QDComponentsViewController alloc] init];
    
    self.presentButton = [QDUIHelper generateLightBorderedButton];
    [self.presentButton setTitle:@"点击打开 Sheet 面板" forState:UIControlStateNormal];
    [self.presentButton addTarget:self action:@selector(handlePresentButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.presentButton];
    
    self.asViewController = [self generateDebugController];
    [self.view addSubview:self.asViewController.view];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsMake(32 + self.qmui_navigationBarMaxYInViewCoordinator, 32, 32, 32);
    self.presentButton.frame = CGRectSetXY(self.presentButton.frame, CGRectGetMinXHorizontallyCenterInParentRect(self.view.bounds, self.presentButton.frame), padding.top);
    CGSize size = [self.asViewController contentSizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
    self.asViewController.view.frame = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.view.bounds), 320), CGRectGetMaxY(self.presentButton.frame) + 32, 320, size.height);
}

- (void)handlePresentButtonEvent {
    self.testVc.qmui_sheetPresentation.preferredSheetContentSizeBlock = ^CGSize(QMUISheetPresentation * _Nonnull aSheetPresentation, CGSize aContainerSize) {
        return CGSizeMake(aContainerSize.width, aContainerSize.height * 0.6);
    };
    QDNavigationController *nav = [[QDNavigationController alloc] qmui_initWithSheetRootViewController:self.testVc];
    [self presentViewController:nav animated:YES completion:nil];
    
    if (self.shouldInvalidateLayout) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.testVc.qmui_sheetPresentation.preferredSheetContentSizeBlock = ^CGSize(QMUISheetPresentation * _Nonnull aSheetPresentation, CGSize aContainerSize) {
                return CGSizeMake(aContainerSize.width, aContainerSize.height * 0.8);
            };
            [self.testVc qmui_invalidateSheetPresentationLayout];
        });
    }
}

- (QMUIInteractiveDebugPanelViewController *)generateDebugController {
    __weak __typeof(self)weakSelf = self;
    QMUIInteractiveDebugPanelViewController *vc = [QDUIHelper generateDebugViewControllerWithTitle:@"修改面板属性" items:@[
        
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"显示导航栏" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.testVc.qmui_sheetPresentation.shouldShowNavigationBar;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.testVc.qmui_sheetPresentation.shouldShowNavigationBar = actionView.on;
    }],
        
        // 跟标准 vc 一样设置标题，浮层会自动关联
        [QMUIInteractiveDebugPanelItem textItemWithTitle:@"标题" valueGetter:^(QMUITextField * _Nonnull actionView) {
        actionView.text = weakSelf.testVc.title;
    } valueSetter:^(QMUITextField * _Nonnull actionView) {
        weakSelf.testVc.title = actionView.text;
    }],
        [QMUIInteractiveDebugPanelItem numbericItemWithTitle:@"圆角" valueGetter:^(QMUITextField * _Nonnull actionView) {
        actionView.text = [NSString stringWithFormat:@"%.0f", weakSelf.testVc.qmui_sheetPresentation.cornerRadius];
    } valueSetter:^(QMUITextField * _Nonnull actionView) {
        weakSelf.testVc.qmui_sheetPresentation.cornerRadius = actionView.text.doubleValue;
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"modal" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.testVc.qmui_sheetPresentation.modal;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.testVc.qmui_sheetPresentation.modal = actionView.on;
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"侧滑手势" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.testVc.qmui_sheetPresentation.supportsSwipeToDismiss;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.testVc.qmui_sheetPresentation.supportsSwipeToDismiss = actionView.on;
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"下拉手势" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.testVc.qmui_sheetPresentation.supportsPullToDismiss;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.testVc.qmui_sheetPresentation.supportsPullToDismiss = actionView.on;
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"升起后改变高度" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.shouldInvalidateLayout;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.shouldInvalidateLayout = actionView.on;
    }],
    ]];
    return vc;
}

@end
