//
//  QMUIInteractiveDebugPanelItem.m
//  qmuidemo
//
//  Created by QMUI Team on 2020/5/20.
//  Copyright © 2020 QMUI Team. All rights reserved.
//

#import "QMUIInteractiveDebugPanelItem.h"

@interface QMUIInteractiveDebugPanelItem ()

@property(nonatomic, strong, readwrite) UILabel *titleLabel;
@end

@interface QMUIInteractiveDebugPanelTextItem : QMUIInteractiveDebugPanelItem <QMUITextFieldDelegate>

@property(nonatomic, strong) QMUITextField *textField;
@end

@interface QMUIInteractiveDebugPanelNumbericItem : QMUIInteractiveDebugPanelTextItem
@end

@interface QMUIInteractiveDebugPanelColorItem : QMUIInteractiveDebugPanelNumbericItem
@end

@interface QMUIInteractiveDebugPanelBoolItem : QMUIInteractiveDebugPanelItem

@property(nonatomic, strong) UISwitch *switcher;
@end

@interface QMUIInteractiveDebugPanelEnumItem : QMUIInteractiveDebugPanelItem

@property(nonatomic, strong) QMUIButton *menuButton;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;
@end

@interface QMUIInteractiveDebugPanelSliderItem : QMUIInteractiveDebugPanelItem

@property(nonatomic, strong) UISlider *slider;
@end

@implementation QMUIInteractiveDebugPanelItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColor.blackColor];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = .8;
        self.titleLabel.numberOfLines = 2;
        self.height = 44;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

