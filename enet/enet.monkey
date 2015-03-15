Strict
Import brl.databuffer
Import brl.datastream
Import monkeyplatform


Class ENetBuffer Extends DataBuffer

	Field Data:Int[] = New Int[0]
	Field DataLength:int
	
	
	Method SetLength:Void(len:Int)
		Data = New Int[len]
	End
 
 	
 
	Method dataLength:Int()
 		DataLength = Data.Length()
 		Return DataLength
	End Method
 
	Method data:Int[]()
 		PeekBytes( 0, Data,0,Length() )
 		Return Data
	End Method

End


Class ENetSocket Abstract

    Method IsNull:Bool() abstract
    
End

Class ENetSocketTypeEnum

	Const ENET_SOCKET_TYPE_STREAM:Int = 1
	Const ENET_SOCKET_TYPE_DATAGRAM:Int = 2

End 


class ENetSocketOption

    Const  ENET_SOCKOPT_NONBLOCK:Int = 1
    Const  ENET_SOCKOPT_BROADCAST:Int = 2
    Const  ENET_SOCKOPT_RCVBUF:Int = 3
    Const  ENET_SOCKOPT_SNDBUF:Int = 4
    Const  ENET_SOCKOPT_REUSEADDR:Int = 5
    Const  ENET_SOCKOPT_RCVTIMEO:Int = 6
    Const  ENET_SOCKOPT_SNDTIMEO:Int = 7
    Const  ENET_SOCKOPT_ERROR:Int = 8
    Const  ENET_SOCKOPT_NODELAY:Int = 9
End

Class ENetSocketShutdown

    Const ENET_SOCKET_SHUTDOWN_READ:Int = 0
    Const ENET_SOCKET_SHUTDOWN_WRITE:Int = 1
    Const ENET_SOCKET_SHUTDOWN_READ_WRITE:Int = 2
End

Class ENetAddress

	Field host:Int
	Field port:Int
	Field host_:String
	
	Function Clone:ENetAddress(address:ENetAddress)
		
		Local other:ENetAddress = New ENetAddress()
		other.port = address.port
		other.host = address.host
		other.host_ = address.host_
		Return other
		
	End

End


Class ENetPacketFlagEnum

	Const ENET_PACKET_FLAG_RELIABLE:Int = 1 Shl 0
	Const ENET_PACKET_FLAG_UNSEQUENCED:Int = 1 Shl 1
	Const ENET_PACKET_FLAG_NO_ALLOCATE:Int = 1 Shl 2
	Const ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT:Int = 1 Shl 3
	Const ENET_PACKET_FLAG_SENT:Int = 1 Shl 8
	
End

Class ENetPacketFreeCallback

	Method Run:Void(packet:ENetPacket) Abstract

End

Class ENetPacket

	Field referenceCount:Int
	Field flags:Int
	Field data:Int[] = New Int[0]
	Field dataLength:Int
	Field freeCallback:ENetPacketFreeCallback
	Field userData:UserData

End

Class UserData Abstract

End

Class ENetObject
	Field ENext:ENetObject
	Field EPrev:ENetObject
End

Class ENetListNode Extends ENetObject


	Field Parent:ENetList
	
	
	Method Delete:Void()
		If EPrev <> Null Then
			If ENext <> Null Then
				
				ENext.EPrev = EPrev
			Endif
			EPrev.ENext = ENext
		Else
			If ENext <> Null Then
				ENext.EPrev = EPrev
			Endif			
		Endif
		If Parent <> Null Then
			If Parent.ENext = Self Then Parent.ENext = ENext
		Endif
	End

End

Class ENetList Extends ENetListNode

	
	Method New()
		SetSentinel(new ENetListNode())	
	End 
	
	Method GetSentinel:ENetObject()
		Return ENext
	End
	
	Method SetSentinel:Void(value:ENetObject)
		ENext = value
	End



End


Class ENetAcknowledgement Extends ENetListNode

	Field sentTime:Int
	Field command:ENetProtocol

	Method acknowledgementList:ENetListNode()
		Return ENetListNode(Self)
	End
	
End


Class ENetOutgoingCommand Extends ENetListNode

	Field reliableSequenceNumber:Int
	Field unreliableSequenceNumber:Int
	Field sentTime:Int
	Field roundTripTimeout:Int
	Field roundTripTimeoutLimit:Int
	Field fragmentOffset:Int
	Field fragmentLength:Int
	Field sendAttempts:Int
	Field command:ENetProtocol
	Field packet:ENetPacket

	
	Method outgoingCommandList:ENetListNode()
		Return ENetListNode(Self)
	End
	
End

Class ENetIncomingCommand Extends ENetListNode


	Field reliableSequenceNumber:Int
	Field unreliableSequenceNumber:Int
	Field sentTime:Int
	Field roundTripTimeout:Int
	Field roundTripTimeoutLimit:Int
	Field fragmentCount:Int
	Field fragmentsRemaining:int
	Field fragmentOffset:Int
	Field fragmentLength:Int
	Field sendAttempts:Int
	Field command:ENetProtocol
	Field packet:ENetPacket
	Field fragments:Int[] = New Int[0]
	
	Method incomingCommandList:ENetListNode()
		Return ENetListNode(Self)
	End

End


Class ENetPeerState

    Const  ENET_PEER_STATE_DISCONNECTED:Int = 0
    Const  ENET_PEER_STATE_CONNECTING:Int = 1
    Const  ENET_PEER_STATE_ACKNOWLEDGING_CONNECT:Int = 2
    Const  ENET_PEER_STATE_CONNECTION_PENDING:Int = 3
    Const  ENET_PEER_STATE_CONNECTION_SUCCEEDED:Int = 4
    Const  ENET_PEER_STATE_CONNECTED:Int = 5
    Const  ENET_PEER_STATE_DISCONNECT_LATER:Int = 6
    Const  ENET_PEER_STATE_DISCONNECTING:Int = 7
    Const  ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT:Int = 8
    Const  ENET_PEER_STATE_ZOMBIE:Int = 9
End



Class ENetChannel

	Field outgoingReliableSequenceNumber:Int
	Field outgoingUnreliableSequenceNumber:Int
	Field usedReliableWindows:Int
	Field reliableWindows:Int[]
	Field incomingReliableSequenceNumber:Int
	Field incomingUnreliableSequenceNumber:Int
	Field incomingReliableCommands:ENetList
	Field incomingUnreliableCommands:ENetList
	Const reliableWindowsLength:Int = ENet.ENET_PEER_RELIABLE_WINDOWS

	Method New()
		reliableWindows = New Int[ENet.ENET_PEER_RELIABLE_WINDOWS]
        incomingReliableCommands = new ENetList()
        incomingUnreliableCommands = new ENetList()		
	End


End

Class ENetPeer Extends ENetList

	Field host:ENetHost
	Field outgoingPeerID:Int
	Field incomingPeerID:Int
	Field connectID:Int
	Field outgoingSessionID:Int
	Field incomingSessionID:Int
	Field address:ENetAddress
	Field data:Int[] = New Int[0]
	Field state:Int
	Field channels:ENetChannel[]
	Field channelCount:Int
	Field incomingBandwidth:Int
	Field outgoingBandwidth:Int
	Field incomingBandwidthThrottleEpoch:Int
	Field outgoingBandwidthThrottleEpoch:Int
	Field incomingDataTotal:Int
	Field outgoingDataTotal:Int
	Field lastSendTime:Int
	Field lastReceiveTime:Int
	Field nextTimeout:Int
	Field earliestTimeout:Int
	Field packetLossEpoch:Int
	Field packetsSent:Int
	Field packetsLost:Int
	Field packetLoss:Int
	Field packetLossVariance:Int
	Field packetThrottle:Int
	Field packetThrottleLimit:Int
	Field packetThrottleCounter:Int
	Field packetThrottleEpoch:Int
	Field packetThrottleAcceleration:Int
	Field packetThrottleDeceleration:Int
	Field packetThrottleInterval:Int
	Field pingInterval:Int
	Field timeoutLimit:Int
	Field timeoutMinimum:Int
	Field timeoutMaximum:Int
	Field lastRoundTripTime:Int
	Field lowestRoundTripTime:Int
	Field lastRoundTripTimeVariance:Int
	Field highestRoundTripTimeVariance:Int
	Field roundTripTime:Int
	Field roundTripTimeVariance:Int
	Field mtu:Int
	Field windowSize:Int
	Field reliableDataInTransit:Int
	Field outgoingReliableSequenceNumber:Int
	Field acknowledgements:ENetList
	Field sentReliableCommands:ENetList
	Field sentUnreliableCommands:ENetList
	Field outgoingReliableCommands:ENetList
	Field outgoingUnreliableCommands:ENetList
	Field dispatchedCommands:ENetList
	Field needsDispatch:Int
	Field incomingUnsequencedGroup:Int
	Field outgoingUnsequencedGroup:Int
	Field unsequencedWindow:Int[]
	Const unsequencedWindowLength:Int = ENet.ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32
	Field eventData:int
	
	Method New()
        acknowledgements = new ENetList()
        sentReliableCommands = new ENetList()
        sentUnreliableCommands = new ENetList()
        outgoingReliableCommands = new ENetList()
        outgoingUnreliableCommands = new ENetList()
        dispatchedCommands = new ENetList()
        unsequencedWindow = new int[ENet.ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32]
	End
	
	Method dispatchList:ENetListNode()
		Return ENetListNode(Self)
	End

End

Class ENetCompressorContext Abstract

End

Class ENetCompressor Abstract

	Method compress:Int(inBuffers:ENetBuffer,inBufferCount:Int,inLimit:Int,outData:Int[],outLimit:Int) Abstract
	Method decompress:Int(inData:Int[],inLimit:Int,outData:Int[],outLimit:Int) Abstract
	Method destroy:Void() Abstract
	
End

Class ENetChecksumCallback Abstract

	Method Run:Int(buffers:ENetBuffer,bufferCount:Int) Abstract

End

Class ENetInterceptCallback Abstract

	Method Run:Int(host:ENetHost, event_:ENetEvent) Abstract

End

Class ENetHost

	Field socket:ENetSocket
	Field address:ENetAddress
	Field incomingBandwidth:Int
	Field outgoingBandwidth:Int
	Field bandwidthThrottleEpoch:Int
	Field mtu:Int
	Field randomSeed:Int
	Field recalculateBandwidthLimits:Int
	Field peers:ENetPeer[]
	Field peerCount:Int
	Field channelLimit:Int
	Field serviceTime:Int
	Field dispatchQueue:ENetList
	Field continueSending:Int
	Field packetSize:Int
	Field headerFlags:Int
	Field commands:ENetProtocol[]
	Const commandsMaxCount:Int = ENet.ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS
	Field commandCount:Int
	Field buffers:ENetBuffer[]
	Const buffersMaxCount:Int = ENet.ENET_BUFFER_MAXIMUM
	Field bufferCount:Int
	Field checksum:ENetChecksumCallback
	Field compressor:ENetCompressor
	Field packetData:Int[][]
	Const packetData0SizeOf:Int = ENet.ENET_PROTOCOL_MAXIMUM_MTU
	Field receivedAddress:ENetAddress
	Field receivedData:Int[]
	Field receivedDataLength:Int
	Field totalSentData:Int
	Field totalSentPackets:Int
	Field totalReceivedData:Int
	Field totalReceivedPackets:Int
	Field intercept:ENetInterceptCallback
	Field connectedPeers:Int
	Field bandwidthLimitedPeers:Int
	
	Method New()
        address = new ENetAddress()
        commands = new ENetProtocol[commandsMaxCount]
        For Local i:Int = 0 To commandsMaxCount-1
        
            commands[i] = New ENetProtocol()
        Next
        buffers = new ENetBuffer[buffersMaxCount]
        For Local i:Int = 0 To buffersMaxCount-1
        
            buffers[i] = New ENetBuffer()
        Next
        For Local i:Int = 0 To buffersMaxCount-1
        
            buffers[i] = New ENetBuffer()
        Next
        dispatchQueue = new ENetPeer()
        packetData = New Int[2][]
        packetData[0] = New Int[ENet.ENET_PROTOCOL_MAXIMUM_MTU]
        packetData[1] = New Int[ENet.ENET_PROTOCOL_MAXIMUM_MTU]	
	End

End

Class ENetEventType

	Const ENET_EVENT_TYPE_NONE:Int = 0
	Const ENET_EVENT_TYPE_CONNECT:Int = 1
	Const ENET_EVENT_TYPE_DISCONNECT:Int = 2
	Const ENET_EVENT_TYPE_RECEIVE:Int = 3

End

Class ENetEvent
	Field type:Int 'ENetEventType
	Field peer:ENetPeer
	Field channelID:Int
	Field data:Int
	Field packet:ENetPacket
End

