package de.hgnut.GnuUtil.Messages;
import de.hgnut.GnuUtil.*;

/**
 *  Construct the appropriate <code>Message</code>
 *  subclass
 *
 */
public class MessageFactory {
	/**
	 *  Location of the function type in the header
	 *
	 */
	final static int typeLocation = 16;

	/**
	 *  Factory method providing messages
	 *
	 */
	public static Message createMessage(
		short[] rawMessage,
		GnuConnection originatingConnection) {
		short type = rawMessage[typeLocation];
		Message message = null;

		switch (type) {
			case Message.PING:
				{
					//System.out.println("MessageFactory created a ping message");
					message =
						new PingMessage(rawMessage, originatingConnection);
					break;
				}

			case Message.PONG:
				{
					//System.out.println("MessageFactory created a pong message");
					message =
						new PongMessage(rawMessage, originatingConnection);
					break;
				}

			case Message.QUERY:
				{
					//System.out.println("MessageFactory created a query message");
					message = new SearchMessage(rawMessage, originatingConnection);					
					break;
				}

			case Message.QUERYREPLY:
				{
					//System.out.println("MessageFactory created a SearchReply message");
					message = new SearchReplyMessage(rawMessage, originatingConnection);
					break;
				}

			case Message.PUSH:
				{
					//System.out.println("MessageFactory created a push message");
					message = null;
					//	new PushMessage(rawMessage, originatingConnection);
					break;
				}
			case Message.BYE:{
					//System.out.println("MessageFactory created a BYE message");
					message = null;
					break;
				}
			default :
				{
					System.out.println(
						"Message factory can't create message, type: " 
						+ Integer.toHexString(type));
					System.out.println(
						"Message factory can't create message, raw bytes: ");

					StringBuffer buffer = new StringBuffer();
					for (int i = 0; i < rawMessage.length; i++) {
						buffer.append(
							"[" + Integer.toHexString(rawMessage[i]) + "]");

					}
					System.out.println(buffer.toString()+"\n");
					break;
				}
		}

		return message;
	}
}
