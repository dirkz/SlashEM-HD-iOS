//
//  WiniOS.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/16/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h> // mkdir()

#import "WiniOS.h"

#import "Queue.h"
#import "KeyEvent.h"
#import "PosKeyEvent.h"
#import "YNQuestionData.h"
#import "NHMapWindow.h"
#import "NHStatusWindow.h"
#import "NSLogger.h"
#import "NHMenuWindow.h"
#import "MenuFinishedEvent.h"

// not used anymore
#define WID_TO(wid, type)(__bridge type *) (void *) wid;

extern int unix_main(int, char *[]);

struct window_procs ios_procs = {
    "ios",
    WC_COLOR|WC_HILITE_PET|
    WC_ASCII_MAP|WC_TILED_MAP|
    WC_FONT_MAP|WC_TILE_FILE|WC_TILE_WIDTH|WC_TILE_HEIGHT|
    WC_PLAYER_SELECTION|WC_SPLASH_SCREEN,
    0L,
    ios_init_nhwindows,
    ios_player_selection,
    ios_askname,
    ios_get_nh_event,
    ios_exit_nhwindows,
    ios_suspend_nhwindows,
    ios_resume_nhwindows,
    ios_create_nhwindow,
    ios_clear_nhwindow,
    ios_display_nhwindow,
    ios_destroy_nhwindow,
    ios_curs,
    ios_putstr,
    ios_display_file,
    ios_start_menu,
    ios_add_menu,
    ios_end_menu,
    ios_select_menu,
    genl_message_menu,    /* no need for X-specific handling */
    ios_update_inventory,
    ios_mark_synch,
    ios_wait_synch,
#ifdef CLIPPING
    ios_cliparound,
#endif
#ifdef POSITIONBAR
    donull,
#endif
    ios_print_glyph,
    ios_raw_print,
    ios_raw_print_bold,
    ios_nhgetch,
    ios_nh_poskey,
    ios_nhbell,
    ios_doprev_message,
    ios_yn_function,
    ios_getlin,
    ios_get_ext_cmd,
    ios_number_pad,
    ios_delay_output,
#ifdef CHANGE_COLOR  /* only a Mac option currently */
    donull,
    donull,
#endif
    /* other defs that really should go away (they're tty specific) */
    ios_start_screen,
    ios_end_screen,
    ios_outrip,
    genl_preference_update,
};

int ios_getpos;

#define BASE_WINDOW ((int) sharedInstance.messageWindow)

static char s_baseFilePath[FQN_MAX_FILENAME];
static WiniOS *sharedInstance;

@interface WiniOS ()

@property (nonatomic, strong) NSMutableDictionary *windows;

@end

@implementation WiniOS
{
    NSThread *netHackThread;
}

@synthesize eventQueue;
@synthesize delegate;
@synthesize mapWindow;
@synthesize messageWindow;
@synthesize statusWindow;
@synthesize windows;

+ (void)initialize
{
    strcpy(s_baseFilePath, [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSASCIIStringEncoding]);

    char nethackBaseOptions[512] = "boulder:0,time,autopickup,autodig"
    ",showexp,pickup_types:$!?\"=/,norest_on_space,runmode:walk"
    ",toptenwin";
    setenv("NETHACKOPTIONS", nethackBaseOptions, 1);
}

+ (const char *)baseFilePath {
    return s_baseFilePath;
}

+ (void)expandFilename:(const char *)filename intoPath:(char *)path {
    sprintf(path, "%s/%s", [self baseFilePath], filename);
}

- (id)init
{
    if ((self = [super init])) {
        eventQueue = [[Queue alloc] init];
        windows = [[NSMutableDictionary alloc] init];
        sharedInstance = self;
    }
    return self;
}

/** Adds the given window to the internal dictionary of all windows */
- (void)addWindow:(NHWindow *)window
{
    NSNumber *identifier = [NSNumber numberWithInt:[window identifier]];
    [windows setObject:window forKey:identifier];
}

- (void)removeWindow:(NHWindow *)window
{
    [windows removeObjectForKey:[NSNumber numberWithInt:[window identifier]]];
}

- (void)removeWindowWithIdentifier:(int)identifier
{
    [windows removeObjectForKey:[NSNumber numberWithInt:identifier]];
}