Class ENet
	Field p:ENetPlatform
	Const ENET_VERSION_MAJOR:Int = 1
	Const ENET_VERSION_MINOR:Int = 3
	Const ENET_VERSION_PATCH:Int = 8
	Const ENET_HOST_ANY:Int = 0
	Const ENET_HOST_BROADCAST:Int = -1
	Const ENET_PORT_ANY:Int = 0
	Const ENET_BUFFER_MAXIMUM:Int = (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
	Const ENET_HOST_RECEIVE_BUFFER_SIZE:Int = 256 * 1024
	Const ENET_HOST_SEND_BUFFER_SIZE:Int = 256 * 1024
	Const ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL:Int = 1000
	Const ENET_HOST_DEFAULT_MTU:Int = 1400
    Const ENET_PEER_DEFAULT_ROUND_TRIP_TIME:Int = 500
    Const ENET_PEER_DEFAULT_PACKET_THROTTLE:Int = 32
    Const ENET_PEER_PACKET_THROTTLE_SCALE:Int = 32
    Const ENET_PEER_PACKET_THROTTLE_COUNTER:Int = 7
    Const ENET_PEER_PACKET_THROTTLE_ACCELERATION:Int = 2
    Const ENET_PEER_PACKET_THROTTLE_DECELERATION:Int = 2
    Const ENET_PEER_PACKET_THROTTLE_INTERVAL:Int = 5000
    Const ENET_PEER_PACKET_LOSS_SCALE:Int = (1 Shl 16)
    Const ENET_PEER_PACKET_LOSS_INTERVAL:Int = 10000
    Const ENET_PEER_WINDOW_SIZE_SCALE:Int = 64 * 1024
    Const ENET_PEER_TIMEOUT_LIMIT:Int = 32
    Const ENET_PEER_TIMEOUT_MINIMUM:Int = 5000
    Const ENET_PEER_TIMEOUT_MAXIMUM:Int = 30000
    Const ENET_PEER_PING_INTERVAL:Int = 500
    Const ENET_PEER_UNSEQUENCED_WINDOWS:Int = 64
    Const ENET_PEER_UNSEQUENCED_WINDOW_SIZE:Int = 1024
    Const ENET_PEER_FREE_UNSEQUENCED_WINDOWS:Int = 32
    Const ENET_PEER_RELIABLE_WINDOWS:Int = 16
    Const ENET_PEER_RELIABLE_WINDOW_SIZE:Int = $1000
    Const ENET_PEER_FREE_RELIABLE_WINDOWS:Int = 8	


    Const ENET_PROTOCOL_MINIMUM_MTU:Int = 576
    Const ENET_PROTOCOL_MAXIMUM_MTU:Int = 4096
    Const ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS:Int = 32
    Const ENET_PROTOCOL_MINIMUM_WINDOW_SIZE:Int = 4096
    Const ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE:Int = 32768
    Const ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT:Int = 1
    Const ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT:Int = 255
    Const ENET_PROTOCOL_MAXIMUM_PEER_ID:Int = $FFF
    Const ENET_PROTOCOL_MAXIMUM_PACKET_SIZE:Int = 1024 * 1024 * 1024
    Const ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT:Int = 1024 * 1024



    Const ENET_PROTOCOL_COMMAND_NONE:Int = 0
    Const ENET_PROTOCOL_COMMAND_ACKNOWLEDGE:Int = 1
    Const ENET_PROTOCOL_COMMAND_CONNECT:Int = 2
    Const ENET_PROTOCOL_COMMAND_VERIFY_CONNECT:Int = 3
    Const ENET_PROTOCOL_COMMAND_DISCONNECT:Int = 4
    Const ENET_PROTOCOL_COMMAND_PING:Int = 5
    Const ENET_PROTOCOL_COMMAND_SEND_RELIABLE:Int = 6
    Const ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE:Int = 7
    Const ENET_PROTOCOL_COMMAND_SEND_FRAGMENT:Int = 8
    Const ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED:Int = 9
    Const ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT:Int = 10
    Const ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE:Int = 11
    Const ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT:Int = 12
    Const ENET_PROTOCOL_COMMAND_COUNT:Int = 13
    Const ENET_PROTOCOL_COMMAND_MASK:Int = 15




    Const ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE:Int = (1 Shl 7)
    Const ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED:Int = (1 Shl 6)

    Const ENET_PROTOCOL_HEADER_FLAG_COMPRESSED:Int = (1 Shl 14)
    Const ENET_PROTOCOL_HEADER_FLAG_SENT_TIME:Int = (1 Shl 15)
    Const ENET_PROTOCOL_HEADER_FLAG_MASK:Int = ENET_PROTOCOL_HEADER_FLAG_COMPRESSED | ENET_PROTOCOL_HEADER_FLAG_SENT_TIME

    Const ENET_PROTOCOL_HEADER_SESSION_MASK:Int = (3 Shl 12)
    Const ENET_PROTOCOL_HEADER_SESSION_SHIFT:Int = 12


    Const ENET_SOCKET_WAIT_NONE:Int = 0
    Const ENET_SOCKET_WAIT_SEND:Int = (1 Shl 0)
    Const ENET_SOCKET_WAIT_RECEIVE:Int = (1 Shl 1)
    Const ENET_SOCKET_WAIT_INTERRUPT:Int = (1 Shl 2)
	Const SOCKET_ERROR:Int = -1
	Const ENET_TIME_OVERFLOW:Int = 86400000
	
	Field initializedCRC32:Bool
	Field crcTable:Int[]
	Field dummyCommand:ENetIncomingCommand
	Field commandSizes:Int[]
	Field test1:Int
	 
	Function ENET_VERSION_CREATE:Int(major:Int,minor:Int,patch:Int)
	
		return ((major) shl 16) | ((minor) shl 8) | (patch)
	
	End
	
	Function ENET_VERSION_GET_MAJOR:Int(version:Int)
		Return ((version) Shr 16) & $FF
	End
	
	Function ENET_VERSION_GET_MINOR:Int(version:Int)
		Return ((version) Shr 8) & $FF
	End
	
	Function ENET_VERSION_GET_PATCH:Int(version:Int)
		Return (version) & $FF
	End
	
	Function ENET_VERSION:Int()
		 return ENET_VERSION_CREATE(ENET_VERSION_MAJOR, ENET_VERSION_MINOR, ENET_VERSION_PATCH)
	End

	Method New()
        dummyCommand = new ENetIncomingCommand()
        commandSizes = new int[13]
        commandSizes[0] = 0
        commandSizes[1] = 8
        commandSizes[2] = 48
        commandSizes[3] = 44
        commandSizes[4] = 8
        commandSizes[5] = 4
        commandSizes[6] = 6
        commandSizes[7] = 8
        commandSizes[8] = 24
        commandSizes[9] = 8
        commandSizes[10] = 12
        commandSizes[11] = 16
        commandSizes[12] = 24	
	End
	
	Method SetPlatform:Void(value:ENetPlatform)
		p = value
	End
	
	Method enet_address_set_host:Int(address:ENetAddress, hostName:String)
		return p.enet_address_set_host(address, hostName)
	End
	
	Method enet_packet_create:ENetPacket(data:Int[],dataLength:Int,flags:Int)
		Local packet:ENetPacket = New ENetPacket()
		If packet = Null Then Return Null
		If flags & ENetPacketFlagEnum.ENET_PACKET_FLAG_NO_ALLOCATE <> 0 Then
			packet.data = data
		Else
			If dataLength <= 0 Then
				packet.data = New Int[0]
			Else
				packet.data = New Int[dataLength]
				If packet.data.Length() = 0 Then
					packet = Null 
					Return Null
				Endif
				If data.Length() <> 0 Then
					For Local i:Int = 0 To dataLength-1
						packet.data[i] = data[i]
					Next
				Endif
			Endif
		Endif
        packet.referenceCount = 0
        packet.flags = flags
        packet.dataLength = dataLength
        packet.freeCallback = null
        packet.userData = null

        return packet		
	End Method
	
	Method enet_packet_destroy:Void(packet:ENetPacket)
		If packet = Null Then Return
		If packet.freeCallback <> Null Then
			packet.freeCallback.Run(packet)
		Endif
		If packet.flags & ENetPacketFlagEnum.ENET_PACKET_FLAG_NO_ALLOCATE = 0 And packet.data.Length() <> 0 Then
			packet.data = New Int[0]
		Endif
		packet = Null
		
	End
	
	Method enet_packet_resize:Int(packet:ENetPacket,dataLength:Int)
		
		Local newData:Int[]
		
		If dataLength <= packet.dataLength Or packet.flags & ENetPacketFlagEnum.ENET_PACKET_FLAG_NO_ALLOCATE <> 0 Then
			packet.dataLength = dataLength
			Return 0
		Endif
		
		newData = packet.data.Resize(dataLength)
		If newData = Null Then
			Return -1
		Endif
		packet.data = newData
		packet.dataLength = dataLength
		Return 0
		
	End
	
	Function reflect_crc:Int(val:Int,bits:Int)
		Local result:Int = 0
		Local bit:Int
		
        For bit = 0 To bits-1
        
            If val & 1 <> 0 Then
            	result  = result | 1 Shl (bits - 1 - bit)
            Endif
            val = val shr 1
        Next

        return result			
	End
	
	Method initialize_crc32:Void()
	
		crcTable = New Int[256]
		Local byte_:Int
		
		Local c:Int = -2147483647
		c = c - 1
		For byte_ = 0 To 255
		
			Local crc:Int = reflect_crc(byte_, 8) Shl 24
			Local offset:Int
			
			For offset = 0 To 7
			
				If crc & c <> 0 Then
					crc = (crc Shl 1) ~ $04c11db7
				Else
					crc = crc Shl 1	
				Endif
			
			Next
			crcTable[byte_] = reflect_crc(crc, 32)
		
		Next
		initializedCRC32 = true
	End
	
	Method enet_crc32:Int(buffers:ENetBuffer[],bufferCount:Int)
		
		Local crc:Int = -1
		
		If Not initializedCRC32 Then initialize_crc32()
		For Local buf:Int = 0 To bufferCount-1
		
			Local data:Int = buffers[buf].data()
			Local dataLength:Int = buffers[buf].dataLength()
		
			For Local i:Int = 0 To dataLength-1
			
				crc = (crc Shr 8) ~ crcTable[(crc & $FF) ~ data[i]]
			
			Next
		
		Next
		
		return p.ENET_HOST_TO_NET_32(~crc)
	
	End
	
	Method enet_host_create:ENetHost(address:ENetAddress,peerCount:Int,channelLimit:Int,incomingBandwidth:Int,outgoingBandwidth:Int)
	
		Local host:ENetHost
		Local currentPeer:ENetPeer
		
		If peerCount > ENET_PROTOCOL_MAXIMUM_PEER_ID Return Null
		
		host = New ENetHost()
		If host = Null Then Return Null
		
		host.peers = New ENetPeer[peerCount]
		If host.peers.Length() = 0 Then 
			host = Null
			Return Null
		Endif
		
		For Local i:Int = 0 To peerCount-1
		
			host.peers[i] = New ENetPeer()
			
		Next
		
		host.socket = p.enet_socket_create(ENetSocketTypeEnum.ENET_SOCKET_TYPE_DATAGRAM)
		If (host.socket <> Null And host.socket.IsNull()) Or (address <> Null And p.enet_socket_bind(host.socket, address) < 0) Then
			If host.socket <> Null And (Not host.socket.IsNull()) Then
				p.enet_socket_destroy(host.socket)
			Endif
			Return null
		Endif
			
        p.enet_socket_set_option(host.socket, ENetSocketOption.ENET_SOCKOPT_NONBLOCK, 1)
        p.enet_socket_set_option(host.socket, ENetSocketOption.ENET_SOCKOPT_BROADCAST, 1)
        p.enet_socket_set_option(host.socket, ENetSocketOption.ENET_SOCKOPT_RCVBUF, ENET_HOST_RECEIVE_BUFFER_SIZE)
        p.enet_socket_set_option(host.socket, ENetSocketOption.ENET_SOCKOPT_SNDBUF, ENET_HOST_SEND_BUFFER_SIZE)		
        
        If address <> Null And p.enet_socket_get_address(host.socket, host.address) < 0 Then
        	host.address = address
        Endif
        
         If channelLimit = 0 Or channelLimit > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT Then
         	channelLimit = ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
         Else
         	If channelLimit < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT Then
         		channelLimit = ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT
         	Endif
         Endif
         
        host.randomSeed = Millisecs()


		host.randomSeed = (host.randomSeed Shl 16) | (host.randomSeed Shr 16)
		host.channelLimit = channelLimit
		host.incomingBandwidth = incomingBandwidth
		host.outgoingBandwidth = outgoingBandwidth
		host.bandwidthThrottleEpoch = 0
		host.recalculateBandwidthLimits = 0
		host.mtu = ENET_HOST_DEFAULT_MTU
		host.peerCount = peerCount
		host.commandCount = 0
		host.bufferCount = 0
		host.checksum = Null
		host.receivedAddress = New ENetAddress()
		host.receivedAddress.host = ENET_HOST_ANY
		host.receivedAddress.port = 0
		host.receivedData = New Int[0]
		host.receivedDataLength = 0
		
		host.totalSentData = 0
		host.totalSentPackets = 0
		host.totalReceivedData = 0
		host.totalReceivedPackets = 0
		
		host.connectedPeers = 0
		host.bandwidthLimitedPeers = 0
		
		host.compressor = Null
		
		host.intercept = Null
		host.dispatchQueue = New ENetPeer()
		host.dispatchQueue.SetSentinel(New ENetPeer())
		enet_list_clear(host.dispatchQueue)         
	
		For Local i:Int = 0 To host.peerCount-1
			currentPeer = host.peers[i]
			currentPeer.host = host
			currentPeer.incomingPeerID = p.IntToUshort(i)
			currentPeer.outgoingSessionID = currentPeer.incomingSessionID = $FF
			currentPeer.data = New Int[0]
			
			enet_list_clear(currentPeer.acknowledgements)
			enet_list_clear(currentPeer.sentReliableCommands)
			enet_list_clear(currentPeer.sentUnreliableCommands)
			enet_list_clear(currentPeer.outgoingReliableCommands)
			enet_list_clear(currentPeer.outgoingUnreliableCommands)
			enet_list_clear(currentPeer.dispatchedCommands)
			
			enet_peer_reset(currentPeer)			
		Next
		
		Return host
	End
	
	Method enet_host_destroy:Void(host:ENetHost)
	
		Local currentPeer:ENetPeer
		
		If host = Null Then Return
		
		p.enet_socket_destroy(host.socket)
		For Local i:Int = 0 To host.peerCount-1
		
            currentPeer = host.peers[i]
            enet_peer_reset(currentPeer)			
			
		Next
		
		If host.compressor <> Null Then
			host.compressor.destroy()
		Endif
		
		host.peers = Null
		host = Null
	
	End
	
	Method enet_host_connect:ENetPeer(host:ENetHost,address:ENetAddress,channelCount:Int,data:Int)
	
		Local currentPeer:ENetPeer
		Local channel:ENetChannel
		Local command:ENetProtocol = New ENetProtocol()
		
		If channelCount < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT Then
			channelCount = ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT
		Else
			If channelCount > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT Then
				channelCount = ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
			Endif
		Endif
	
		For Local i:Int = 0 To host.peerCount-1
			currentPeer = host.peers[i]
			If currentPeer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Then
				Exit
			Endif
		Next
		If host.peerCount = 0 Then
			Return Null
		Endif
		currentPeer.channels = New ENetChannel[channelCount]
		
		For Local i:Int = 0 To channelCount-1
		
			currentPeer.channels[i] = new ENetChannel()
		
		Next
		
		If currentPeer.channels.Length() = 0 Then
			Return Null
		Endif
        currentPeer.channelCount = channelCount
        currentPeer.state = ENetPeerState.ENET_PEER_STATE_CONNECTING
        currentPeer.address = ENetAddress.Clone(address)
        currentPeer.connectID = currentPeer.connectID+host.randomSeed
        
        If host.outgoingBandwidth = 0 Then
        
        	currentPeer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
        Else
        	currentPeer.windowSize = (host.outgoingBandwidth / ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
        
        Endif
        
        If currentPeer.windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE Then
        
        	currentPeer.windowSize = ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
        Else
        	If currentPeer.windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE Then
        		currentPeer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
        	Endif
        
        Endif
        
        For Local i:Int = 0 To channelCount-1
        
            channel = currentPeer.channels[i]

            channel.outgoingReliableSequenceNumber = 0
            channel.outgoingUnreliableSequenceNumber = 0
            channel.incomingReliableSequenceNumber = 0
            channel.incomingUnreliableSequenceNumber = 0

            enet_list_clear(channel.incomingReliableCommands)
            enet_list_clear(channel.incomingUnreliableCommands)

            channel.usedReliableWindows = 0
            
            For Local k:Int = 0 To ENET_PEER_RELIABLE_WINDOWS-1
            
            	channel.reliableWindows[k] = 0
            
            Next
		Next   
        command.header = new ENetProtocolCommandHeader()
        command.header.command = ENET_PROTOCOL_COMMAND_CONNECT | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
        command.header.channelID = $FF
        command.connect = new ENetProtocolConnect()
        command.connect.outgoingPeerID = p.ENET_HOST_TO_NET_16(currentPeer.incomingPeerID)
        command.connect.incomingSessionID = currentPeer.incomingSessionID
        command.connect.outgoingSessionID = currentPeer.outgoingSessionID
        command.connect.mtu = p.ENET_HOST_TO_NET_32(currentPeer.mtu)
        command.connect.windowSize = p.ENET_HOST_TO_NET_32(currentPeer.windowSize)
        command.connect.channelCount = p.ENET_HOST_TO_NET_32(channelCount)
        command.connect.incomingBandwidth = p.ENET_HOST_TO_NET_32(host.incomingBandwidth)
        command.connect.outgoingBandwidth = p.ENET_HOST_TO_NET_32(host.outgoingBandwidth)
        command.connect.packetThrottleInterval = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleInterval)
        command.connect.packetThrottleAcceleration = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleAcceleration)
        command.connect.packetThrottleDeceleration = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleDeceleration)
        command.connect.connectID = currentPeer.connectID
        command.connect.data = p.ENET_HOST_TO_NET_32(data)

        enet_peer_queue_outgoing_command(currentPeer, command, null, 0, 0)                 	
        
        return currentPeer
        
        
	
	End
	
	
	Method enet_host_broadcast:Void(host:ENetHost,channelID:Int,packet:ENetPacket)
	
		Local currentPeer:ENetPeer
		
		For Local i:Int = 0 To host.peerCount-1
		
			currentPeer = host.peers[i]
			If currentPeer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED Then
				Continue
			Endif
			enet_peer_send(currentPeer, channelID, packet)		
		Next
	
		If packet.referenceCount = 0 Then
			enet_packet_destroy(packet)
		Endif	
	
	End
	
	Method enet_host_compress:Void(host:ENetHost,compressor:ENetCompressor)
	
		If host.compressor <> Null Then
			host.compressor.destroy()
		Endif
		
		If compressor <> Null Then
			host.compressor = compressor
		Else
			host.compressor = null
		Endif
	
	End
	
	Method enet_host_channel_limit:Void(host:ENetHost,channelLimit:Int)
	
		If (channelLimit = 0) Or channelLimit > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT Then
		
			channelLimit = ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
		Else
			If channelLimit < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT Then
				channelLimit = ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT
			Endif
			
		Endif
		host.channelLimit = channelLimit
	
	End
	
	Method enet_host_bandwidth_limit:Void(host:ENetHost,incomingBandwidth:Int,outgoingBandwidth:Int)
	
        host.incomingBandwidth = incomingBandwidth
        host.outgoingBandwidth = outgoingBandwidth
        host.recalculateBandwidthLimits = 1
	
	End

	Method enet_host_bandwidth_throttle:Void(host:ENetHost)
	
	
        Local timeCurrent:Int = p.enet_time_get()
        Local elapsedTime:Int = timeCurrent - host.bandwidthThrottleEpoch
        Local peersRemaining:Int = host.connectedPeers
        Local dataTotal:Int = ~0
        Local bandwidth:Int = ~0
        Local throttle:Int = 0
        Local bandwidthLimit:Int = 0
        Local needsAdjustment:Int
        Local peer:ENetPeer;
        Local command:ENetProtocol = New ENetProtocol()	
	
		If host.bandwidthLimitedPeers > 0 Then
			needsAdjustment = 1
		Else
			needsAdjustment = 0
		Endif
		
		If elapsedTime < ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL Then Return
		
		host.bandwidthThrottleEpoch = timeCurrent
		If peersRemaining = 0 Then Return
		
		If host.outgoingBandwidth <> 0 Then
		
            dataTotal = 0
            bandwidth = (host.outgoingBandwidth * elapsedTime) / 1000			
			For Local i:Int = 0 To host.peerCount-1
			
				peer = host.peers[i]
				If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
				
					Continue
				
				Endif
				dataTotal = dataTotal+peer.outgoingDataTotal
			
			Next
			
		Endif
		
		While peersRemaining > 0 And needsAdjustment <> 0
		
			needsAdjustment = 0
			
			If dataTotal <= bandwidth Then
			
				throttle = ENET_PEER_PACKET_THROTTLE_SCALE
				
			Else
			
				throttle = (bandwidth * ENET_PEER_PACKET_THROTTLE_SCALE) / dataTotal
			
			Endif
			
			For Local i:Int = 0 To host.peerCount-1
			
				peer = host.peers[i]
				Local peerBandwidth:Int
				
				If (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Or peer.incomingBandwidth = 0 Or peer.outgoingBandwidthThrottleEpoch = timeCurrent Then
					Continue
				Endif
				peerBandwidth = (peer.incomingBandwidth * elapsedTime) / 1000
				
				If (throttle * peer.outgoingDataTotal) / ENET_PEER_PACKET_THROTTLE_SCALE <= peerBandwidth Then
					continue
				Endif
				peer.packetThrottleLimit = (peerBandwidth * ENET_PEER_PACKET_THROTTLE_SCALE) / peer.outgoingDataTotal
				If peer.packetThrottleLimit = 0 Then peer.packetThrottleLimit = 1
				If peer.packetThrottle > peer.packetThrottleLimit Then peer.packetThrottle = peer.packetThrottleLimit
                peer.outgoingBandwidthThrottleEpoch = timeCurrent

                peer.incomingDataTotal = 0
                peer.outgoingDataTotal = 0

                needsAdjustment = 1
                peersRemaining=peersRemaining-1
                bandwidth = bandwidth-peerBandwidth
                dataTotal = dataTotal-peerBandwidth				
			Next
		
		Wend
		
		If peersRemaining > 0 Then
		
			If dataTotal <= bandwidth Then
			
				throttle = ENET_PEER_PACKET_THROTTLE_SCALE
			
			Else
			
				throttle = (bandwidth * ENET_PEER_PACKET_THROTTLE_SCALE) / dataTotal
			
			Endif
			
			For Local i:Int = 0 To host.peerCount-1
			
				peer = host.peers[i]
				If (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Or peer.outgoingBandwidthThrottleEpoch = timeCurrent Then
				
					Continue
				
				Endif
				
				peer.packetThrottleLimit = throttle
				If peer.packetThrottle > peer.packetThrottleLimit Then peer.packetThrottle = peer.packetThrottleLimit
				
				
                peer.incomingDataTotal = 0
                peer.outgoingDataTotal = 0		
			Next
		
		Endif
		
		If host.recalculateBandwidthLimits <> 0 Then
		
			host.recalculateBandwidthLimits = 0
            peersRemaining = host.connectedPeers
            bandwidth = host.incomingBandwidth
            needsAdjustment = 1
            
            If bandwidth = 0 Then
            
            	bandwidthLimit = 0
            Else
            	While peersRemaining > 0 And needsAdjustment <> 0
            	
            	
                    needsAdjustment = 0
                    bandwidthLimit = bandwidth / peersRemaining            		
            	
            		For Local i:Int = 0 To host.peerCount-1
            		
            			peer = host.peers[i]
            			If (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Or peer.incomingBandwidthThrottleEpoch = timeCurrent Then
            			
            				Continue
            			
            			Endif
            			
            			If peer.outgoingBandwidth > 0 And peer.outgoingBandwidth >= bandwidthLimit Then Continue

                        peer.incomingBandwidthThrottleEpoch = timeCurrent

                        needsAdjustment = 1
                        peersRemaining=peersRemaining-1
                        bandwidth = bandwidth-peer.outgoingBandwidth
            		
            		Next
            	
            	Wend
            	
            Endif			
			For Local i:Int = 0 To host.peerCount-1
			
			
				peer = host.peers[i]
				If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then Continue
                command.header.command = ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
                command.header.channelID = $FF
                command.bandwidthLimit = new ENetProtocolBandwidthLimit()
                command.bandwidthLimit.outgoingBandwidth = p.ENET_HOST_TO_NET_32(host.outgoingBandwidth)
                
                If peer.incomingBandwidthThrottleEpoch = timeCurrent Then
                
                	command.bandwidthLimit.incomingBandwidth = p.ENET_HOST_TO_NET_32(peer.outgoingBandwidth)
                
                Else
                
                	command.bandwidthLimit.incomingBandwidth = p.ENET_HOST_TO_NET_32(bandwidthLimit)
                
                Endif
                enet_peer_queue_outgoing_command(peer, command, null, 0, 0)			
			Next
		Endif
	
	End
	




	
	Method enet_peer_throttle_configure:Void(peer:ENetPeer,interval:Int,acceleration:Int,deceleration:Int)
	
		Local command:ENetProtocol = New ENetProtocol()
		peer.packetThrottleInterval = interval
		peer.packetThrottleAcceleration = acceleration
		peer.packetThrottleDeceleration = deceleration
		command.header.command = ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
		command.header.channelID = $FF
		command.throttleConfigure.packetThrottleInterval = p.ENET_HOST_TO_NET_32(interval)
		command.throttleConfigure.packetThrottleAcceleration = p.ENET_HOST_TO_NET_32(acceleration)
		command.throttleConfigure.packetThrottleDeceleration = p.ENET_HOST_TO_NET_32(deceleration)
		enet_peer_queue_outgoing_command(peer, command, null, 0, 0)
	
	End
	
	Method enet_peer_throttle:Int(peer:ENetPeer,rtt:Int)
	
		If peer.lastRoundTripTime <= peer.lastRoundTripTimeVariance Then
		
			peer.packetThrottle = peer.packetThrottleLimit
		
		Else
		
			If rtt < peer.lastRoundTripTime Then
			
				peer.packetThrottle = peer.packetThrottle+peer.packetThrottleAcceleration
				
				If peer.packetThrottle > peer.packetThrottleLimit Then peer.packetThrottle = peer.packetThrottleLimit
				
				Return 1
			
			Else
			
				If rtt > peer.lastRoundTripTime + 2 * peer.lastRoundTripTimeVariance Then
				
					If peer.packetThrottle > peer.packetThrottleDeceleration Then
					
						peer.packetThrottle = peer.packetThrottle-peer.packetThrottleDeceleration
					
					Else
						peer.packetThrottle = 0
					Endif
					
					Return -1
					
				Endif
				
			
			Endif
		
		Endif
		
		Return 0
	
	End
	
	
	Method enet_peer_send:Int(peer:ENetPeer,channelID:Int,packet:ENetPacket)
	
		Local channel:ENetChannel = peer.channels[channelID]
		Local command:ENetProtocol = New ENetProtocol()
		Local fragmentLength:Int
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED Or channelID >= peer.channelCount Or packet.dataLength() > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Then
			Return -1
		Endif
		
		fragmentLength = peer.mtu - ENetProtocolHeader.SizeOf - ENetProtocolSendFragment.SizeOf
		
		If peer.host.checksum <> Null Then
			fragmentLength = fragmentLength - 4
		Endif
	
		If packet.dataLength > fragmentLength Then
			Local fragmentCount:int = (packet.dataLength + fragmentLength - 1) / fragmentLength
			Local fragmentNumber:Int
			Local fragmentOffset:Int
			Local commandNumber:Int
			Local startSequenceNumber:Int
			Local fragments:ENetList = Null
			Local fragment:ENetOutgoingCommand
			
			If fragmentCount > ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT Then Return -1
			
			If (packet.flags & (ENetPacketFlagEnum.ENET_PACKET_FLAG_RELIABLE | ENetPacketFlagEnum.ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT)) = ENetPacketFlagEnum.ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT And channel.outgoingUnreliableSequenceNumber < $FFFF Then
			
				commandNumber = ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
				startSequenceNumber = p.ENET_HOST_TO_NET_16(p.IntToUshort(channel.outgoingUnreliableSequenceNumber + 1))
			
			Else
				commandNumber = ENET_PROTOCOL_COMMAND_SEND_FRAGMENT | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
				startSequenceNumber = p.ENET_HOST_TO_NET_16(p.IntToUshort(channel.outgoingReliableSequenceNumber + 1))
			
			Endif
			
			enet_list_clear(fragments)
			fragmentNumber = 0
			fragmentOffset = 0
			
			While fragmentOffset < packet.dataLength
			
				If packet.dataLength - fragmentOffset < fragmentLength Then fragmentLength = packet.dataLength - fragmentOffset
				
				fragment = New ENetOutgoingCommand()
				If fragment = Null Then
				
					While Not enet_list_empty(fragments)
					
						fragment = p.CastToENetOutgoingCommand(enet_list_remove(enet_list_begin(fragments)).data)
						
					
					Wend
					Return -1
				
				Endif
				fragment.fragmentOffset = fragmentOffset
				fragment.fragmentLength = p.IntToUshort(fragmentLength)
				fragment.packet = packet
				fragment.command.header.command = commandNumber
				fragment.command.header.channelID = channelID
				fragment.command.sendFragment.startSequenceNumber = startSequenceNumber
				fragment.command.sendFragment.dataLength = p.ENET_HOST_TO_NET_16(p.IntToUshort(fragmentLength))
				fragment.command.sendFragment.fragmentCount = p.ENET_HOST_TO_NET_32(fragmentCount)
				fragment.command.sendFragment.fragmentNumber = p.ENET_HOST_TO_NET_32(fragmentNumber)
				fragment.command.sendFragment.totalLength = p.ENET_HOST_TO_NET_32(packet.dataLength)
				fragment.command.sendFragment.fragmentOffset = p.ENET_NET_TO_HOST_32(fragmentOffset)
				enet_list_insert(enet_list_end(fragments), fragment)
				fragmentNumber=fragmentNumber+1
				fragmentOffset = fragmentOffset+fragmentLength
			
			Wend
			
			packet.referenceCount = packet.referenceCount + fragmentNumber
			
			While Not enet_list_empty(fragments)
			
				fragment = p.CastToENetOutgoingCommand(enet_list_remove(enet_list_begin(fragments)))
				
				enet_peer_setup_outgoing_command(peer, fragment)
				
				
			
			Wend
			
			Return 0
					
		Endif
		
		command.header.channelID = channelID
		If (packet.flags & (ENetPacketFlagEnum.ENET_PACKET_FLAG_RELIABLE | ENetPacketFlagEnum.ENET_PACKET_FLAG_UNSEQUENCED)) = ENetPacketFlagEnum.ENET_PACKET_FLAG_UNSEQUENCED Then
			command.header.command = ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED | ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED
			command.sendUnsequenced.dataLength = p.ENET_HOST_TO_NET_16(p.IntToUshort(packet.dataLength))
		Else
			If ((packet.flags & ENetPacketFlagEnum.ENET_PACKET_FLAG_RELIABLE) <> 0) Or channel.outgoingUnreliableSequenceNumber >= $FFFF Then
			
				command.header.command = ENET_PROTOCOL_COMMAND_SEND_RELIABLE | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
				command.sendReliable = New ENetProtocolSendReliable()
				command.sendReliable.dataLength = p.ENET_HOST_TO_NET_16(p.IntToUshort(packet.dataLength))
			
			Else
			
				command.header.command = ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
				command.sendUnreliable = New ENetProtocolSendUnreliable()
				command.sendUnreliable.dataLength = p.ENET_HOST_TO_NET_16(p.IntToUshort(packet.dataLength))
			
			Endif
			
		Endif
		
		If enet_peer_queue_outgoing_command(peer, command, packet, 0, p.IntToUshort(packet.dataLength)) = Null Then Return -1
		
		Return 0
		
	
	End
	
	
	Method enet_peer_receive:ENetPacket(peer:ENetPeer,channelID:Int)
	
		Local incomingCommand:ENetIncomingCommand
		Local packet:ENetPacket
		
		If enet_list_empty(peer.dispatchedCommands) = True Then
			Return Null
		Endif
		
		incomingCommand = p.CastToENetIncomingCommand(enet_list_remove(enet_list_begin(peer.dispatchedCommands)))
		
		If channelID <> 0 Then
		
			channelID = incomingCommand.command.header.channelID
		
		Endif
		
		packet = incomingCommand.packet
		packet.referenceCount = packet.referenceCount - 1
		
		If incomingCommand.fragments.Length() <> 0 Then
			incomingCommand.fragments = New Int[0] 'i guess?
		Endif
		incomingCommand.Delete()
		incomingCommand = Null
		
		Return packet
	End
	
	Method enet_peer_reset_outgoing_commands:Void(queue:ENetList)
	
		Local outgoingCommand:ENetOutgoingCommand
		
		While Not enet_list_empty(queue)
		
			outgoingCommand = p.CastToENetOutgoingCommand(enet_list_remove(enet_list_begin(queue)))
			
			If outgoingCommand.packet <> Null Then
			
				outgoingCommand.packet.referenceCount=outgoingCommand.packet.referenceCount-1
				If outgoingCommand.packet.referenceCount = 0 Then
					
					enet_packet_destroy(outgoingCommand.packet)
					
				Endif
			
			Endif
			
			outgoingCommand.Delete()
			outgoingCommand = Null 'should be removed from something?
			
		Wend
	
	End

	Method enet_peer_remove_incoming_commands:Void(queue:ENetList, startCommand:ENetListNode, endCommand:ENetListNode)
	
		Local currentCommand:ENetListNode = startCommand

		repeat
		

		
			Local incomingCommand:ENetIncomingCommand = ENetIncomingCommand(currentCommand)'p.CastToENetIncomingCommand(currentCommand)
			currentCommand = enet_list_next(currentCommand)
			enet_list_remove(incomingCommand.incomingCommandList())
			
			If incomingCommand <> Null then
				If incomingCommand.packet <> Null Then
				
					incomingCommand.packet.referenceCount=incomingCommand.packet.referenceCount-1
					If incomingCommand.packet.referenceCount = 0 Then enet_packet_destroy(incomingCommand.packet)
					
				
				Endif
				
				If incomingCommand.fragments.Length() <> 0 Then
					incomingCommand.fragments = New Int[0]
				Endif
				
				incomingCommand.Delete()
				incomingCommand = Null
			Endif
			
		Until currentCommand = endCommand
	
	End
	
	Method enet_peer_reset_incoming_commands:Void(queue:ENetList)
		enet_peer_remove_incoming_commands(queue, enet_list_begin(queue), enet_list_end(queue))
	End

	Method enet_peer_reset_queues:Void(peer:ENetPeer)
		
		Local channel:ENetChannel
		If peer.needsDispatch <> 0 Then
		
			enet_list_remove(peer.dispatchList())
			peer.needsDispatch = 0
		
		Endif
		
		While Not enet_list_empty(peer.acknowledgements)
		
			Local n:ENetListNode = enet_list_remove(enet_list_begin(peer.acknowledgements))
		
			n.Delete()
		
		Wend

		enet_peer_reset_outgoing_commands(peer.sentReliableCommands)
		enet_peer_reset_outgoing_commands(peer.sentUnreliableCommands)
		enet_peer_reset_outgoing_commands(peer.outgoingReliableCommands)
		enet_peer_reset_outgoing_commands(peer.outgoingUnreliableCommands)
		enet_peer_reset_incoming_commands(peer.dispatchedCommands)		
		
		If peer.channels.Length() <> 0 And peer.channelCount > 0 Then
		
			For Local i:Int = 0 To peer.channelCount-1
			
				channel = peer.channels[i]
				enet_peer_reset_incoming_commands(channel.incomingReliableCommands)
				enet_peer_reset_incoming_commands(channel.incomingUnreliableCommands)
			
			Next
			'peer.channels.Delete()
		
		Endif
		peer.channels = New ENetChannel[0]
		peer.channelCount = 0
		
	End
	
	
	Method enet_peer_on_connect:Void(peer:ENetPeer)
	
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
			
			If peer.incomingBandwidth <> 0 Then
			
				peer.host.bandwidthLimitedPeers=peer.host.bandwidthLimitedPeers+1
			
			Endif
			peer.host.connectedPeers=peer.host.connectedPeers+1
		
		Endif
	
	End


	Method enet_peer_on_disconnect:Void(peer:ENetPeer)
	
	
		If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			If peer.incomingBandwidth <> 0 Then
			
				peer.host.bandwidthLimitedPeers=peer.host.bandwidthLimitedPeers-1
			
			Endif
			peer.host.connectedPeers=peer.host.connectedPeers-1
		
		Endif
	
	End
	
	Method enet_peer_reset:Void(peer:ENetPeer)
	
		enet_peer_on_disconnect(peer)
		peer.outgoingPeerID = ENET_PROTOCOL_MAXIMUM_PEER_ID
		peer.connectID = 0
		
		peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED
		
		peer.incomingBandwidth = 0
		peer.outgoingBandwidth = 0
		peer.incomingBandwidthThrottleEpoch = 0
		peer.outgoingBandwidthThrottleEpoch = 0
		peer.incomingDataTotal = 0
		peer.outgoingDataTotal = 0
		peer.lastSendTime = 0
		peer.lastReceiveTime = 0
		peer.nextTimeout = 0
		peer.earliestTimeout = 0
		peer.packetLossEpoch = 0
		peer.packetsSent = 0
		peer.packetsLost = 0
		peer.packetLoss = 0
		peer.packetLossVariance = 0
		peer.packetThrottle = ENET_PEER_DEFAULT_PACKET_THROTTLE
		peer.packetThrottleLimit = ENET_PEER_PACKET_THROTTLE_SCALE
		peer.packetThrottleCounter = 0
		peer.packetThrottleEpoch = 0
		peer.packetThrottleAcceleration = ENET_PEER_PACKET_THROTTLE_ACCELERATION
		peer.packetThrottleDeceleration = ENET_PEER_PACKET_THROTTLE_DECELERATION
		peer.packetThrottleInterval = ENET_PEER_PACKET_THROTTLE_INTERVAL
		peer.pingInterval = ENET_PEER_PING_INTERVAL
		peer.timeoutLimit = ENET_PEER_TIMEOUT_LIMIT
		peer.timeoutMinimum = ENET_PEER_TIMEOUT_MINIMUM
		peer.timeoutMaximum = ENET_PEER_TIMEOUT_MAXIMUM
		peer.lastRoundTripTime = ENET_PEER_DEFAULT_ROUND_TRIP_TIME
		peer.lowestRoundTripTime = ENET_PEER_DEFAULT_ROUND_TRIP_TIME
		peer.lastRoundTripTimeVariance = 0
		peer.highestRoundTripTimeVariance = 0
		peer.roundTripTime = ENET_PEER_DEFAULT_ROUND_TRIP_TIME
		peer.roundTripTimeVariance = 0
		peer.mtu = peer.host.mtu
		peer.reliableDataInTransit = 0
		peer.outgoingReliableSequenceNumber = 0
		peer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
		peer.incomingUnsequencedGroup = 0
		peer.outgoingUnsequencedGroup = 0
		peer.eventData = 0		
		
		For Local i:Int = 0 To ENetPeer.unsequencedWindowLength-1
		
			peer.unsequencedWindow[i] = 0
		
		Next
	
		enet_peer_reset_queues(peer)
	
	End

	Method enet_peer_ping:Void(peer:ENetPeer)
	
		Local command:ENetProtocol = New ENetProtocol()
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED Then Return
		
		command.header.command = ENET_PROTOCOL_COMMAND_PING | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
		command.header.channelID = $FF
		enet_peer_queue_outgoing_command(peer, command, null, 0, 0)
	
	End
	
	
	Method enet_peer_ping_interval:Void(peer:ENetPeer,pingInterval:Int)
	
	
		If pingInterval <> 0 Then 
			peer.pingInterval = pingInterval
		Else	
			peer.pingInterval = ENET_PEER_PING_INTERVAL		
		Endif
		
	End
	
	Method enet_peer_timeout:Void(peer:ENetPeer, timeoutLimit:Int, timeoutMinimum:Int, timeoutMaximum:Int)
	
		If timeoutLimit <> 0 Then
			peer.timeoutLimit = timeoutLimit
		Else
			peer.timeoutLimit = ENET_PEER_TIMEOUT_LIMIT
		Endif
		
		If timeoutMinimum <> 0 Then
			peer.timeoutMinimum = timeoutMinimum
		Else
			peer.timeoutMinimum = ENET_PEER_TIMEOUT_MINIMUM
		Endif
		
		If timeoutMaximum <> 0 Then
			peer.timeoutMaximum = timeoutMaximum
		Else
			peer.timeoutMaximum = ENET_PEER_TIMEOUT_MAXIMUM
		Endif
	
	End
	
	Method enet_peer_disconnect_now:Void(peer:ENetPeer, data:Int)
	
		Local command:ENetProtocol = New ENetProtocol()
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Then Return
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_ZOMBIE And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECTING Then
		
			enet_peer_reset_queues(peer)
			command.header.command = ENET_PROTOCOL_COMMAND_DISCONNECT | ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED
			command.header.channelID = $FF
			command.disconnect.data = p.ENET_HOST_TO_NET_32(data)
			enet_peer_queue_outgoing_command(peer, command, Null, 0, 0)
			enet_host_flush(peer.host)
		
		Endif
		
		enet_peer_reset(peer)
	End
	
	
	Method enet_peer_disconnect:Void(peer:ENetPeer, data:Int)
	
		Local command:ENetProtocol = New ENetProtocol()
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTING Or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT Or peer.state = ENetPeerState.ENET_PEER_STATE_ZOMBIE Then Return
		
		enet_peer_reset_queues(peer)
		
		command.header.command = ENET_PROTOCOL_COMMAND_DISCONNECT
		command.header.channelID = $FF
		command.disconnect.data = p.ENET_HOST_TO_NET_32(data)
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			command.header.command = command.header.command | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
			
		Else
		
			command.header.command = command.header.command | ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED
		
		Endif
		
		enet_peer_queue_outgoing_command(peer, command, null, 0, 0)
	
	
		If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			enet_peer_on_disconnect(peer)
			peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTING
		
		Else
			
			enet_host_flush(peer.host)
			enet_peer_reset(peer)
			
		Endif
	
	End
	
	Method enet_peer_disconnect_later:Void(peer:ENetPeer, data:Int)
	
		If (peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) And Not (enet_list_empty(peer.outgoingReliableCommands) And enet_list_empty(peer.outgoingUnreliableCommands) And enet_list_empty(peer.sentReliableCommands)) Then
		
			peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER
			peer.eventData = data
			
		Else
		
			enet_peer_disconnect(peer, data)
		
		Endif
	
	End
	
	Method enet_peer_queue_acknowledgement:ENetAcknowledgement(peer:ENetPeer, command:ENetProtocol, sentTime:Int)
	
		Local acknowledgement:ENetAcknowledgement
		
		If command.header.channelID < peer.channelCount Then
		
			Local channel:ENetChannel = peer.channels[command.header.channelID]
			Local reliableWindow:Int = p.IntToUshort(command.header.reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
			Local currentWindow:Int = p.IntToUshort(channel.incomingReliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
			
			If command.header.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
			
				reliableWindow = reliableWindow+ENET_PEER_RELIABLE_WINDOWS
			
			Endif
			
			If reliableWindow >= currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS - 1 And reliableWindow <= currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS Then
			
				Return null
			
			Endif
		
		Endif
		
		acknowledgement = New ENetAcknowledgement()
		If acknowledgement = Null Then Return Null
		
		peer.outgoingDataTotal = peer.outgoingDataTotal+ENetProtocolAcknowledge.SizeOf
		acknowledgement.sentTime = sentTime
		acknowledgement.command = command
		
		enet_list_insert(enet_list_end(peer.acknowledgements), acknowledgement)
		
		return acknowledgement
	
	End
	
	Method enet_peer_setup_outgoing_command:Void(peer:ENetPeer, outgoingCommand:ENetOutgoingCommand)
	
		Local channel:ENetChannel = Null
		
		peer.outgoingDataTotal = peer.outgoingDataTotal + enet_protocol_command_size(outgoingCommand.command.header.command) + outgoingCommand.fragmentLength
		
		If outgoingCommand.command.header.channelID = $FF Then
		
			peer.outgoingReliableSequenceNumber = peer.outgoingReliableSequenceNumber + 1
			outgoingCommand.reliableSequenceNumber = peer.outgoingReliableSequenceNumber
			outgoingCommand.unreliableSequenceNumber = 0
		
		Else
		
			channel = peer.channels[outgoingCommand.command.header.channelID]
			If (outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE) <> 0 then
			
				channel.outgoingReliableSequenceNumber = channel.outgoingReliableSequenceNumber + 1
				channel.outgoingUnreliableSequenceNumber = 0
				outgoingCommand.reliableSequenceNumber = channel.outgoingReliableSequenceNumber
				outgoingCommand.unreliableSequenceNumber = 0
				
			Else
				If (outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED) <> 0 Then
				
					peer.outgoingUnsequencedGroup = peer.outgoingUnsequencedGroup + 1
					outgoingCommand.reliableSequenceNumber = 0
					outgoingCommand.unreliableSequenceNumber = 0
					
				Else
				
					If outgoingCommand.fragmentOffset = 0 Then
						channel.outgoingUnreliableSequenceNumber = channel.outgoingUnreliableSequenceNumber + 1
					Endif
				
					outgoingCommand.reliableSequenceNumber = channel.outgoingReliableSequenceNumber
					outgoingCommand.unreliableSequenceNumber = channel.outgoingUnreliableSequenceNumber
				
				Endif
			
			Endif
			
		Endif
		
		outgoingCommand.sendAttempts = 0
		outgoingCommand.sentTime = 0
		outgoingCommand.roundTripTimeout = 0
		outgoingCommand.roundTripTimeoutLimit = 0
		outgoingCommand.command.header.reliableSequenceNumber = p.ENET_HOST_TO_NET_16(outgoingCommand.reliableSequenceNumber)
		
		Select outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK
		
			Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
				outgoingCommand.command.sendUnreliable.unreliableSequenceNumber = p.ENET_HOST_TO_NET_16(outgoingCommand.unreliableSequenceNumber)
				
			Case ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
				outgoingCommand.command.sendUnsequenced.unsequencedGroup = p.ENET_HOST_TO_NET_16(peer.outgoingUnsequencedGroup)
		
		
		
		End Select
		
		If (outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE) <> 0 Then
		
			enet_list_insert(enet_list_end(peer.outgoingReliableCommands), outgoingCommand)
		
		Else
			
			enet_list_insert(enet_list_end(peer.outgoingUnreliableCommands), outgoingCommand)
		
		Endif
	
	End
	
	Method enet_peer_queue_outgoing_command:ENetOutgoingCommand(peer:ENetPeer, command:ENetProtocol, packet:ENetPacket, offset:Int, length:Int)
	
		Local outgoingCommand:ENetOutgoingCommand = New ENetOutgoingCommand()
		
		If outgoingCommand = Null Then Return Null
		
		outgoingCommand.command = command
		outgoingCommand.fragmentOffset = offset
		outgoingCommand.fragmentLength = length
		outgoingCommand.packet = packet
		If packet <> Null Then
		
			packet.referenceCount = packet.referenceCount + 1
		
		Endif
		
		enet_peer_setup_outgoing_command(peer, outgoingCommand)
		
		return outgoingCommand
	
	End
	
	Method enet_peer_dispatch_incoming_unreliable_commands:Void(peer:ENetPeer,channel:ENetChannel)
	
		Local droppedCommand:ENetListNode
		Local startCommand:ENetListNode
		Local currentCommand:ENetListNode
		Local lastCommand:ENetListNode
		
		lastCommand = enet_list_end(channel.incomingUnreliableCommands)
		droppedCommand = enet_list_begin(channel.incomingUnreliableCommands)
		startCommand = droppedCommand
		currentCommand = droppedCommand
		
		Repeat
		
			Local incomingCommand:ENetIncomingCommand = p.CastToENetIncomingCommand(currentCommand)
		
			If (incomingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK) = ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED Then Continue
			
			If incomingCommand.reliableSequenceNumber = channel.incomingReliableSequenceNumber Then
				
				If incomingCommand.fragmentsRemaining <= 0 Then
					channel.incomingUnreliableSequenceNumber = incomingCommand.unreliableSequenceNumber
					Continue
				Endif
			
				If startCommand <> currentCommand Then
					enet_list_move(enet_list_end(peer.dispatchedCommands), startCommand, enet_list_previous(currentCommand))
					
					If peer.needsDispatch = 0 Then
					
						enet_list_insert(enet_list_end(peer.host.dispatchQueue), peer.dispatchList())
						peer.needsDispatch = 1
						
					
					Endif
					
					droppedCommand = currentCommand
					
				Else
				
					If droppedCommand <> currentCommand Then
					
						droppedCommand = enet_list_previous(currentCommand)
					
					Endif
				
				Endif
			
			Else
			
				Local reliableWindow:Int = p.IntToUshort(incomingCommand.reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
				Local currentWindow:Int = p.IntToUshort(channel.incomingReliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)				
			
				If incomingCommand.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
				
					reliableWindow = reliableWindow+ENET_PEER_RELIABLE_WINDOWS
				
				Endif
				
				If reliableWindow >= currentWindow And reliableWindow < currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS - 1 Then
					
					Exit
				
				Endif
				
				droppedCommand = enet_list_next(currentCommand)
				
				If startCommand <> currentCommand Then
				
					enet_list_move(enet_list_end(peer.dispatchedCommands), startCommand, enet_list_previous(currentCommand))
					
					If peer.needsDispatch = 0 Then
						
						enet_list_insert(enet_list_end(peer.host.dispatchQueue), peer.dispatchList())
						peer.needsDispatch = 1
						
					Endif
				
				Endif
				
			Endif
		
			startCommand = enet_list_next(currentCommand)
			currentCommand = enet_list_next(currentCommand)
		Until currentCommand = lastCommand
		
		If startCommand <> currentCommand Then
		
			enet_list_move(enet_list_end(peer.dispatchedCommands), startCommand, enet_list_previous(currentCommand))
			
			If peer.needsDispatch = 0 Then
				
				enet_list_insert(enet_list_end(peer.host.dispatchQueue), peer.dispatchList())
				peer.needsDispatch = 1;
				
			Endif
		
			droppedCommand = currentCommand
		
		Endif
		
		enet_peer_remove_incoming_commands(channel.incomingUnreliableCommands, enet_list_begin(channel.incomingUnreliableCommands), droppedCommand)
	
	End
	
	
	Method enet_peer_dispatch_incoming_reliable_commands:Void(peer:ENetPeer, channel:ENetChannel)
	
	
		Local currentCommand:ENetListNode
		Local lastCommand:ENetListNode
	
		currentCommand = enet_list_begin(channel.incomingReliableCommands)
		lastCommand = enet_list_end(channel.incomingReliableCommands)
		
		Repeat
		
			Local incomingCommand:ENetIncomingCommand = p.CastToENetIncomingCommand(currentCommand)
			
			If incomingCommand.fragmentsRemaining > 0 Or incomingCommand.reliableSequenceNumber <> p.IntToUshort(channel.incomingReliableSequenceNumber + 1) Then
			
				Exit
			
			Endif
			
			channel.incomingReliableSequenceNumber = incomingCommand.reliableSequenceNumber
			
			If incomingCommand.fragmentCount > 0 Then
			
				channel.incomingReliableSequenceNumber = channel.incomingReliableSequenceNumber+incomingCommand.fragmentCount - 1
				
			
			Endif

		Until currentCommand = lastCommand
		
		If currentCommand = enet_list_begin(channel.incomingReliableCommands) Then
			
			return
		
		Endif
		
		channel.incomingUnreliableSequenceNumber = 0
		
		enet_list_move(enet_list_end(peer.dispatchedCommands), enet_list_begin(channel.incomingReliableCommands), enet_list_previous(currentCommand))
		
		If peer.needsDispatch = 0 Then
		
			enet_list_insert(enet_list_end(peer.host.dispatchQueue), peer.dispatchList())
			peer.needsDispatch = 1
		
		Endif
		
		If Not enet_list_empty(channel.incomingUnreliableCommands) Then
		
			enet_peer_dispatch_incoming_unreliable_commands(peer, channel)
		
		Endif
	
	End
	
	Method enet_peer_queue_incoming_command:ENetIncomingCommand(peer:ENetPeer, command:ENetProtocol, packet:ENetPacket, fragmentCount:Int)
	
		Local channel:ENetChannel = peer.channels[command.header.channelID]
		Local unreliableSequenceNumber:Int = 0
		Local reliableSequenceNumber:int = 0
		Local reliableWindow:int
		Local currentWindow:int
		Local incomingCommand:ENetIncomingCommand = Null
		Local currentCommand:ENetListNode	
		Local lastCommand:ENetListNode
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			return freePacket(fragmentCount, packet)
		
		Endif
		
		If (command.header.command & ENET_PROTOCOL_COMMAND_MASK) <> ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED Then
		
			reliableSequenceNumber = command.header.reliableSequenceNumber
			reliableWindow = reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE
			currentWindow = channel.incomingReliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE
			
			If reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
			
				reliableWindow = reliableWindow+ENET_PEER_RELIABLE_WINDOWS

			Endif
			
			If reliableWindow < currentWindow or reliableWindow >= currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS - 1 Then
			
				return freePacket(fragmentCount, packet)
			
			Endif
		
		Endif
		
		Select command.header.command & ENET_PROTOCOL_COMMAND_MASK
		
			Case ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,ENET_PROTOCOL_COMMAND_SEND_RELIABLE
				
				If reliableSequenceNumber = channel.incomingReliableSequenceNumber Then
				
					return freePacket(fragmentCount, packet)
				
				Endif
				
				lastCommand = enet_list_end(channel.incomingReliableCommands)
				currentCommand = enet_list_previous(enet_list_end(channel.incomingReliableCommands))
				
				Repeat
					incomingCommand = p.CastToENetIncomingCommand(currentCommand)
					
					If reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
					
						If incomingCommand.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
							currentCommand = enet_list_previous(currentCommand)
							Continue
						
						Endif
					
					Else
					
						If incomingCommand.reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then Exit
					
					Endif
					
					If incomingCommand.reliableSequenceNumber <= reliableSequenceNumber Then
					
						If incomingCommand.reliableSequenceNumber < reliableSequenceNumber Then Exit
						
						return freePacket(fragmentCount, packet)
					
					Endif
				
					currentCommand = enet_list_previous(currentCommand)
				Until currentCommand = lastCommand
				
			Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE,ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
			
				unreliableSequenceNumber = p.ENET_NET_TO_HOST_16(command.sendUnreliable.unreliableSequenceNumber)
				
				If reliableSequenceNumber = channel.incomingReliableSequenceNumber and unreliableSequenceNumber <= channel.incomingUnreliableSequenceNumber Then
				
					return freePacket(fragmentCount, packet)
				
				Endif
				
				currentCommand = enet_list_previous(enet_list_end(channel.incomingUnreliableCommands))
				lastCommand = enet_list_end(channel.incomingUnreliableCommands)
				
				Repeat
					incomingCommand = p.CastToENetIncomingCommand(currentCommand)
					
					If (command.header.command & ENET_PROTOCOL_COMMAND_MASK) = ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED Then
						
						currentCommand = enet_list_previous(currentCommand)
						Continue
					
					Endif
					
					If reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
					
						If incomingCommand.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
						
							currentCommand = enet_list_previous(currentCommand)
							Continue							
						
						Endif
					
					Else
					
						If incomingCommand.reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
							Exit
						Endif
					
					Endif
					
					If incomingCommand.reliableSequenceNumber < reliableSequenceNumber Then
						
						Exit
						
					Endif
					
					If incomingCommand.reliableSequenceNumber > reliableSequenceNumber Then

						currentCommand = enet_list_previous(currentCommand)
						Continue
												
					Endif
					
					If incomingCommand.unreliableSequenceNumber <= unreliableSequenceNumber Then
					
						If incomingCommand.unreliableSequenceNumber < unreliableSequenceNumber Then
							Exit
						Endif
						
						return freePacket(fragmentCount, packet)
					
					Endif
					
					currentCommand = enet_list_previous(currentCommand)
				Until currentCommand = lastCommand
			
			Case ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
				currentCommand = enet_list_end(channel.incomingUnreliableCommands)
				
			Default
				return freePacket(fragmentCount, packet)
		
		End Select
		
		incomingCommand = New ENetIncomingCommand()
		
		If incomingCommand = Null Then Return notifyError(packet)
		
		incomingCommand.reliableSequenceNumber = command.header.reliableSequenceNumber
		incomingCommand.unreliableSequenceNumber = p.IntToUshort(unreliableSequenceNumber & $FFFF)
		incomingCommand.command = command
		incomingCommand.fragmentCount = fragmentCount
		incomingCommand.fragmentsRemaining = fragmentCount
		incomingCommand.packet = packet
		incomingCommand.fragments = New Int[0]		
	
		If fragmentCount > 0 Then
			
			If fragmentCount <= ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT Then
			
				incomingCommand.fragments = new int[(fragmentCount + 31) / 32]
			
			Endif
			
			If incomingCommand.fragments.Length() = 0 Then
			
				incomingCommand.Delete()
				return notifyError(packet)
			
			Endif
			
			For Local i:Int = 0 To ((fragmentCount + 31) / 32)-1
			
				incomingCommand.fragments[i] = 0
			
			Next
		
		Endif
		
		If packet <> Null Then
		
			packet.referenceCount = packet.referenceCount + 1
			
		Endif
		
		enet_list_insert(enet_list_next(currentCommand), incomingCommand)
		
		Select command.header.command & ENET_PROTOCOL_COMMAND_MASK
		
			Case ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,ENET_PROTOCOL_COMMAND_SEND_RELIABLE
				
				enet_peer_dispatch_incoming_reliable_commands(peer, channel)
				
			Default
				enet_peer_dispatch_incoming_unreliable_commands(peer, channel)
		
		End Select
		
		return incomingCommand
	
	End
	
	Method freePacket:ENetIncomingCommand(fragmentCount:Int,packet:ENetPacket)
		
		If fragmentCount > 0 Then
		
			return notifyError(packet)
		
		Endif
		
		If packet <> Null And packet.referenceCount = 0 Then
		
			enet_packet_destroy(packet)
		
		Endif
		
		return dummyCommand
	
	End
	
	
	Method notifyError:ENetIncomingCommand(packet:ENetPacket)

		If packet <> Null And packet.referenceCount = 0 Then
			enet_packet_destroy(packet)
		Endif
		
		Return Null

	End
	
	
	Method enet_host_compress_with_range_coder:Int(host:ENetHost)
	
		return 0
	
	End
	
	Method enet_protocol_command_size:Int(commandNumber:Int)
	
		return commandSizes[commandNumber & ENET_PROTOCOL_COMMAND_MASK]
	
	End
	
	Method enet_list_clear:Void(list:ENetList)
	
		p.CastToENetListNode(list.GetSentinel()).ENext = list.GetSentinel()
		p.CastToENetListNode(list.GetSentinel()).EPrev = list.GetSentinel()
	
	End
	
	Method enet_list_insert:ENetListNode(position:ENetListNode, data:ENetObject)
	
		Local result:ENetListNode = p.CastToENetListNode(data)
		result.EPrev = position.EPrev
		result.ENext = position
		
		p.CastToENetListNode(result.EPrev).ENext = result
		position.EPrev = result
		
		return result
	
	
	End
	
	Method enet_list_remove:ENetListNode(position:ENetListNode)
		If position = Null Then Return Null
		
		p.CastToENetListNode(position.EPrev).ENext = position.ENext
		p.CastToENetListNode(position.ENext).EPrev = position.EPrev
		
		return position
	
	End
	
	Method enet_list_move:ENetListNode(position:ENetListNode, dataFirst:ENetListNode, dataLast:ENetListNode)
	
		Local first:ENetListNode = dataFirst
		Local last:ENetListNode = dataLast
		
		p.CastToENetListNode(first.EPrev).ENext = last.ENext
		p.CastToENetListNode(last.ENext).EPrev = first.EPrev
		
		first.EPrev = position.EPrev
		last.ENext = position
		
		p.CastToENetListNode(first.EPrev).ENext = first
		position.EPrev = last
		
		return first
		
	
	End
	
	
	Method enet_list_size:Int(list:ENetList)
	
		Local size:Int = 0
		Local position:ENetListNode = enet_list_begin(list)
		Local last:ENetListNode = enet_list_end(list)
		
		Repeat
			size = size + 1
			
			position = enet_list_next(position)
		Until position = last
		
		Return size
		
	
	End
	
	Method enet_list_begin:ENetListNode(list:ENetList)
		
		Return p.CastToENetListNode(p.CastToENetListNode(list.GetSentinel()).ENext)
	
	End
	
	Method enet_list_end:ENetListNode(list:ENetList)
	
		Return p.CastToENetListNode(list.GetSentinel())
	
	End
	
	Method enet_list_empty:Bool(list:ENetList)
	
		If enet_list_begin(list) = enet_list_end(list) Then
		
			Return True
		
		Endif
		
		Return False
	
	End
	
	Method enet_list_next:ENetListNode(iterator:ENetListNode)
	
		return p.CastToENetListNode((iterator).ENext)
	
	End
	
	Method enet_list_previous:ENetListNode(iterator:ENetListNode)
	
		return p.CastToENetListNode((iterator).EPrev)
	
	End
	
	Method enet_list_front:ENetListNode(list:ENetList)
		
		return p.CastToENetListNode(p.CastToENetListNode(list.GetSentinel()).ENext)
	
	End
	
	Method enet_list_back:ENetListNode(list:ENetList)
	
		return p.CastToENetListNode(p.CastToENetListNode(list.GetSentinel()).EPrev)
	
	End
	
	
	Method enet_protocol_change_state:Void(host:ENetHost, peer:ENetPeer,state:Int)
	
	
		If state = ENetPeerState.ENET_PEER_STATE_CONNECTED or state = ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			enet_peer_on_connect(peer)
			
		Else
		
			enet_peer_on_disconnect(peer)
		
		Endif
		
		peer.state = state
	
	End
	
	Method enet_protocol_dispatch_state:Void(host:ENetHost, peer:ENetPeer, state:Int)
	
		enet_protocol_change_state(host, peer, state)
		
		If peer.needsDispatch = 0 Then
		
			enet_list_insert(enet_list_end(host.dispatchQueue), peer.dispatchList())
			peer.needsDispatch = 1
		
		Endif
	
	End
	
	Method enet_protocol_dispatch_incoming_commands:Int(host:ENetHost, event_:ENetEvent)
	
		While Not enet_list_empty(host.dispatchQueue)
		
			Local peer:ENetPeer = p.CastToENetPeer(enet_list_remove(enet_list_begin(host.dispatchQueue)))
			
			peer.needsDispatch = 0
			
			Select peer.state
			
				Case ENetPeerState.ENET_PEER_STATE_CONNECTION_PENDING,ENetPeerState.ENET_PEER_STATE_CONNECTION_SUCCEEDED
					
					enet_protocol_change_state(host, peer, ENetPeerState.ENET_PEER_STATE_CONNECTED)
					event_.type = ENetEventType.ENET_EVENT_TYPE_CONNECT
					event_.peer = peer
					event_.data = peer.eventData
					
					Return 1
					
				Case ENetPeerState.ENET_PEER_STATE_ZOMBIE
				
					host.recalculateBandwidthLimits = 1
					event_.type = ENetEventType.ENET_EVENT_TYPE_DISCONNECT
					event_.peer = peer
					enet_peer_reset(peer)
			
					Return 1
					
				Case ENetPeerState.ENET_PEER_STATE_CONNECTED
				
					If enet_list_empty(peer.dispatchedCommands) Then
						Continue
					Endif
					
					event_.packet = enet_peer_receive(peer, event_.channelID)
					'Convert Event_.ChannelID to byte?
					If event_.packet = Null Then Continue
					event_.type = ENetEventType.ENET_EVENT_TYPE_RECEIVE
					event_.peer = peer
					
					If Not enet_list_empty(peer.dispatchedCommands) Then
					
						peer.needsDispatch = 1
						enet_list_insert(enet_list_end(host.dispatchQueue), peer.dispatchList())
						
					
					Endif
					
					Return 1
					
				Default
					Exit
			
			
			End Select
		
		
		
		Wend
		
		Return 0
	
	End
	
	Method enet_protocol_notify_connect:Void(host:ENetHost, peer:ENetPeer, event_:ENetEvent)

		host.recalculateBandwidthLimits = 1
		
		If event_ <> Null Then
		
			enet_protocol_change_state(host, peer, ENetPeerState.ENET_PEER_STATE_CONNECTED)
			event_.type = ENetEventType.ENET_EVENT_TYPE_CONNECT
			event_.peer = peer
			event_.data = peer.eventData
			
		Else
		
			If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTING Then
				enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_CONNECTION_PENDING)
			Else
				enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_CONNECTION_SUCCEEDED)
			endif
		
		Endif
		
		

	End


	Method enet_protocol_notify_disconnect:Void(host:ENetHost, peer:ENetPeer, event_:ENetEvent)

		
		If peer.state >= ENetPeerState.ENET_PEER_STATE_CONNECTION_PENDING Then
		
			host.recalculateBandwidthLimits = 1
		
		Endif
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTING And peer.state < ENetPeerState.ENET_PEER_STATE_CONNECTION_SUCCEEDED Then
		
			enet_peer_reset(peer)
		
		Else
		
			If event_ <> Null Then
			
				event_.type = ENetEventType.ENET_EVENT_TYPE_DISCONNECT
				event_.peer = peer
				event_.data = 0
				enet_peer_reset(peer)
			
			Else
			
				peer.eventData = 0
				enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_ZOMBIE)
			
			Endif
		
		Endif

	End
	
	
	Method enet_protocol_remove_sent_unreliable_commands:Void(peer:ENetPeer)
	
		Local outgoingCommand:ENetOutgoingCommand
		
		While Not enet_list_empty(peer.sentUnreliableCommands)
		
		
			outgoingCommand = p.CastToENetOutgoingCommand(enet_list_front(peer.sentUnreliableCommands))
			enet_list_remove(outgoingCommand.outgoingCommandList())
			
			If outgoingCommand.packet <> Null Then
			
				outgoingCommand.packet.referenceCount=outgoingCommand.packet.referenceCount-1
				If outgoingCommand.packet.referenceCount = 0 Then
				
					outgoingCommand.packet.flags = outgoingCommand.packet.flags|ENetPacketFlagEnum.ENET_PACKET_FLAG_SENT
					enet_packet_destroy(outgoingCommand.packet)
				
				Endif
			
			
			Endif
		
		
		
			outgoingCommand.Delete()
		Wend
	
	End
	
	
	Method enet_protocol_remove_sent_reliable_command:Int(peer:ENetPeer, reliableSequenceNumber:Int, channelID:Int)
	
		Local outgoingCommand:ENetOutgoingCommand = Null
		Local currentCommand:ENetListNode
		Local lastCommand:ENetListNode		
		Local commandNumber:Int
		Local wasSent:Int = 1
		
		currentCommand = enet_list_begin(peer.sentReliableCommands)
		lastCommand = enet_list_end(peer.sentReliableCommands)
		
		Repeat
		
			outgoingCommand = p.CastToENetOutgoingCommand(currentCommand)
			If outgoingCommand.reliableSequenceNumber = reliableSequenceNumber And outgoingCommand.command.header.channelID = channelID Then
				Exit
			Endif
			
			currentCommand = enet_list_next(currentCommand)
		Until currentCommand = lastCommand
		
		If currentCommand = enet_list_end(peer.sentReliableCommands) Then
			
			currentCommand = enet_list_begin(peer.outgoingReliableCommands)
			lastCommand = enet_list_end(peer.outgoingReliableCommands)
			
			Repeat
			
				outgoingCommand = p.CastToENetOutgoingCommand(currentCommand)
				
				If outgoingCommand.sendAttempts < 1 Return ENET_PROTOCOL_COMMAND_NONE
			
				If outgoingCommand.reliableSequenceNumber = reliableSequenceNumber And outgoingCommand.command.header.channelID = channelID Then
					Exit
				Endif
			
				currentCommand = enet_list_next(currentCommand)
			Until currentCommand = lastCommand
		
		
			If currentCommand = enet_list_end(peer.outgoingReliableCommands) Then Return ENET_PROTOCOL_COMMAND_NONE
			
			wasSent = 0
		
		Endif
		
		If outgoingCommand = Null Then Return ENET_PROTOCOL_COMMAND_NONE
		
		If channelID < peer.channelCount Then
		
			Local channel:ENetChannel = peer.channels[channelID]
			Local reliableWindow:Int = p.IntToUshort(reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
			
			If channel.reliableWindows[reliableWindow] > 0 Then
			
				channel.reliableWindows[reliableWindow] = channel.reliableWindows[reliableWindow] - 1
				If channel.reliableWindows[reliableWindow] = 0 Then
				
					channel.usedReliableWindows = channel.usedReliableWindows & (~(1 Shl reliableWindow))
					
				Endif
			
			Endif
		
		Endif
		
		commandNumber = (outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK)
		
		enet_list_remove(outgoingCommand.outgoingCommandList())
		
		If outgoingCommand.packet <> Null Then
		
			If wasSent <> 0 Then
			
				peer.reliableDataInTransit -= outgoingCommand.fragmentLength
			
			Endif
			
			outgoingCommand.packet.referenceCount = outgoingCommand.packet.referenceCount - 1
			
			If outgoingCommand.packet.referenceCount = 0 Then
			
				outgoingCommand.packet.flags = outgoingCommand.packet.flags|ENetPacketFlagEnum.ENET_PACKET_FLAG_SENT
				enet_packet_destroy(outgoingCommand.packet)
			
			Endif
		
		Endif	
	
		outgoingCommand.Delete()
		
		If enet_list_empty(peer.sentReliableCommands) Then
		
			return commandNumber
		
		Endif
		
		outgoingCommand = p.CastToENetOutgoingCommand(enet_list_front(peer.sentReliableCommands))
		peer.nextTimeout = outgoingCommand.sentTime + outgoingCommand.roundTripTimeout
		return commandNumber
	
	End
	
	
	Method enet_protocol_handle_connect:ENetPeer(host:ENetHost, header:ENetProtocolHeader, command:ENetProtocol)
	
		Local incomingSessionID:Int
		Local outgoingSessionID:Int
		Local mtu:Int
		Local windowSize:Int
		Local channel:ENetChannel
		Local channelCount:Int
		Local currentPeer:ENetPeer = New ENetPeer()
		Local verifyCommand:ENetProtocol = New ENetProtocol()
		
		
		channelCount = p.ENET_NET_TO_HOST_32(command.connect.channelCount)
		
		If channelCount < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT Or channelCount > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT	 Then
			Return Null
		Endif	
		
		Local i:Int
		
		For i = 0 To host.peerCount-1
		
			currentPeer = host.peers[i]
			If currentPeer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECTED And currentPeer.address.host = host.receivedAddress.host And currentPeer.address.port = host.receivedAddress.port And currentPeer.connectID = command.connect.connectID Then
				Return Null
			Endif	
		
		Next
		For i = 0 To host.peerCount-1
		
			currentPeer = host.peers[i]
			If currentPeer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Then
				Exit
			Endif
		
		Next
		
		If i >= host.peerCount Then Return Null
		
		If channelCount > host.channelLimit Then
			channelCount = host.channelLimit
		Endif
		
		currentPeer.channels = New ENetChannel[channelCount]
		
		For Local k:Int = 0 To channelCount-1
		
			currentPeer.channels[k] = new ENetChannel()
		
		Next
		
		If currentPeer.channels.Length() = 0 Then Return Null
		
		currentPeer.channelCount = channelCount
		currentPeer.state = ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_CONNECT
		currentPeer.connectID = command.connect.connectID
		currentPeer.address = host.receivedAddress
		currentPeer.outgoingPeerID = p.ENET_NET_TO_HOST_16(command.connect.outgoingPeerID)
		currentPeer.incomingBandwidth = p.ENET_NET_TO_HOST_32(command.connect.incomingBandwidth)
		currentPeer.outgoingBandwidth = p.ENET_NET_TO_HOST_32(command.connect.outgoingBandwidth)
		currentPeer.packetThrottleInterval = p.ENET_NET_TO_HOST_32(command.connect.packetThrottleInterval)
		currentPeer.packetThrottleAcceleration = p.ENET_NET_TO_HOST_32(command.connect.packetThrottleAcceleration)
		currentPeer.packetThrottleDeceleration = p.ENET_NET_TO_HOST_32(command.connect.packetThrottleDeceleration)
		currentPeer.eventData = p.ENET_NET_TO_HOST_32(command.connect.data)	
		
		If command.connect.incomingSessionID = $FF Then
			incomingSessionID = currentPeer.outgoingSessionID
		Else
			incomingSessionID = command.connect.incomingSessionID
		Endif
		
		incomingSessionID = ToByte((incomingSessionID + 1) & (ENET_PROTOCOL_HEADER_SESSION_MASK Shr ENET_PROTOCOL_HEADER_SESSION_SHIFT))
		If incomingSessionID = currentPeer.outgoingSessionID Then
			incomingSessionID = ToByte((incomingSessionID + 1) & (ENET_PROTOCOL_HEADER_SESSION_MASK Shr ENET_PROTOCOL_HEADER_SESSION_SHIFT))
		Endif
		
		currentPeer.outgoingSessionID = incomingSessionID
		
		If command.connect.outgoingSessionID = $FF Then
			outgoingSessionID = currentPeer.incomingSessionID
		Else
			outgoingSessionID = command.connect.outgoingSessionID
		Endif
		
		outgoingSessionID = ToByte((outgoingSessionID + 1) & (ENET_PROTOCOL_HEADER_SESSION_MASK Shr ENET_PROTOCOL_HEADER_SESSION_SHIFT))
		If outgoingSessionID = currentPeer.incomingSessionID Then
			outgoingSessionID = ToByte((outgoingSessionID + 1) & (ENET_PROTOCOL_HEADER_SESSION_MASK Shr ENET_PROTOCOL_HEADER_SESSION_SHIFT))
		Endif
		
		currentPeer.incomingSessionID = outgoingSessionID
		
		For i = 0 To currentPeer.channelCount-1
		
			channel = currentPeer.channels[i]
			channel.outgoingReliableSequenceNumber = 0
			channel.outgoingUnreliableSequenceNumber = 0
			channel.incomingReliableSequenceNumber = 0
			channel.incomingUnreliableSequenceNumber = 0		
			
			enet_list_clear(channel.incomingReliableCommands)
			enet_list_clear(channel.incomingUnreliableCommands)
			channel.usedReliableWindows = 0
			
			For Local k:Int = 0 To ENetChannel.reliableWindowsLength-1
			
				channel.reliableWindows[k] = 0
			
			Next	
		
		Next
		
		mtu = p.ENET_NET_TO_HOST_32(command.connect.mtu)
		
		If mtu < ENET_PROTOCOL_MINIMUM_MTU Then
		
			mtu = ENET_PROTOCOL_MINIMUM_MTU
		
		Else
		
			If mtu > ENET_PROTOCOL_MAXIMUM_MTU Then
				
				mtu = ENET_PROTOCOL_MAXIMUM_MTU
				
			Endif
		
		Endif
		
		
		currentPeer.mtu = mtu
		
		If host.outgoingBandwidth = 0 And currentPeer.incomingBandwidth = 0 Then
		
			currentPeer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
		
		Else
		
			If host.outgoingBandwidth = 0 Or currentPeer.incomingBandwidth = 0 Then
			
				currentPeer.windowSize = (ENET_MAX(host.outgoingBandwidth, currentPeer.incomingBandwidth) / ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
				
			
			Else
			
				currentPeer.windowSize = (ENET_MIN(host.outgoingBandwidth, currentPeer.incomingBandwidth) /ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
			
			Endif
		
		Endif
		
		If currentPeer.windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE Then
		
			currentPeer.windowSize = ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		
		Else
		
			If currentPeer.windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE Then
			
				currentPeer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
			
			Endif
		
		Endif
		
		
		If host.incomingBandwidth = 0 Then
		
			windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
		
		Else
			windowSize = (host.incomingBandwidth / ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		
		Endif
		
		If windowSize > p.ENET_NET_TO_HOST_32(command.connect.windowSize) Then
		
			windowSize = p.ENET_NET_TO_HOST_32(command.connect.windowSize)
		
		Endif
		
		If windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE Then
		
			windowSize = ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		
		Else
		
			If windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE Then
			
				windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
				
			Endif
		
		Endif

		verifyCommand.header = New ENetProtocolCommandHeader()
		verifyCommand.header.command = ENET_PROTOCOL_COMMAND_VERIFY_CONNECT | ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE
		verifyCommand.header.channelID = $FF
		verifyCommand.verifyConnect = New ENetProtocolVerifyConnect()
		verifyCommand.verifyConnect.outgoingPeerID = p.ENET_HOST_TO_NET_16(currentPeer.incomingPeerID)
		verifyCommand.verifyConnect.incomingSessionID = incomingSessionID
		verifyCommand.verifyConnect.outgoingSessionID = outgoingSessionID
		verifyCommand.verifyConnect.mtu = p.ENET_HOST_TO_NET_32(currentPeer.mtu)
		verifyCommand.verifyConnect.windowSize = p.ENET_HOST_TO_NET_32(windowSize)
		verifyCommand.verifyConnect.channelCount = p.ENET_HOST_TO_NET_32(channelCount)
		verifyCommand.verifyConnect.incomingBandwidth = p.ENET_HOST_TO_NET_32(host.incomingBandwidth)
		verifyCommand.verifyConnect.outgoingBandwidth = p.ENET_HOST_TO_NET_32(host.outgoingBandwidth)
		verifyCommand.verifyConnect.packetThrottleInterval = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleInterval)
		verifyCommand.verifyConnect.packetThrottleAcceleration = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleAcceleration)
		verifyCommand.verifyConnect.packetThrottleDeceleration = p.ENET_HOST_TO_NET_32(currentPeer.packetThrottleDeceleration)
		verifyCommand.verifyConnect.connectID = currentPeer.connectID		
		
		enet_peer_queue_outgoing_command(currentPeer, verifyCommand, Null, 0, 0)
		
		Return currentPeer
		
	End
	
	
	Function ToByte:Int(a:int)
	
		Return a & $FF
	
	End
	
	
	Method enet_protocol_handle_send_reliable:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol, currentData:Int[], currentDataI:Int[])
	
		Local packet:ENetPacket
		Local dataLength:Int
		
		If command.header.channelID >= peer.channelCount Or (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Then
		
			Return -1
		
		Endif
		
		dataLength = ENET_NET_TO_HOST_16(command.sendReliable.dataLength)
		
		If dataLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or currentDataI[0] < 0 Or currentDataI[0] > host.receivedDataLength Then
		
			Return -1
		
		Endif
		
		command.data = New Int[dataLength]
		
		For Local i:Int = 0 To dataLength-1
		
			command.data[i] = currentData[currentDataI[0] + i]
		
		Next
		
		currentDataI[0] = currentDataI[0]+dataLength
		
		packet = enet_packet_create(command.data,dataLength,ENetPacketFlagEnum.ENET_PACKET_FLAG_RELIABLE)
		
		If packet = Null Or enet_peer_queue_incoming_command(peer, command, packet, 0) = Null Then
		
			Return -1
		
		Endif
		
		Return 0
	
	End
	
	
	Method enet_protocol_handle_send_unsequenced:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol, currentData:Int[])
	
		return 0
	
	End
	
	Method enet_protocol_handle_send_unreliable:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol, currentData:Int[], currentDataI:Int[])
	
		Local packet:ENetPacket
		Local dataLength:Int		
	
	
		If command.header.channelID >= peer.channelCount Or (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Then
		
			Return -1
			
		Endif
		
		dataLength = p.ENET_NET_TO_HOST_16(command.sendUnreliable.dataLength)
		currentDataI[0] = currentDataI[0]+dataLength
		
		If dataLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or currentDataI[0] < 0 Or currentDataI[0] > host.receivedDataLength Then
		
			Return -1
		
		Endif
		
		
		command.data = New Int[dataLength]
		
		For Local i:Int = 0 To dataLength-1
		
			command.data[i] = currentData[currentDataI[0] - dataLength + i]
		
		
		Next
		
		packet = enet_packet_create(command.data, dataLength, 0)
		
		If packet = Null Or enet_peer_queue_incoming_command(peer, command, packet, 0) = Null Then
			Return -1
		Endif
		
		Return 0
	
	End
	
	
	Method enet_protocol_handle_send_fragment:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol, currentData:Int[], currentDataI:Int[])
	
		Local fragmentNumber:Int
		Local fragmentCount:Int
		Local fragmentOffset:Int
		Local fragmentLength:Int
		Local startSequenceNumber:Int
		Local totalLength:Int
		Local channel:ENetChannel
		Local startWindow:Int
		Local currentWindow:Int
		Local currentCommand:ENetListNode
		Local startCommand:ENetIncomingCommand = Null
		Local lastCommand:ENetIncomingCommand = Null
		
		
		If command.header.channelID >= peer.channelCount Or (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Then
			Return -1
		Endif
		
		fragmentLength = p.ENET_NET_TO_HOST_16(command.sendFragment.dataLength)
		currentDataI[0] = currentDataI[0] + fragmentLength	
		
		If fragmentLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or currentDataI[0] < 0 Or currentDataI[0] > host.receivedDataLength Then
			Return -1
		Endif
		
		channel = peer.channels[command.header.channelID]
		startSequenceNumber = p.ENET_NET_TO_HOST_16(command.sendFragment.startSequenceNumber)
		startWindow = p.IntToUshort(startSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
		currentWindow = p.IntToUshort(channel.incomingReliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
		
		If startSequenceNumber < channel.incomingReliableSequenceNumber Then
			startWindow = startWindow + ENET_PEER_RELIABLE_WINDOWS
		Endif
		
		If startWindow < currentWindow Or startWindow >= currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS - 1 Then
			Return 0
		Endif

		fragmentNumber = p.ENET_NET_TO_HOST_32(command.sendFragment.fragmentNumber)
		fragmentCount = p.ENET_NET_TO_HOST_32(command.sendFragment.fragmentCount)
		fragmentOffset = p.ENET_NET_TO_HOST_32(command.sendFragment.fragmentOffset)
		totalLength = p.ENET_NET_TO_HOST_32(command.sendFragment.totalLength)
		
		If fragmentCount > ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT Or fragmentNumber >= fragmentCount Or totalLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or fragmentOffset >= totalLength Or fragmentLength > totalLength - fragmentOffset	Then
			Return -1
		Endif
		
		currentCommand = enet_list_previous(enet_list_end(channel.incomingReliableCommands))
		lastCommand = ENetIncomingCommand(enet_list_end(channel.incomingReliableCommands))
	
		Repeat
			
			
			Local incomingCommand:ENetIncomingCommand = p.CastToENetIncomingCommand(currentCommand)
			
			If startSequenceNumber >= channel.incomingReliableSequenceNumber Then
			
				If incomingCommand.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
				
					currentCommand = enet_list_previous(currentCommand)
					Continue
				
				Endif
			
			Else
			
				If incomingCommand.reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
				
					currentCommand = enet_list_previous(currentCommand)
					Continue					
				
				Endif
			
			Endif
			
			If incomingCommand.reliableSequenceNumber <= startSequenceNumber Then
			
				If incomingCommand.reliableSequenceNumber < startSequenceNumber Then
					Exit
				Endif
			
				If (incomingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK) <> ENET_PROTOCOL_COMMAND_SEND_FRAGMENT Or totalLength <> incomingCommand.packet.dataLength Or fragmentCount <> incomingCommand.fragmentCount Then
			
					return -1
			
				Endif
				
				startCommand = incomingCommand
				Exit
			
			Endif
			
			
			currentCommand = enet_list_previous(currentCommand)
		Until currentCommand = lastCommand
	
		If startCommand = Null Then
		
			Local hostCommand:ENetProtocol = command
			Local packet:ENetPacket = enet_packet_create(New Int[0], totalLength, ENetPacketFlagEnum.ENET_PACKET_FLAG_RELIABLE)
			
			If packet = Null Then Return -1
			
			hostCommand.header.reliableSequenceNumber = p.IntToUshort(startSequenceNumber)
			
			startCommand = enet_peer_queue_incoming_command(peer, hostCommand, packet, fragmentCount)
			
			If startCommand = Null Then Return -1
		Endif
			
		If startCommand.fragments[fragmentNumber / 32] & (1 Shl (fragmentNumber Mod 32)) = 0 Then
		
			startCommand.fragmentsRemaining = startCommand.fragmentsRemaining - 1
			
			startCommand.fragments[fragmentNumber / 32] = startCommand.fragments[fragmentNumber / 32]|(1 Shl (fragmentNumber Mod 32))
			
			If fragmentOffset + fragmentLength > startCommand.packet.dataLength Then
			
				fragmentLength = startCommand.packet.dataLength - fragmentOffset
			
			Endif
			
			Local data:Int[] = New Int[128]
			
			SerializeCommand(data, command)
			
			For Local i:Int = 0 To fragmentLength-1
			
				startCommand.packet.data[i + fragmentOffset] = data[i + ENetProtocolSendFragment.SizeOf]
			
			Next
			
			If startCommand.fragmentsRemaining <= 0 Then
			
				enet_peer_dispatch_incoming_reliable_commands(peer, channel)
			
			Endif
		
		Endif
		
		Return 0
	
	
	End
	
	
	Method enet_protocol_handle_send_unreliable_fragment:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol, currentData:Int[])


		Local fragmentNumber:Int
		Local fragmentCount:Int
		Local fragmentOffset:Int
		Local fragmentLength:Int
		Local reliableSequenceNumber:Int
		Local startSequenceNumber:Int
		Local totalLength:Int
		Local channel:ENetChannel
		Local reliableWindow:Int
		Local currentWindow:Int
		Local currentCommand:ENetListNode
		Local startCommand:ENetIncomingCommand = Null
		Local lastCommand:ENetIncomingCommand = Null
		
		
		If command.header.channelID >= peer.channelCount Or (peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER) Then
		
			Return -1
		
		Endif
		
		fragmentLength = ENET_NET_TO_HOST_16(command.sendFragment.dataLength)
		Local currentDataI:Int = 0
		currentDataI = currentDataI+fragmentLength
		
		If fragmentLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or currentDataI < 0 Or currentDataI > host.receivedDataLength Then
			Return -1
		Endif
		
		channel = peer.channels[command.header.channelID]
		reliableSequenceNumber = command.header.reliableSequenceNumber
		startSequenceNumber = ENET_NET_TO_HOST_16(command.sendFragment.startSequenceNumber)
		reliableWindow = p.IntToUshort(reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
		currentWindow = p.IntToUshort(channel.incomingReliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
		
		If reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
			reliableWindow = reliableWindow+ENET_PEER_RELIABLE_WINDOWS
		Endif
		
		If reliableWindow < currentWindow Or reliableWindow >= currentWindow + ENET_PEER_FREE_RELIABLE_WINDOWS - 1 Then
			Return 0
		Endif
		
		If reliableSequenceNumber = channel.incomingReliableSequenceNumber and startSequenceNumber <= channel.incomingUnreliableSequenceNumber Then
			Return 0
		Endif
		
		fragmentNumber = ENET_NET_TO_HOST_32(command.sendFragment.fragmentNumber)
		fragmentCount = ENET_NET_TO_HOST_32(command.sendFragment.fragmentCount)
		fragmentOffset = ENET_NET_TO_HOST_32(command.sendFragment.fragmentOffset)
		totalLength = ENET_NET_TO_HOST_32(command.sendFragment.totalLength)
		
		If fragmentCount > ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT Or fragmentNumber >= fragmentCount Or totalLength > ENET_PROTOCOL_MAXIMUM_PACKET_SIZE Or fragmentOffset >= totalLength Or fragmentLength > totalLength - fragmentOffset Then
			Return -1
		Endif
		
		currentCommand = enet_list_previous(enet_list_end(channel.incomingUnreliableCommands))
		lastCommand = ENetIncomingCommand(enet_list_end(channel.incomingUnreliableCommands))
		
		Repeat
		
			Local incomingCommand:ENetIncomingCommand = p.CastToENetIncomingCommand(currentCommand)
		
			If reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
			
				If incomingCommand.reliableSequenceNumber < channel.incomingReliableSequenceNumber Then
					
					currentCommand = enet_list_previous(currentCommand)
					Continue
					
				Endif
			
			Else
				If incomingCommand.reliableSequenceNumber >= channel.incomingReliableSequenceNumber Then
				
					Exit
				
				Endif
			Endif
			
			If incomingCommand.reliableSequenceNumber < reliableSequenceNumber Then
			
				Exit
			
			Endif
			
			If incomingCommand.reliableSequenceNumber > reliableSequenceNumber Then
			
				currentCommand = enet_list_previous(currentCommand)
				Continue
			
			Endif
			
			If incomingCommand.unreliableSequenceNumber <= startSequenceNumber Then
			
				If incomingCommand.unreliableSequenceNumber < startSequenceNumber Then
					
					Exit
				
				Endif
				
				If (incomingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK) <> ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT Or totalLength <> incomingCommand.packet.dataLength Or fragmentCount <> incomingCommand.fragmentCount Then
					
					Return -1
				
				Endif
			
				startCommand = incomingCommand
				Exit
			
			Endif
		
			currentCommand = enet_list_previous(currentCommand)
		Until currentCommand = lastCommand
		
		If startCommand = Null Then
		
		
			Local packet:ENetPacket = enet_packet_create(New Int[0], totalLength, ENetPacketFlagEnum.ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT)
			
			If packet = Null Then Return -1
			
			startCommand = enet_peer_queue_incoming_command(peer, command, packet, fragmentCount)
			
			If startCommand = Null Then Return -1
		
		Endif
		
		If (startCommand.fragments[fragmentNumber / 32] & (1 shl (fragmentNumber mod 32))) = 0 Then
			
			startCommand.fragmentsRemaining=startCommand.fragmentsRemaining-1
			
			startCommand.fragments[fragmentNumber / 32] = startCommand.fragments[fragmentNumber / 32]|(1 Shl (fragmentNumber Mod 32))
			
			If fragmentOffset + fragmentLength > startCommand.packet.dataLength Then
			
				fragmentLength = startCommand.packet.dataLength - fragmentOffset
			
			Endif
			
			For Local i:Int = 0 To fragmentLength-1
			
				startCommand.packet.data[fragmentOffset + i] = command.data[i]
			
			
			Next
			
			If startCommand.fragmentsRemaining <= 0 Then
				enet_peer_dispatch_incoming_unreliable_commands(peer, channel)
			Endif
			
			
		
		Endif
		
		Return 0

	End	
	
	
	Method enet_protocol_handle_ping:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol)
	
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
		
			Return -1
		
		Endif
		
		Return 0
	
	
	End
	
	
	Method enet_protocol_handle_bandwidth_limit:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol)
	
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
			Return -1
		Endif
		
		If peer.incomingBandwidth <> 0 Then
		
			host.bandwidthLimitedPeers = host.bandwidthLimitedPeers -1
		
		Endif
		
		peer.incomingBandwidth = p.ENET_NET_TO_HOST_32(command.bandwidthLimit.incomingBandwidth)
		peer.outgoingBandwidth = p.ENET_NET_TO_HOST_32(command.bandwidthLimit.outgoingBandwidth)
		
		If peer.incomingBandwidth <> 0 Then
		
			host.bandwidthLimitedPeers = host.bandwidthLimitedPeers + 1 
		
		Endif
		
		If peer.incomingBandwidth = 0 And host.outgoingBandwidth = 0 Then
		
			peer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
		
		Else
		
			peer.windowSize = (ENET_MIN(peer.incomingBandwidth, host.outgoingBandwidth) / ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		
		Endif
		
		If peer.windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE Then
			peer.windowSize = ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		Else
		
			If peer.windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE Then
				peer.windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
			Endif
		
		Endif
	
		Return 0
	
	End
	
	
	Method enet_protocol_handle_throttle_configure:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol)
	
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then Return -1
	
		peer.packetThrottleInterval = p.ENET_NET_TO_HOST_32(command.throttleConfigure.packetThrottleInterval)
		peer.packetThrottleAcceleration = p.ENET_NET_TO_HOST_32(command.throttleConfigure.packetThrottleAcceleration)
		peer.packetThrottleDeceleration = p.ENET_NET_TO_HOST_32(command.throttleConfigure.packetThrottleDeceleration)
		
		Return 0
	
	
	End
	
	
	Method enet_protocol_handle_disconnect:Int(host:ENetHost, peer:ENetPeer, command:ENetProtocol)
	
		If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED or peer.state = ENetPeerState.ENET_PEER_STATE_ZOMBIE or peer.state = ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT Then
		
			Return 0
		
		Endif
		
		enet_peer_reset_queues(peer)
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTION_SUCCEEDED or peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTING Then
		
			enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_ZOMBIE)
		
		Else
			If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTED And peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER Then
			
				If peer.state = ENetPeerState.ENET_PEER_STATE_CONNECTION_PENDING Then host.recalculateBandwidthLimits = 1
				
				enet_peer_reset(peer)
			
			Else
			
				If (command.header.command & ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE) <> 0 Then
				
					enet_protocol_change_state(host, peer, ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT)
					
				Else
				
					enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_ZOMBIE)
				
				Endif
			
			Endif
		
		Endif
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_DISCONNECTED Then
			
			peer.eventData = p.ENET_NET_TO_HOST_32(command.disconnect.data)
		
		Endif
		
		Return 0
	
	
	End
	
	
	Method enet_protocol_handle_acknowledge:int(host:ENetHost, event_:ENetEvent, peer:ENetPeer, command:ENetProtocol)
	
		Local roundTripTime:Int
		Local receivedSentTime:Int
		Local receivedReliableSequenceNumber:Int
		Local commandNumber:Int
		
		If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED or peer.state = ENetPeerState.ENET_PEER_STATE_ZOMBIE Then Return 0
	
		receivedSentTime = p.ENET_NET_TO_HOST_16(command.acknowledge.receivedSentTime)
		receivedSentTime = receivedSentTime|host.serviceTime & -65536
		If (receivedSentTime & $8000) > (host.serviceTime & $8000) Then
			receivedSentTime = receivedSentTime-$10000
		Endif
		
		If ENET_TIME_LESS(host.serviceTime, receivedSentTime) Then Return 0
		
		peer.lastReceiveTime = host.serviceTime
		peer.earliestTimeout = 0
		
		roundTripTime = ENET_TIME_DIFFERENCE(host.serviceTime, receivedSentTime)
		enet_peer_throttle(peer, roundTripTime)
		
		peer.roundTripTimeVariance = peer.roundTripTimeVariance-(peer.roundTripTimeVariance / 4)
		
		If roundTripTime >= peer.roundTripTime Then
		
			peer.roundTripTime = peer.roundTripTime+(roundTripTime - peer.roundTripTime) / 8
			peer.roundTripTimeVariance = peer.roundTripTimeVariance + (roundTripTime - peer.roundTripTime) / 4
			
		
		Else
		
			peer.roundTripTime = peer.roundTripTime-(peer.roundTripTime - roundTripTime) / 8
			peer.roundTripTimeVariance = peer.roundTripTimeVariance+(peer.roundTripTime - roundTripTime) / 4;
		
		Endif
		
		If peer.roundTripTime < peer.lowestRoundTripTime Then
			peer.lowestRoundTripTime = peer.roundTripTime
		Endif
		
		If peer.roundTripTimeVariance > peer.highestRoundTripTimeVariance Then
			peer.highestRoundTripTimeVariance = peer.roundTripTimeVariance
		Endif
		
		If peer.packetThrottleEpoch = 0 or ENET_TIME_DIFFERENCE(host.serviceTime, peer.packetThrottleEpoch) >= peer.packetThrottleInterval Then
		
			peer.lastRoundTripTime = peer.lowestRoundTripTime
			peer.lastRoundTripTimeVariance = peer.highestRoundTripTimeVariance
			peer.lowestRoundTripTime = peer.roundTripTime
			peer.highestRoundTripTimeVariance = peer.roundTripTimeVariance
			peer.packetThrottleEpoch = host.serviceTime			
		
		Endif
		
		receivedReliableSequenceNumber = p.ENET_NET_TO_HOST_16(command.acknowledge.receivedReliableSequenceNumber)
		
		commandNumber = enet_protocol_remove_sent_reliable_command(peer, p.IntToUshort(receivedReliableSequenceNumber), command.header.channelID)
		
		Select peer.state
		
			Case ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_CONNECT
				If commandNumber <> ENET_PROTOCOL_COMMAND_VERIFY_CONNECT Then
					return -1
				Endif
				
				enet_protocol_notify_connect(host, peer, event_)
				
			Case ENetPeerState.ENET_PEER_STATE_DISCONNECTING
				If commandNumber <> ENET_PROTOCOL_COMMAND_DISCONNECT Then
					Return -1
				Endif
				
				enet_protocol_notify_disconnect(host, peer, event_)
				
			Case ENetPeerState.ENET_PEER_STATE_DISCONNECT_LATER
				If enet_list_empty(peer.outgoingReliableCommands) And enet_list_empty(peer.outgoingUnreliableCommands) And enet_list_empty(peer.sentReliableCommands) Then
					enet_peer_disconnect(peer, peer.eventData)
				Endif
		
		
		End Select
		
		return 0
	
	End
	
	Method enet_protocol_handle_verify_connect:Int(host:ENetHost, event_:ENetEvent, peer:ENetPeer, command:ENetProtocol)
	
		Local mtu:Int
		Local windowSize:Int
		Local channelCount:Int
		
		If peer.state <> ENetPeerState.ENET_PEER_STATE_CONNECTING Then
			Return 0
		Endif
		
		channelCount = p.ENET_NET_TO_HOST_32(command.verifyConnect.channelCount)
		
		If channelCount < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT Or channelCount > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT Or p.ENET_NET_TO_HOST_32(command.verifyConnect.packetThrottleInterval) <> peer.packetThrottleInterval Or p.ENET_NET_TO_HOST_32(command.verifyConnect.packetThrottleAcceleration) <> peer.packetThrottleAcceleration Or p.ENET_NET_TO_HOST_32(command.verifyConnect.packetThrottleDeceleration) <> peer.packetThrottleDeceleration Or command.verifyConnect.connectID <> peer.connectID Then
			
			peer.eventData = 0
			enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_ZOMBIE)
			return -1
			
		Endif
		
		enet_protocol_remove_sent_reliable_command(peer, 1, $FF)
		
		If channelCount < peer.channelCount Then
			peer.channelCount = channelCount
		Endif
		
		peer.outgoingPeerID = p.ENET_NET_TO_HOST_16(command.verifyConnect.outgoingPeerID)
		peer.incomingSessionID = command.verifyConnect.incomingSessionID
		peer.outgoingSessionID = command.verifyConnect.outgoingSessionID
		
		mtu = p.ENET_NET_TO_HOST_32(command.verifyConnect.mtu)
		
		If mtu < ENET_PROTOCOL_MINIMUM_MTU Then
		
			mtu = ENET_PROTOCOL_MINIMUM_MTU
		
		Else
		
			If mtu > ENET_PROTOCOL_MAXIMUM_MTU Then
			
				mtu = ENET_PROTOCOL_MAXIMUM_MTU
			
			Endif
		
		Endif
		
		If mtu < peer.mtu Then
		
			peer.mtu = mtu
		
		Endif
		
		windowSize = p.ENET_NET_TO_HOST_32(command.verifyConnect.windowSize)
		
		If windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE Then windowSize = ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
		If windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE Then windowSize = ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
		If windowSize < peer.windowSize Then peer.windowSize = windowSize
		
		peer.incomingBandwidth = p.ENET_NET_TO_HOST_32(command.verifyConnect.incomingBandwidth)
		peer.outgoingBandwidth = p.ENET_NET_TO_HOST_32(command.verifyConnect.outgoingBandwidth)
		
		enet_protocol_notify_connect(host, peer, event_)
		
		return 0
		
		
		
	
	End
	
	
	Method enet_protocol_handle_incoming_commands:Int(host:ENetHost, event_:ENetEvent)
	
		Local header:ENetProtocolHeader
		Local command:ENetProtocol = Null
		Local peer:ENetPeer
		Local currentData:Int[]
		Local headerSize:Int = 0
		Local peerID:Int
		Local flags:Int
		Local sessionID:Int
		
		Local currentDataI:Int[] = New Int[1]
		currentDataI[0] = 0	
		
		header = Deserialize(host.receivedData)
		
		peerID = ENET_NET_TO_HOST_16(header.peerID)
		sessionID = (peerID & ENET_PROTOCOL_HEADER_SESSION_MASK) Shr ENET_PROTOCOL_HEADER_SESSION_SHIFT
		flags = p.IntToUshort(peerID & ENET_PROTOCOL_HEADER_FLAG_MASK)
		peerID = peerID&p.IntToUshort(~(ENET_PROTOCOL_HEADER_FLAG_MASK | ENET_PROTOCOL_HEADER_SESSION_MASK))
		
		If (flags & ENET_PROTOCOL_HEADER_FLAG_SENT_TIME) <> 0 Then
			headerSize = ENetProtocolHeader.SizeOf
		Else
			headerSize = 2
		Endif
	
		If host.checksum <> Null Then
			headerSize = headerSize + 4
		Endif
	
		If peerID = ENET_PROTOCOL_MAXIMUM_PEER_ID Then
			peer = null
		Else
			If peerID >= host.peerCount Then
				Return 0
			
			Else
				peer = host.peers[peerID]
				If peer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Or peer.state = ENetPeerState.ENET_PEER_STATE_ZOMBIE Or ((host.receivedAddress.host <> peer.address.host Or host.receivedAddress.port <> peer.address.port) And peer.address.host <> ENET_HOST_BROADCAST) Or (peer.outgoingPeerID < ENET_PROTOCOL_MAXIMUM_PEER_ID And sessionID <> peer.incomingSessionID) Then
					Return 0
				Endif
					
			Endif
		
		Endif
		
		If (flags & ENET_PROTOCOL_HEADER_FLAG_COMPRESSED) <> 0 Then
		
			Local originalSize:Int = 0
			If host.compressor = Null Then Return 0
			
			'For Local i:Int = 0 To headerSize-1
			
				'host.packetData[1][i]=header[i];	
			
			'Next
		
			host.receivedData = host.packetData[1]
			host.receivedDataLength = headerSize + originalSize
		
		Endif
		
		If host.checksum <> Null Then
		
			Local checksum:Int = 0
			Local desiredChecksum:Int = checksum 'who wrote the original?
			Local buffer:ENetBuffer = New ENetBuffer()
			
			If peer <> Null Then
				checksum = peer.connectID
			Else
				checksum = 0
			Endif
			
			buffer.Data = host.receivedData
			buffer.DataLength = host.receivedDataLength
			
			If host.checksum.Run(buffer, 1) <> desiredChecksum Then
				return 0
			Endif
			
			
		
		Endif
		
		If peer <> Null Then
		
			peer.address.host = host.receivedAddress.host
			peer.address.port = host.receivedAddress.port
			peer.incomingDataTotal += host.receivedDataLength
			
		
		
		Endif
		
		currentDataI[0] = currentDataI[0] + headerSize
		Local test:Int = 0
		
		While currentDataI[0] < host.receivedDataLength
		
			Local commandNumber:Int
			Local commandSize:Int
			
			test=test+1
			
			If currentDataI[0] + ENetProtocolCommandHeader.SizeOf > host.receivedDataLength Then Exit
			
			command = DeserializeProtocolCommandHeader(host.receivedData, currentDataI[0])
			commandNumber = ToByte(command.header.command & ENET_PROTOCOL_COMMAND_MASK)
			
			If commandNumber >= ENET_PROTOCOL_COMMAND_COUNT Then Exit
			
			commandSize = commandSizes[commandNumber]
			
			If commandSize = 0 Or currentDataI[0] + commandSize > host.receivedDataLength Then Exit
			
			DeserializeProtocolCommandCommand(host.receivedData, currentDataI[0], commandNumber, command)
			currentDataI[0] = currentDataI[0] + commandSize
			
			If peer <> Null And commandNumber <> ENET_PROTOCOL_COMMAND_CONNECT Then Exit
			
			If command.header.reliableSequenceNumber = 1 Then test1=test1+1
			
			Select commandNumber
			
				Case ENET_PROTOCOL_COMMAND_ACKNOWLEDGE
					If enet_protocol_handle_acknowledge(host, event_, peer, command) <> 0 Then
						Return commandError(event_)
					Endif
					
				Case ENET_PROTOCOL_COMMAND_CONNECT
					If peer <> Null Then Return commandError(event_)
					peer = enet_protocol_handle_connect(host, header, command)
					If peer = Null Then Return commandError(event_)
				
				Case ENET_PROTOCOL_COMMAND_VERIFY_CONNECT
					If enet_protocol_handle_verify_connect(host, event_, peer, command) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_DISCONNECT
					If enet_protocol_handle_disconnect(host, peer, command) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_PING
					If enet_protocol_handle_ping(host, peer, command) <> 0 Then commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_SEND_RELIABLE
					If enet_protocol_handle_send_reliable(host, peer, command, host.receivedData, currentDataI) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
					If enet_protocol_handle_send_unreliable(host, peer, command, host.receivedData, currentDataI) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
					If enet_protocol_handle_send_unsequenced(host, peer, command, currentData) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_SEND_FRAGMENT
					If enet_protocol_handle_send_fragment(host, peer, command, host.receivedData, currentDataI) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT
					If enet_protocol_handle_bandwidth_limit(host, peer, command) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE
					If enet_protocol_handle_throttle_configure(host, peer, command) <> 0 Then Return commandError(event_)
					
				Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
					If enet_protocol_handle_send_unreliable_fragment(host, peer, command, currentData) <> 0 Then Return commandError(event_)
					
				Default
					return commandError(event_)
			
			
			End Select
			
			If peer <> Null And (command.header.command & ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE) <> 0 Then
				
				Local sentTime:Int
				If (flags & ENET_PROTOCOL_HEADER_FLAG_SENT_TIME) = 0 Then
				
					exit
				
				Endif
				
				sentTime = ENET_NET_TO_HOST_16(header.sentTime)
				
				Select peer.state
				
					Case ENetPeerState.ENET_PEER_STATE_DISCONNECTING,ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_CONNECT,ENetPeerState.ENET_PEER_STATE_DISCONNECTED,ENetPeerState.ENET_PEER_STATE_ZOMBIE
						Print "diconnected"
						
						
					Case ENetPeerState.ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT
						If (command.header.command & ENET_PROTOCOL_COMMAND_MASK) = ENET_PROTOCOL_COMMAND_DISCONNECT Then
							enet_peer_queue_acknowledgement(peer, command, sentTime)
						Endif
						
					Default
						enet_peer_queue_acknowledgement(peer, command, sentTime)
					
				
				End Select
				
			Endif
			
		
		Wend
		
		If event_ <> Null And event_.type <> ENetEventType.ENET_EVENT_TYPE_NONE Then
			Return 1
		Endif
		
		
		Return 0
	
	End
	
	Method DeserializeProtocolCommandCommand:Void(readBuf:Int[],currentDataI:Int, commandNumber:Int, command:ENetProtocol)
	
		Local pos:Int = currentDataI + ENetProtocolCommandHeader.SizeOf
		Local buffer:DataBuffer = New DataBuffer(readBuf.Length())
		buffer.PokeBytes( 0, readBuf, 0, readBuf.Length() )
		Local dataStream:DataStream = New DataStream(buffer)
		dataStream.Seek(pos)
		
		Select commandNumber
		
			Case ENET_PROTOCOL_COMMAND_ACKNOWLEDGE
				command.acknowledge = New ENetProtocolAcknowledge()
				command.acknowledge.receivedReliableSequenceNumber = dataStream.ReadShort()
				
				
			Case ENET_PROTOCOL_COMMAND_CONNECT
				command.connect = new ENetProtocolConnect()
				command.connect.outgoingPeerID = dataStream.ReadShort()
				command.connect.incomingSessionID = dataStream.ReadByte()
				command.connect.outgoingSessionID = dataStream.ReadByte()
				command.connect.mtu = dataStream.ReadInt()
				command.connect.windowSize = dataStream.ReadInt()
				command.connect.channelCount = dataStream.ReadInt()
				command.connect.incomingBandwidth = dataStream.ReadInt()
				command.connect.outgoingBandwidth = dataStream.ReadInt()
				command.connect.packetThrottleInterval = dataStream.ReadInt()
				command.connect.packetThrottleAcceleration = dataStream.ReadInt()
				command.connect.packetThrottleDeceleration = dataStream.ReadInt()
				command.connect.connectID = dataStream.ReadInt()
				command.connect.data = dataStream.ReadInt()		
				
			Case ENET_PROTOCOL_COMMAND_VERIFY_CONNECT
				command.verifyConnect = new ENetProtocolVerifyConnect()
				command.verifyConnect.outgoingPeerID = dataStream.ReadShort()
				command.verifyConnect.incomingSessionID = dataStream.ReadByte()
				command.verifyConnect.outgoingSessionID = dataStream.ReadByte()
				command.verifyConnect.mtu = dataStream.ReadInt()
				command.verifyConnect.windowSize = dataStream.ReadInt()
				command.verifyConnect.channelCount = dataStream.ReadInt()
				command.verifyConnect.incomingBandwidth = dataStream.ReadInt()
				command.verifyConnect.outgoingBandwidth = dataStream.ReadInt()
				command.verifyConnect.packetThrottleInterval = dataStream.ReadInt()
				command.verifyConnect.packetThrottleAcceleration = dataStream.ReadInt()
				command.verifyConnect.packetThrottleDeceleration = dataStream.ReadInt()
				command.verifyConnect.connectID = dataStream.ReadInt()
				
			Case ENET_PROTOCOL_COMMAND_DISCONNECT
				command.disconnect = New ENetProtocolDisconnect()
				command.disconnect.data = dataStream.ReadInt()
				
			Case ENET_PROTOCOL_COMMAND_PING
				command.ping = New ENetProtocolPing()
			
			Case ENET_PROTOCOL_COMMAND_SEND_RELIABLE
				command.sendReliable = New ENetProtocolSendReliable()
				command.sendReliable.dataLength = dataStream.ReadShort()
			
			Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
				command.sendUnreliable = New ENetProtocolSendUnreliable()
				command.sendUnreliable.unreliableSequenceNumber = dataStream.ReadShort()
				command.sendUnreliable.dataLength = dataStream.ReadShort()
				
			Case ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
				command.sendUnsequenced = New ENetProtocolSendUnsequenced()
				command.sendUnsequenced.unsequencedGroup = dataStream.ReadShort()
				command.sendUnsequenced.dataLength = dataStream.ReadShort()
			
			Case ENET_PROTOCOL_COMMAND_SEND_FRAGMENT
				command.sendFragment = new ENetProtocolSendFragment()
				command.sendFragment.startSequenceNumber = dataStream.ReadShort() 
				command.sendFragment.dataLength = dataStream.ReadShort() 
				command.sendFragment.fragmentCount = dataStream.ReadInt() 
				command.sendFragment.fragmentNumber = dataStream.ReadInt() 
				command.sendFragment.totalLength = dataStream.ReadInt() 
				command.sendFragment.fragmentOffset = dataStream.ReadInt()
				
			Case ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT
				command.bandwidthLimit = New ENetProtocolBandwidthLimit()
				command.bandwidthLimit.incomingBandwidth = dataStream.ReadInt()
				command.bandwidthLimit.outgoingBandwidth = dataStream.ReadInt()
				
			Case ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE
				command.throttleConfigure = New ENetProtocolThrottleConfigure()
				command.throttleConfigure.packetThrottleInterval = dataStream.ReadInt()
				command.throttleConfigure.packetThrottleAcceleration = dataStream.ReadInt()
				command.throttleConfigure.packetThrottleDeceleration = dataStream.ReadInt()
				
			Case ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
				command.sendFragment = new ENetProtocolSendFragment()
				command.sendFragment.startSequenceNumber = dataStream.ReadShort() 
				command.sendFragment.dataLength = dataStream.ReadShort() 
				command.sendFragment.fragmentCount = dataStream.ReadInt() 
				command.sendFragment.fragmentNumber = dataStream.ReadInt() 
				command.sendFragment.totalLength = dataStream.ReadInt() 
				command.sendFragment.fragmentOffset = dataStream.ReadInt() 				
												
				
		
		End Select
	
		dataStream.Close()
		buffer.Discard()
	
	
	End
	
	
	Method DeserializeProtocolCommandHeader:ENetProtocol(currentData:Int[],currentDataI:Int)
	
		Local pos:Int = currentDataI
		Local a:ENetProtocol = New ENetProtocol()
		Local buffer:DataBuffer = New DataBuffer(currentData.Length())
		buffer.PokeBytes( 0, currentData, 0, currentData.Length() )
		Local dataStream:DataStream = New DataStream(buffer)
		dataStream.Seek(pos)
		
				
		a.header = New ENetProtocolCommandHeader()
		a.header.command = dataStream.ReadByte()
		a.header.channelID = dataStream.ReadByte()
		a.header.reliableSequenceNumber = dataStream.ReadShort()
		dataStream.Close()
		buffer.Discard()
		
		Return a
			
	End
	
	Method SerializeCommand:Void(buf:Int[], a:ENetProtocol)
	
		If a = Null Then a = New ENetProtocol()
		Local buffer:DataBuffer = New DataBuffer(buf.Length())
		Local dataStream:DataStream = New DataStream(buffer)
		
		dataStream.WriteByte(a.header.command)
		dataStream.WriteByte(a.header.channelID)
		dataStream.WriteShort(a.header.reliableSequenceNumber)
		
		
		Select a.header.command & ENET_PROTOCOL_COMMAND_MASK
		
		
			Case ENet.ENET_PROTOCOL_COMMAND_ACKNOWLEDGE
				dataStream.WriteShort(a.acknowledge.receivedReliableSequenceNumber)
				dataStream.WriteShort(a.acknowledge.receivedSentTime)
			
			Case ENet.ENET_PROTOCOL_COMMAND_CONNECT
				dataStream.WriteShort(a.connect.outgoingPeerID)
				dataStream.WriteByte(a.connect.incomingSessionID)
				dataStream.WriteByte(a.connect.outgoingSessionID)
				dataStream.WriteInt(a.connect.mtu)
				dataStream.WriteInt(a.connect.windowSize)
				dataStream.WriteInt(a.connect.channelCount)
				dataStream.WriteInt(a.connect.incomingBandwidth)
				dataStream.WriteInt(a.connect.outgoingBandwidth)
				dataStream.WriteInt(a.connect.packetThrottleInterval)
				dataStream.WriteInt(a.connect.packetThrottleAcceleration)
				dataStream.WriteInt(a.connect.packetThrottleDeceleration)
				dataStream.WriteInt(a.connect.connectID)
				dataStream.WriteInt(a.connect.data) 
				
			Case ENet.ENET_PROTOCOL_COMMAND_VERIFY_CONNECT
				dataStream.WriteInt(a.connect.outgoingPeerID)
				dataStream.WriteByte(a.connect.incomingSessionID)
				dataStream.WriteByte(a.connect.outgoingSessionID)
				dataStream.WriteInt(a.connect.mtu)
				dataStream.WriteInt(a.connect.windowSize)
				dataStream.WriteInt(a.connect.channelCount)
				dataStream.WriteInt(a.connect.incomingBandwidth)
				dataStream.WriteInt(a.connect.outgoingBandwidth)
				dataStream.WriteInt(a.connect.packetThrottleInterval)
				dataStream.WriteInt(a.connect.packetThrottleAcceleration)
				dataStream.WriteInt(a.connect.packetThrottleDeceleration)
				dataStream.WriteInt(a.connect.connectID)
				
			Case ENet.ENET_PROTOCOL_COMMAND_DISCONNECT
				dataStream.WriteInt(a.disconnect.data)
				
			Case ENet.ENET_PROTOCOL_COMMAND_PING
				Print "PING"
			
			Case ENet.ENET_PROTOCOL_COMMAND_SEND_RELIABLE
				dataStream.WriteShort(a.sendReliable.dataLength)	
			
			Case ENet.ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
				dataStream.WriteShort(a.sendUnreliable.unreliableSequenceNumber)	
				dataStream.WriteShort(a.sendUnreliable.dataLength)		
				
			Case ENet.ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,ENet.ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
				dataStream.WriteShort(a.sendFragment.startSequenceNumber)
				dataStream.WriteShort(a.sendFragment.dataLength)
				dataStream.WriteInt(a.sendFragment.fragmentCount)
				dataStream.WriteInt(a.sendFragment.fragmentNumber)
				dataStream.WriteInt(a.sendFragment.totalLength)
				dataStream.WriteInt(a.sendFragment.fragmentOffset)	
				
			Case ENet.ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
				dataStream.WriteShort(a.sendUnsequenced.unsequencedGroup)
				dataStream.WriteShort(a.sendUnsequenced.dataLength)

			Case ENet.ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT
				dataStream.WriteInt(a.bandwidthLimit.incomingBandwidth)
				dataStream.WriteInt(a.bandwidthLimit.outgoingBandwidth)
				
			Case ENet.ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE
				dataStream.WriteInt(a.throttleConfigure.packetThrottleInterval)	
				dataStream.WriteInt(a.throttleConfigure.packetThrottleAcceleration)
				dataStream.WriteInt(a.throttleConfigure.packetThrottleDeceleration)		
		
		
		End Select
		
		
		'return data to original array
		buffer = dataStream.Data()
		For Local i:Int = 0 To buf.Length()-1
			
			buf[i] = buffer.PeekByte(i)
		
		Next
		
		dataStream.Close()
		buffer.Discard()		
	
	
	End
	
	Method commandError:Int(event_:ENetEvent)
	
		If event_ <> Null And event_.type <> ENetEventType.ENET_EVENT_TYPE_NONE Then Return 1
		
		Return 0
	
	End
	
	
	Method Deserialize:ENetProtocolHeader(a:Int[])
	
		Local h:ENetProtocolHeader = New ENetProtocolHeader()
		Local buffer:DataBuffer = New DataBuffer(a.Length())
		buffer.PokeBytes( 0, a, 0, a.Length() )
		Local dataStream:DataStream = New DataStream(buffer)
		
		
		h.peerID = dataStream.ReadShort()
		h.sentTime = dataStream.ReadShort()
		
		dataStream.Close()
		buffer.Discard()
		
		Return h
			
	End
	
	Method enet_protocol_receive_incoming_commands:Int(host:ENetHost, event_:ENetEvent)
	
		Repeat
			
			Local receivedLength:Int
			Local buffer:ENetBuffer = New ENetBuffer()
			buffer.Data = host.packetData[0]
			'no need to set length it is transfered with data array
			'buffer.SetLength(ENetHost.packetDataSizeOf)
			Local buffers:ENetBuffer[] = New ENetBuffer[1]
			buffers[0] = buffer
			receivedLength = p.enet_socket_receive(host.socket, host.receivedAddress, buffers,1)
			
			If receivedLength < 0 Then Return -1
			If receivedLength = 0 Then Return 0
			
			host.receivedData = host.packetData[0]
			host.receivedDataLength = receivedLength
			
			host.totalReceivedData = host.totalReceivedData + receivedLength
			
			host.totalReceivedPackets = host.totalReceivedPackets + 1
			
			If host.intercept <> Null Then
			
				Select host.intercept.Run(host, event_)
				
					Case 1
						If event_ <> Null And event_.type <> ENetEventType.ENET_EVENT_TYPE_NONE Then Return 1
						Continue
					
					Case -1
						Return -1
						
					Default
						'nothing	
					
				
				End Select
			
			
			Endif
			
			Select enet_protocol_handle_incoming_commands(host, event_)
				
				Case 1
					Return 1
					
				Case -1
					Return -1
					
				Default
					'nothing
					
			End Select
		
		Forever
		
		Return -1
	
	End
	
	
	Method enet_protocol_send_acknowledgements:Void(host:ENetHost, peer:ENetPeer)
	
		Local commandI:Int = host.commandCount
		Local bufferI:Int = host.bufferCount
		Local acknowledgement:ENetAcknowledgement
		local currentAcknowledgement:ENetListNode
		Local reliableSequenceNumber:Int
		
		currentAcknowledgement = enet_list_begin(peer.acknowledgements)
		
		While currentAcknowledgement <> enet_list_end(peer.acknowledgements)
		
			If commandI >= ENetHost.commandsMaxCount Or bufferI >= ENetHost.buffersMaxCount Or peer.mtu - host.packetSize < ENetProtocolAcknowledge.SizeOf Then
			
				host.continueSending = 1
				Exit
			
			Endif
			
			acknowledgement = p.CastToENetAcknowledgement(currentAcknowledgement)
			currentAcknowledgement = enet_list_next(currentAcknowledgement)
			reliableSequenceNumber = ENET_HOST_TO_NET_16(acknowledgement.command.header.reliableSequenceNumber)
			
			host.commands[commandI].header.command = ENET_PROTOCOL_COMMAND_ACKNOWLEDGE
			host.commands[commandI].header.channelID = acknowledgement.command.header.channelID
			host.commands[commandI].header.reliableSequenceNumber = reliableSequenceNumber
			host.commands[commandI].acknowledge = new ENetProtocolAcknowledge()
			host.commands[commandI].acknowledge.receivedReliableSequenceNumber = reliableSequenceNumber
			host.commands[commandI].acknowledge.receivedSentTime = ENET_HOST_TO_NET_16(p.IntToUshort(acknowledgement.sentTime))	
			
			Local buf:Int[] = New Int[128]
			SerializeCommand(buf, host.commands[commandI])
			host.buffers[bufferI].Data = buf
			host.buffers[bufferI].DataLength = ENetProtocolAcknowledge.SizeOf
			host.packetSize = host.packetSize+host.buffers[bufferI].dataLength()
			
			If (acknowledgement.command.header.command & ENET_PROTOCOL_COMMAND_MASK) = ENET_PROTOCOL_COMMAND_DISCONNECT Then
			
				enet_protocol_dispatch_state(host, peer, ENetPeerState.ENET_PEER_STATE_ZOMBIE)
			
			Endif
			
			enet_list_remove(acknowledgement.acknowledgementList())
			
            commandI=commandI+1
            bufferI=bufferI+1			
		
		Wend		
		host.commandCount = commandI
		host.bufferCount = bufferI
	
	End
	
	
	Method enet_protocol_send_unreliable_outgoing_commands:Void(host:ENetHost, peer:ENetPeer)
	
		'TODO
	
	End
	
	Method enet_protocol_check_timeouts:Int(host:ENetHost, peer:ENetPeer, event_:ENetEvent)
	
		Local outgoingCommand:ENetOutgoingCommand = Null
		Local currentCommand:ENetListNode 
		Local insertPosition:ENetListNode	
		
		currentCommand = enet_list_begin(peer.sentReliableCommands)
		insertPosition = enet_list_begin(peer.outgoingReliableCommands)
		
		While currentCommand <> enet_list_end(peer.sentReliableCommands)
		
		
			outgoingCommand = p.CastToENetOutgoingCommand(currentCommand)
			currentCommand = enet_list_next(currentCommand)
			
			If ENET_TIME_DIFFERENCE(host.serviceTime, outgoingCommand.sentTime) < outgoingCommand.roundTripTimeout Then
				Continue
			Endif
			
			If peer.earliestTimeout = 0 Or ENET_TIME_LESS(outgoingCommand.sentTime, peer.earliestTimeout) Then
			
				peer.earliestTimeout = outgoingCommand.sentTime
			
			Endif
			
			If peer.earliestTimeout <> 0 And (ENET_TIME_DIFFERENCE(host.serviceTime, peer.earliestTimeout) >= peer.timeoutMaximum Or (outgoingCommand.roundTripTimeout >= outgoingCommand.roundTripTimeoutLimit And ENET_TIME_DIFFERENCE(host.serviceTime, peer.earliestTimeout) >= peer.timeoutMinimum)) Then
			
				enet_protocol_notify_disconnect(host, peer, event_)
				Return 1
			
			Endif
			
			If outgoingCommand.packet <> Null Then 
				
				peer.reliableDataInTransit = peer.reliableDataInTransit-outgoingCommand.fragmentLength
				
			Endif
		
			peer.packetsLost = peer.packetsLost - 1
			
			outgoingCommand.roundTripTimeout = outgoingCommand.roundTripTimeout * 2
			
			enet_list_insert(insertPosition, enet_list_remove(outgoingCommand.outgoingCommandList()))
			
			If currentCommand = enet_list_begin(peer.sentReliableCommands) And Not enet_list_empty(peer.sentReliableCommands) Then
			
				outgoingCommand = p.CastToENetOutgoingCommand(currentCommand)
				peer.nextTimeout = outgoingCommand.sentTime + outgoingCommand.roundTripTimeout
			
			Endif
		
		Wend
	
		Return 0
	
	End
	
	
	
	Method enet_protocol_send_reliable_outgoing_commands:Int(host:ENetHost, peer:ENetPeer)
	
	
		Local commandI:Int = host.commandCount
		Local bufferI:Int = host.bufferCount
		Local outgoingCommand:ENetOutgoingCommand 
		Local currentCommand:ENetListNode
		Local channel:ENetChannel
		Local reliableWindow:Int
		Local commandSize:Int
		Local windowExceeded:Int = 0
		Local windowWrap:Int = 0
		Local canPing:Int = 1		
	
	
		 currentCommand = enet_list_begin(peer.outgoingReliableCommands)
		 
		 While currentCommand <> enet_list_end(peer.outgoingReliableCommands)
		 
		 
		 	outgoingCommand = p.CastToENetOutgoingCommand(currentCommand)
		 	
		 	If outgoingCommand.command.header.channelID < peer.channelCount Then
		 		channel = peer.channels[outgoingCommand.command.header.channelID]
		 	Else
		 		channel = Null
		 	Endif
		 	
		 	reliableWindow = p.IntToUshort(outgoingCommand.reliableSequenceNumber / ENET_PEER_RELIABLE_WINDOW_SIZE)
		 	
		 	If channel <> Null Then
		 	
				If (windowWrap = 0) And outgoingCommand.sendAttempts < 1 And ((outgoingCommand.reliableSequenceNumber Mod ENET_PEER_RELIABLE_WINDOW_SIZE) = 0) And (channel.reliableWindows[(reliableWindow + ENET_PEER_RELIABLE_WINDOWS - 1) Mod ENET_PEER_RELIABLE_WINDOWS] >= ENET_PEER_RELIABLE_WINDOW_SIZE Or ((channel.usedReliableWindows & ((((1 Shl ENET_PEER_FREE_RELIABLE_WINDOWS) - 1) Shl reliableWindow) | (((1 Shl ENET_PEER_FREE_RELIABLE_WINDOWS) - 1) Shr (ENET_PEER_RELIABLE_WINDOW_SIZE - reliableWindow)))) <> 0))	Then
				
					windowWrap = 1
				
				Endif	
				
				If windowWrap <> 0 Then 
					currentCommand = enet_list_next(currentCommand)
					Continue
				 Endif		
		 	
		 	Endif
		 	
		 	If outgoingCommand.packet <> Null Then
		 	
		 		If windowExceeded = 0 Then
		 		
		 			Local windowSize:Int = (peer.packetThrottle * peer.windowSize) / ENET_PEER_PACKET_THROTTLE_SCALE
		 			
		 			If peer.reliableDataInTransit + outgoingCommand.fragmentLength > ENET_MAX(windowSize, peer.mtu) Then
		 			
		 				windowExceeded = 1
		 			
		 			Endif
		 		
		 		Endif
		 		
		 		If windowExceeded <> 0 Then
		 		
		 			currentCommand = enet_list_next(currentCommand)
		 			
		 			Continue
		 		
		 		
		 		Endif
		 		
		 		
		 	
		 	Endif
		 	
		 	canPing = 0
		 	
		 	commandSize = commandSizes[outgoingCommand.command.header.command & ENET_PROTOCOL_COMMAND_MASK]
		 	
		 	If commandI > host.commandCount Or bufferI > host.bufferCount Or peer.mtu - host.packetSize < commandSize Or (outgoingCommand.packet <> Null And ToUint16(peer.mtu - host.packetSize) < ToUint16(commandSize + outgoingCommand.fragmentLength)) Then
		 	
		 		host.continueSending = 1
		 		Exit
		 	
		 	Endif
		 	
		 	currentCommand = enet_list_next(currentCommand)
		 	
		 	If channel <> Null And outgoingCommand.sendAttempts < 1 Then
		 	
		 		channel.usedReliableWindows = channel.usedReliableWindows | 1 Shl reliableWindow
		 		channel.reliableWindows[reliableWindow]=channel.reliableWindows[reliableWindow]+1
		 	
		 	Endif
		 	
		 	outgoingCommand.sendAttempts = outgoingCommand.sendAttempts + 1
		 	
		 	If outgoingCommand.roundTripTimeout = 0 Then
		 	
		 		outgoingCommand.roundTripTimeout = peer.roundTripTime + 4 * peer.roundTripTimeVariance
		 		outgoingCommand.roundTripTimeoutLimit = peer.timeoutLimit * outgoingCommand.roundTripTimeout
		 	
		 	Endif
		 	
		 	If enet_list_empty(peer.sentReliableCommands) Then
		 	
		 		peer.nextTimeout = host.serviceTime + outgoingCommand.roundTripTimeout
		 	
		 	Endif
		 	
		 	enet_list_insert(enet_list_end(peer.sentReliableCommands),enet_list_remove(outgoingCommand.outgoingCommandList()))
		 	
		 	outgoingCommand.sentTime = host.serviceTime
		 	Local command:ENetProtocol = outgoingCommand.command
		 	
		 	host.commands[commandI] = command
		 	host.buffers[bufferI].Data = New Int[commandSize]
		 	SerializeCommand(host.buffers[bufferI].Data, host.commands[commandI])
		 	'host.buffers[bufferI].dataLength = commandSize
		 	
		 	host.packetSize = host.packetSize+host.buffers[bufferI].dataLength()
		 	host.headerFlags = host.headerFlags|ENET_PROTOCOL_HEADER_FLAG_SENT_TIME
		 	
		 	If outgoingCommand.packet <> Null Then
		 	
		 		bufferI=bufferI+1
		 		
		 		Local data:Int[] = New Int[outgoingCommand.packet.dataLength]
		 		For Local i:Int = 0 To outgoingCommand.packet.dataLength - outgoingCommand.fragmentOffset-1
		 		
		 			data[i] = outgoingCommand.packet.data[i + outgoingCommand.fragmentOffset]
		 		
		 		Next
		 		
		 		host.buffers[bufferI].Data = data
		 		host.buffers[bufferI].DataLength = outgoingCommand.fragmentLength
		 		host.packetSize = host.packetSize + outgoingCommand.fragmentLength
		 		
		 		peer.reliableDataInTransit = peer.reliableDataInTransit + outgoingCommand.fragmentLength
		 	
		 	Endif
		 	peer.packetsSent=peer.packetsSent+1
		 	commandI=commandI+1
		 	bufferI=bufferI+1
		 
		 Wend
	
		host.commandCount = commandI
		host.bufferCount = bufferI
		
		Return canPing
	
	End
	
	
	Method ToUint16:Int(a:Int)
	
		return p.IntToUshort(a)
	
	End
	
	Method enet_protocol_send_outgoing_commands:Int(host:ENetHost, event_:ENetEvent, checkForTimeouts:Int)
	
		Local headerData:Int[] = New Int[ENetProtocolHeader.SizeOf + 4]
		Local header:ENetProtocolHeader = New ENetProtocolHeader()
		Local currentPeer:ENetPeer 
		Local sentLength:Int
		Local shouldCompress:Int
		
		host.continueSending = 1
		
		While host.continueSending <> 0
		
			host.continueSending = 0
			
			For Local i:Int = 0 To host.peerCount-1
			
				currentPeer = host.peers[i]
				
				If currentPeer.state = ENetPeerState.ENET_PEER_STATE_DISCONNECTED Or currentPeer.state = ENetPeerState.ENET_PEER_STATE_ZOMBIE Then Continue
			
			
				host.headerFlags = 0
				host.commandCount = 0
				host.bufferCount = 1
				host.packetSize = ENetProtocolHeader.SizeOf
				
				If Not enet_list_empty(currentPeer.acknowledgements) Then
				
					enet_protocol_send_acknowledgements(host, currentPeer)
				
				Endif
				
				If checkForTimeouts <> 0 And Not enet_list_empty(currentPeer.sentReliableCommands) And ENET_TIME_GREATER_EQUAL(host.serviceTime, currentPeer.nextTimeout) And enet_protocol_check_timeouts(host, currentPeer, event_) = 1 Then
				
					If event_ <> Null And event_.type <> ENetEventType.ENET_EVENT_TYPE_NONE Then
						Return 1
					Else
						Continue
					Endif
					
				
				Endif
				
				If (enet_list_empty(currentPeer.outgoingReliableCommands) Or (enet_protocol_send_reliable_outgoing_commands(host, currentPeer) <> 0)) And enet_list_empty(currentPeer.sentReliableCommands) And ENET_TIME_DIFFERENCE(host.serviceTime, currentPeer.lastReceiveTime) >= currentPeer.pingInterval And currentPeer.mtu - host.packetSize >= ENetProtocolPing.SizeOf Then
				
					enet_peer_ping(currentPeer)
					enet_protocol_send_reliable_outgoing_commands(host, currentPeer)
				
				Endif			
				
				If Not enet_list_empty(currentPeer.outgoingUnreliableCommands) Then
				
					enet_protocol_send_unreliable_outgoing_commands(host, currentPeer)
				
				Endif
				
				If host.commandCount = 0 Then Continue
				
				If currentPeer.packetLossEpoch = 0 Then
				
					currentPeer.packetLossEpoch = host.serviceTime
				
				Else
				
					If ENET_TIME_DIFFERENCE(host.serviceTime, currentPeer.packetLossEpoch) >= ENET_PEER_PACKET_LOSS_INTERVAL And currentPeer.packetsSent > 0 Then
					
						Local packetLoss:Int = currentPeer.packetsLost * ENET_PEER_PACKET_LOSS_SCALE / currentPeer.packetsSent
						currentPeer.packetLossVariance = currentPeer.packetLossVariance - currentPeer.packetLossVariance / 4
						
						If packetLoss >= currentPeer.packetLoss Then
						
							currentPeer.packetLoss = currentPeer.packetLoss + (packetLoss - currentPeer.packetLoss) / 8
							currentPeer.packetLossVariance = currentPeer.packetLossVariance + (packetLoss - currentPeer.packetLoss) / 4
						
						Else
						
							currentPeer.packetLoss = currentPeer.packetLoss - (currentPeer.packetLoss - packetLoss) / 8
							currentPeer.packetLossVariance = currentPeer.packetLossVariance + (currentPeer.packetLoss - packetLoss) / 4
						
						Endif
						
						currentPeer.packetLossEpoch = host.serviceTime
						currentPeer.packetsSent = 0
						currentPeer.packetsLost = 0
					
					Endif
					
					
				
				Endif
				
				host.buffers[0].Data = headerData
				
				If (host.headerFlags & ENET_PROTOCOL_HEADER_FLAG_SENT_TIME) <> 0 Then
				
					header.sentTime = ENET_HOST_TO_NET_16(p.IntToUshort(host.serviceTime & $FFFF))
					host.buffers[0].DataLength = ENetProtocolHeader.SizeOf
					
				Else
				
					host.buffers[0].DataLength = 2
				
				Endif
				
				shouldCompress = 0
				If host.compressor <> Null Then
				
					'todo
				
				Endif
				
				If currentPeer.outgoingPeerID < ENET_PROTOCOL_MAXIMUM_PEER_ID Then
				
					host.headerFlags = host.headerFlags|p.IntToUshort(currentPeer.outgoingSessionID shl ENET_PROTOCOL_HEADER_SESSION_SHIFT)
				
				Endif
				
				header.peerID = ENET_HOST_TO_NET_16(p.IntToUshort(currentPeer.outgoingPeerID | host.headerFlags))
				
				SerializeHeader(headerData, header)
				
				If host.checksum <> Null Then
				
					'todo
				
				Endif
				
				If shouldCompress > 0 Then
				
					host.buffers[1].Data = host.packetData[1]
					host.buffers[1].DataLength = shouldCompress
					host.bufferCount = 2
				
				Endif
				
				currentPeer.lastSendTime = host.serviceTime
				sentLength = p.enet_socket_send(host.socket, currentPeer.address, host.buffers, host.bufferCount)
				enet_protocol_remove_sent_unreliable_commands(currentPeer)
				
				If sentLength < 0 Then Return -1
				
				host.totalSentData = host.totalSentData + sentLength
				host.totalSentPackets=host.totalSentPackets+1
			
			Next
		
		Wend
		
		Return 0
		
	End
	
	Method SerializeHeader:Void(headerData:Int[], header:ENetProtocolHeader)
	
		Local buffer:DataBuffer = New DataBuffer(headerData.Length())
		Local dataStream:DataStream = New DataStream(buffer)
		
		dataStream.WriteShort(header.peerID)
		dataStream.WriteShort(header.sentTime)
		
		
		
		dataStream.Data().PeekBytes( 0, headerData, 0, headerData.Length() )
		

	
	End
	
	
	Method enet_host_flush:Void(host:ENetHost)
	
		host.serviceTime = p.enet_time_get()
		enet_protocol_send_outgoing_commands(host, null, 0)
	
	
	End
	
	
	Method enet_host_check_events:Int(host:ENetHost,event_:ENetEvent)
	
		If event_ = Null Then Return -1
		
		event_.type = ENetEventType.ENET_EVENT_TYPE_NONE
		event_.peer = Null
		event_.packet = Null
		
		Return enet_protocol_dispatch_incoming_commands(host, event_)
	
	
	End
	
	
	Method enet_host_service:Int(host:ENetHost,event_:ENetEvent,timeout:Int)
	
		Local waitCondition:Int[] = New Int[1]
		
		If event_ <> Null Then
		
			event_.type = ENetEventType.ENET_EVENT_TYPE_NONE
			event_.peer = Null
			event_.packet = Null
			
			Select enet_protocol_dispatch_incoming_commands(host, event_)
			
				Case 1
					Return 1
					
				Case -1
					Return -1
					
				Default 
					'?	
			
			
			End Select	
		
		Endif
		
		host.serviceTime = p.enet_time_get()
		timeout = timeout + host.serviceTime
		
		
		While (waitCondition[0] & ENET_SOCKET_WAIT_RECEIVE) <> 0
		
			If ENET_TIME_DIFFERENCE(host.serviceTime, host.bandwidthThrottleEpoch) >= ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL Then
			
				enet_host_bandwidth_throttle(host)
			
			Endif
			
			Select enet_protocol_send_outgoing_commands(host, event_, 1)
			
				Case 1
					Return 1
				 
				Case -1
					Return -1
			
			End Select


			Select enet_protocol_receive_incoming_commands(host, event_)
			
				Case 1
					Return 1
				 
				Case -1
					Return -1
			
			End Select		


			Select enet_protocol_send_outgoing_commands(host, event_, 1)
			
				Case 1
					Return 1
				 
				Case -1
					Return -1
			
			End Select	


			Select enet_protocol_dispatch_incoming_commands(host, event_)
			
				Case 1
					Return 1
				 
				Case -1
					Return -1
			
			End Select	

			While (waitCondition[0] & ENET_SOCKET_WAIT_INTERRUPT) <> 0
			
				host.serviceTime = p.enet_time_get()
				If ENET_TIME_GREATER_EQUAL(host.serviceTime, timeout) Then Return 0
				
				waitCondition[0] = ENET_SOCKET_WAIT_RECEIVE | ENET_SOCKET_WAIT_INTERRUPT
				
				If p.enet_socket_wait(host.socket, waitCondition, ENET_TIME_DIFFERENCE(timeout, host.serviceTime)) <> 0 Then
				
					Return -1
				
				Endif
				
			
			Wend
			host.serviceTime = p.enet_time_get()
		
		Wend
		
		Return 0
	
	End
	
	
	
	Method enet_initialize:Int()
	
		Return 0
	
	End
	
	Method enet_deinitialize:Void()
	
		
	
	End
	
	
	Method ENET_MAX:Int(x:Int, y:Int)
	
		If x > y Then
			Return x
		Else
			Return y
		Endif
	End

	Method ENET_MIN:Int(x:Int, y:Int)
	
		If x < y Then
			Return x
		Else
			Return y
		Endif
	End	
	
	Method ENET_TIME_LESS:Bool(a:Int,b:Int)
	
		If a - b < 0 Then
			Return True
		Else
			Return False
		Endif
	
	End
	
	Method ENET_TIME_GREATER:Bool(a:Int,b:Int)
	
		If a - b > 0 Then
			Return True
		Else
			Return False
		Endif
	
	End	
	
	Method ENET_TIME_GREATER:Bool(a:Int,b:Int)
	
		Return Not ENET_TIME_GREATER(a, b)
	
	End
	
	Method ENET_TIME_GREATER_EQUAL:Bool(a:Int,b:Int)
	
		Return Not ENET_TIME_LESS(a, b)
	
	End
	
	Method ENET_TIME_DIFFERENCE:Int(a:Int, b:Int)
	
		If a-b < 0 Then
		
			Return b-a
		
		Else
		
			Return a-b
		
		Endif
	
	End	
	
	
	Method ENET_HOST_TO_NET_16:Int(a:Int)
	
		return p.ENET_HOST_TO_NET_16(a)
	
	End
	
	Method ENET_HOST_TO_NET_32:Int(a:Int)
	
		return p.ENET_HOST_TO_NET_32(a)
	
	End	
	
	Method ENET_NET_TO_HOST_16:Int(a:Int)
	
		return p.ENET_NET_TO_HOST_16(a)
	
	End	

	Method ENET_NET_TO_HOST_32:Int(a:Int)
	
		return p.ENET_NET_TO_HOST_32(a)
	
	End	
	
	
	
End

Class Math_

	Function isLessThanUnsigned:Bool(n1:Int,n2:Int)
	
		Local comp:Bool
		
		If n1 < n2 Then comp = True
		
		Local testa:Bool 
		Local testb:Bool
		
		If n1 < 0 Then testa = True
		If n2 < 0 Then testb = True
		
		If testa <> testb Then
		
			comp = Not comp
		
		Endif
		
		Return comp
	
	
	End

End


Class ENetSymbol

	Field value:Int
	Field count:Int
	Field under:Int
	Field left:Int
	Field right:Int
	Field symbols:Int
	Field escapes:Int
	Field total:Int
	Field parent:Int

End


Class ENetProtocolHeader

	Field peerID:Int
	Field sentTime:Int
	Const SizeOf:Int = 4

End

Class ENetProtocolCommandHeader
	
	Field command:Int
	Field channelID:Int
	Field reliableSequenceNumber:Int
	Const SizeOf:Int = 4

End


Class ENetProtocolAcknowledge

	Field receivedReliableSequenceNumber:Int
	Field receivedSentTime:Int
	Const SizeOf:int = 8

End

Class ENetProtocolConnect

	Field outgoingPeerID:Int
	Field incomingSessionID:Int
	Field outgoingSessionID:Int
	Field mtu:Int
	Field windowSize:Int
	Field channelCount:Int
	Field incomingBandwidth:Int
	Field outgoingBandwidth:Int
	Field packetThrottleInterval:Int
	Field packetThrottleAcceleration:Int
	Field packetThrottleDeceleration:Int
	Field connectID:Int
	Field data:Int
	

End


Class ENetProtocolVerifyConnect

	Field outgoingPeerID:Int
	Field incomingSessionID:Int
	Field outgoingSessionID:Int
	Field mtu:Int
	Field windowSize:Int
	Field channelCount:Int
	Field incomingBandwidth:Int
	Field outgoingBandwidth:Int
	Field packetThrottleInterval:Int
	Field packetThrottleAcceleration:Int
	Field packetThrottleDeceleration:Int
	Field connectID:Int	

End

Class ENetProtocolBandwidthLimit

	Field incomingBandwidth:Int
	Field outgoingBandwidth:Int	

End


Class ENetProtocolThrottleConfigure

	Field packetThrottleInterval:Int
	Field packetThrottleAcceleration:Int
	Field packetThrottleDeceleration:Int

End

Class ENetProtocolDisconnect

	Field data:Int	

End

Class ENetProtocolPing

	Const SizeOf:Int = ENetProtocolCommandHeader.SizeOf

End

Class ENetProtocolSendReliable

	Field dataLength:Int
	Const SizeOf:Int = 6

End

Class ENetProtocolSendUnreliable

	Field dataLength:Int
	Field unreliableSequenceNumber:Int
	Const SizeOf:Int = 12

End

Class ENetProtocolSendUnsequenced

	Field unsequencedGroup:Int
	Field dataLength:Int
	

End


Class ENetProtocolSendFragment

	Field startSequenceNumber:Int
	Field dataLength:Int
	Field fragmentCount:Int
	Field fragmentNumber:Int
	Field totalLength:Int
	Field fragmentOffset:Int
	Const SizeOf:Int = ENetProtocolCommandHeader.SizeOf + 24

End

Class ENetProtocol

	Field header:ENetProtocolCommandHeader
	Field acknowledge:ENetProtocolAcknowledge
	Field connect:ENetProtocolConnect
	Field verifyConnect:ENetProtocolVerifyConnect
	Field disconnect:ENetProtocolDisconnect
	Field ping:ENetProtocolPing
	Field sendReliable:ENetProtocolSendReliable
	Field sendUnreliable:ENetProtocolSendUnreliable
	Field sendUnsequenced:ENetProtocolSendUnsequenced
	Field sendFragment:ENetProtocolSendFragment
	Field bandwidthLimit:ENetProtocolBandwidthLimit
	Field throttleConfigure:ENetProtocolThrottleConfigure
	Field data:Int[] = New Int[0]
	
	
	Method New()
	
		header = new ENetProtocolCommandHeader()
	
	End




End


Class ENetPlatform Abstract

	Method time:Int() Abstract
	Method enet_socket_create:ENetSocket(type:Int) Abstract
	Method enet_socket_bind:Int(socket:ENetSocket, address:ENetAddress) Abstract
	Method enet_socket_get_address:Int(socket:ENetSocket, address:ENetAddress) Abstract
	Method enet_socket_listen:Int(socket:ENetSocket, backlog:Int) Abstract
	Method enet_socket_accept:Int(socket:ENetSocket, address:ENetAddress) Abstract
	Method enet_socket_connect:Int(socket:ENetSocket, address:ENetAddress) Abstract
	Method enet_socket_send:Int(socket:ENetSocket, address:ENetAddress, buffers:ENetBuffer[], bufferCount:Int) Abstract
	Method enet_socket_receive:Int(socket:ENetSocket, address:ENetAddress, buffers:ENetBuffer[], bufferCount:int) Abstract
	Method enet_socket_wait:Int(socket:ENetSocket, condition:Int[], timeout:Int) Abstract
	Method enet_socket_set_option:Int(socket:ENetSocket, option:Int, value:Int) Abstract
	Method enet_socket_shutdown:Int(socket:ENetSocket, how:ENetSocketShutdown) Abstract
	Method enet_socket_destroy:Void(socket:ENetSocket) Abstract
	Method ENET_HOST_TO_NET_16:Int(p:Int) Abstract
	Method ENET_HOST_TO_NET_32:Int(p:Int) Abstract
	Method ENET_NET_TO_HOST_16:Int(p:Int) Abstract
	Method ENET_NET_TO_HOST_32:Int(fragmentOffset:Int) Abstract
	Method enet_time_get:Int() Abstract
	Method CastToENetOutgoingCommand:ENetOutgoingCommand(a:ENetObject) Abstract
	Method CastToENetIncomingCommand:ENetIncomingCommand(a:ENetObject) Abstract
	Method CastToENetPeer:ENetPeer(a:ENetListNode) Abstract
	Method CastToENetListNode:ENetListNode(a:ENetObject) Abstract
	Method CastToENetAcknowledgement:ENetAcknowledgement(a:ENetListNode) Abstract
	Method enet_address_set_host:Int(address:ENetAddress, hostName:String) Abstract
	Method IntToUshort:Int(p:Int) Abstract
	

End