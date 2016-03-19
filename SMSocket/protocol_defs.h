/*
 * Copyright 2012 by Avnera Corporation, Beaverton, Oregon.
 *
 *
 * All Rights Reserved
 *
 *
 * This file may not be modified, copied, or distributed in part or in whole
 * without prior written consent from Avnera Corporation.
 *
 *
 * AVNERA DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
 * ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
 * AVNERA BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
 * ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
 * ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
 * SOFTWARE.
 */

#ifndef __PROTOCOL_DEFS_H_
#define __PROTOCOL_DEFS_H_

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#define u8 uint8_t
#define s8 int8_t
#define s16 int16_t
#define u16 uint16_t
#define s32 int32_t
#define u32 uint32_t

#include "VersionInfo.h"

#endif

#define FLASH_SECTOR_SIZE           (65536)
#define FLASH_SUBSECTOR_SIZE        (4096)
#define FLASH_PAGE_SIZE             (256)
#define FLASH_PAGES_PER_SUBSECTOR   (FLASH_SUBSECTOR_SIZE/FLASH_PAGE_SIZE)

#define SC_START_BYTE (0xA5)

typedef  struct {
    u8 start_byte;      // 0xA5 Start of packet
    u8 packet_len;      // Size of packet in bytes.
    u16 packet_total;   // Number of packets total if divided into multiple. Usually set to 1.
    u16 packet_number;  // If part of a multiple packet transfer, which number. Usually set to 1.
    u8 parameter;       // Fault status, Battery Voltage, Ö
    u8 command;         // Get, Set, Enable, Disable, ACK, NAK Ö
    s16 value;          // Valid range is -0x7FFF to +0x7FFF
    u8 reserved1;       // Reserved Set
    u8 reserved2;       // Reserved
    u8 checksum;        // Summation of entire packet except the checksum itself.
    u8 bulk_data[FLASH_PAGE_SIZE];  // Bulk data bytes
} SoundcasePacket;

#define PACKET_HEADER_LEN   (13)

typedef enum {
    ChargeControlAppleDevice 		= 0,
    ChargeControlSplit 				= 1,
    ChargeControlSoundCase 			= 2
} ChargeControl_t;

typedef enum {
    ParmChargeMode					= 0,
    ParmBatteryVoltagePercent		= 1,
    ParmFlash						= 2,
    ParmDspIndex					= 3,
    //    ParmAccessoryVolume				= 4,
    ParmFirmwareVersion				= 5,
    ParmStateVector					= 6,
    ParmBuildTime					= 7,
    ParmBatteryMillivolts			= 8,
    //    ParmNormalizedAccessoryVolume	= 9,
    ParmBulkData					= 10,
    ParmFlashAccess					= 11,
    ParmSettingsPage				= 12,
    ParmEventReadStart		        = 13,
    ParmEventPage				    = 14,
    ParmEventReset                  = 15,
    ParmNVRAM                       = 16,
    ParmUpgradeStartPage            = 17,
    ParmResetDevice                 = 18,
    ParmDspAutoSelect               = 19,
    ParmMfgData                     = 20,
    ParmFault                  		= 21,
    ParmChargeBoost                 = 22,
    ParmThermistorVoltage           = 23,
    ParmPowerMode                   = 24,   // Battery vs. WallPower
    ParmSysState					= 25,
    ParmGpioToggle					= 26,
    ParmUsageHours					= 27,
    ParmSerialNumber				= 28,
    ParmSKU                         = 29,
    ParmHardwareRevision			= 30,
    ParmSm2gStandby                 = 31,
    ParmSocket                      = 32,
} SoundSkinParameter_t;

enum {
	GpioToggleClearEvents			= 0,
	GpioToggleClearEventsAndStayOn  = 1,
};

enum {
	FaultOverTemp = 0,
	FaultThermistorShorted = 1,
};

typedef enum {
    PmodeBattery    = 0,
    PmodeVdc        = 1,
    PmodeInvalid    = 2,
} PowerMode_t;

typedef enum {
    DspIndexFlat,
    DspIndexSpatialOff,
    DspIndexSpatialPlus4,
    DspIndexSpatialPlus8,
    DSPIndexConference
} DspIndex_t;

typedef enum {
    DspProfile_Balanced         = 0,
    DspProfile_Music            = 1,
    DspProfile_Movie          = 2,
    DspProfile_Gaming           = 3,
    DspProfile_Conference       = 4,
    DspProfile_Headphone        = 5,
    DspProfile_Radio            = 6,
    DspProfile_AudioBook        = 7,
    DspProfile_Reserved8        = 8,
    DspProfile_Reserved9        = 9,
    DspProfile_ElectricFlat     = 10, ///< Not specifiable by app
} DspProfile_t;

typedef enum {
    MediaDetect_None            = 0,
    MediaDetect_Music           = 1,
    MediaDetect_Movie           = 2,
    MediaDetect_Netflix         = 3,
    MediaDetect_Pandora         = 4,
    MediaDetect_YouTube         = 5,
    MediaDetect_MobileSafari    = 6,
} MediaDetect_t;

typedef enum {
    DspInstruction_Default      = 0,
    DspInstruction_Amplifier    = 1,
    DspInstruction_Headphone    = 2,
    DspInstruction_Unused       = 3,
} DspInstruction_t;

typedef enum {
    cmdSet,
    cmdGet,
    cmdEnable,
    cmdDisable,
    cmdACK,
    cmdNAK,
    cmdStart,
    cmdEnd,
    cmdRead,
    cmdWrite,
    cmdSend,
    cmdRequest
} Command_t;

typedef enum {
    imageFactory = 0,
    imageUpgrade = 1,
} ThunderImageType;

#define BATTERY_CHARGING_VALUE		(255)
#define BATTERY_CHARGED_VALUE		(100)
#define BATTERY_LOW_VALUE			(0)

#define NUMBER_OF_SERIAL_NUMBER_BYTES   (14)
#define NUMBER_OF_SKU_BYTES             (3)
#define NUMBER_OF_HW_REV_BYTES          (2)

// specified values
#ifndef VOLUME_MIN_DB
#define VOLUME_MIN_DB (-60)
#endif
#ifndef VOLUME_MAX_DB
#define VOLUME_MAX_DB (10)
#endif

#define VOLUME_MUTE_DB (-127)

#define DEFAULT_VOLUME  -20

#endif