+ (instancetype)itemWithTitle:(NSString *)title actionView:(__kindof UIView *)actionView valueGetter:(void (^)(__kindof UIView * _Nonnull))valueGetter valueSetter:(void (^)(__kindof UIView * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelItem *item = QMUIInteractiveDebugPanelItem.new;
    item.title = title;
    item.actionView = actionView;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

+ (instancetype)textItemWithTitle:(NSString *)title valueGetter:(void (^)(QMUITextField * _Nonnull))valueGetter valueSetter:(void (^)(QMUITextField * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelTextItem *item = QMUIInteractiveDebugPanelTextItem.new;
    item.title = title;
    item.actionView = item.textField;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

+ (instancetype)numbericItemWithTitle:(NSString *)title valueGetter:(void (^)(QMUITextField * _Nonnull))valueGetter valueSetter:(void (^)(QMUITextField * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelNumbericItem *item = QMUIInteractiveDebugPanelNumbericItem.new;
    item.title = title;
    item.actionView = item.textField;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

+ (instancetype)colorItemWithTitle:(NSString *)title valueGetter:(void (^)(QMUITextField * _Nonnull))valueGetter valueSetter:(void (^)(QMUITextField * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelColorItem *item = QMUIInteractiveDebugPanelColorItem.new;
    item.title = title;
    item.actionView = item.textField;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

+ (instancetype)boolItemWithTitle:(NSString *)title valueGetter:(void (^)(UISwitch * _Nonnull))valueGetter valueSetter:(void (^)(UISwitch * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelBoolItem *item = QMUIInteractiveDebugPanelBoolItem.new;
    item.title = title;
    item.actionView = item.switcher;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

+ (instancetype)enumItemWithTitle:(NSString *)title items:(NSArray<NSString *> *)items valueGetter:(void (^)(QMUIButton * _Nonnull, NSArray<NSString *> * _Nonnull))valueGetter valueSetter:(void (^)(QMUIButton * _Nonnull, NSArray<NSString *> * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelEnumItem *item = [[QMUIInteractiveDebugPanelEnumItem alloc] initWithItems:items];
    item.extraObject = items;
    item.title = title;
    item.actionView = item.menuButton;
    item.valueGetter2 = valueGetter;
    item.valueSetter2 = valueSetter;
    return item;
}

+ (instancetype)sliderItemWithTitle:(NSString *)title minValue:(float)minValue maxValue:(float)maxValue valueGetter:(void (^)(UISlider * _Nonnull))valueGetter valueSetter:(void (^)(UISlider * _Nonnull))valueSetter {
    QMUIInteractiveDebugPanelSliderItem *item = QMUIInteractiveDebugPanelSliderItem.new;
    item.title = title;
    item.actionView = item.slider;
    item.slider.minimumValue = minValue;
    item.slider.maximumValue = maxValue;
    item.valueGetter = valueGetter;
    item.valueSetter = valueSetter;
    return item;
}

@end

@implementation QMUIInteractiveDebugPanelTextItem

- (QMUITextField *)textField {
    if (!_textField) {
        _textField = [[QMUITextField alloc] qmui_initWithSize:CGSizeMake(160, 38)];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.font = [UIFont fontWithName:@"Menlo" size:14];
        _textField.textColor = UIColor.blackColor;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.qmui_borderWidth = PixelOne;
        _textField.qmui_borderPosition = QMUIViewBorderPositionBottom;
        _textField.qmui_borderColor = [UIColorBlack colorWithAlphaComponent:.3];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(handleTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (void)handleTextFieldChanged:(QMUITextField *)textField {
    if (!textField.isFirstResponder) return;
    if (self.valueSetter) self.valueSetter(textField);
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

@end

@implementation QMUIInteractiveDebugPanelNumbericItem

- (QMUITextField *)textField {
    QMUITextField *textField = [super textField];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    return textField;
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 删除文字
    if (range.length > 0 && string.length <= 0) {
        return YES;
    }
    
    return !![string qmui_stringMatchedByPattern:@"[-\\d\\.]"];// 模拟器里，通过电脑键盘输入“点”，输出的可能是中文的句号
}

@end

@implementation QMUIInteractiveDebugPanelColorItem

- (QMUITextField *)textField {
    QMUITextField *textField = [super textField];
    textField.placeholder = @"255,255,255,1.0";
    return textField;
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 删除文字
    if (range.length > 0 && string.length <= 0) {
        return YES;
    }
    
    return !![string qmui_stringMatchedByPattern:@"[\\d\\s\\,\\.]+"];
}

@end

@implementation QMUIInteractiveDebugPanelBoolItem

- (UISwitch *)switcher {
    if (!_switcher) {
        _switcher = [[UISwitch alloc] init];
        _switcher.layer.anchorPoint = CGPointMake(.5, .5);
        _switcher.transform = CGAffineTransformMakeScale(.7, .7);
        [_switcher addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _switcher;
}

- (void)handleSwitchEvent:(UISwitch *)switcher {
    if (self.valueSetter) self.valueSetter(switcher);
}

@end

@implementation QMUIInteractiveDebugPanelEnumItem

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    if (self = [super init]) {
        __weak __typeof(self)weakSelf = self;
        _menuButton = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(160, 32)];
        _menuButton.adjustsTitleTintColorAutomatically = YES;
        _menuButton.adjustsImageTintColorAutomatically = YES;
        _menuButton.layer.borderColor = UIColorSeparator.CGColor;
        _menuButton.layer.borderWidth = PixelOne;
        _menuButton.layer.cornerRadius = 5;
        _menuButton.titleLabel.font = [UIFont fontWithName:@"Menlo" size:14];
        UIImage *triangle = [UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:UIColor.blackColor];
        [_menuButton setImage:[[triangle qmui_imageWithOrientation:UIImageOrientationDown] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_menuButton setImage:[triangle imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        _menuButton.imagePosition = QMUIButtonImagePositionRight;
        _menuButton.spacingBetweenImageAndTitle = 4;
        if (@available(iOS 14.0, *)) {
            self.didAddBlock = ^(QMUIInteractiveDebugPanelEnumItem * _Nonnull item, UIView * _Nonnull containerView) {
                item.menuButton.showsMenuAsPrimaryAction = YES;
                if (@available(iOS 15.0, *)) {
                    item.menuButton.menu = [UIMenu menuWithTitle:item.title image:nil identifier:nil options:UIMenuOptionsSingleSelection children:[items qmui_mapWithBlock:^id _Nonnull(NSString * _Nonnull aItem, NSInteger index) {
                        UIAction *a = [UIAction actionWithTitle:aItem image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                            [weakSelf.menuButton setTitle:action.title forState:UIControlStateNormal];
                            if (weakSelf.valueSetter2) {
                                weakSelf.valueSetter2(weakSelf.menuButton, weakSelf.extraObject);
                            }
                        }];
                        if ([item.menuButton.currentTitle isEqualToString:aItem]) {
                            a.state = UIMenuElementStateOn;
                        }
                        return a;
                    }]];
                } else {
                    // 低于 iOS 15 处理选择不太方便，干脆不支持算了
                    item.menuButton.menu = [UIMenu menuWithChildren:[items qmui_mapWithBlock:^id _Nonnull(NSString * _Nonnull aItem, NSInteger index) {
                        return [UIAction actionWithTitle:aItem image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                            [weakSelf.menuButton setTitle:action.title forState:UIControlStateNormal];
                            if (weakSelf.valueSetter2) {
                                weakSelf.valueSetter2(weakSelf.menuButton, weakSelf.extraObject);
                            }
                        }];
                    }]];
                }
            };
        } else {
            _menuButton.enabled = NO;
            [_menuButton setTitle:@"仅支持 iOS 14+" forState:UIControlStateNormal];
        }
    }
    return self;
}

@end

@implementation QMUIInteractiveDebugPanelSliderItem

- (instancetype)init {
    if (self = [super init]) {
        _slider = [[UISlider alloc] qmui_initWithSize:CGSizeMake(160, 38)];
        _slider.qmui_trackHeight = 1;
        _slider.qmui_thumbSize = CGSizeMake(12, 12);
        [_slider addTarget:self action:@selector(handleSliderEvent:) forControlEvents:UIControlEventValueChanged];
        self.didAddBlock = ^(QMUIInteractiveDebugPanelSliderItem * _Nonnull item, UIView * _Nonnull containerView) {
            [item updateTitle];
        };
    }
    return self;
}

- (void)handleSliderEvent:(UISlider *)slider {
    [self updateTitle];
    if (self.valueSetter) self.valueSetter(slider);
}

- (void)updateTitle {
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%.2f)", self.title, self.slider.value];
    [self.titleLabel sizeToFit];
}

@end
