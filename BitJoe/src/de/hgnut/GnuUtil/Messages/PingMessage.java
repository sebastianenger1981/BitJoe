package de.hgnut.GnuUtil.Messages;
import de.hgnut.GnuUtil.*;
public class PingMessage extends Message {
	/**
	 *  Ping message queries for hosts
	 *  No payload on this message
	 *
	 */
	public PingMessage() {
		super(Message.PING);
	}

	/**
	 *  Construct a PingMessage from network data
	 *
	 *  @param rawMessage binary data from a connection
	 *  @param originatingConnection Connection creating this message
	 */
	PingMessage(short[] rawMessage, GnuConnection originatingConnection) {
		super(rawMessage, originatingConnection);
	}

}
