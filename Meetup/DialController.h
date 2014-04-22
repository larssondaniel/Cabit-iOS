//
//  DialController.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DialControllerDelegate;

@interface DialController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
    BOOL isSpinning;    //refers to wether the user is spinning it
    BOOL isAnimating;   //refers to wether it is animating into position
    NSArray *strings;
    NSInteger selectedStringIndex;
    NSString *selectedString;
    __unsafe_unretained id<DialControllerDelegate> delegate;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *strings;

@property (nonatomic, copy) NSString *selectedString;

@property (readonly) NSInteger selectedStringIndex;
@property BOOL isSpinning;

@property (nonatomic, assign) id<DialControllerDelegate> delegate;

- (id)initWithDialFrame:(CGRect)frame strings:(NSArray *)dialStrings;
- (void)spinToIndex:(int)index;

@end


@protocol DialControllerDelegate <NSObject>
- (void)dialControllerDidSpin:(DialController *)controller;
@required
- (void)dialController:(DialController *)dial didSnapToString:(NSString *)string;
@end