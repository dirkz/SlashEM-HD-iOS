//
//  NHDirection.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/29/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#ifndef SlashEM_HD_NHDirection_h
#define SlashEM_HD_NHDirection_h

#include "math.h"

/** The 8 directions of NetHack */
typedef enum {
    NHDirectionNorth,
    NHDirectionNorthEast,
    NHDirectionEast,
    NHDirectionSouthEast,
    NHDirectionSouth,
    NHDirectionSouthWest,
    NHDirectionWest,
    NHDirectionNorthWest,
    NHDirectionError
} NHDirection;

static inline const char *NHDirectionCStringForDirection(NHDirection direction)
{
    static const char *directions[] = {
        "NHDirectionNorth",
        "NHDirectionNorthEast",
        "NHDirectionEast",
        "NHDirectionSouthEast",
        "NHDirectionSouth",
        "NHDirectionSouthWest",
        "NHDirectionWest",
        "NHDirectionNorthWest",
        "NHDirectionError",
    };
    return directions[direction];
}

static inline NHDirection NHDirectionFromEuclidieanUnitDelta(float dx, float dy)
{
    static float COS_22_5 = 0.923879533f;
    static float COS_67_5 = 0.382683432f;
    static float SIN_67_5 = 0.923879533f;

    float length = sqrtf(dx*dx + dy*dy);
    dx /= length;
    dy /= length;

    if (dx >= COS_22_5) {
        return NHDirectionEast;
    } else if (dx <= -COS_22_5) {
        return NHDirectionWest;
    } else if (dx >= COS_67_5) {
        if (dy >= 0) {
            return NHDirectionNorthEast;
        } else {
            return NHDirectionSouthEast;
        }
    } else if (dx <= -COS_67_5) {
        if (dy >= 0) {
            return NHDirectionNorthWest;
        } else {
            return NHDirectionSouthWest;
        }
    } else if (dy >= SIN_67_5) {
        return NHDirectionNorth;
    } else if (dy <= -SIN_67_5) {
        return NHDirectionSouth;
    }
    return NHDirectionError;
}

#endif