- (NHWindow *)windowForIdentifier:(int)identifier
{
    return [windows objectForKey:[NSNumber numberWithInt:identifier]];
}

- (void)start
{
    [delegate setEventQueue:eventQueue];
    netHackThread = [[NSThread alloc] initWithTarget:self selector:@selector(netHackMainLoop:) object:nil];
    [netHackThread start];
}

#pragma mark - NetHack main loop

- (void)netHackMainLoop:(id)arg
{
#ifdef SLASHEM
    char *argv[] = {
        "SlashEM",
    };
#else
    char *argv[] = {
        "NetHack",
    };
#endif
    int argc = sizeof(argv)/sizeof(char *);

    // create necessary directories
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDirectory = [paths objectAtIndex:0];
    LOG_WINIOS(1, @"baseDir %@", baseDirectory);
    setenv("NETHACKDIR", [baseDirectory cStringUsingEncoding:NSASCIIStringEncoding], 1);
    //setenv("SHOPTYPE", "G", 1); // force general stores on every level in wizard mode
    NSString *saveDirectory = [baseDirectory stringByAppendingPathComponent:@"save"];
    mkdir([saveDirectory cStringUsingEncoding:NSASCIIStringEncoding], 0777);

    // show directory (for debugging)
#if 0
    for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:baseDirectory]) {
        LOG_WINIOS(1, @"%@", filename);
    }
#endif

    // call it
    unix_main(argc, argv);
}

FILE *ios_dlb_fopen(const char *filename, const char *mode) {
    char path[FQN_MAX_FILENAME];
    [WiniOS expandFilename:filename intoPath:path];
    FILE *file = fopen(path, mode);
    return file;
}

// These must be defined but are not used (they handle keyboard interrupts).
void intron() {}
void introff() {}

int dosuspend()
{
    LOG_WINIOS(1, @"dosuspend");
    return 0;
}

void error(const char *s, ...)
{
    LOG_WINIOS(1, @"error: %s");
    char message[512];
    va_list ap;
    va_start(ap, s);
    vsprintf(message, s, ap);
    va_end(ap);
    ios_raw_print(message);
    // todo (button to wait for user?)
    exit(0);
}

#pragma mark - nethack window API

void ios_init_nhwindows(int* argc, char** argv)
{
    LOG_WINIOS(1, @"init_nhwindows");
    iflags.runmode = RUN_STEP;
    iflags.window_inited = TRUE;
    iflags.use_color = TRUE;
    switch_graphics(IBM_GRAPHICS);
}

void ios_askname()
{
    LOG_WINIOS(1, @"askname");
    ios_getlin("Enter your name", plname);
}

void ios_get_nh_event()
{
    LOG_WINIOS(1, @"get_nh_event");
}

void ios_exit_nhwindows(const char *str)
{
    LOG_WINIOS(1, @"exit_nhwindows %s", str);
}

void ios_suspend_nhwindows(const char *str)
{
    LOG_WINIOS(1, @"suspend_nhwindows %s", str);
}

void ios_resume_nhwindows()
{
    LOG_WINIOS(1, @"resume_nhwindows");
}

winid ios_create_nhwindow(int type)
{
    NHWindow *window;

    switch (type) {
        case NHW_MESSAGE:
            sharedInstance.messageWindow = [[NHWindow alloc] initWithType:type];
            window = sharedInstance.messageWindow;
            break;
        case NHW_STATUS:
            sharedInstance.statusWindow = [[NHStatusWindow alloc] init];
            window = sharedInstance.statusWindow;
            break;
        case NHW_MAP:
            sharedInstance.mapWindow = [[NHMapWindow alloc] init];
            window = sharedInstance.mapWindow;
            break;
        case NHW_MENU:
            window = [[NHMenuWindow alloc] init];
            [sharedInstance addWindow:window];
            break;
        case NHW_TEXT:
            window = [[NHWindow alloc] initWithType:type];
            [sharedInstance addWindow:window];
            break;
        default:
            window = [[NHWindow alloc] initWithType:type];
            break;
    }

    LOG_WINIOS(1, @"create_nhwindow(%x) %@", type, window.description);
    return (int) window;
}

