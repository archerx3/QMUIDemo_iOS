//
//  QDCheckboxViewController.m
//  qmuidemo
//
//  Created by molice on 2024/8/1.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QDCheckboxViewController.h"
#import "QMUIInteractiveDebugger.h"

@interface QDCheckboxViewController ()
@property(nonatomic, strong) QMUICheckbox *checkbox;
@property(nonatomic, strong) QMUIInteractiveDebugPanelViewController *debugViewController;
@end

@implementation QDCheckboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkbox = QMUICheckbox.new;
    self.checkbox.spacingBetweenImageAndTitle = 8;
    self.checkbox.titleLabel.font = UIFontMake(16);
    self.checkbox.adjustsTitleTintColorAutomatically = YES;
    [self.checkbox addTarget:self action:@selector(handleCheckboxEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.checkbox];
    
    __weak __typeof(self)weakSelf = self;
    __weak __typeof(self.checkbox)weakCheckbox = self.checkbox;
    self.debugViewController = [QDUIHelper generateDebugViewControllerWithTitle:@"配置参数" items:@[
        [QMUIInteractiveDebugPanelItem enumItemWithTitle:@"状态" items:@[@"Normal", @"Selected", @"Indeterminate", @"Disabled"] valueGetter:^(QMUIButton * _Nonnull actionView, NSArray<NSString *> * _Nonnull items) {
        NSInteger index = 0;
        if (weakCheckbox.state == UIControlStateNormal) index = 0;
        else if (weakCheckbox.state == UIControlStateSelected) index = 1;
        else if (weakCheckbox.indeterminate) index = 2;
        else if (!weakCheckbox.enabled) index = 3;
        [actionView setTitle:items[index] forState:UIControlStateNormal];
    } valueSetter:^(QMUIButton * _Nonnull actionView, NSArray<NSString *> * _Nonnull items) {
        NSInteger index = [items indexOfObject:actionView.currentTitle];
        switch (index) {
            case 0:
                weakCheckbox.enabled = YES;
                weakCheckbox.selected = NO;
                weakCheckbox.indeterminate = NO;
                break;
            case 1:
                weakCheckbox.enabled = YES;
                weakCheckbox.selected = YES;
                break;
            case 2:
                weakCheckbox.enabled = YES;
                weakCheckbox.indeterminate = YES;
                break;
            case 3:
                weakCheckbox.enabled = NO;
                break;
            default:
                break;
        }
    }],
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"尺寸" minValue:12 maxValue:40 valueGetter:^(UISlider * _Nonnull actionView) {
        actionView.value = weakCheckbox.checkboxSize.width;
    } valueSetter:^(UISlider * _Nonnull actionView) {
        weakCheckbox.checkboxSize = CGSizeMake(actionView.value, actionView.value);
        [weakSelf.view setNeedsLayout];
    }],
        [QMUIInteractiveDebugPanelItem colorItemWithTitle:@"颜色" valueGetter:^(QMUITextField * _Nonnull actionView) {
        actionView.text = weakCheckbox.tintColor.qmui_RGBAString;
    } valueSetter:^(QMUITextField * _Nonnull actionView) {
        weakCheckbox.tintColor = [UIColor qmui_colorWithRGBAString:actionView.text];
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"文本" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakCheckbox.currentTitle.length > 0;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        [weakCheckbox setTitle:actionView.on ? @"同意用户及隐私协议" : nil forState:UIControlStateNormal];
        [weakSelf.view setNeedsLayout];
    }],
    ]];
    [self.view addSubview:self.debugViewController.view];
}

- (void)handleCheckboxEvent {
    if (!self.checkbox.selected && !self.checkbox.indeterminate) self.checkbox.selected = YES;
    else if (self.checkbox.selected) self.checkbox.indeterminate = YES;
    else {
        self.checkbox.selected = NO;
        self.checkbox.indeterminate = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.checkbox sizeToFit];
    self.checkbox.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, self.qmui_navigationBarMaxYInViewCoordinator + 32 + self.checkbox.qmui_height / 2);
    CGSize size = [self.debugViewController contentSizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
    self.debugViewController.view.frame = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.view.bounds), 320), 200, 320, size.height);
}

@end
