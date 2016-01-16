ffi = require 'ffi'
--local al = ffi.load( "soft_oal" )
ffi.cdef[[
typedef char ALboolean;
typedef char ALchar;
typedef signed char ALbyte;
typedef unsigned char ALubyte;
typedef short ALshort;
typedef unsigned short ALushort;
typedef int ALint;
typedef unsigned int ALuint;
typedef int ALsizei;
typedef int ALenum;
typedef float ALfloat;
typedef double ALdouble;
typedef void ALvoid;
enum{
AL_NONE                                  = 0     ,
AL_FALSE                                 = 0     ,
AL_TRUE                                  = 1     ,
AL_SOURCE_RELATIVE                       = 0x202 ,
AL_CONE_INNER_ANGLE                      = 0x1001,
AL_CONE_OUTER_ANGLE                      = 0x1002,
AL_PITCH                                 = 0x1003,
AL_POSITION                              = 0x1004,
AL_DIRECTION                             = 0x1005,
AL_VELOCITY                              = 0x1006,
AL_LOOPING                               = 0x1007,
AL_BUFFER                                = 0x1009,
AL_GAIN                                  = 0x100A,
AL_MIN_GAIN                              = 0x100D,
AL_MAX_GAIN                              = 0x100E,
AL_ORIENTATION                           = 0x100F,
AL_SOURCE_STATE                          = 0x1010,
AL_INITIAL                               = 0x1011,
AL_PLAYING                               = 0x1012,
AL_PAUSED                                = 0x1013,
AL_STOPPED                               = 0x1014,
AL_BUFFERS_QUEUED                        = 0x1015,
AL_BUFFERS_PROCESSED                     = 0x1016,
AL_REFERENCE_DISTANCE                    = 0x1020,
AL_ROLLOFF_FACTOR                        = 0x1021,
AL_CONE_OUTER_GAIN                       = 0x1022,
AL_MAX_DISTANCE                          = 0x1023,
AL_SEC_OFFSET                            = 0x1024,
AL_SAMPLE_OFFSET                         = 0x1025,
AL_BYTE_OFFSET                           = 0x1026,
AL_SOURCE_TYPE                           = 0x1027,
AL_STATIC                                = 0x1028,
AL_STREAMING                             = 0x1029,
AL_UNDETERMINED                          = 0x1030,
AL_FORMAT_MONO8                          = 0x1100,
AL_FORMAT_MONO16                         = 0x1101,
AL_FORMAT_STEREO8                        = 0x1102,
AL_FORMAT_STEREO16                       = 0x1103,
AL_FREQUENCY                             = 0x2001,
AL_BITS                                  = 0x2002,
AL_CHANNELS                              = 0x2003,
AL_SIZE                                  = 0x2004,
AL_UNUSED                                = 0x2010,
AL_PENDING                               = 0x2011,
AL_PROCESSED                             = 0x2012,
AL_NO_ERROR                              = 0     ,
AL_INVALID_NAME                          = 0xA001,
AL_INVALID_ENUM                          = 0xA002,
AL_INVALID_VALUE                         = 0xA003,
AL_INVALID_OPERATION                     = 0xA004,
AL_OUT_OF_MEMORY                         = 0xA005,
AL_VENDOR                                = 0xB001,
AL_VERSION                               = 0xB002,
AL_RENDERER                              = 0xB003,
AL_EXTENSIONS                            = 0xB004,
AL_DOPPLER_FACTOR                        = 0xC000,
ALC_ALL_DEVICES_SPECIFIER				 = 0x1013
};
void alDopplerFactor(ALfloat value);
enum{ AL_DOPPLER_VELOCITY                      = 0xC001};
void alDopplerVelocity(ALfloat value);
enum{ AL_SPEED_OF_SOUND                        = 0xC003};
void alSpeedOfSound(ALfloat value);
enum{
AL_DISTANCE_MODEL                        = 0xD000,
AL_INVERSE_DISTANCE                      = 0xD001,
AL_INVERSE_DISTANCE_CLAMPED              = 0xD002,
AL_LINEAR_DISTANCE                       = 0xD003,
AL_LINEAR_DISTANCE_CLAMPED               = 0xD004,
AL_EXPONENT_DISTANCE                     = 0xD005,
AL_EXPONENT_DISTANCE_CLAMPED             = 0xD006,
};
void alDistanceModel(ALenum distanceModel);
void alEnable(ALenum capability);
void alDisable(ALenum capability);
ALboolean alIsEnabled(ALenum capability);
const ALchar* alGetString(ALenum param);
void alGetBooleanv(ALenum param, ALboolean *values);
void alGetIntegerv(ALenum param, ALint *values);
void alGetFloatv(ALenum param, ALfloat *values);
void alGetDoublev(ALenum param, ALdouble *values);
ALboolean alGetBoolean(ALenum param);
ALint alGetInteger(ALenum param);
ALfloat alGetFloat(ALenum param);
ALdouble alGetDouble(ALenum param);
ALenum alGetError(void);
ALboolean alIsExtensionPresent(const ALchar *extname);
void* alGetProcAddress(const ALchar *fname);
ALenum alGetEnumValue(const ALchar *ename);
void alListenerf(ALenum param, ALfloat value);
void alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alListenerfv(ALenum param, const ALfloat *values);
void alListeneri(ALenum param, ALint value);
void alListener3i(ALenum param, ALint value1, ALint value2, ALint value3);
void alListeneriv(ALenum param, const ALint *values);
void alGetListenerf(ALenum param, ALfloat *value);
void alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetListenerfv(ALenum param, ALfloat *values);
void alGetListeneri(ALenum param, ALint *value);
void alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetListeneriv(ALenum param, ALint *values);
void alGenSources(ALsizei n, ALuint *sources);
void alDeleteSources(ALsizei n, const ALuint *sources);
ALboolean alIsSource(ALuint source);
void alSourcef(ALuint source, ALenum param, ALfloat value);
void alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alSourcefv(ALuint source, ALenum param, const ALfloat *values);
void alSourcei(ALuint source, ALenum param, ALint value);
void alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
void alSourceiv(ALuint source, ALenum param, const ALint *values);
void alGetSourcef(ALuint source, ALenum param, ALfloat *value);
void alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetSourcefv(ALuint source, ALenum param, ALfloat *values);
void alGetSourcei(ALuint source,  ALenum param, ALint *value);
void alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetSourceiv(ALuint source,  ALenum param, ALint *values);
void alSourcePlayv(ALsizei n, const ALuint *sources);
void alSourceStopv(ALsizei n, const ALuint *sources);
void alSourceRewindv(ALsizei n, const ALuint *sources);
void alSourcePausev(ALsizei n, const ALuint *sources);
void alSourcePlay(ALuint source);
void alSourceStop(ALuint source);
void alSourceRewind(ALuint source);
void alSourcePause(ALuint source);
void alSourceQueueBuffers(ALuint source, ALsizei nb, const ALuint *buffers);
void alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers);
void alGenBuffers(ALsizei n, ALuint *buffers);
void alDeleteBuffers(ALsizei n, const ALuint *buffers);
ALboolean alIsBuffer(ALuint buffer);
void alBufferData(ALuint buffer, ALenum format, const ALvoid *data, ALsizei size, ALsizei freq);
void alBufferf(ALuint buffer, ALenum param, ALfloat value);
void alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alBufferfv(ALuint buffer, ALenum param, const ALfloat *values);
void alBufferi(ALuint buffer, ALenum param, ALint value);
void alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
void alBufferiv(ALuint buffer, ALenum param, const ALint *values);
void alGetBufferf(ALuint buffer, ALenum param, ALfloat *value);
void alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values);
void alGetBufferi(ALuint buffer, ALenum param, ALint *value);
void alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetBufferiv(ALuint buffer, ALenum param, ALint *values);
enum{ ALC_EFX_MAJOR_VERSION                    = 0x20001 };
enum{ ALC_EFX_MINOR_VERSION                    = 0x20002 };
enum{ ALC_MAX_AUXILIARY_SENDS                  = 0x20003 };

