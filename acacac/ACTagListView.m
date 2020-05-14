//
//  searchTagListView.m
//  fff
//
//  Created by wang on 2020/5/13.
//  Copyright © 2020 wang. All rights reserved.
//

#import "ACTagListView.h"
#import <Masonry.h>

static CGFloat const kContentLeftRightMargin = 10;
static CGFloat const kTagHeight_std = 28;
static CGFloat const kTagSpacing = 5;
static CGFloat const kButtonTitleLeftRightMargin_std = 10;

#define GCBlockInvoke(block, ...)   \
do {                            \
    if (block) {                \
        block(__VA_ARGS__);    \
    }                           \
} while(0)


@interface ACTagListView ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *tagButtonList;

@property (nonatomic, assign) TagListViewStyle style;
@property (nonatomic, copy) TagListViewOnTagClick onTagClickBlock;
@end

@implementation ACTagListView

/**
 *  计算标签视图需要的高度
 *
 *  @param tags          标签列表
 *  @param tagItemHandle 处理回调，通知外面这个Tag的显示信息
 *
 *  @return Tags在UI上的高度。
 */
+ (CGFloat)_heightWithTags:(NSArray<NSString *> *)tags style:(TagListViewStyle)style tagItemHandle:(void(^)(NSUInteger index, NSString *tagName, CGSize tagSize, BOOL needWrap))tagItemHandle {
    __block CGFloat tagsHeight = 0;
    if (tags && (tags.count > 0)) {
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat titleLeftRightMargin =  style == TagListViewStyleOnlyText ? 0 :  kButtonTitleLeftRightMargin_std;
        CGFloat tagHeight =  kTagHeight_std;
        tagsHeight += tagHeight;
        
        CGFloat tagsContentWdith = kScreenWidth - kContentLeftRightMargin * 2;
        __block CGFloat currentRowWidth = tagsContentWdith;
        [tags enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat tagWidth = [obj boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.width + titleLeftRightMargin * 2 + ( style == TagListViewStyleOnlyText ? 30 : 15);
            BOOL needWrap = NO;
            if (tagWidth > currentRowWidth && currentRowWidth != tagsContentWdith) {
                // 换行
                tagsHeight += kTagSpacing + tagHeight;
                currentRowWidth = tagsContentWdith;
                needWrap = YES;
            }
            GCBlockInvoke(tagItemHandle, idx, obj, CGSizeMake(MIN(tagWidth, tagsContentWdith), tagHeight), needWrap);
            currentRowWidth -= (tagWidth + kTagSpacing);
        }];
    }
    return tagsHeight;
}

+ (CGFloat)heightWithTags:(NSArray<NSString *> *)tags style:(TagListViewStyle)style {
    return [self _heightWithTags:tags style:style tagItemHandle:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        self.contentTopMargin = 0;
        self.tagButtonList = [NSMutableArray array];
        self.style = TagListViewStyleNormal;
    }
    return self;
}

- (instancetype)initWithStyle:(TagListViewStyle)style {
    if (self = [super init]) {
        self.contentTopMargin = 0;
        self.tagButtonList = [NSMutableArray array];
        self.style = style;
    }
    return self;
}

#pragma mark - public methods

- (void)setTags:(NSArray<NSString *> *)tags {
    _tags = [tags copy];
    [self _reloadButtonList];
}

- (void)onTagClick:(TagListViewOnTagClick)block {
    self.onTagClickBlock = block;
}
-(void)btnClick:(UIButton *)sender {
    if (self.onTagClickBlock) {
        self.onTagClickBlock(sender.tag, sender.titleLabel.text);
    }
}

#pragma mark - private methods

- (UIButton *)_createButtonWithTagName:(NSString *)tagName {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    if (self.style == TagListViewStyleOnlyText) {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:tagName];
        NSRange titleRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FE6257"] range:titleRange];
        [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:titleRange];
        [button setAttributedTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#FE6257"] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = [UIColor colorWithHexString:@"#F6F7FA"];
        CGFloat titleLeftRightMargin = kButtonTitleLeftRightMargin_std;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, titleLeftRightMargin, 0, titleLeftRightMargin);
        button.layer.cornerRadius =  kTagHeight_std  * 0.5;
        button.layer.borderWidth = 0;
        [button setTitle:tagName forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#4a4a4a"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"#"] forState:(UIControlStateNormal)];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
   
    [button addTarget:self action:@selector(btnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    return button;
}

- (void)_reloadButtonList {
    [self.tagButtonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.tagButtonList removeAllObjects];
    
    __block UIView *prevView = nil;
    [ACTagListView _heightWithTags:self.tags style:self.style tagItemHandle:^(NSUInteger index, NSString *tagName, CGSize tagSize, BOOL needWrap) {
        UIButton *btn = [self _createButtonWithTagName:tagName];
        btn.tag = index;
        [self addSubview:btn];
        [self.tagButtonList addObject:btn];
        
        UIButton *button = self.tagButtonList[index];
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (prevView == nil) {
                make.left.equalTo(self).offset(kContentLeftRightMargin);
                make.top.equalTo(self).offset(self.contentTopMargin);
            }
            else if (needWrap) {
                make.left.equalTo(self).offset(kContentLeftRightMargin);
                make.top.equalTo(prevView.mas_bottom).offset(kTagSpacing);
            }
            else {
                make.left.equalTo(prevView.mas_right).offset(kTagSpacing);
                make.top.equalTo(prevView);
            }
            make.size.mas_equalTo(tagSize);
        }];
        prevView = button;
    }];
}



@end