void ios_clear_nhwindow(winid wid)
{
    LOG_WINIOS(1, @"clear_nhwindow %@", wid);
    if (wid == (winid) sharedInstance.messageWindow) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sharedInstance.delegate handleClearMessages];
        });
    } else if (wid == (winid) sharedInstance.mapWindow) {
        [sharedInstance.mapWindow clear];
    } else {
        LOG_WINIOS(1, @"unhandled clear_nhwindow %@", wid);
    }
}

void ios_display_nhwindow(winid wid, BOOLEAN_P block)
{
    LOG_WINIOS(1, @"display_nhwindow %@ block %i", wid, block);
}

void ios_destroy_nhwindow(winid wid)
{
    LOG_WINIOS(1, @"destroy_nhwindow %@", wid);
    [sharedInstance removeWindowWithIdentifier:wid];
}

void ios_curs(winid wid, int x, int y)
{
    LOG_WINIOS(1, @"curs %@ %d,%d", wid, x, y);
    if (wid == (winid) sharedInstance.statusWindow) {
        [sharedInstance.statusWindow setCursorX:x y:y];
    } else if (wid == (winid) sharedInstance.mapWindow) {
        [sharedInstance.mapWindow cliparoundX:x y:y];
    } else {
        LOG_WINIOS(1, @"unhandled curs %@ %d,%d", wid, x, y);
    }
}

void ios_putstr(winid wid, int attr, const char *text)
{
    LOG_WINIOS(1, @"putstr %@ %s", wid, text);
    if (strlen(text) > 0) {
        if (wid == (winid) sharedInstance.messageWindow) {
            // copy text since it might be gone later
            NSString *string = [NSString stringWithCString:text encoding:NSASCIIStringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sharedInstance.delegate handlePutstr:string attribute:attr];
            });
        } else if (wid == (winid) sharedInstance.statusWindow) {
            [sharedInstance.statusWindow putString:[NSString stringWithCString:text encoding:NSASCIIStringEncoding]
                                     withAttribute:attr];
        } else {
            LOG_WINIOS(1, @"unhandled putstr %@ %s", wid, text);
        }
    }
}

void ios_display_file(const char *filename, BOOLEAN_P must_exist)
{
    LOG_WINIOS(1, @"display_file %s", filename);
    char path[FQN_MAX_FILENAME];
    [WiniOS expandFilename:filename intoPath:path];
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:
                          [NSString stringWithCString:path encoding:NSASCIIStringEncoding]
                                                   encoding:NSASCIIStringEncoding error:&error];
    if (must_exist && error) {
        char msg[512];
        sprintf(msg, "Could not display file %s", filename);
        ios_raw_print(msg);
    } else if (!error) {
        // todo use contents
        contents = nil;
    }
}

void ios_start_menu(winid wid)
{
    LOG_WINIOS(1, @"start_menu %x", wid);
    NHMenuWindow *w = (NHMenuWindow *) [sharedInstance windowForIdentifier:wid];
    [w reset];
}

void ios_add_menu(winid wid, int glyph, const ANY_P *identifier, CHAR_P accelerator, CHAR_P group_accel, int attr,
                  const char *str, BOOLEAN_P presel)
{
    LOG_WINIOS(1, @"add_menu %x %s", wid, str);
    NHMenuWindow *w = (NHMenuWindow *) [sharedInstance windowForIdentifier:wid];
    if (identifier == NULL) {
        [w addGroupWithTitle:[NSString stringWithCString:str encoding:NSASCIIStringEncoding] accelerator:group_accel];
    } else {
        [w addTtemWithTitle:[NSString stringWithCString:str encoding:NSASCIIStringEncoding] glyph:glyph
                 identifier:*identifier accelerator:accelerator attribute:attr preselected:presel];
    }
}

void ios_end_menu(winid wid, const char *prompt)
{
    LOG_WINIOS(1, @"end_menu %x, %s", wid, prompt);
    NHMenuWindow *w = (NHMenuWindow *) [sharedInstance windowForIdentifier:wid];
    if (prompt) {
        w.prompt = [NSString stringWithCString:prompt encoding:NSASCIIStringEncoding];
    }
}

