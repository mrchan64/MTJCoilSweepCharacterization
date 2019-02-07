#line 1 "C:\Users\Magneto\Documents\PC-FPGA\Matlab_API\okFrontPanelDLL.h"






















	typedef unsigned int  UINT32;
	typedef unsigned char UINT8;











	typedef const char * okFP_dll_pchar;




typedef void (* DLL_EP)(void);








typedef unsigned long okPLL22150_HANDLE;
typedef unsigned long okPLL22393_HANDLE;
typedef struct okDeviceSettingsHandle* okDeviceSettings_HANDLE;
typedef unsigned long okFrontPanel_HANDLE;
typedef struct okFrontPanelManagerHandle* okFrontPanelManager_HANDLE;
typedef struct okCFrontPanelManagerHandle* okCFrontPanelManager_HANDLE;
typedef int Bool;










typedef enum {
	ok_ClkSrc22150_Ref=0,
	ok_ClkSrc22150_Div1ByN=1,
	ok_ClkSrc22150_Div1By2=2,
	ok_ClkSrc22150_Div1By3=3,
	ok_ClkSrc22150_Div2ByN=4,
	ok_ClkSrc22150_Div2By2=5,
	ok_ClkSrc22150_Div2By4=6
} ok_ClockSource_22150;

typedef enum {
	ok_ClkSrc22393_Ref=0,
	ok_ClkSrc22393_PLL0_0=2,
	ok_ClkSrc22393_PLL0_180=3,
	ok_ClkSrc22393_PLL1_0=4,
	ok_ClkSrc22393_PLL1_180=5,
	ok_ClkSrc22393_PLL2_0=6,
	ok_ClkSrc22393_PLL2_180=7
} ok_ClockSource_22393;

typedef enum {
	ok_DivSrc_Ref = 0,
	ok_DivSrc_VCO = 1
} ok_DividerSource;

typedef enum {
	ok_brdUnknown = 0,
	ok_brdXEM3001v1 = 1,
	ok_brdXEM3001v2 = 2,
	ok_brdXEM3010 = 3,
	ok_brdXEM3005 = 4,
	ok_brdXEM3001CL = 5,
	ok_brdXEM3020 = 6,
	ok_brdXEM3050 = 7,
	ok_brdXEM9002 = 8,
	ok_brdXEM3001RB = 9,
	ok_brdXEM5010 = 10,
	ok_brdXEM6110LX45 = 11,
	ok_brdXEM6110LX150 = 15,
	ok_brdXEM6001 = 12,
	ok_brdXEM6010LX45 = 13,
	ok_brdXEM6010LX150 = 14,
	ok_brdXEM6006LX9 = 16,
	ok_brdXEM6006LX16 = 17,
	ok_brdXEM6006LX25 = 18,
	ok_brdXEM5010LX110 = 19,
	ok_brdZEM4310=20,
	ok_brdXEM6310LX45=21,
	ok_brdXEM6310LX150=22,
	ok_brdXEM6110v2LX45=23,
	ok_brdXEM6110v2LX150=24,
	ok_brdXEM6002LX9=25,
	ok_brdXEM6310MTLX45T=26,
	ok_brdXEM6320LX130T=27,
	ok_brdXEM7350K70T=28,
	ok_brdXEM7350K160T=29,
	ok_brdXEM7350K410T=30
} ok_BoardModel;

typedef enum {
	ok_NoError                    = 0,
	ok_Failed                     = -1,
	ok_Timeout                    = -2,
	ok_DoneNotHigh                = -3,
	ok_TransferError              = -4,
	ok_CommunicationError         = -5,
	ok_InvalidBitstream           = -6,
	ok_FileError                  = -7,
	ok_DeviceNotOpen              = -8,
	ok_InvalidEndpoint            = -9,
	ok_InvalidBlockSize           = -10,
	ok_I2CRestrictedAddress       = -11,
	ok_I2CBitError                = -12,
	ok_I2CNack                    = -13,
	ok_I2CUnknownStatus           = -14,
	ok_UnsupportedFeature         = -15,
	ok_FIFOUnderflow              = -16,
	ok_FIFOOverflow               = -17,
	ok_DataAlignmentError         = -18,
	ok_InvalidResetProfile        = -19,
	ok_InvalidParameter           = -20
} ok_ErrorCode;























































