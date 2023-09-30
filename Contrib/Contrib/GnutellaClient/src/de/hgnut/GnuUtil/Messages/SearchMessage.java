package de.hgnut.GnuUtil.Messages;

import de.hgnut.GnuUtil.*;

public class SearchMessage extends Message {

	// Get file by name
	public final static int GET_BY_NAME = 0;
	// Get file by sha1 hash
	public final static int GET_BY_HASH = 1;
	
	private String criteria;
	private int searchType;

	/**
	 * Construct a GNUTella search query
	 *
	 */
	// TODO something with the speed
	public SearchMessage(String criteria, int searchType, int minumumSpeed) {
		super(Message.QUERY);
		this.searchType = searchType;
		this.criteria = criteria;
		buildPayload();
	}

	/**
	 * Construct a SearchMessage from data read from network
	 *
	 * @param rawMessage binary data from a connection
	 * @param originatingConnection Connection creating this message
	 *
	 */
	SearchMessage(short[] rawMessage, GnuConnection originatingConnection) {
		super(rawMessage, originatingConnection);
	}

	/**
	 * EDITED BY: Daniel Meyers, 2004
	 * <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * Contructs the payload for the search message
	 *
	 * Bytes 0-1 download speed
	 * followed by search query (null terminated)
	 */
	void buildPayload() {
		byte[] chars = criteria.getBytes();
		short[] payload = null;
		
		if (searchType == GET_BY_NAME) {
			// +5 for URN request and null, +3 for speed & null 
			payload = new short[(chars.length + 5) + 3];
			payload[0] = 0; // TODO speed
			payload[1] = 0;

			int payloadIndex = 2;
		
			for (int i = 0; i < chars.length; i++) {
				payload[payloadIndex] = chars[i];
				payloadIndex += 1;
			}

			payload[payloadIndex++] = 0;

			// Now add request for sha1 string
			payload[payloadIndex++] = 'u';
			payload[payloadIndex++] = 'r';
			payload[payloadIndex++] = 'n';
			payload[payloadIndex++] = ':';
			payload[payloadIndex++] = 0;
		}
		else if (searchType == GET_BY_HASH) {
			// +3 for speed & null, +1 for extra null
			payload = new short[(chars.length + 3) + 1];
			payload[0] = 0; // TODO speed
			payload[1] = 0;

			int payloadIndex = 2;
			
			payload[payloadIndex++] = 0;
			
			for (int i = 0; i < chars.length; i++) {
				payload[payloadIndex] = chars[i];
				payloadIndex += 1;
			}
			
			payload[payloadIndex++] = 0;
		}

		addPayload(payload);
	}

	/**
	 * Get the minimum download speed for responses
	 *
	 * @return download speed
	 */
	public int getMinimumDownloadSpeed() {
		int byte1 = payload[0];
		int byte2 = payload[1];

		return byte1 | (byte2 << 8);
	}

	/**
	 * EDITED BY: Daniel Meyers, 2004
	 * <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 * Query the search criteria for this message
	 *
	 * @return search criteria
	 */
	public String getSearchCriteria() {
		if (null == payload || payload.length < 3) {
			// no data
			System.out.println("Query hat keine daten");
			return new String("");
		}

		byte[] text = null;
		
		if (searchType == GET_BY_NAME) {
			// 2 speed, 2 nulls, 4 'urn:'
			text = new byte[payload.length - 2 - 2 - 4];
			// skip 2 speed bytes
			int payloadIndex = 2;
			for (int i = 0; i < text.length; i++) {
				text[i] = (byte)payload[payloadIndex++];
			}
		}
		return new String(text);
	}
}