/* Listener properties. */
enum{ AL_METERS_PER_UNIT                       = 0x20004 };
/* Source properties. */
enum{ AL_DIRECT_FILTER                         = 0x20005 };
enum{ AL_AUXILIARY_SEND_FILTER                 = 0x20006 };
enum{ AL_AIR_ABSORPTION_FACTOR                 = 0x20007 };
enum{ AL_ROOM_ROLLOFF_FACTOR                   = 0x20008 };
enum{ AL_CONE_OUTER_GAINHF                     = 0x20009 };
enum{ AL_DIRECT_FILTER_GAINHF_AUTO             = 0x2000A };
enum{ AL_AUXILIARY_SEND_FILTER_GAIN_AUTO       = 0x2000B };
enum{ AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO     = 0x2000C };

/* Effect properties. */
/* Reverb effect parameters */
enum{ AL_REVERB_DENSITY                        = 0x0001 };
enum{ AL_REVERB_DIFFUSION                      = 0x0002 };
enum{ AL_REVERB_GAIN                           = 0x0003 };
enum{ AL_REVERB_GAINHF                         = 0x0004 };
enum{ AL_REVERB_DECAY_TIME                     = 0x0005 };
enum{ AL_REVERB_DECAY_HFRATIO                  = 0x0006 };
enum{ AL_REVERB_REFLECTIONS_GAIN               = 0x0007 };
enum{ AL_REVERB_REFLECTIONS_DELAY              = 0x0008 };
enum{ AL_REVERB_LATE_REVERB_GAIN               = 0x0009 };
enum{ AL_REVERB_LATE_REVERB_DELAY              = 0x000A };
enum{ AL_REVERB_AIR_ABSORPTION_GAINHF          = 0x000B };
enum{ AL_REVERB_ROOM_ROLLOFF_FACTOR            = 0x000C };
enum{ AL_REVERB_DECAY_HFLIMIT                  = 0x000D };
/* EAX Reverb effect parameters */
enum{ AL_EAXREVERB_DENSITY                     = 0x0001 };
enum{ AL_EAXREVERB_DIFFUSION                   = 0x0002 };
enum{ AL_EAXREVERB_GAIN                        = 0x0003 };
enum{ AL_EAXREVERB_GAINHF                      = 0x0004 };
enum{ AL_EAXREVERB_GAINLF                      = 0x0005 };
enum{ AL_EAXREVERB_DECAY_TIME                  = 0x0006 };
enum{ AL_EAXREVERB_DECAY_HFRATIO               = 0x0007 };
enum{ AL_EAXREVERB_DECAY_LFRATIO               = 0x0008 };
enum{ AL_EAXREVERB_REFLECTIONS_GAIN            = 0x0009 };
enum{ AL_EAXREVERB_REFLECTIONS_DELAY           = 0x000A };
enum{ AL_EAXREVERB_REFLECTIONS_PAN             = 0x000B };
enum{ AL_EAXREVERB_LATE_REVERB_GAIN            = 0x000C };
enum{ AL_EAXREVERB_LATE_REVERB_DELAY           = 0x000D };
enum{ AL_EAXREVERB_LATE_REVERB_PAN             = 0x000E };
enum{ AL_EAXREVERB_ECHO_TIME                   = 0x000F };
enum{ AL_EAXREVERB_ECHO_DEPTH                  = 0x0010 };
enum{ AL_EAXREVERB_MODULATION_TIME             = 0x0011 };
enum{ AL_EAXREVERB_MODULATION_DEPTH            = 0x0012 };
enum{ AL_EAXREVERB_AIR_ABSORPTION_GAINHF       = 0x0013 };
enum{ AL_EAXREVERB_HFREFERENCE                 = 0x0014 };
enum{ AL_EAXREVERB_LFREFERENCE                 = 0x0015 };
enum{ AL_EAXREVERB_ROOM_ROLLOFF_FACTOR         = 0x0016 };
enum{ AL_EAXREVERB_DECAY_HFLIMIT               = 0x0017 };
/* Chorus effect parameters */
enum{ AL_CHORUS_WAVEFORM                       = 0x0001 };
enum{ AL_CHORUS_PHASE                          = 0x0002 };
enum{ AL_CHORUS_RATE                           = 0x0003 };
enum{ AL_CHORUS_DEPTH                          = 0x0004 };
enum{ AL_CHORUS_FEEDBACK                       = 0x0005 };
enum{ AL_CHORUS_DELAY                          = 0x0006 };
/* Distortion effect parameters */
enum{ AL_DISTORTION_EDGE                       = 0x0001 };
enum{ AL_DISTORTION_GAIN                       = 0x0002 };
enum{ AL_DISTORTION_LOWPASS_CUTOFF             = 0x0003 };
enum{ AL_DISTORTION_EQCENTER                   = 0x0004 };
enum{ AL_DISTORTION_EQBANDWIDTH                = 0x0005 };