enum okEFPGAConfigurationMethod {
	ok_FPGAConfigurationMethod_NVRAM =(0),
	ok_FPGAConfigurationMethod_JTAG  =(1)
};


typedef struct {
	UINT32   address;
	UINT32   data;
} okTRegisterEntry;





typedef struct {
	UINT32   address;
	UINT32   mask;
} okTTriggerEntry;


typedef struct {

	UINT32                     magic;


	UINT32                     configFileLocation;


	UINT32                     configFileLength;



	UINT32                     doneWaitUS;



	UINT32                     resetWaitUS;



	UINT32                     registerWaitUS;


	UINT32                     padBytes1[28];



	UINT32                     wireInValues[32];


	UINT32                     registerEntryCount;


	okTRegisterEntry           registerEntries[256];


	UINT32                     triggerEntryCount;



	okTTriggerEntry            triggerEntries[32];


	UINT8                      padBytes2[1520];
} okTFPGAResetProfile;



typedef struct {
	UINT32             sectorCount;
	UINT32             sectorSize;
	UINT32             pageSize;
	UINT32             minUserSector;
	UINT32             maxUserSector;
} okTFlashLayout;


typedef struct {
	char            deviceID[(33)];
	char            serialNumber[(11)];
	char            productName[(128)];
	int             productID;
	int             deviceInterface;
	int             usbSpeed;
	int             deviceMajorVersion;
	int             deviceMinorVersion;
	int             hostInterfaceMajorVersion;
	int             hostInterfaceMinorVersion;





	char            isPLL22150Supported;
	char            isPLL22393Supported;
	char            isFrontPanelEnabled;

	int             wireWidth;
	int             triggerWidth;
	int             pipeWidth;
	int             registerAddressWidth;
	int             registerDataWidth;

	okTFlashLayout  flashSystem;
	okTFlashLayout  flashFPGA;
} okTDeviceInfo;














 void _stdcall okFrontPanelDLL_GetVersion(char *date, char *time);




 okPLL22393_HANDLE _stdcall okPLL22393_Construct();
 void _stdcall okPLL22393_Destruct(okPLL22393_HANDLE pll);
 void _stdcall okPLL22393_SetCrystalLoad(okPLL22393_HANDLE pll, double capload);
 void _stdcall okPLL22393_SetReference(okPLL22393_HANDLE pll, double freq);
 double _stdcall okPLL22393_GetReference(okPLL22393_HANDLE pll);
 Bool _stdcall okPLL22393_SetPLLParameters(okPLL22393_HANDLE pll, int n, int p, int q, Bool enable);
 Bool _stdcall okPLL22393_SetPLLLF(okPLL22393_HANDLE pll, int n, int lf);
 Bool _stdcall okPLL22393_SetOutputDivider(okPLL22393_HANDLE pll, int n, int div);
 Bool _stdcall okPLL22393_SetOutputSource(okPLL22393_HANDLE pll, int n, ok_ClockSource_22393 clksrc);
 void _stdcall okPLL22393_SetOutputEnable(okPLL22393_HANDLE pll, int n, Bool enable);
 int _stdcall okPLL22393_GetPLLP(okPLL22393_HANDLE pll, int n);
 int _stdcall okPLL22393_GetPLLQ(okPLL22393_HANDLE pll, int n);
 double _stdcall okPLL22393_GetPLLFrequency(okPLL22393_HANDLE pll, int n);
 int _stdcall okPLL22393_GetOutputDivider(okPLL22393_HANDLE pll, int n);
 ok_ClockSource_22393 _stdcall okPLL22393_GetOutputSource(okPLL22393_HANDLE pll, int n);
 double _stdcall okPLL22393_GetOutputFrequency(okPLL22393_HANDLE pll, int n);
 Bool _stdcall okPLL22393_IsOutputEnabled(okPLL22393_HANDLE pll, int n);
 Bool _stdcall okPLL22393_IsPLLEnabled(okPLL22393_HANDLE pll, int n);
 void _stdcall okPLL22393_InitFromProgrammingInfo(okPLL22393_HANDLE pll, unsigned char *buf);
 void _stdcall okPLL22393_GetProgrammingInfo(okPLL22393_HANDLE pll, unsigned char *buf);





 okPLL22150_HANDLE _stdcall okPLL22150_Construct();
 void _stdcall okPLL22150_Destruct(okPLL22150_HANDLE pll);
 void _stdcall okPLL22150_SetCrystalLoad(okPLL22150_HANDLE pll, double capload);
 void _stdcall okPLL22150_SetReference(okPLL22150_HANDLE pll, double freq, Bool extosc);
 double _stdcall okPLL22150_GetReference(okPLL22150_HANDLE pll);
 Bool _stdcall okPLL22150_SetVCOParameters(okPLL22150_HANDLE pll, int p, int q);
 int _stdcall okPLL22150_GetVCOP(okPLL22150_HANDLE pll);
 int _stdcall okPLL22150_GetVCOQ(okPLL22150_HANDLE pll);
 double _stdcall okPLL22150_GetVCOFrequency(okPLL22150_HANDLE pll);
 void _stdcall okPLL22150_SetDiv1(okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n);
 void _stdcall okPLL22150_SetDiv2(okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n);
 ok_DividerSource _stdcall okPLL22150_GetDiv1Source(okPLL22150_HANDLE pll);
 ok_DividerSource _stdcall okPLL22150_GetDiv2Source(okPLL22150_HANDLE pll);
 int _stdcall okPLL22150_GetDiv1Divider(okPLL22150_HANDLE pll);
 int _stdcall okPLL22150_GetDiv2Divider(okPLL22150_HANDLE pll);
 void _stdcall okPLL22150_SetOutputSource(okPLL22150_HANDLE pll, int output, ok_ClockSource_22150 clksrc);
 void _stdcall okPLL22150_SetOutputEnable(okPLL22150_HANDLE pll, int output, Bool enable);
 ok_ClockSource_22150 _stdcall okPLL22150_GetOutputSource(okPLL22150_HANDLE pll, int output);
 double _stdcall okPLL22150_GetOutputFrequency(okPLL22150_HANDLE pll, int output);
 Bool _stdcall okPLL22150_IsOutputEnabled(okPLL22150_HANDLE pll, int output);
 void _stdcall okPLL22150_InitFromProgrammingInfo(okPLL22150_HANDLE pll, unsigned char *buf);
 void _stdcall okPLL22150_GetProgrammingInfo(okPLL22150_HANDLE pll, unsigned char *buf);





 okDeviceSettings_HANDLE _stdcall okDeviceSettings_Construct();
 void _stdcall okDeviceSettings_Destruct(okDeviceSettings_HANDLE hnd);
 ok_ErrorCode _stdcall okDeviceSettings_GetString(okDeviceSettings_HANDLE hnd, const char *key, int length, char *buf);
 ok_ErrorCode _stdcall okDeviceSettings_SetString(okDeviceSettings_HANDLE hnd, const char *key, const char *buf);
 ok_ErrorCode _stdcall okDeviceSettings_GetInt(okDeviceSettings_HANDLE hnd, const char *key, UINT32 *value);
 ok_ErrorCode _stdcall okDeviceSettings_SetInt(okDeviceSettings_HANDLE hnd, const char *key, UINT32 value);
 ok_ErrorCode _stdcall okDeviceSettings_Delete(okDeviceSettings_HANDLE hnd, const char *key);
 ok_ErrorCode _stdcall okDeviceSettings_Save(okDeviceSettings_HANDLE hnd);




 okFrontPanel_HANDLE _stdcall okFrontPanel_Construct();
 void _stdcall okFrontPanel_Destruct(okFrontPanel_HANDLE hnd);
 ok_ErrorCode _stdcall okFrontPanel_WriteI2C(okFrontPanel_HANDLE hnd, const int addr, int length, unsigned char *data);
 ok_ErrorCode _stdcall okFrontPanel_ReadI2C(okFrontPanel_HANDLE hnd, const int addr, int length, unsigned char *data);
 ok_ErrorCode _stdcall okFrontPanel_FlashEraseSector(okFrontPanel_HANDLE hnd, UINT32 address);
 ok_ErrorCode _stdcall okFrontPanel_FlashWrite(okFrontPanel_HANDLE hnd, UINT32 address, UINT32 length, const UINT8 *buf);
 ok_ErrorCode _stdcall okFrontPanel_FlashRead(okFrontPanel_HANDLE hnd, UINT32 address, UINT32 length, UINT8 *buf);
 ok_ErrorCode _stdcall okFrontPanel_GetFPGAResetProfile(okFrontPanel_HANDLE hnd, okEFPGAConfigurationMethod method, okTFPGAResetProfile *profile);
 ok_ErrorCode _stdcall okFrontPanel_SetFPGAResetProfile(okFrontPanel_HANDLE hnd, okEFPGAConfigurationMethod method, const okTFPGAResetProfile *profile);
 ok_ErrorCode _stdcall okFrontPanel_ReadRegister(okFrontPanel_HANDLE hnd, UINT32 addr, UINT32 *data);
 ok_ErrorCode _stdcall okFrontPanel_ReadRegisters(okFrontPanel_HANDLE hnd, unsigned num, okTRegisterEntry* regs);
 ok_ErrorCode _stdcall okFrontPanel_WriteRegister(okFrontPanel_HANDLE hnd, UINT32 addr, UINT32 data);
 ok_ErrorCode _stdcall okFrontPanel_WriteRegisters(okFrontPanel_HANDLE hnd, unsigned num, const okTRegisterEntry* regs);
 int _stdcall okFrontPanel_GetHostInterfaceWidth(okFrontPanel_HANDLE hnd);
 Bool _stdcall okFrontPanel_IsHighSpeed(okFrontPanel_HANDLE hnd);
 ok_BoardModel _stdcall okFrontPanel_GetBoardModel(okFrontPanel_HANDLE hnd);
 void _stdcall okFrontPanel_GetBoardModelString(okFrontPanel_HANDLE hnd, ok_BoardModel m, char *buf);
 int _stdcall okFrontPanel_GetDeviceCount(okFrontPanel_HANDLE hnd);
 ok_BoardModel _stdcall okFrontPanel_GetDeviceListModel(okFrontPanel_HANDLE hnd, int num);
 void _stdcall okFrontPanel_GetDeviceListSerial(okFrontPanel_HANDLE hnd, int num, char *buf);
 ok_ErrorCode _stdcall okFrontPanel_OpenBySerial(okFrontPanel_HANDLE hnd, const char *serial);
 Bool _stdcall okFrontPanel_IsOpen(okFrontPanel_HANDLE hnd);
 void _stdcall okFrontPanel_EnableAsynchronousTransfers(okFrontPanel_HANDLE hnd, Bool enable);
 ok_ErrorCode _stdcall okFrontPanel_SetBTPipePollingInterval(okFrontPanel_HANDLE hnd, int interval);
 void _stdcall okFrontPanel_SetTimeout(okFrontPanel_HANDLE hnd, int timeout);
 int _stdcall okFrontPanel_GetDeviceMajorVersion(okFrontPanel_HANDLE hnd);
 int _stdcall okFrontPanel_GetDeviceMinorVersion(okFrontPanel_HANDLE hnd);
 ok_ErrorCode _stdcall okFrontPanel_ResetFPGA(okFrontPanel_HANDLE hnd);
 void _stdcall okFrontPanel_Close(okFrontPanel_HANDLE hnd);
 void _stdcall okFrontPanel_GetSerialNumber(okFrontPanel_HANDLE hnd, char *buf);
 ok_ErrorCode _stdcall okFrontPanel_GetDeviceSettings(okFrontPanel_HANDLE hnd, okDeviceSettings_HANDLE settings);
 ok_ErrorCode _stdcall okFrontPanel_GetDeviceInfo(okFrontPanel_HANDLE hnd, okTDeviceInfo *info);
 void _stdcall okFrontPanel_GetDeviceID(okFrontPanel_HANDLE hnd, char *buf);
 void _stdcall okFrontPanel_SetDeviceID(okFrontPanel_HANDLE hnd, const char *strID);
 ok_ErrorCode _stdcall okFrontPanel_ConfigureFPGA(okFrontPanel_HANDLE hnd, const char *strFilename);
 ok_ErrorCode _stdcall okFrontPanel_ConfigureFPGAFromMemory(okFrontPanel_HANDLE hnd, unsigned char *data, unsigned long length);
 ok_ErrorCode _stdcall okFrontPanel_GetPLL22150Configuration(okFrontPanel_HANDLE hnd, okPLL22150_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_SetPLL22150Configuration(okFrontPanel_HANDLE hnd, okPLL22150_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_GetEepromPLL22150Configuration(okFrontPanel_HANDLE hnd, okPLL22150_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_SetEepromPLL22150Configuration(okFrontPanel_HANDLE hnd, okPLL22150_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_GetPLL22393Configuration(okFrontPanel_HANDLE hnd, okPLL22393_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_SetPLL22393Configuration(okFrontPanel_HANDLE hnd, okPLL22393_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_GetEepromPLL22393Configuration(okFrontPanel_HANDLE hnd, okPLL22393_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_SetEepromPLL22393Configuration(okFrontPanel_HANDLE hnd, okPLL22393_HANDLE pll);
 ok_ErrorCode _stdcall okFrontPanel_LoadDefaultPLLConfiguration(okFrontPanel_HANDLE hnd);
 Bool _stdcall okFrontPanel_IsFrontPanelEnabled(okFrontPanel_HANDLE hnd);
 Bool _stdcall okFrontPanel_IsFrontPanel3Supported(okFrontPanel_HANDLE hnd);
 void _stdcall okFrontPanel_UpdateWireIns(okFrontPanel_HANDLE hnd);
 ok_ErrorCode _stdcall okFrontPanel_GetWireInValue(okFrontPanel_HANDLE hnd, int epAddr, UINT32 *val);
 ok_ErrorCode _stdcall okFrontPanel_SetWireInValue(okFrontPanel_HANDLE hnd, int ep, unsigned long val, unsigned long mask);
 void _stdcall okFrontPanel_UpdateWireOuts(okFrontPanel_HANDLE hnd);
 unsigned long _stdcall okFrontPanel_GetWireOutValue(okFrontPanel_HANDLE hnd, int epAddr);
 ok_ErrorCode _stdcall okFrontPanel_ActivateTriggerIn(okFrontPanel_HANDLE hnd, int epAddr, int bit);
 void _stdcall okFrontPanel_UpdateTriggerOuts(okFrontPanel_HANDLE hnd);
 Bool _stdcall okFrontPanel_IsTriggered(okFrontPanel_HANDLE hnd, int epAddr, unsigned long mask);
 long _stdcall okFrontPanel_GetLastTransferLength(okFrontPanel_HANDLE hnd);
 long _stdcall okFrontPanel_WriteToPipeIn(okFrontPanel_HANDLE hnd, int epAddr, long length, unsigned char *data);
 long _stdcall okFrontPanel_ReadFromPipeOut(okFrontPanel_HANDLE hnd, int epAddr, long length, unsigned char *data);
 long _stdcall okFrontPanel_WriteToBlockPipeIn(okFrontPanel_HANDLE hnd, int epAddr, int blockSize, long length, unsigned char *data);
 long _stdcall okFrontPanel_ReadFromBlockPipeOut(okFrontPanel_HANDLE hnd, int epAddr, int blockSize, long length, unsigned char *data);





 okCFrontPanelManager_HANDLE _stdcall okFrontPanelManager_Construct(okFrontPanelManager_HANDLE self);
 void _stdcall okFrontPanelManager_Destruct(okCFrontPanelManager_HANDLE hnd);
 ok_ErrorCode _stdcall okFrontPanelManager_StartMonitoring(okCFrontPanelManager_HANDLE hnd);
 okFrontPanel_HANDLE _stdcall okFrontPanelManager_Open(okCFrontPanelManager_HANDLE hnd, const char *serial);


















































































































































































































































































































































































