int ios_select_menu(winid wid, int how, menu_item **selected)
{
    LOG_WINIOS(1, @"select_menu %x", wid);
    NHMenuWindow *w = (NHMenuWindow *) [sharedInstance windowForIdentifier:wid];
    w.selected = selected;
    w.menuStyle = how;
    dispatch_async(dispatch_get_main_queue(), ^{
        [sharedInstance.delegate handleMenuWindow:w];
    });

    MenuFinishedEvent *event = [sharedInstance.eventQueue leaveObject];
    event = nil;

    selected = w.selected;

    return w.numberOfItemsSelected;
}

void ios_update_inventory()
{
    LOG_WINIOS(1, @"update_inventory");
}

void ios_mark_synch()
{
    LOG_WINIOS(1, @"mark_synch");
}

void ios_wait_synch()
{
    LOG_WINIOS(1, @"wait_synch");
}

void ios_cliparound(int x, int y)
{
    LOG_WINIOS(1, @"cliparound %d,%d", x, y);
    [sharedInstance.mapWindow cliparoundX:x y:y];
}

void ios_cliparound_window(winid wid, int x, int y)
{
    LOG_WINIOS(1, @"cliparound_window %@ %d,%d", wid, x, y);
    if (wid == (winid) sharedInstance.mapWindow) {
        [sharedInstance.mapWindow cliparoundX:x y:y];
    } else {
        LOG_WINIOS(1, @"unhandled cliparound_window %@ %d,%d", wid, x, y);
    }
}

void ios_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph)
{
    LOG_WINIOS(1, @"print_glyph %x %d,%d %d", wid, x, y, glyph);
    if (wid == (winid) sharedInstance.mapWindow) {
        [sharedInstance.mapWindow setGlyph:glyph atX:x y:y];
    } else {
        LOG_WINIOS(1, @"unhandled print_glyph %x %d,%d %d", wid, x, y, glyph);
    }
}

void ios_raw_print(const char *str)
{
    LOG_WINIOS(1, @"raw_print %s", str);
    ios_putstr(BASE_WINDOW, ATR_BOLD, str);
}

void ios_raw_print_bold(const char *str)
{
    LOG_WINIOS(1, @"raw_print_bold %s", str);
    ios_raw_print(str);
}

int ios_nhgetch()
{
    LOG_WINIOS(1, @"nhgetch");
    return 0;
}

int ios_nh_poskey(int *x, int *y, int *mod)
{
    LOG_WINIOS(1, @"nh_poskey");

    dispatch_async(dispatch_get_main_queue(), ^{
        [sharedInstance.delegate handlePoskey];
    });

    PosKeyEvent *event = [sharedInstance.eventQueue leaveObject];
    *x = event.x;
    *y = event.y;
    *mod = event.mod;

    return event.key;
}

void ios_nhbell()
{
    LOG_WINIOS(1, @"nhbell");
}

int ios_doprev_message()
{
    LOG_WINIOS(1, @"doprev_message");
    return 0;
}

char ios_yn_function(const char *question, const char *choices, CHAR_P def)
{
    LOG_WINIOS(1, @"yn_function %s", question);
    ios_putstr(BASE_WINDOW, ATR_NONE, question);

    dispatch_async(dispatch_get_main_queue(), ^{
        YNQuestionData *data = [YNQuestionData dataWithPrompt:[NSString stringWithCString:question encoding:NSASCIIStringEncoding]
                                                      choices:[NSString stringWithCString:choices encoding:NSASCIIStringEncoding]
                                                defaultChoice:def];
        [sharedInstance.delegate handleYNQuestion:data];
    });

    KeyEvent *event = [sharedInstance.eventQueue leaveObject];

    return event.key;
}

void ios_getlin(const char *prompt, char *line)
{
    LOG_WINIOS(1, @"getlin %s", prompt);
}

int ios_get_ext_cmd()
{
    LOG_WINIOS(1, @"get_ext_cmd");
    return 0;
}

void ios_number_pad(int num)
{
    LOG_WINIOS(1, @"number_pad %d", num);
}

void ios_delay_output()
{
    LOG_WINIOS(1, @"delay_output");
#if TARGET_IPHONE_SIMULATOR
    //usleep(500000);
#endif
}

void ios_start_screen()
{
    LOG_WINIOS(1, @"start_screen");
}

void ios_end_screen()
{
    LOG_WINIOS(1, @"end_screen");
}

void ios_outrip(winid wid, int how)
{
    LOG_WINIOS(1, @"outrip %x", wid);
}