/* Echo effect parameters */
enum{ AL_ECHO_DELAY                            = 0x0001 };
enum{ AL_ECHO_LRDELAY                          = 0x0002 };
enum{ AL_ECHO_DAMPING                          = 0x0003 };
enum{ AL_ECHO_FEEDBACK                         = 0x0004 };
enum{ AL_ECHO_SPREAD                           = 0x0005 };

/* Flanger effect parameters */
enum{ AL_FLANGER_WAVEFORM                      = 0x0001 };
enum{ AL_FLANGER_PHASE                         = 0x0002 };
enum{ AL_FLANGER_RATE                          = 0x0003 };
enum{ AL_FLANGER_DEPTH                         = 0x0004 };
enum{ AL_FLANGER_FEEDBACK                      = 0x0005 };
enum{ AL_FLANGER_DELAY                         = 0x0006 };

/* Frequency shifter effect parameters */
enum{ AL_FREQUENCY_SHIFTER_FREQUENCY           = 0x0001 };
enum{ AL_FREQUENCY_SHIFTER_LEFT_DIRECTION      = 0x0002 };
enum{ AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION     = 0x0003 };

/* Vocal morpher effect parameters */
enum{ AL_VOCAL_MORPHER_PHONEMEA                = 0x0001 };
enum{ AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING  = 0x0002 };
enum{ AL_VOCAL_MORPHER_PHONEMEB                = 0x0003 };
enum{ AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING  = 0x0004 };
enum{ AL_VOCAL_MORPHER_WAVEFORM                = 0x0005 };
enum{ AL_VOCAL_MORPHER_RATE                    = 0x0006 };

