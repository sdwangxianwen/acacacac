//
//  searchTagListView.h
//  fff
//
//  Created by wang on 2020/5/13.
//  Copyright © 2020 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TagListViewStyle) {
    TagListViewStyleOnlyText, //含有下划线的
    TagListViewStyleNormal, //普通样式
};

typedef void(^TagListViewOnTagClick)(NSUInteger index, NSString *tag);


@interface ACTagListView : UIView

+ (CGFloat)heightWithTags:(NSArray<NSString *> *)tags style:(TagListViewStyle)style;

/// 标签整体内容上间隔。默认0
@property (nonatomic, assign) CGFloat contentTopMargin;

/// 标签数据
@property (nonatomic, copy) NSArray<NSString *> *tags;

- (instancetype)initWithStyle:(TagListViewStyle)style;

/// 用户点击了某个标签
- (void)onTagClick:(TagListViewOnTagClick)block;
@end

NS_ASSUME_NONNULL_END
