//
//  ItemWithAmountTableViewCellCell.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "ItemWithAmountTableViewCellCell.h"

@interface ItemWithAmountTableViewCellCell ()

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation ItemWithAmountTableViewCellCell

@synthesize textLabel;
@synthesize amountSlider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