/* Pitchshifter effect parameters */
enum{ AL_PITCH_SHIFTER_COARSE_TUNE             = 0x0001 };
enum{ AL_PITCH_SHIFTER_FINE_TUNE               = 0x0002 };

/* Ringmodulator effect parameters */
enum{ AL_RING_MODULATOR_FREQUENCY              = 0x0001 };
enum{ AL_RING_MODULATOR_HIGHPASS_CUTOFF        = 0x0002 };
enum{ AL_RING_MODULATOR_WAVEFORM               = 0x0003 };

/* Autowah effect parameters */
enum{ AL_AUTOWAH_ATTACK_TIME                   = 0x0001 };
enum{ AL_AUTOWAH_RELEASE_TIME                  = 0x0002 };
enum{ AL_AUTOWAH_RESONANCE                     = 0x0003 };
enum{ AL_AUTOWAH_PEAK_GAIN                     = 0x0004 };

/* Compressor effect parameters */
enum{ AL_COMPRESSOR_ONOFF                      = 0x0001 };

/* Equalizer effect parameters */
enum{ AL_EQUALIZER_LOW_GAIN                    = 0x0001 };
enum{ AL_EQUALIZER_LOW_CUTOFF                  = 0x0002 };
enum{ AL_EQUALIZER_MID1_GAIN                   = 0x0003 };
enum{ AL_EQUALIZER_MID1_CENTER                 = 0x0004 };
enum{ AL_EQUALIZER_MID1_WIDTH                  = 0x0005 };
enum{ AL_EQUALIZER_MID2_GAIN                   = 0x0006 };
enum{ AL_EQUALIZER_MID2_CENTER                 = 0x0007 };
enum{ AL_EQUALIZER_MID2_WIDTH                  = 0x0008 };
enum{ AL_EQUALIZER_HIGH_GAIN                   = 0x0009 };
enum{ AL_EQUALIZER_HIGH_CUTOFF                 = 0x000A };

/* Effect type */
enum{ AL_EFFECT_FIRST_PARAMETER                = 0x0000 };
enum{ AL_EFFECT_LAST_PARAMETER                 = 0x8000 };
enum{ AL_EFFECT_TYPE                           = 0x8001 };

