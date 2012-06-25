//
//  WiniOS.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/16/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "hack.h"

#import "NHMapWindow.h"
#import "NHMenuWindow.h"

void ios_init_nhwindows(int* argc, char** argv);
void ios_askname(void);
void ios_player_selection(void);
void ios_get_nh_event(void);
void ios_exit_nhwindows(const char *str);
void ios_suspend_nhwindows(const char *str);
void ios_resume_nhwindows(void);
winid ios_create_nhwindow(int type);
void ios_clear_nhwindow(winid wid);
void ios_display_nhwindow(winid wid, BOOLEAN_P block);
void ios_destroy_nhwindow(winid wid);
void ios_curs(winid wid, int x, int y);
void ios_putstr(winid wid, int attr, const char *text);
void ios_display_file(const char *filename, BOOLEAN_P must_exist);
void ios_start_menu(winid wid);
void ios_add_menu(winid wid, int glyph, const ANY_P *identifier,
                  CHAR_P accelerator, CHAR_P group_accel, int attr, 
                  const char *str, BOOLEAN_P presel);
void ios_end_menu(winid wid, const char *prompt);
int ios_select_menu(winid wid, int how, menu_item **menu_list);
void ios_update_inventory(void);
void ios_mark_synch(void);
void ios_wait_synch(void);
void ios_cliparound(int x, int y);
void ios_cliparound_window(winid wid, int x, int y);
void ios_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph);
void ios_raw_print(const char *str);
void ios_raw_print_bold(const char *str);
int ios_nhgetch(void);
int ios_nh_poskey(int *x, int *y, int *mod);
void ios_nhbell(void);
int ios_doprev_message(void);
char ios_yn_function(const char *question, const char *choices, CHAR_P def);
void ios_getlin(const char *prompt, char *line);
int ios_get_ext_cmd(void);
void ios_number_pad(int num);
void ios_delay_output(void);
void ios_start_screen(void);
void ios_end_screen(void);
void ios_outrip(winid wid, int how);

extern int ios_getpos;

#if __OBJC__ /* Is this a bug? If you include this in a C file the section it protects it gets processed anyway */

/** Used for event queue for menu event */
extern NSString * const WiniOSMenuFinishedEvent;

/** Used for event queue for message display event */
extern NSString * const WiniOSMessageDisplayFinishedEvent;

@class Queue;
@class YNQuestionData;

@protocol WiniOSDelegate <NSObject>

- (void)setEventQueue:(Queue *)eventQueue;
- (void)handleYNQuestion:(YNQuestionData *)question;
- (void)handlePutstr:(NSString *)message attribute:(int)attr;
- (void)handlePoskey;
- (void)handleClearMessages;
- (void)handleMenuWindow:(NHMenuWindow *)window;
- (void)setStatusString:(NSString *)string line:(NSUInteger)i;
- (void)handleMessageMenuWindow:(NHMenuWindow *)window;
- (void)handleMapDisplay:(NHMapWindow *)window block:(BOOL)block;

@end

@class NHMapWindow;
@class NHWindow;
@class NHStatusWindow;

@interface WiniOS : NSObject

@property (nonatomic, strong) Queue *eventQueue;
@property (nonatomic, weak) id<WiniOSDelegate> delegate;
@property (nonatomic, strong) NHMapWindow *mapWindow;
@property (nonatomic, strong) NHWindow *messageWindow;
@property (nonatomic, strong) NHStatusWindow *statusWindow;

+ (const char *)baseFilePath;
+ (void)expandFilename:(const char *)filename intoPath:(char *)path;

- (void)start;

@end

#endif
