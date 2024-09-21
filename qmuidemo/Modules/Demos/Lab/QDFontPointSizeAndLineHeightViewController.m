//
//  QDFontPointSizeAndLineHeightViewController.m
//  qmuidemo
//
//  Created by QMUI Team on 2016/10/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QDFontPointSizeAndLineHeightViewController.h"
#import "QMUIInteractiveDebugger.h"

@interface QDFontPointSizeAndLineHeightViewController ()

@property(nonatomic, strong) UILabel *fontPointSizeLabel;
@property(nonatomic, strong) UILabel *lineHeightLabel;
@property(nonatomic, strong) UILabel *glyphLabel;

@property(nonatomic, strong) UILabel *exampleLabel;
@property(nonatomic, strong) UILabel *exampleLabel2;

@property(nonatomic, assign) NSInteger oldFontPointSize;
@property(nonatomic, assign) NSInteger newFontPointSize;
@property(nonatomic, assign) CGFloat lineHeightRatio;
@property(nonatomic, assign) BOOL isMedium;

@property(nonatomic, strong) QMUIInteractiveDebugPanelViewController *asViewController;
@end

@implementation QDFontPointSizeAndLineHeightViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.oldFontPointSize = 16;
        self.newFontPointSize = 16;
        self.lineHeightRatio = 1.4;
    }
    return self;
}

- (void)initSubviews {
    [super initSubviews];
    self.fontPointSizeLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColor.qd_mainTextColor];
    [self.fontPointSizeLabel qmui_calculateHeightAfterSetAppearance];
    [self.view addSubview:self.fontPointSizeLabel];
    
    self.lineHeightLabel = [[UILabel alloc] init];
    [self.lineHeightLabel qmui_setTheSameAppearanceAsLabel:self.fontPointSizeLabel];
    [self.lineHeightLabel qmui_calculateHeightAfterSetAppearance];
    [self.view addSubview:self.lineHeightLabel];
    
    self.glyphLabel = [[UILabel alloc] init];
    [self.glyphLabel qmui_setTheSameAppearanceAsLabel:self.fontPointSizeLabel];
    [self.glyphLabel qmui_calculateHeightAfterSetAppearance];
    [self.view addSubview:self.glyphLabel];
    
    self.exampleLabel = [[UILabel alloc] init];
    self.exampleLabel.backgroundColor = [UIColor.qd_tintColor colorWithAlphaComponent:.3];
    self.exampleLabel.textColor = UIColorWhite;
    self.exampleLabel.text = @"Expel 国";// 中英文不影响，这里为了便于观察，挑选了几个横跨多条线的字母
    self.exampleLabel.qmui_showPrincipalLines = YES;
    [self.view addSubview:self.exampleLabel];
    
    self.exampleLabel2 = [[UILabel alloc] init];
    self.exampleLabel2.backgroundColor = [UIColor.qd_tintColor colorWithAlphaComponent:.3];
    self.exampleLabel2.qmui_showPrincipalLines = YES;
    [self.view addSubview:self.exampleLabel2];
    
    self.asViewController = [self generateDebugController];
    [self.view addSubview:self.asViewController.view];
    
    [self updateLabelsBaseOnSliderForce:YES];
}

- (void)updateLabelsBaseOnSliderForce:(BOOL)force {
    NSInteger fontPointSize = self.newFontPointSize;
    if (force || fontPointSize != self.oldFontPointSize) {
        
        UIFont *font = self.isMedium ? UIFontMediumMake(fontPointSize) : UIFontMake(fontPointSize);
        self.exampleLabel.font = font;
        [self.exampleLabel sizeToFit];
        CGFloat lineHeight = round(font.pointSize * self.lineHeightRatio);
        CGFloat baseline = [QMUIHelper baselineOffsetWhenVerticalAlignCenterInHeight:lineHeight withFont:font];
        
        self.exampleLabel2.attributedText = [[NSAttributedString alloc] initWithString:self.exampleLabel.text attributes:@{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColorWhite,
            NSParagraphStyleAttributeName: [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight],
            NSBaselineOffsetAttributeName: @(baseline),
        }];
        [self.exampleLabel2 sizeToFit];
        
        self.fontPointSizeLabel.text = [NSString stringWithFormat:@"font:%@, descender:%.1f, xHeight:%.1f, capHeight:%.1f", @(fontPointSize), font.descender, font.xHeight, font.capHeight];
        self.lineHeightLabel.text = [NSString stringWithFormat:@"font.lineHeight:%.1f, actually lineHeight:%.1f, baseline:%.1f", font.lineHeight, lineHeight, baseline];
        self.glyphLabel.text = [NSString stringWithFormat:@"label1's location.y:%.1f, label2's location.y:%.1f", [self locationForFirstGlyphInLabel:self.exampleLabel].y, [self locationForFirstGlyphInLabel:self.exampleLabel2].y];
        
        self.oldFontPointSize = fontPointSize;
    }
}