#pragma mark - window API player_selection()
// from tty port
/* clean up and quit */
static void bail(const char *mesg)
{
    ios_exit_nhwindows(mesg);
    terminate(EXIT_SUCCESS);
}

// from tty port
static int ios_role_select(char *pbuf, char *plbuf)
{
#ifdef SLASHEM
    int i, n;
    char thisch, lastch = 0;
    char rolenamebuf[QBUFSZ];
    winid win;
    anything any;
    menu_item *selected = 0;

    ios_clear_nhwindow(BASE_WINDOW);
    ios_putstr(BASE_WINDOW, 0, "Choosing Character's Role");

    /* Prompt for a role */
    win = create_nhwindow(NHW_MENU);
    start_menu(win);
    any.a_void = 0;         /* zero out all bits */
    for (i = 0; roles[i].name.m; i++) {
        if (ok_role(i, flags.initrace, flags.initgend,
                    flags.initalign)) {
            any.a_int = i+1;    /* must be non-zero */
            thisch = lowc(roles[i].name.m[0]);
            if (thisch == lastch) thisch = highc(thisch);
            if (flags.initgend != ROLE_NONE && flags.initgend != ROLE_RANDOM) {
                if (flags.initgend == 1  && roles[i].name.f)
                    Strcpy(rolenamebuf, roles[i].name.f);
                else
                    Strcpy(rolenamebuf, roles[i].name.m);
            } else {
                if (roles[i].name.f) {
                    Strcpy(rolenamebuf, roles[i].name.m);
                    Strcat(rolenamebuf, "/");
                    Strcat(rolenamebuf, roles[i].name.f);
                } else
                    Strcpy(rolenamebuf, roles[i].name.m);
            }
            add_menu(win, NO_GLYPH, &any, thisch,
                     0, ATR_NONE, an(rolenamebuf), MENU_UNSELECTED);
            lastch = thisch;
        }
    }
    any.a_int = pick_role(flags.initrace, flags.initgend,
                          flags.initalign, PICK_RANDOM)+1;
    if (any.a_int == 0) /* must be non-zero */
        any.a_int = randrole()+1;
    add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
             "Random", MENU_UNSELECTED);
    any.a_int = i+1;    /* must be non-zero */
    add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
             "Quit", MENU_UNSELECTED);
    Sprintf(pbuf, "Pick a role for your %s", plbuf);
    end_menu(win, pbuf);
    n = select_menu(win, PICK_ONE, &selected);
    destroy_nhwindow(win);

    /* Process the choice */
    if (n != 1 || selected[0].item.a_int == any.a_int) {
        free((genericptr_t) selected),  selected = 0;
        return (-1);        /* Selected quit */
    }

    flags.initrole = selected[0].item.a_int - 1;
    free((genericptr_t) selected),  selected = 0;
    return (flags.initrole);
#endif
}

// from tty port
static int ios_race_select(char * pbuf, char * plbuf)
{
#ifdef SLASHEM
    int i, k, n;
    char thisch, lastch;
    winid win;
    anything any;
    menu_item *selected = 0;

    /* Count the number of valid races */
    n = 0;  /* number valid */
    k = 0;  /* valid race */
    for (i = 0; races[i].noun; i++) {
        if (ok_race(flags.initrole, i, flags.initgend,
                    flags.initalign)) {
            n++;
            k = i;
        }
    }
    if (n == 0) {
        for (i = 0; races[i].noun; i++) {
            if (validrace(flags.initrole, i)) {
                n++;
                k = i;
            }
        }
    }

    /* Permit the user to pick, if there is more than one */
    if (n > 1) {
        ios_clear_nhwindow(BASE_WINDOW);
        ios_putstr(BASE_WINDOW, 0, "Choosing Race");
        win = create_nhwindow(NHW_MENU);
        start_menu(win);
        any.a_void = 0;         /* zero out all bits */
        for (i = 0; races[i].noun; i++)
            if (ok_race(flags.initrole, i, flags.initgend,
                        flags.initalign)) {
                any.a_int = i+1;    /* must be non-zero */
                thisch = lowc(races[i].noun[0]);
                if (thisch == lastch) thisch = highc(thisch);
                add_menu(win, NO_GLYPH, &any, thisch,
                         0, ATR_NONE, races[i].noun, MENU_UNSELECTED);
                lastch = thisch;
            }
        any.a_int = pick_race(flags.initrole, flags.initgend,
                              flags.initalign, PICK_RANDOM)+1;
        if (any.a_int == 0) /* must be non-zero */
            any.a_int = randrace(flags.initrole)+1;
        add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
                 "Random", MENU_UNSELECTED);
        any.a_int = i+1;    /* must be non-zero */
        add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
                 "Quit", MENU_UNSELECTED);
        Sprintf(pbuf, "Pick the race of your %s", plbuf);
        end_menu(win, pbuf);
        n = select_menu(win, PICK_ONE, &selected);
        destroy_nhwindow(win);
        if (n != 1 || selected[0].item.a_int == any.a_int)
            return(-1);     /* Selected quit */

        k = selected[0].item.a_int - 1;
        free((genericptr_t) selected),  selected = 0;
    }

    flags.initrace = k;
    return (k);