/* Effect types, used with the AL_EFFECT_TYPE property /
enum{ AL_EFFECT_NULL                           = 0x0000 };
enum{ AL_EFFECT_REVERB                         = 0x0001 };
enum{ AL_EFFECT_CHORUS                         = 0x0002 };
enum{ AL_EFFECT_DISTORTION                     = 0x0003 };
enum{ AL_EFFECT_ECHO                           = 0x0004 };
enum{ AL_EFFECT_FLANGER                        = 0x0005 };
enum{ AL_EFFECT_FREQUENCY_SHIFTER              = 0x0006 };
enum{ AL_EFFECT_VOCAL_MORPHER                  = 0x0007 };
enum{ AL_EFFECT_PITCH_SHIFTER                  = 0x0008 };
enum{ AL_EFFECT_RING_MODULATOR                 = 0x0009 };
enum{ AL_EFFECT_AUTOWAH                        = 0x000A };
enum{ AL_EFFECT_COMPRESSOR                     = 0x000B };
enum{ AL_EFFECT_EQUALIZER                      = 0x000C };
enum{ AL_EFFECT_EAXREVERB                      = 0x8000 };

/* Auxiliary Effect Slot properties. */
enum{ AL_EFFECTSLOT_EFFECT                     = 0x0001 };
enum{ AL_EFFECTSLOT_GAIN                       = 0x0002 };
enum{ AL_EFFECTSLOT_AUXILIARY_SEND_AUTO        = 0x0003 };

/* NULL Auxiliary Slot ID to disable a source send. */
enum{ AL_EFFECTSLOT_NULL                       = 0x0000 };


/* Filter properties. */

/* Lowpass filter parameters */
enum{ AL_LOWPASS_GAIN                          = 0x0001 };
enum{ AL_LOWPASS_GAINHF                        = 0x0002 };

/* Highpass filter parameters */
enum{ AL_HIGHPASS_GAIN                         = 0x0001 };
enum{ AL_HIGHPASS_GAINLF                       = 0x0002 };

/* Bandpass filter parameters */
enum{ AL_BANDPASS_GAIN                         = 0x0001 };
enum{ AL_BANDPASS_GAINLF                       = 0x0002 };
enum{ AL_BANDPASS_GAINHF                       = 0x0003 };

/* Filter type */
enum{ AL_FILTER_FIRST_PARAMETER                = 0x0000 };
enum{ AL_FILTER_LAST_PARAMETER                 = 0x8000 };
enum{ AL_FILTER_TYPE                           = 0x8001 };

/* Filter types, used with the AL_FILTER_TYPE property */
enum{ AL_FILTER_NULL                           = 0x0000 };
enum{ AL_FILTER_LOWPASS                        = 0x0001 };
enum{ AL_FILTER_HIGHPASS                       = 0x0002 };
enum{ AL_FILTER_BANDPASS                       = 0x0003 };
ALvoid alGenEffects(ALsizei n, ALuint *effects);
ALvoid alDeleteEffects(ALsizei n, const ALuint *effects);
ALboolean alIsEffect(ALuint effect);
ALvoid alEffecti(ALuint effect, ALenum param, ALint iValue);
ALvoid alEffectiv(ALuint effect, ALenum param, const ALint *piValues);
ALvoid alEffectf(ALuint effect, ALenum param, ALfloat flValue);
ALvoid alEffectfv(ALuint effect, ALenum param, const ALfloat *pflValues);
ALvoid alGetEffecti(ALuint effect, ALenum param, ALint *piValue);
ALvoid alGetEffectiv(ALuint effect, ALenum param, ALint *piValues);
ALvoid alGetEffectf(ALuint effect, ALenum param, ALfloat *pflValue);
ALvoid alGetEffectfv(ALuint effect, ALenum param, ALfloat *pflValues);
ALvoid alGenFilters(ALsizei n, ALuint *filters);
ALvoid alDeleteFilters(ALsizei n, const ALuint *filters);
ALboolean alIsFilter(ALuint filter);
ALvoid alFilteri(ALuint filter, ALenum param, ALint iValue);
ALvoid alFilteriv(ALuint filter, ALenum param, const ALint *piValues);
ALvoid alFilterf(ALuint filter, ALenum param, ALfloat flValue);
ALvoid alFilterfv(ALuint filter, ALenum param, const ALfloat *pflValues);
ALvoid alGetFilteri(ALuint filter, ALenum param, ALint *piValue);
ALvoid alGetFilteriv(ALuint filter, ALenum param, ALint *piValues);
ALvoid alGetFilterf(ALuint filter, ALenum param, ALfloat *pflValue);
ALvoid alGetFilterfv(ALuint filter, ALenum param, ALfloat *pflValues);
ALvoid alGenAuxiliaryEffectSlots(ALsizei n, ALuint *effectslots);
ALvoid alDeleteAuxiliaryEffectSlots(ALsizei n, const ALuint *effectslots);
ALboolean alIsAuxiliaryEffectSlot(ALuint effectslot);
ALvoid alAuxiliaryEffectSloti(ALuint effectslot, ALenum param, ALint iValue);
ALvoid alAuxiliaryEffectSlotiv(ALuint effectslot, ALenum param, const ALint *piValues);
ALvoid alAuxiliaryEffectSlotf(ALuint effectslot, ALenum param, ALfloat flValue);
ALvoid alAuxiliaryEffectSlotfv(ALuint effectslot, ALenum param, const ALfloat *pflValues);
ALvoid alGetAuxiliaryEffectSloti(ALuint effectslot, ALenum param, ALint *piValue);
ALvoid alGetAuxiliaryEffectSlotiv(ALuint effectslot, ALenum param, ALint *piValues);
ALvoid alGetAuxiliaryEffectSlotf(ALuint effectslot, ALenum param, ALfloat *pflValue);
ALvoid alGetAuxiliaryEffectSlotfv(ALuint effectslot, ALenum param, ALfloat *pflValues);