// 得到第一个字符的左上角位置在 label 里的实际渲染坐标（CoreText 坐标系，原点在左下角），理论上应该符合表达式：location.y = capHeight - descender + baselineOffset
- (CGPoint)locationForFirstGlyphInLabel:(UILabel *)label {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:label.bounds.size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = label.numberOfLines;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:NSMakeRange(0, 1) actualGlyphRange:&glyphRange];
    CGPoint glyphLocation = [layoutManager locationForGlyphAtIndex:glyphRange.location];
    return glyphLocation;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsMake(24 + self.qmui_navigationBarMaxYInViewCoordinator, 24 + self.view.safeAreaInsets.left, 24 + self.view.safeAreaInsets.bottom, 24 + self.view.safeAreaInsets.right);
    CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(padding);
    CGSize size = [self.asViewController contentSizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.asViewController.view.frame = CGRectMake(padding.left, padding.top, contentWidth, size.height);
    self.fontPointSizeLabel.frame = CGRectFlatMake(padding.left, CGRectGetMaxY(self.asViewController.view.frame) + 24, contentWidth, CGRectGetHeight(self.fontPointSizeLabel.frame));
    self.lineHeightLabel.frame = CGRectFlatMake(padding.left, CGRectGetMaxY(self.fontPointSizeLabel.frame) + 16, contentWidth, CGRectGetHeight(self.lineHeightLabel.frame));
    self.glyphLabel.frame = CGRectFlatMake(padding.left, CGRectGetMaxY(self.lineHeightLabel.frame) + 16, contentWidth, CGRectGetHeight(self.glyphLabel.frame));
    self.exampleLabel.frame = CGRectSetXY(self.exampleLabel.frame, padding.left, CGRectGetMaxY(self.glyphLabel.frame) + 24);
    self.exampleLabel2.frame = CGRectSetXY(self.exampleLabel2.frame, CGRectGetMaxX(self.exampleLabel.frame) + 8, CGRectGetMaxY(self.exampleLabel.frame) - CGRectGetHeight(self.exampleLabel2.frame));
}

- (QMUIInteractiveDebugPanelViewController *)generateDebugController {
    __weak __typeof(self)weakSelf = self;
    QMUIInteractiveDebugPanelViewController *vc = [QDUIHelper generateDebugViewControllerWithTitle:@"修改字体" items:@[
        [QMUIInteractiveDebugPanelItem sliderItemWithTitle:@"字号" minValue:8 maxValue:50 valueGetter:^(UISlider * _Nonnull actionView) {
        actionView.value = round(weakSelf.newFontPointSize);
    } valueSetter:^(UISlider * _Nonnull actionView) {
        weakSelf.newFontPointSize = round(actionView.value);
        [weakSelf updateLabelsBaseOnSliderForce:NO];
    }],
        [QMUIInteractiveDebugPanelItem numbericItemWithTitle:@"行高倍数" valueGetter:^(QMUITextField * _Nonnull actionView) {
        actionView.text = [NSString stringWithFormat:@"%.2f", weakSelf.lineHeightRatio];
    } valueSetter:^(QMUITextField * _Nonnull actionView) {
        weakSelf.lineHeightRatio = actionView.text.doubleValue;
        [weakSelf updateLabelsBaseOnSliderForce:YES];
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"加粗" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.isMedium;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.isMedium = actionView.on;
        [weakSelf updateLabelsBaseOnSliderForce:YES];
    }],
        [QMUIInteractiveDebugPanelItem boolItemWithTitle:@"显示参考线" valueGetter:^(UISwitch * _Nonnull actionView) {
        actionView.on = weakSelf.exampleLabel.qmui_showPrincipalLines;
    } valueSetter:^(UISwitch * _Nonnull actionView) {
        weakSelf.exampleLabel.qmui_showPrincipalLines = actionView.on;
        weakSelf.exampleLabel2.qmui_showPrincipalLines = actionView.on;
    }],
    ]];
    return vc;
}

@end
