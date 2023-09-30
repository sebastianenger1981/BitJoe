/*
Hilfsklasse Basisstruktur einer Gnutella Message
Wird in den anderen Klassen dieses Packages erweitert und implementiert
!!	Diese Klasse wird abstract-> keine Objecte erzeugbar	!!
Konnte fast den kompletten Code aus JTella klauen.
Ausnahme: GUID hab ich noch nicht. Ist hier als short[16] gefakt, hoffe das reicht zum pingen&pongen
*/
package de.hgnut.GnuUtil.Messages;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import de.hgnut.GnuUtil.*;
/**
 *  Abstract base class for GNUTella messages
 *
 */
public abstract class Message {
	public final static int SIZE = 23;

	final static short PING = (short)0x00;
	final static short PONG = (short)0x01;
	final static short BYE  = (short)0x02;
	final static short PUSH = (short)0x40;
	final static short QUERY = (short)0x80;
	final static short QUERYREPLY = (short)0x81;

	final static int SIZE_PING_PAYLOAD = 0;
	final static int SIZE_PONG_PAYLOAD = 14;
	final static int SIZE_PUSH_PAYLOAD = 26;
	final static int SIZE_QUERY_PAYLOAD = 257;
	final static int SIZE_QUERYREPLY_PAYLOAD = 65536;

	protected GnuConnection originatingConnection;
	protected GUID guid;
	protected short type;
	protected byte ttl;
	protected byte hops;
	protected short[] payload;
	protected int payloadSize;

	/**
	 *  Constructs a new message
	 *
	 *
	 *  @param type function type
	 */
	Message(int type) {
		this(new GUID(), type);
	}

	/**
	 *  Construct a message with a specific guid
	 *
	 *  @param guid
	 *  @type message type
	 */
	Message(GUID guid, int type) {
		this.guid = guid;
		this.type = (short)type;
		ttl = 7;
		hops = 0;
	}

	/**
	 *  Query the type of message
	 *
	 *  @return type
	 */
	public int getType() {
		return type;
	}

	/**
	 *  Constructs a message from data read from network
	 *
	 *  @param rawMessage bytes
	 */
	Message(short[] rawMessage, GnuConnection originatingConnection) {
		this.originatingConnection = originatingConnection;
		StringBuffer buffer = new StringBuffer();

		for (int i = 0; i < rawMessage.length; i++) {
			buffer.append("[" + Integer.toHexString(rawMessage[i]) + "]");

		}

		//System.out.println("Raw Message Bytes: " + buffer.toString());

		// Copy the GUID
		short[] guidData = new short[16];
		System.arraycopy(rawMessage, 0, guidData, 0, guidData.length);
		guid = new GUID(guidData);

		// Copy the function identifier
		type = rawMessage[16];

		// Copy the TTL 
		ttl = (byte)rawMessage[17];

		// Copy the hop count
		hops = (byte)rawMessage[18];

		// Copy the payoad size (little endian)
		int byte1 = rawMessage[19];
		int byte2 = rawMessage[20];
		int byte3 = rawMessage[21];
		int byte4 = rawMessage[22];

		payloadSize += byte1;
		payloadSize += (byte2 << 8);
		payloadSize += (byte3 << 16);
		payloadSize += (byte4 << 24);

	}

	/**
	 *  Query the GUID 
	 *
	 *  @return 16 byte array
	 */

	public GUID getGUID() {
		return guid;
	}

	/**
	 *  Apply a guid to the message
	 *
	 *  @param guid new guid
	 */
	public void setGUID(GUID guid) {
		this.guid = guid;
	}

	/**
	 *  Get the Time to live for the message
	 *
	 */
	public int getTTL() {
		return ttl;
	}

	/**
	 *  Set the ttl value for the message
	 *
	 */
	public void setTTL(byte ttl) {
		this.ttl = ttl;
	}

	/**
	 *  Get the hop count for this message
	 *
	 */
	public int getHops() {
		return hops;
	}

	/**
	 *  Set the hop count for this message, seven is the recommended maximum
	 *
	 */
	public void setHops(byte hops) {
		this.hops = hops;
	}

	/**
	 *  Add a payload to the message
	 *
	 *  @param payload payload for the message
	 */
	public void addPayload(short[] payload) {
		this.payload = payload;
		payloadSize = payload.length;
	}

	/**
	 *  Add a payload to the message
	 *
	 *  @param payload payload for the message
	 */
	public void addPayload(byte[] payload) {
		short[] shortPayload = new short[payload.length];

		for (int i = 0; i < payload.length; i++) {
			shortPayload[i] = payload[i];
		}

		addPayload(shortPayload);
	}

	/**
	 *  Query the payload size for this message
	 *
	 */
	public int getPayloadLength() {
		return payloadSize;
	}