//alc
/** Opaque device handle */
typedef struct ALCdevice_struct ALCdevice;
/** Opaque context handle */
typedef struct ALCcontext_struct ALCcontext;
/** 8-bit boolean */
typedef char ALCboolean;
/** character */
typedef char ALCchar;
/** signed 8-bit 2's complement integer */
typedef signed char ALCbyte;
/** unsigned 8-bit integer */
typedef unsigned char ALCubyte;
/** signed 16-bit 2's complement integer */
typedef short ALCshort;
/** unsigned 16-bit integer */
typedef unsigned short ALCushort;
/** signed 32-bit 2's complement integer */
typedef int ALCint;
/** unsigned 32-bit integer */
typedef unsigned int ALCuint;
/** non-negative 32-bit binary integer size */
typedef int ALCsizei;
/** enumerated 32-bit value */
typedef int ALCenum;
/** 32-bit IEEE754 floating-point */
typedef float ALCfloat;
/** 64-bit IEEE754 floating-point */
typedef double ALCdouble;
/** void type (for opaque pointers only) */
typedef void ALCvoid;
typedef struct ALCdevice_struct ALCdevice;
/** Opaque context handle */
typedef struct ALCcontext_struct ALCcontext;
ALCcontext* alcCreateContext(ALCdevice *device, const ALCint* attrlist);
ALCboolean  alcMakeContextCurrent(ALCcontext *context);
void        alcProcessContext(ALCcontext *context);
void        alcSuspendContext(ALCcontext *context);
void        alcDestroyContext(ALCcontext *context);
ALCcontext* alcGetCurrentContext(void);
ALCdevice*  alcGetContextsDevice(ALCcontext *context);
/** Device management. */
ALCdevice* alcOpenDevice(const ALCchar *devicename);
ALCboolean alcCloseDevice(ALCdevice *device);

/**
 * Error support.
 *
 * Obtain the most recent Device error.
 */
ALCenum alcGetError(ALCdevice *device);
/**
 * Extension support.
 *
 * Query for the presence of an extension, and obtain any appropriate
 * function pointers and enum values.
 */
ALCboolean alcIsExtensionPresent(ALCdevice *device, const ALCchar *extname);
void*      alcGetProcAddress(ALCdevice *device, const ALCchar *funcname);
ALCenum    alcGetEnumValue(ALCdevice *device, const ALCchar *enumname);
/** Query function. */
const ALCchar* alcGetString(ALCdevice *device, ALCenum param);
void           alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);
/** Capture function. */
ALCdevice* alcCaptureOpenDevice(const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
ALCboolean alcCaptureCloseDevice(ALCdevice *device);
void       alcCaptureStart(ALCdevice *device);
void       alcCaptureStop(ALCdevice *device);
void       alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);
]]
local module
if(jit.os == 'Linux') then
    module = ffi.load( 'bin/libopenal.so' )--interference from linux openal must be prevented
else
    module = ffi.load( 'openal' )
end
local al = setmetatable( {}, {__index = module} )
return al
