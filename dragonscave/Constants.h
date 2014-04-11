//
//  Constants.h

#import "AppDelegate.h"
#import "Macros.h"


// Physic collision bitmasks

static const uint32_t backBitMask         =  0x1 << 0;
static const uint32_t dragonBitMask       =  0x1 << 1;
static const uint32_t floorBitMask        =  0x1 << 2;
static const uint32_t blockBitMask        =  0x1 << 3;
static const uint32_t projectileCategory  =  0x1 << 4;
static const uint32_t monsterCategory     =  0x1 << 5;