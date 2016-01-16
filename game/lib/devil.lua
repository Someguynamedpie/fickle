local ffi = require( 'ffi' )
ffi.cdef[[

typedef unsigned int   ILenum;
typedef unsigned char  ILboolean;
typedef unsigned int   ILbitfield;
typedef signed char    ILbyte;
typedef signed short   ILshort;
typedef int     	   ILint;
typedef size_t         ILsizei;
typedef unsigned char  ILubyte;
typedef unsigned short ILushort;
typedef unsigned int   ILuint;
typedef float          ILfloat;
typedef float          ILclampf;
typedef double         ILdouble;
typedef double         ILclampd;

typedef long long int          ILint64;
typedef long long unsigned int ILuint64;

typedef char ILchar;
typedef char* ILstring;
typedef char const * ILconst_string;

typedef void* ILHANDLE;
//typedef void      (*fCloseRProc)(ILHANDLE);
//typedef ILboolean (*fEofProc)   (ILHANDLE);
//typedef ILint     (*fGetcProc)  (ILHANDLE);
//typedef ILHANDLE  (*fOpenRProc) (ILconst_string);
//typedef ILint     (*fReadProc)  (void*, ILuint, ILuint, ILHANDLE);
//typedef ILint     (*fSeekRProc) (ILHANDLE, ILint, ILint);
//typedef ILint     (*fTellRProc) (ILHANDLE);
//
//// Callback functions for file writing
//typedef void     (*fCloseWProc)(ILHANDLE);
//typedef ILHANDLE (*fOpenWProc) (ILconst_string);
//typedef ILint    (*fPutcProc)  (ILubyte, ILHANDLE);
//typedef ILint    (*fSeekWProc) (ILHANDLE, ILint, ILint);
//typedef ILint    (*fTellWProc) (ILHANDLE);
//typedef ILint    (*fWriteProc) (const void*, ILuint, ILuint, ILHANDLE);

// Callback functions for allocation and deallocation
//typedef void* (*mAlloc)(const ILsizei);
//typedef void  (*mFree) (const void* CONST_RESTRICT);
//
//// Registered format procedures
//typedef ILenum (*IL_LOADPROC)(ILconst_string);
//typedef ILenum (*IL_SAVEPROC)(ILconst_string);


// ImageLib Functions
ILboolean ilActiveFace(ILuint Number);
ILboolean ilActiveImage(ILuint Number);
ILboolean ilActiveLayer(ILuint Number);
ILboolean ilActiveMipmap(ILuint Number);
ILboolean ilApplyPal(ILconst_string FileName);
ILboolean ilApplyProfile(ILstring InProfile, ILstring OutProfile);
void		ilBindImage(ILuint Image);
ILboolean ilBlit(ILuint Source, ILint DestX, ILint DestY, ILint DestZ, ILuint SrcX, ILuint SrcY, ILuint SrcZ, ILuint Width, ILuint Height, ILuint Depth);
ILboolean ilClampNTSC(void);
void		ilClearColour(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
ILboolean ilClearImage(void);
ILuint    ilCloneCurImage(void);
ILubyte*	ilCompressDXT(ILubyte *Data, ILuint Width, ILuint Height, ILuint Depth, ILenum DXTCFormat, ILuint *DXTCSize);
ILboolean ilCompressFunc(ILenum Mode);
ILboolean ilConvertImage(ILenum DestFormat, ILenum DestType);
ILboolean ilConvertPal(ILenum DestFormat);
ILboolean ilCopyImage(ILuint Src);
ILuint    ilCopyPixels(ILuint XOff, ILuint YOff, ILuint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
ILuint    ilCreateSubImage(ILenum Type, ILuint Num);
ILboolean ilDefaultImage(void);
void		ilDeleteImage(const ILuint Num);
void      ilDeleteImages(ILsizei Num, const ILuint *Images);
ILenum	ilDetermineType(ILconst_string FileName);
ILenum	ilDetermineTypeF(ILHANDLE File);
ILenum	ilDetermineTypeL(const void *Lump, ILuint Size);
ILboolean ilDisable(ILenum Mode);
ILboolean ilDxtcDataToImage(void);
ILboolean ilDxtcDataToSurface(void);
ILboolean ilEnable(ILenum Mode);
void		ilFlipSurfaceDxtcData(void);
ILboolean ilFormatFunc(ILenum Mode);
void	    ilGenImages(ILsizei Num, ILuint *Images);
ILuint	ilGenImage(void);
ILubyte*  ilGetAlpha(ILenum Type);
ILboolean ilGetBoolean(ILenum Mode);
void      ilGetBooleanv(ILenum Mode, ILboolean *Param);
ILubyte*  ilGetData(void);
ILuint    ilGetDXTCData(void *Buffer, ILuint BufferSize, ILenum DXTCFormat);
ILenum    ilGetError(void);
ILint     ilGetInteger(ILenum Mode);
void      ilGetIntegerv(ILenum Mode, ILint *Param);
ILuint    ilGetLumpPos(void);
ILubyte*  ilGetPalette(void);
ILconst_string  ilGetString(ILenum StringName);
void      ilHint(ILenum Target, ILenum Mode);
ILboolean	ilInvertSurfaceDxtcDataAlpha(void);
void      ilInit(void);
ILboolean ilImageToDxtcData(ILenum Format);
ILboolean ilIsDisabled(ILenum Mode);
ILboolean ilIsEnabled(ILenum Mode);
ILboolean ilIsImage(ILuint Image);
ILboolean ilIsValid(ILenum Type, ILconst_string FileName);
ILboolean ilIsValidF(ILenum Type, ILHANDLE File);
ILboolean ilIsValidL(ILenum Type, void *Lump, ILuint Size);
void      ilKeyColour(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
ILboolean ilLoad(ILenum Type, ILconst_string FileName);
ILboolean ilLoadF(ILenum Type, ILHANDLE File);
ILboolean ilLoadImage(ILconst_string FileName);
ILboolean ilLoadL(ILenum Type, const void *Lump, ILuint Size);
ILboolean ilLoadPal(ILconst_string FileName);
void      ilModAlpha(ILdouble AlphaValue);
ILboolean ilOriginFunc(ILenum Mode);
ILboolean ilOverlayImage(ILuint Source, ILint XCoord, ILint YCoord, ILint ZCoord);
void      ilPopAttrib(void);
void      ilPushAttrib(ILuint Bits);
void      ilRegisterFormat(ILenum Format);
//ILboolean ilRegisterLoad(ILconst_string Ext, IL_LOADPROC Load);
ILboolean ilRegisterMipNum(ILuint Num);
ILboolean ilRegisterNumFaces(ILuint Num);
ILboolean ilRegisterNumImages(ILuint Num);
void      ilRegisterOrigin(ILenum Origin);
void      ilRegisterPal(void *Pal, ILuint Size, ILenum Type);
//ILboolean ilRegisterSave(ILconst_string Ext, IL_SAVEPROC Save);
void      ilRegisterType(ILenum Type);
ILboolean ilRemoveLoad(ILconst_string Ext);
ILboolean ilRemoveSave(ILconst_string Ext);
void      ilResetMemory(void); // Deprecated
void      ilResetRead(void);
void      ilResetWrite(void);
ILboolean ilSave(ILenum Type, ILconst_string FileName);
ILuint    ilSaveF(ILenum Type, ILHANDLE File);
ILboolean ilSaveImage(ILconst_string FileName);
ILuint    ilSaveL(ILenum Type, void *Lump, ILuint Size);
ILboolean ilSavePal(ILconst_string FileName);
ILboolean ilSetAlpha(ILdouble AlphaValue);
ILboolean ilSetData(void *Data);
ILboolean ilSetDuration(ILuint Duration);
void      ilSetInteger(ILenum Mode, ILint Param);
//void      ilSetMemory(mAlloc, mFree);
void      ilSetPixels(ILint XOff, ILint YOff, ILint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
//void      ilSetRead(fOpenRProc, fCloseRProc, fEofProc, fGetcProc, fReadProc, fSeekRProc, fTellRProc);
void      ilSetString(ILenum Mode, const char *String);
//void      ilSetWrite(fOpenWProc, fCloseWProc, fPutcProc, fSeekWProc, fTellWProc, fWriteProc);
void      ilShutDown(void);
ILboolean ilSurfaceToDxtcData(ILenum Format);
ILboolean ilTexImage(ILuint Width, ILuint Height, ILuint Depth, ILubyte NumChannels, ILenum Format, ILenum Type, void *Data);
ILboolean ilTexImageDxtc(ILint w, ILint h, ILint d, ILenum DxtFormat, const ILubyte* data);
ILenum    ilTypeFromExt(ILconst_string FileName);
ILboolean ilTypeFunc(ILenum Mode);
ILboolean ilLoadData(ILconst_string FileName, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilLoadDataF(ILHANDLE File, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilLoadDataL(void *Lump, ILuint Size, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
ILboolean ilSaveData(ILconst_string FileName);
]]
local module = ffi.load'IL'
local devil = setmetatable( {}, {__index = function(_, k) return module['il' .. k] end} )
devil.COLOUR_INDEX    = 0x1900
devil.COLOR_INDEX     = 0x1900
devil.ALPHA			  = 0x1906
devil.RGB             = 0x1907
devil.RGBA            = 0x1908
devil.BGR             = 0x80E0
devil.BGRA            = 0x80E1
devil.LUMINANCE       = 0x1909
devil.LUMINANCE_ALPHA = 0x190A

devil.BYTE           = 0x1400
devil.UNSIGNED_BYTE  = 0x1401
devil.SHORT          = 0x1402
devil.UNSIGNED_SHORT = 0x1403
devil.INT            = 0x1404
devil.UNSIGNED_INT   = 0x1405
devil.FLOAT          = 0x1406
devil.DOUBLE         = 0x140A
devil.HALF           = 0x140B

devil.VERSION_NUM           = 0x0DE2
devil.IMAGE_WIDTH           = 0x0DE4
devil.IMAGE_HEIGHT          = 0x0DE5
devil.IMAGE_DEPTH           = 0x0DE6
devil.IMAGE_SIZE_OF_DATA    = 0x0DE7
devil.IMAGE_BPP             = 0x0DE8
devil.IMAGE_BYTES_PER_PIXEL = 0x0DE8
devil.IMAGE_BPP             = 0x0DE8
devil.IMAGE_BITS_PER_PIXEL  = 0x0DE9
devil.IMAGE_FORMAT          = 0x0DEA
devil.IMAGE_TYPE            = 0x0DEB
devil.PALETTE_TYPE          = 0x0DEC
devil.PALETTE_SIZE          = 0x0DED
devil.PALETTE_BPP           = 0x0DEE
devil.PALETTE_NUM_COLS      = 0x0DEF
devil.PALETTE_BASE_TYPE     = 0x0DF0
devil.NUM_FACES             = 0x0DE1
devil.NUM_IMAGES            = 0x0DF1
devil.NUM_MIPMAPS           = 0x0DF2
devil.NUM_LAYERS            = 0x0DF3
devil.ACTIVE_IMAGE          = 0x0DF4
devil.ACTIVE_MIPMAP         = 0x0DF5
devil.ACTIVE_LAYER          = 0x0DF6
devil.ACTIVE_FACE           = 0x0E00
devil.CUR_IMAGE             = 0x0DF7
devil.IMAGE_DURATION        = 0x0DF8
devil.IMAGE_PLANESIZE       = 0x0DF9
devil.IMAGE_BPC             = 0x0DFA
devil.IMAGE_OFFX            = 0x0DFB
devil.IMAGE_OFFY            = 0x0DFC
devil.IMAGE_CUBEFLAGS       = 0x0DFD
devil.IMAGE_ORIGIN          = 0x0DFE
devil.IMAGE_CHANNELS        = 0x0DFF

return devil
