//
//  NHTextWindow.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHWindow.h"

@interface NHTextWindow : NHWindow

/** Some NH routines use NHWindow for displaying text */
- (void)putString:(NSString *)string;

/** @return If putString was used, all lines as newline-separated string */
@property (nonatomic, readonly) NSString *text;

@end