#if 0 /* This version deals with more than 2 races per letter */
    int i, k, n, choicelet = 0;
    char thisch;
    char choicestr[3];
    winid win;
    anything any;
    menu_item *selected = 0;
    char pbuf[QBUFSZ];

    /* Count the number of valid races */
    n = 0;  /* number valid */
    k = 0;  /* valid race */
    for (i = 0; races[i].noun; i++) {
        if (ok_race(flags.initrole, i, flags.initgend,
                    flags.initalign)) {
            n++;
            k = i;
        }
    }
    if (n == 0) {
        for (i = 0; races[i].noun; i++) {
            if (validrace(flags.initrole, i)) {
                n++;
                k = i;
            }
        }
    }

    /* Permit the user to pick, if there is more than one */
    if (n > 1) do {
        win = create_nhwindow(NHW_MENU);
        start_menu(win);
        any.a_void = 0;         /* zero out all bits */
        for (i = 0; races[i].noun; i++)
            if (ok_race(flags.initrole, i, flags.initgend,
                        flags.initalign)
                && (!choicelet || !strncmpi(races[i].noun,
                                            choicestr, choicelet))) {

                thisch = lowc(races[i].noun[choicelet]);
                any.a_int = i+1;    /* must be non-zero */
                add_menu(win, NO_GLYPH, &any, thisch,
                         0, ATR_NONE, races[i].noun, MENU_UNSELECTED);
            }
        any.a_int = pick_race(flags.initrole, flags.initgend,
                              flags.initalign)+1;
        if (any.a_int == 0) /* must be non-zero */
            any.a_int = randrace(flags.initrole)+1;
        add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
                 "Random", MENU_UNSELECTED);
        any.a_int = i+1;    /* must be non-zero */
        add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
                 "Quit", MENU_UNSELECTED);
        Sprintf(pbuf, "Pick the race of your %s",
                roles[flags.initrole].name.m);
        end_menu(win, pbuf);
        n = select_menu(win, PICK_ONE, &selected);
        destroy_nhwindow(win);


        if (n != 1 || selected[0].item.a_int == any.a_int) {
            free((genericptr_t) selected),  selected = 0;
            if (!choicelet) {
                return (-1);        /* Selected quit */
            } else {
                choicelet--;
                n = 2; /* there are at least 2 */
                continue;
            }
        } else {
            k = selected[0].item.a_int - 1;
            free((genericptr_t) selected),  selected = 0;
            choicestr[choicelet] = races[k].noun[choicelet];
            choicelet++;
        }

        /* Check whether there are at least 2 choices left */
        n = 0;
        for (i = 0; (races[i].noun && (n <= 1)); i++)
            if (ok_race(flags.initrole, i, flags.initgend,
                        flags.initalign)
                && (!choicelet || !strncmpi(races[i].noun,
                                            choicestr, choicelet)))
                n++;
    } while (n > 1);

    flags.initrace = k;
    return (k);
#endif
#endif
}