	/**
	 *  Retrieve the message payload
	 *
	 *  @return payload
	 */
	public short[] getPayload() {
		return payload;
	}

	/**
	 *  Produces a byte[] suitable for 
	 *  GNUTELLA network
	 *
	 */
	public byte[] getByteArray() {
		// TODO handle expection avoid null pointer
		ByteArrayOutputStream byteStream = null;

		try {

			byteStream = new ByteArrayOutputStream();
			DataOutputStream payloadStream = new DataOutputStream(byteStream);

			// Write the guid			
			short[] guidData = guid.getData();			
			for (int i = 0; i < guidData.length; i++) {
				payloadStream.writeByte((byte)guidData[i]);
			}

			// Write the function (payload descriptor)
			payloadStream.writeByte(type);

			// Write the time to live
			payloadStream.writeByte(ttl);

			// Write the hop count
			payloadStream.writeByte(0);

			if (this.getType() == PING) {
				payload = null;
			}

			// Write the Payload size in little-endian
			int payloadSize1 = 0x000000FF & payloadSize;
			int payloadSize2 = (0x0000FF00 & payloadSize) >> 8;
			int payloadSize3 = (0x00FF0000 & payloadSize) >> 16;
			int payloadSize4 = (0xFF000000 & payloadSize) >> 24;

			payloadStream.writeByte(payloadSize1);
			payloadStream.writeByte(payloadSize2);
			payloadStream.writeByte(payloadSize3);
			payloadStream.writeByte(payloadSize4);

			// Write the payload
			if (null != payload) {
				// Message may not have a payload (ex. Ping)
				for (int i = 0; i < payload.length; i++) {
					byte payloadByte = (byte)payload[i];
					payloadStream.writeByte(payloadByte);
				}
			}
			// all done
			payloadStream.close();

		}
		catch (IOException io) {
			io.printStackTrace();
		}		
		return byteStream.toByteArray();
	}

	/**
	 *  Checks validity of a payloads size
	 *
	 *  @param message to test
	 *  @return true if valid, false otherwise
	 */
	public boolean validatePayloadSize(){
		boolean result = false;

		switch (type){
			case PING :
				{
					if (SIZE_PING_PAYLOAD == payloadSize){
						result = true;
					}
					break;
				}

			case PONG :
				{
					if (SIZE_PONG_PAYLOAD == payloadSize) {
						result = true;
					}
					break;
				}

			case PUSH :
				{
					if (SIZE_PUSH_PAYLOAD == payloadSize) {
						result = true;
					}
					break;
				}

			case QUERY :
				{
					if (payloadSize < SIZE_QUERY_PAYLOAD) {
						result = true;
					}
					break;
				}

			case QUERYREPLY :
				{
					if (payloadSize < SIZE_QUERYREPLY_PAYLOAD) {
						result = true;
					}
					break;
				}
		}

		return result;
	}

	/**
	 *  String representation of the message
	 *
	 */
	public String toString() {
		StringBuffer message = new StringBuffer();

		message.append("GUID: ");

		short[] guidData = getGUID().getData();
		for (int i = 0; i < guidData.length; i++) {
			message.append("[" + Integer.toHexString(guidData[i]) + "]");
		}

		message.append("\n");

		switch (type) {
			case PING :
				{
					message.append("PING message\n");
					break;
				}

			case PONG :
				{
					message.append("PONG message\n");
					break;
				}

			case QUERY :
				{
					message.append("QUERY message\n");
					break;
				}

			case QUERYREPLY :
				{
					message.append("QUERY REPLY message\n");
					break;
				}

			case PUSH :
				{
					message.append("PUSH message\n");
					break;
				}

			default :
				{
					message.append("Unknown message");
					break;
				}
		}

		message.append("Payload length: " + payloadSize + "\n");
		message.append("Payload: \n");

		if (null != payload) {
			for (int i = 0; i < payload.length; i++) {
				message.append("[" + Integer.toHexString(payload[i]) + "]");
			}

			message.append("\n");
		}
		else {
			message.append("No payload");
		}

		return message.toString();
	}

	/**
	 *  Returns a String containing the flattened message
	 *
	 *  @return message string
	 */
	public String toRawString() {
		StringBuffer buffer = new StringBuffer();
		byte[] rawMessage = getByteArray();

		for (int i = 0; i < rawMessage.length; i++) {
			buffer.append("[" + Integer.toHexString(rawMessage[i]) + "]");

		}

		return buffer.toString();
	}

	/**
	 *  Get the connection that was the source for this message
	 *
	 * 
	 *  @return originating connection or null if this <code>Message</code> was
	 *  not read from the network
	 */
	public GnuConnection getOriginatingConnection() {
		return originatingConnection;
	}
}
