Import enet
Import mojo
Import brl.socket

Class ENetMonkeySocket Extends ENetSocket

	Field socket_:Socket
	Field RecieveBuffer:Int
	Field Broadcast:Bool
	Field SendBuffer:Int
	
	Method IsNull:Bool()
	
		If socket_ = Null Then
			Return True
		Else
			Return false
		Endif
	
	End
End

Class ENetPlatformMonkey Extends ENetPlatform

	Field timeBase:int
	

	Method time:Int() 
	
		Return Millisecs()
	
	End
	
	Method enet_socket_create:ENetSocket(type:Int)
		
		Local esock:ENetMonkeySocket = New ENetMonkeySocket()
		
		Select type
		
			Case ENetSocketTypeEnum.ENET_SOCKET_TYPE_STREAM
				
				esock.socket_ = New Socket("stream")
				
			Case ENetSocketTypeEnum.ENET_SOCKET_TYPE_DATAGRAM
			
				esock.socket_ = New Socket("datagram")
		
		End Select
	
		Return esock
	
	End
	
	
	Method enet_socket_bind:Int(socket:ENetSocket, address:ENetAddress) 
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		
		If esock = Null Then Return -1
		
		If esock.socket_.Bind( address.host_, address.port ) = True Then
			Return 0
		Else
			Return -1
		Endif
	
	End
	
	Method enet_socket_get_address:Int(socket:ENetSocket, address:ENetAddress) 
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		
		address.host_ = esock.socket_.LocalAddress().Host()
		address.port = esock.socket_.LocalAddress().Port()
		
		Return 0
	
	End
	
	Method enet_socket_listen:Int(socket:ENetSocket, backlog:Int) 
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		
		'no listen command so return 0
		
		Return 0		
		
			
	End
	
	Method enet_socket_accept:Int(socket:ENetSocket, address:ENetAddress)
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		
		'dafuq do i do with the new socket?
		Return 0		
	
	End
	
	
	Method enet_socket_connect:Int(socket:ENetSocket, address:ENetAddress) 
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		
		If esock.socket_.Connect( address.host_, address.port ) = True Then
			Return 0
		Else
			Return -1
		Endif
		
	
	End
	
	Method enet_socket_send:Int(socket:ENetSocket, address:ENetAddress, buffers:ENetBuffer[], bufferCount:Int) 
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		Local totalLength:int = 0
		For Local i:Int = 0 To bufferCount-1
			
			Local data:DataBuffer = New DataBuffer(buffers[i].dataLength())
			
			data.PeekBytes(0, buffers[i].Data, 0, buffers[i].Data.Length() )
			totalLength = totalLength + esock.socket_.SendTo( data, 0, buffers[i].Data.Length(), New SocketAddress(address.host_, address.port) )		
			 
		Next
	
		Return totalLength
	
	End
	

	
	Method enet_socket_receive:Int(socket:ENetSocket, address:ENetAddress, buffers:ENetBuffer[], bufferCount:Int)
	
		Local esock:ENetMonkeySocket = ENetMonkeySocket(socket)
		If esock = Null Then Return -1
		If esock.socket_ = Null Then Return -1
		
		If bufferCount < 1 Then 
		
			Print "No Buffer given"
			Return -1
		
		Endif	
		
		Local address_:SocketAddress = New SocketAddress()
		Local databuffer:DataBuffer = New DataBuffer(buffers[0].Data.Length())
		Local received:Int = esock.socket_.ReceiveFrom(databuffer, 0, buffers[0].Data.Length(), address_ )
		address.host_ = address_.Host()
		address.port = address_.Port()
		
		For Local i:Int = 0 To received-1
		
			buffers[0].Data[i] = databuffer.PeekByte(i)
		
		Next
		
		Return received
	
	End
	
	
	Method enet_socket_wait:Int(socket:ENetSocket, condition:Int[], timeout:Int) 
	
		Return 0
	
	End
	
	
	Method enet_socket_set_option:Int(socket:ENetSocket, option:Int, value:Int) 
	
		'cant set these options
		Return -1
	
	end
	
	Method enet_socket_shutdown:Int(socket:ENetSocket, how:ENetSocketShutdown) 
	
		'Socket too dumbed down to use this
		Return 0
	
	End
	
	Method enet_socket_destroy:Void(socket:ENetSocket) 
	
		'Derp
		
		
		
				
	
	End
	
	'can't seem to find anywhere that shows how to code htonl and htons functions
	
	Method ENET_HOST_TO_NET_16:Int(p:Int)
		Return p
	End 
	Method ENET_HOST_TO_NET_32:Int(p:Int) 
		Return p
	End 	
	Method ENET_NET_TO_HOST_16:Int(p:Int)
		Return p
	End 	 
	Method ENET_NET_TO_HOST_32:Int(p:Int) 
		Return p
	End 	
	Method enet_time_get:Int() 
		Return Millisecs() - timeBase
	end
	
	Method CastToENetOutgoingCommand:ENetOutgoingCommand(a:ENetObject) 
		Return ENetOutgoingCommand(a)
	End
	Method CastToENetIncomingCommand:ENetIncomingCommand(a:ENetObject) 
		Return ENetIncomingCommand(a)
	End
	Method CastToENetPeer:ENetPeer(a:ENetListNode) 
		Return ENetPeer(a)
	End
	Method CastToENetListNode:ENetListNode(a:ENetObject) 
		Return ENetListNode(a)
	End
	Method CastToENetAcknowledgement:ENetAcknowledgement(a:ENetListNode) 
		Return ENetAcknowledgement(a)
	End
	Method enet_address_set_host:Int(address:ENetAddress, hostName:String)
	
		address.host_ = hostName
		Return 0
	End
	Method IntToUshort:Int(p:Int) 
	
		Return p
	
	End
	#rem
	Function htnol:Int(a:Int)
		long lValue1 = 1234;
		long lValue2 = 0;
		
		lValue2 |= (lValue1 & 0xFF000000) >> 24;
		lValue2 |= (lValue1 & 0x00FF0000) >> 8;
		lValue2 |= (lValue1 & 0x0000FF00) << 8;
		lValue2 |= (lValue1 & 0x000000FF) << 24;	
	End
	#end
	
End