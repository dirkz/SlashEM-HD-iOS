//
//  NSLogger.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#ifndef SlashEM_NSLogger_h
#define SlashEM_NSLogger_h

#import "LoggerCommon.h"
#import "LoggerClient.h"

#ifdef CONFIGURATION_Debug
#define LOG(level, ...)            LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"general",level,__VA_ARGS__)
#define LOG_WINIOS(level, ...)     LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"winios",level,__VA_ARGS__)
#define LOG_VIEW(level, ...)       LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"view",level,__VA_ARGS__)
#define LOG_UTIL(level, ...)       LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"util",level,__VA_ARGS__)
#else
#define LOG(...)            do{}while(0)
#define LOG_WINIOS(...)     do{}while(0)
#define LOG_VIEW(...)     do{}while(0)
#define LOG_UTIL(...)       do{}while(0)
#endif

#endif