// from tty port
void
ios_player_selection()
{
#ifdef SLASHEM
    int i, k, n;
    char pick4u = 'n';
    char pbuf[QBUFSZ], plbuf[QBUFSZ];
    winid win;
    anything any;
    menu_item *selected = 0;

    /* prevent an unnecessary prompt */
    rigid_role_checks();

    /* Should we randomly pick for the player? */
    if (!flags.randomall &&
        (flags.initrole == ROLE_NONE || flags.initrace == ROLE_NONE ||
         flags.initgend == ROLE_NONE || flags.initalign == ROLE_NONE)) {
            char *prompt = build_plselection_prompt(pbuf, QBUFSZ, flags.initrole,
                                                    flags.initrace, flags.initgend, flags.initalign);

            pick4u = ios_yn_function(prompt, "ynq", pick4u);
            ios_clear_nhwindow(BASE_WINDOW);

            if (pick4u != 'y' && pick4u != 'n') {
            give_up:    /* Quit */
                if (selected) free((genericptr_t) selected);
                bail((char *)0);
                /*NOTREACHED*/
                return;
            }
        }

    (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
                                    flags.initrole, flags.initrace, flags.initgend, flags.initalign);

    /* Select a role, if necessary */
    /* we'll try to be compatible with pre-selected race/gender/alignment,
     * but may not succeed */
    if (flags.initrole < 0) {
        /* Process the choice */
        if (pick4u == 'y' || flags.initrole == ROLE_RANDOM || flags.randomall) {
            /* Pick a random role */
            flags.initrole = pick_role(flags.initrace, flags.initgend,
                                       flags.initalign, PICK_RANDOM);
            if (flags.initrole < 0) {
                ios_putstr(BASE_WINDOW, 0, "Incompatible role!");
                flags.initrole = randrole();
            }
        } else {
            if (ios_role_select(pbuf, plbuf) < 0) goto give_up;
        }
        (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
                                        flags.initrole, flags.initrace, flags.initgend, flags.initalign);
    }

    /* Select a race, if necessary */
    /* force compatibility with role, try for compatibility with
     * pre-selected gender/alignment */
    if (flags.initrace < 0 || !validrace(flags.initrole, flags.initrace)) {
        /* pre-selected race not valid */
        if (pick4u == 'y' || flags.initrace == ROLE_RANDOM || flags.randomall) {
            flags.initrace = pick_race(flags.initrole, flags.initgend,
                                       flags.initalign, PICK_RANDOM);
            if (flags.initrace < 0) {
                ios_putstr(BASE_WINDOW, 0, "Incompatible race!");
                flags.initrace = randrace(flags.initrole);
            }
        } else {    /* pick4u == 'n' */
            if (ios_race_select(pbuf, plbuf) < 0) goto give_up;
        }
        (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
                                        flags.initrole, flags.initrace, flags.initgend, flags.initalign);
    }

    /* Select a gender, if necessary */
    /* force compatibility with role/race, try for compatibility with
     * pre-selected alignment */
    if (flags.initgend < 0 || !validgend(flags.initrole, flags.initrace,
                                         flags.initgend)) {
        /* pre-selected gender not valid */
        if (pick4u == 'y' || flags.initgend == ROLE_RANDOM || flags.randomall) {
            flags.initgend = pick_gend(flags.initrole, flags.initrace,
                                       flags.initalign, PICK_RANDOM);
            if (flags.initgend < 0) {
                ios_putstr(BASE_WINDOW, 0, "Incompatible gender!");
                flags.initgend = randgend(flags.initrole, flags.initrace);
            }
        } else {    /* pick4u == 'n' */
            /* Count the number of valid genders */
            n = 0;  /* number valid */
            k = 0;  /* valid gender */
            for (i = 0; i < ROLE_GENDERS; i++) {
                if (ok_gend(flags.initrole, flags.initrace, i,
                            flags.initalign)) {
                    n++;
                    k = i;
                }
            }
            if (n == 0) {
                for (i = 0; i < ROLE_GENDERS; i++) {
                    if (validgend(flags.initrole, flags.initrace, i)) {
                        n++;
                        k = i;
                    }
                }
            }

            /* Permit the user to pick, if there is more than one */
            if (n > 1) {
                ios_clear_nhwindow(BASE_WINDOW);
                ios_putstr(BASE_WINDOW, 0, "Choosing Gender");
                win = create_nhwindow(NHW_MENU);
                start_menu(win);
                any.a_void = 0;         /* zero out all bits */
                for (i = 0; i < ROLE_GENDERS; i++)
                    if (ok_gend(flags.initrole, flags.initrace, i,
                                flags.initalign)) {
                        any.a_int = i+1;
                        add_menu(win, NO_GLYPH, &any, genders[i].adj[0],
                                 0, ATR_NONE, genders[i].adj, MENU_UNSELECTED);
                    }
                any.a_int = pick_gend(flags.initrole, flags.initrace,
                                      flags.initalign, PICK_RANDOM)+1;
                if (any.a_int == 0) /* must be non-zero */
                    any.a_int = randgend(flags.initrole, flags.initrace)+1;
                add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
                         "Random", MENU_UNSELECTED);
                any.a_int = i+1;    /* must be non-zero */
                add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
                         "Quit", MENU_UNSELECTED);
                Sprintf(pbuf, "Pick the gender of your %s", plbuf);
                end_menu(win, pbuf);
                n = select_menu(win, PICK_ONE, &selected);
                destroy_nhwindow(win);
                if (n != 1 || selected[0].item.a_int == any.a_int)
                    goto give_up;       /* Selected quit */

                k = selected[0].item.a_int - 1;
                free((genericptr_t) selected),  selected = 0;
            }
            flags.initgend = k;
        }
        (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
                                        flags.initrole, flags.initrace, flags.initgend, flags.initalign);
    }

    /* Select an alignment, if necessary */
    /* force compatibility with role/race/gender */
    if (flags.initalign < 0 || !validalign(flags.initrole, flags.initrace,
                                           flags.initalign)) {
        /* pre-selected alignment not valid */
        if (pick4u == 'y' || flags.initalign == ROLE_RANDOM || flags.randomall) {
            flags.initalign = pick_align(flags.initrole, flags.initrace,
                                         flags.initgend, PICK_RANDOM);
            if (flags.initalign < 0) {
                ios_putstr(BASE_WINDOW, 0, "Incompatible alignment!");
                flags.initalign = randalign(flags.initrole, flags.initrace);
            }
        } else {    /* pick4u == 'n' */
            /* Count the number of valid alignments */
            n = 0;  /* number valid */
            k = 0;  /* valid alignment */
            for (i = 0; i < ROLE_ALIGNS; i++) {
                if (ok_align(flags.initrole, flags.initrace, flags.initgend,
                             i)) {
                    n++;
                    k = i;
                }
            }
            if (n == 0) {
                for (i = 0; i < ROLE_ALIGNS; i++) {
                    if (validalign(flags.initrole, flags.initrace, i)) {
                        n++;
                        k = i;
                    }
                }
            }

            /* Permit the user to pick, if there is more than one */
            if (n > 1) {
                ios_clear_nhwindow(BASE_WINDOW);
                ios_putstr(BASE_WINDOW, 0, "Choosing Alignment");
                win = create_nhwindow(NHW_MENU);
                start_menu(win);
                any.a_void = 0;         /* zero out all bits */
                for (i = 0; i < ROLE_ALIGNS; i++)
                    if (ok_align(flags.initrole, flags.initrace,
                                 flags.initgend, i)) {
                        any.a_int = i+1;
                        add_menu(win, NO_GLYPH, &any, aligns[i].adj[0],
                                 0, ATR_NONE, aligns[i].adj, MENU_UNSELECTED);
                    }
                any.a_int = pick_align(flags.initrole, flags.initrace,
                                       flags.initgend, PICK_RANDOM)+1;
                if (any.a_int == 0) /* must be non-zero */
                    any.a_int = randalign(flags.initrole, flags.initrace)+1;
                add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
                         "Random", MENU_UNSELECTED);
                any.a_int = i+1;    /* must be non-zero */
                add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
                         "Quit", MENU_UNSELECTED);
                Sprintf(pbuf, "Pick the alignment of your %s", plbuf);
                end_menu(win, pbuf);
                n = select_menu(win, PICK_ONE, &selected);
                destroy_nhwindow(win);
                if (n != 1 || selected[0].item.a_int == any.a_int)
                    goto give_up;       /* Selected quit */

                k = selected[0].item.a_int - 1;
                free((genericptr_t) selected),  selected = 0;
            }
            flags.initalign = k;
        }
    }
    /* Success! */
    ios_display_nhwindow(BASE_WINDOW, FALSE);
#endif
}

@end
