local ffi=require'ffi'
ffi.cdef[[
static const int enet_VERSION_MAJOR = 1;
static const int enet_VERSION_MINOR = 3;
static const int enet_VERSION_PATCH = 4;
static const int enet_VERSION = (((enet_VERSION_MAJOR)<<16) | ((enet_VERSION_MINOR)<<8) | (enet_VERSION_PATCH));
// SOCKET has different definitions on different systems (unsigned int on Windows, signed on Linux).
// This is only provided for aligning structs. It's perfectly possible to avoid using the sockets directly.
//typedef SOCKET ENetSocket;
typedef int SOCKET;
typedef SOCKET ENetSocket;
enum
{
enet_SOCKET_NULL = (ENetSocket)(~0)
};
typedef struct
{
size_t dataLength;
void * data;
} ENetBuffer;
typedef struct fd_set ENetSocketSet; // Only used internally so doesn't really need to be exposed
typedef uint8_t enet_uint8;
typedef uint16_t enet_uint16;
typedef uint32_t enet_uint32;
enum
{
enet_PROTOCOL_MINIMUM_MTU = 576,
enet_PROTOCOL_MAXIMUM_MTU = 4096,
enet_PROTOCOL_MAXIMUM_PACKET_COMMANDS = 32,
enet_PROTOCOL_MINIMUM_WINDOW_SIZE = 4096,
enet_PROTOCOL_MAXIMUM_WINDOW_SIZE = 32768,
enet_PROTOCOL_MINIMUM_CHANNEL_COUNT = 1,
enet_PROTOCOL_MAXIMUM_CHANNEL_COUNT = 255,
enet_PROTOCOL_MAXIMUM_PEER_ID = 0xFFF,
enet_PROTOCOL_MAXIMUM_PACKET_SIZE = 1024 * 1024 * 1024,
enet_PROTOCOL_MAXIMUM_FRAGMENT_COUNT = 1024 * 1024
};
typedef enum _ENetProtocolCommand
{
enet_PROTOCOL_COMMAND_NONE = 0,
enet_PROTOCOL_COMMAND_ACKNOWLEDGE = 1,
enet_PROTOCOL_COMMAND_CONNECT = 2,
enet_PROTOCOL_COMMAND_VERIFY_CONNECT = 3,
enet_PROTOCOL_COMMAND_DISCONNECT = 4,
enet_PROTOCOL_COMMAND_PING = 5,
enet_PROTOCOL_COMMAND_SEND_RELIABLE = 6,
enet_PROTOCOL_COMMAND_SEND_UNRELIABLE = 7,
enet_PROTOCOL_COMMAND_SEND_FRAGMENT = 8,
enet_PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9,
enet_PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10,
enet_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11,
enet_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12,
enet_PROTOCOL_COMMAND_COUNT = 13,
enet_PROTOCOL_COMMAND_MASK = 0x0F
} ENetProtocolCommand;
typedef enum _ENetProtocolFlag
{
enet_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 << 7),
enet_PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 << 6),
enet_PROTOCOL_HEADER_FLAG_COMPRESSED = (1 << 14),
enet_PROTOCOL_HEADER_FLAG_SENT_TIME = (1 << 15),
enet_PROTOCOL_HEADER_FLAG_MASK = enet_PROTOCOL_HEADER_FLAG_COMPRESSED | enet_PROTOCOL_HEADER_FLAG_SENT_TIME,
enet_PROTOCOL_HEADER_SESSION_MASK = (3 << 12),
enet_PROTOCOL_HEADER_SESSION_SHIFT = 12
} ENetProtocolFlag;
typedef struct _ENetProtocolHeader
{
enet_uint16 peerID;
enet_uint16 sentTime;
} __attribute__ ((packed)) ENetProtocolHeader;
typedef struct _ENetProtocolCommandHeader
{
enet_uint8 command;
enet_uint8 channelID;
enet_uint16 reliableSequenceNumber;
} __attribute__ ((packed)) ENetProtocolCommandHeader;
typedef struct _ENetProtocolAcknowledge
{
ENetProtocolCommandHeader header;
enet_uint16 receivedReliableSequenceNumber;
enet_uint16 receivedSentTime;
} __attribute__ ((packed)) ENetProtocolAcknowledge;
typedef struct _ENetProtocolConnect
{
ENetProtocolCommandHeader header;
enet_uint16 outgoingPeerID;
enet_uint8 incomingSessionID;
enet_uint8 outgoingSessionID;
enet_uint32 mtu;
enet_uint32 windowSize;
enet_uint32 channelCount;
enet_uint32 incomingBandwidth;
enet_uint32 outgoingBandwidth;
enet_uint32 packetThrottleInterval;
enet_uint32 packetThrottleAcceleration;
enet_uint32 packetThrottleDeceleration;
enet_uint32 connectID;
enet_uint32 data;
} __attribute__ ((packed)) ENetProtocolConnect;
typedef struct _ENetProtocolVerifyConnect
{
ENetProtocolCommandHeader header;
enet_uint16 outgoingPeerID;
enet_uint8 incomingSessionID;
enet_uint8 outgoingSessionID;
enet_uint32 mtu;
enet_uint32 windowSize;
enet_uint32 channelCount;
enet_uint32 incomingBandwidth;
enet_uint32 outgoingBandwidth;
enet_uint32 packetThrottleInterval;
enet_uint32 packetThrottleAcceleration;
enet_uint32 packetThrottleDeceleration;
enet_uint32 connectID;
} __attribute__ ((packed)) ENetProtocolVerifyConnect;
typedef struct _ENetProtocolBandwidthLimit
{
ENetProtocolCommandHeader header;
enet_uint32 incomingBandwidth;
enet_uint32 outgoingBandwidth;
} __attribute__ ((packed)) ENetProtocolBandwidthLimit;
typedef struct _ENetProtocolThrottleConfigure
{
ENetProtocolCommandHeader header;
enet_uint32 packetThrottleInterval;
enet_uint32 packetThrottleAcceleration;
enet_uint32 packetThrottleDeceleration;
} __attribute__ ((packed)) ENetProtocolThrottleConfigure;
typedef struct _ENetProtocolDisconnect
{
ENetProtocolCommandHeader header;
enet_uint32 data;
} __attribute__ ((packed)) ENetProtocolDisconnect;
typedef struct _ENetProtocolPing
{
ENetProtocolCommandHeader header;
} __attribute__ ((packed)) ENetProtocolPing;
typedef struct _ENetProtocolSendReliable
{
ENetProtocolCommandHeader header;
enet_uint16 dataLength;
} __attribute__ ((packed)) ENetProtocolSendReliable;
typedef struct _ENetProtocolSendUnreliable
{
ENetProtocolCommandHeader header;
enet_uint16 unreliableSequenceNumber;
enet_uint16 dataLength;
} __attribute__ ((packed)) ENetProtocolSendUnreliable;
typedef struct _ENetProtocolSendUnsequenced
{
ENetProtocolCommandHeader header;
enet_uint16 unsequencedGroup;
enet_uint16 dataLength;
} __attribute__ ((packed)) ENetProtocolSendUnsequenced;
typedef struct _ENetProtocolSendFragment
{
ENetProtocolCommandHeader header;
enet_uint16 startSequenceNumber;
enet_uint16 dataLength;
enet_uint32 fragmentCount;
enet_uint32 fragmentNumber;
enet_uint32 totalLength;
enet_uint32 fragmentOffset;
} __attribute__ ((packed)) ENetProtocolSendFragment;
typedef union _ENetProtocol
{
ENetProtocolCommandHeader header;
ENetProtocolAcknowledge acknowledge;
ENetProtocolConnect connect;
ENetProtocolVerifyConnect verifyConnect;
ENetProtocolDisconnect disconnect;
ENetProtocolPing ping;
ENetProtocolSendReliable sendReliable;
ENetProtocolSendUnreliable sendUnreliable;
ENetProtocolSendUnsequenced sendUnsequenced;
ENetProtocolSendFragment sendFragment;
ENetProtocolBandwidthLimit bandwidthLimit;
ENetProtocolThrottleConfigure throttleConfigure;
} __attribute__ ((packed)) ENetProtocol;
typedef struct _ENetListNode
{
struct _ENetListNode * next;
struct _ENetListNode * previous;
} ENetListNode;
typedef ENetListNode * ENetListIterator;
typedef struct _ENetList
{
ENetListNode sentinel;
} ENetList;
extern void enet_list_clear (ENetList *);
extern ENetListIterator enet_list_insert (ENetListIterator, void *);
extern void * enet_list_remove (ENetListIterator);
extern ENetListIterator enet_list_move (ENetListIterator, void *, void *);
extern size_t enet_list_size (ENetList *);
typedef struct _ENetCallbacks
{
void * (__attribute__((__cdecl__)) * malloc) (size_t size);
void (__attribute__((__cdecl__)) * free) (void * memory);
void (__attribute__((__cdecl__)) * no_memory) (void);
} ENetCallbacks;
extern void * enet_malloc (size_t);
extern void enet_free (void *);
typedef enet_uint32 ENetVersion;
typedef enum _ENetSocketType
{
enet_SOCKET_TYPE_STREAM = 1,
enet_SOCKET_TYPE_DATAGRAM = 2
} ENetSocketType;
typedef enum _ENetSocketWait
{
enet_SOCKET_WAIT_NONE = 0,
enet_SOCKET_WAIT_SEND = (1 << 0),
enet_SOCKET_WAIT_RECEIVE = (1 << 1)
} ENetSocketWait;
typedef enum _ENetSocketOption
{
enet_SOCKOPT_NONBLOCK = 1,
enet_SOCKOPT_BROADCAST = 2,
enet_SOCKOPT_RCVBUF = 3,
enet_SOCKOPT_SNDBUF = 4,
enet_SOCKOPT_REUSEADDR = 5,
enet_SOCKOPT_RCVTIMEO = 6,
enet_SOCKOPT_SNDTIMEO = 7
} ENetSocketOption;
enum
{
enet_HOST_ANY = 0,
enet_HOST_BROADCAST = 0xFFFFFFFF,
enet_PORT_ANY = 0
};
typedef struct _ENetAddress
{
enet_uint32 host;
enet_uint16 port;
} ENetAddress;
typedef enum _ENetPacketFlag
{
enet_PACKET_FLAG_RELIABLE = (1 << 0),
enet_PACKET_FLAG_UNSEQUENCED = (1 << 1),
enet_PACKET_FLAG_NO_ALLOCATE = (1 << 2),
enet_PACKET_FLAG_UNRELIABLE_FRAGMENT = (1 << 3)
} ENetPacketFlag;
struct _ENetPacket;
typedef void (__attribute__((__cdecl__)) * ENetPacketFreeCallback) (struct _ENetPacket *);
typedef struct _ENetPacket
{
size_t referenceCount;
enet_uint32 flags;
enet_uint8 * data;
size_t dataLength;
ENetPacketFreeCallback freeCallback;
} ENetPacket;
typedef struct _ENetAcknowledgement
{
ENetListNode acknowledgementList;
enet_uint32 sentTime;
ENetProtocol command;
} ENetAcknowledgement;
typedef struct _ENetOutgoingCommand
{
ENetListNode outgoingCommandList;
enet_uint16 reliableSequenceNumber;
enet_uint16 unreliableSequenceNumber;
enet_uint32 sentTime;
enet_uint32 roundTripTimeout;
enet_uint32 roundTripTimeoutLimit;
enet_uint32 fragmentOffset;
enet_uint16 fragmentLength;
enet_uint16 sendAttempts;
ENetProtocol command;
ENetPacket * packet;
} ENetOutgoingCommand;
typedef struct _ENetIncomingCommand
{
ENetListNode incomingCommandList;
enet_uint16 reliableSequenceNumber;
enet_uint16 unreliableSequenceNumber;
ENetProtocol command;
enet_uint32 fragmentCount;
enet_uint32 fragmentsRemaining;
enet_uint32 * fragments;
ENetPacket * packet;
} ENetIncomingCommand;
typedef enum _ENetPeerState
{
enet_PEER_STATE_DISCONNECTED = 0,
enet_PEER_STATE_CONNECTING = 1,
enet_PEER_STATE_ACKNOWLEDGING_CONNECT = 2,
enet_PEER_STATE_CONNECTION_PENDING = 3,
enet_PEER_STATE_CONNECTION_SUCCEEDED = 4,
enet_PEER_STATE_CONNECTED = 5,
enet_PEER_STATE_DISCONNECT_LATER = 6,
enet_PEER_STATE_DISCONNECTING = 7,
enet_PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8,
enet_PEER_STATE_ZOMBIE = 9
} ENetPeerState;
enum
{
enet_HOST_RECEIVE_BUFFER_SIZE = 256 * 1024,
enet_HOST_SEND_BUFFER_SIZE = 256 * 1024,
enet_HOST_BANDWIDTH_THROTTLE_INTERVAL = 1000,
enet_HOST_DEFAULT_MTU = 1400,
enet_PEER_DEFAULT_ROUND_TRIP_TIME = 500,
enet_PEER_DEFAULT_PACKET_THROTTLE = 32,
enet_PEER_PACKET_THROTTLE_SCALE = 32,
enet_PEER_PACKET_THROTTLE_COUNTER = 7,
enet_PEER_PACKET_THROTTLE_ACCELERATION = 2,
enet_PEER_PACKET_THROTTLE_DECELERATION = 2,
enet_PEER_PACKET_THROTTLE_INTERVAL = 5000,
enet_PEER_PACKET_LOSS_SCALE = (1 << 16),
enet_PEER_PACKET_LOSS_INTERVAL = 10000,
enet_PEER_WINDOW_SIZE_SCALE = 64 * 1024,
enet_PEER_TIMEOUT_LIMIT = 32,
enet_PEER_TIMEOUT_MINIMUM = 5000,
enet_PEER_TIMEOUT_MAXIMUM = 30000,
enet_PEER_PING_INTERVAL = 500,
enet_PEER_UNSEQUENCED_WINDOWS = 64,
enet_PEER_UNSEQUENCED_WINDOW_SIZE = 1024,
enet_PEER_FREE_UNSEQUENCED_WINDOWS = 32,
enet_PEER_RELIABLE_WINDOWS = 16,
enet_PEER_RELIABLE_WINDOW_SIZE = 0x1000,
enet_PEER_FREE_RELIABLE_WINDOWS = 8
};
typedef struct _ENetChannel
{
enet_uint16 outgoingReliableSequenceNumber;
enet_uint16 outgoingUnreliableSequenceNumber;
enet_uint16 usedReliableWindows;
enet_uint16 reliableWindows [enet_PEER_RELIABLE_WINDOWS];
enet_uint16 incomingReliableSequenceNumber;
enet_uint16 incomingUnreliableSequenceNumber;
ENetList incomingReliableCommands;
ENetList incomingUnreliableCommands;
} ENetChannel;
typedef struct _ENetPeer
{
ENetListNode dispatchList;
struct _ENetHost * host;
enet_uint16 outgoingPeerID;
enet_uint16 incomingPeerID;
enet_uint32 connectID;
enet_uint8 outgoingSessionID;
enet_uint8 incomingSessionID;
ENetAddress address;
void * data;
ENetPeerState state;
ENetChannel * channels;
size_t channelCount;
enet_uint32 incomingBandwidth;
enet_uint32 outgoingBandwidth;
enet_uint32 incomingBandwidthThrottleEpoch;
enet_uint32 outgoingBandwidthThrottleEpoch;
enet_uint32 incomingDataTotal;
enet_uint32 outgoingDataTotal;
enet_uint32 lastSendTime;
enet_uint32 lastReceiveTime;
enet_uint32 nextTimeout;
enet_uint32 earliestTimeout;
enet_uint32 packetLossEpoch;
enet_uint32 packetsSent;
enet_uint32 packetsLost;
enet_uint32 packetLoss;
enet_uint32 packetLossVariance;
enet_uint32 packetThrottle;
enet_uint32 packetThrottleLimit;
enet_uint32 packetThrottleCounter;
enet_uint32 packetThrottleEpoch;
enet_uint32 packetThrottleAcceleration;
enet_uint32 packetThrottleDeceleration;
enet_uint32 packetThrottleInterval;
enet_uint32 pingInterval;
enet_uint32 timeoutLimit;
enet_uint32 timeoutMinimum;
enet_uint32 timeoutMaximum;
enet_uint32 lastRoundTripTime;
enet_uint32 lowestRoundTripTime;
enet_uint32 lastRoundTripTimeVariance;
enet_uint32 highestRoundTripTimeVariance;
enet_uint32 roundTripTime;
enet_uint32 roundTripTimeVariance;
enet_uint32 mtu;
enet_uint32 windowSize;
enet_uint32 reliableDataInTransit;
enet_uint16 outgoingReliableSequenceNumber;
ENetList acknowledgements;
ENetList sentReliableCommands;
ENetList sentUnreliableCommands;
ENetList outgoingReliableCommands;
ENetList outgoingUnreliableCommands;
ENetList dispatchedCommands;
int needsDispatch;
enet_uint16 incomingUnsequencedGroup;
enet_uint16 outgoingUnsequencedGroup;
enet_uint32 unsequencedWindow [enet_PEER_UNSEQUENCED_WINDOW_SIZE / 32];
enet_uint32 eventData;
} ENetPeer;
typedef struct _ENetCompressor
{
void * context;
size_t (__attribute__((__cdecl__)) * compress) (void * context, const ENetBuffer * inBuffers, size_t inBufferCount, size_t inLimit, enet_uint8 * outData, size_t outLimit);
size_t (__attribute__((__cdecl__)) * decompress) (void * context, const enet_uint8 * inData, size_t inLimit, enet_uint8 * outData, size_t outLimit);
void (__attribute__((__cdecl__)) * destroy) (void * context);
} ENetCompressor;
typedef enet_uint32 (__attribute__((__cdecl__)) * ENetChecksumCallback) (const ENetBuffer * buffers, size_t bufferCount);
typedef struct _ENetHost
{
ENetSocket socket;
ENetAddress address;
enet_uint32 incomingBandwidth;
enet_uint32 outgoingBandwidth;
enet_uint32 bandwidthThrottleEpoch;
enet_uint32 mtu;
enet_uint32 randomSeed;
int recalculateBandwidthLimits;
ENetPeer * peers;
size_t peerCount;
size_t channelLimit;
enet_uint32 serviceTime;
ENetList dispatchQueue;
int continueSending;
size_t packetSize;
enet_uint16 headerFlags;
ENetProtocol commands [enet_PROTOCOL_MAXIMUM_PACKET_COMMANDS];
size_t commandCount;
ENetBuffer buffers [(1 + 2 * enet_PROTOCOL_MAXIMUM_PACKET_COMMANDS)];
size_t bufferCount;
ENetChecksumCallback checksum;
ENetCompressor compressor;
enet_uint8 packetData [2][enet_PROTOCOL_MAXIMUM_MTU];
ENetAddress receivedAddress;
enet_uint8 * receivedData;
size_t receivedDataLength;
enet_uint32 totalSentData;
enet_uint32 totalSentPackets;
enet_uint32 totalReceivedData;
enet_uint32 totalReceivedPackets;
} ENetHost;
typedef enum _ENetEventType
{
enet_EVENT_TYPE_NONE = 0,
enet_EVENT_TYPE_CONNECT = 1,
enet_EVENT_TYPE_DISCONNECT = 2,
enet_EVENT_TYPE_RECEIVE = 3
} ENetEventType;
typedef struct _ENetEvent
{
ENetEventType type;
ENetPeer * peer;
enet_uint8 channelID;
enet_uint32 data;
ENetPacket * packet;
} ENetEvent;
extern int enet_initialize (void);
extern int enet_initialize_with_callbacks (ENetVersion version, const ENetCallbacks * inits);
extern void enet_deinitialize (void);
extern enet_uint32 enet_time_get (void);
extern void enet_time_set (enet_uint32);
extern ENetSocket enet_socket_create (ENetSocketType);
extern int enet_socket_bind (ENetSocket, const ENetAddress *);
extern int enet_socket_listen (ENetSocket, int);
extern ENetSocket enet_socket_accept (ENetSocket, ENetAddress *);
extern int enet_socket_connect (ENetSocket, const ENetAddress *);
extern int enet_socket_send (ENetSocket, const ENetAddress *, const ENetBuffer *, size_t);
extern int enet_socket_receive (ENetSocket, ENetAddress *, ENetBuffer *, size_t);
extern int enet_socket_wait (ENetSocket, enet_uint32 *, enet_uint32);
extern int enet_socket_set_option (ENetSocket, ENetSocketOption, int);
extern void enet_socket_destroy (ENetSocket);
extern int enet_socketset_select (ENetSocket, ENetSocketSet *, ENetSocketSet *, enet_uint32);
extern int enet_address_set_host (ENetAddress * address, const char * hostName);
extern int enet_address_get_host_ip (const ENetAddress * address, char * hostName, size_t nameLength);
extern int enet_address_get_host (const ENetAddress * address, char * hostName, size_t nameLength);
extern ENetPacket * enet_packet_create (const void *, size_t, enet_uint32);
extern void enet_packet_destroy (ENetPacket *);
extern int enet_packet_resize (ENetPacket *, size_t);
extern enet_uint32 enet_crc32 (const ENetBuffer *, size_t);
extern ENetHost * enet_host_create (const ENetAddress *, size_t, size_t, enet_uint32, enet_uint32);
extern void enet_host_destroy (ENetHost *);
extern ENetPeer * enet_host_connect (ENetHost *, const ENetAddress *, size_t, enet_uint32);
extern int enet_host_check_events (ENetHost *, ENetEvent *);
extern int enet_host_service (ENetHost *, ENetEvent *, enet_uint32);
extern void enet_host_flush (ENetHost *);
extern void enet_host_broadcast (ENetHost *, enet_uint8, ENetPacket *);
extern void enet_host_compress (ENetHost *, const ENetCompressor *);
extern int enet_host_compress_with_range_coder (ENetHost * host);
extern void enet_host_channel_limit (ENetHost *, size_t);
extern void enet_host_bandwidth_limit (ENetHost *, enet_uint32, enet_uint32);
extern void enet_host_bandwidth_throttle (ENetHost *);
extern int enet_peer_send (ENetPeer *, enet_uint8, ENetPacket *);
extern ENetPacket * enet_peer_receive (ENetPeer *, enet_uint8 * channelID);
extern void enet_peer_ping (ENetPeer *);
extern void enet_peer_ping_interval (ENetPeer *, enet_uint32);
extern void enet_peer_timeout (ENetPeer *, enet_uint32, enet_uint32, enet_uint32);
extern void enet_peer_reset (ENetPeer *);
extern void enet_peer_disconnect (ENetPeer *, enet_uint32);
extern void enet_peer_disconnect_now (ENetPeer *, enet_uint32);
extern void enet_peer_disconnect_later (ENetPeer *, enet_uint32);
extern void enet_peer_throttle_configure (ENetPeer *, enet_uint32, enet_uint32, enet_uint32);
extern int enet_peer_throttle (ENetPeer *, enet_uint32);
extern void enet_peer_reset_queues (ENetPeer *);
extern void enet_peer_setup_outgoing_command (ENetPeer *, ENetOutgoingCommand *);
extern ENetOutgoingCommand * enet_peer_queue_outgoing_command (ENetPeer *, const ENetProtocol *, ENetPacket *, enet_uint32, enet_uint16);
extern ENetIncomingCommand * enet_peer_queue_incoming_command (ENetPeer *, const ENetProtocol *, ENetPacket *, enet_uint32);
extern ENetAcknowledgement * enet_peer_queue_acknowledgement (ENetPeer *, const ENetProtocol *, enet_uint16);
extern void enet_peer_dispatch_incoming_unreliable_commands (ENetPeer *, ENetChannel *);
extern void enet_peer_dispatch_incoming_reliable_commands (ENetPeer *, ENetChannel *);
extern void * enet_range_coder_create (void);
extern void enet_range_coder_destroy (void *);
extern size_t enet_range_coder_compress (void *, const ENetBuffer *, size_t, size_t, enet_uint8 *, size_t);
extern size_t enet_range_coder_decompress (void *, const enet_uint8 *, size_t, enet_uint8 *, size_t);
extern size_t enet_protocol_command_size (enet_uint8);]]

local module = ffi.load'enet'
local enet = setmetatable( {}, {__index = function(_, k) return module['enet_' .. k] end} )
return enet