/*
	Autor:		Sebastian Enger
	Lastmod:	5.5.2006 @ 20.40 Uhr
	Aufgabe:	Basisklasse zum Erstellen einer GUID
	Memo:		http://www.the-gdf.org/wiki/index.php?title=Standard_Message_Architecture
*/
package de.hgnut.GnuUtil;
import java.util.Random;
import de.hgnut.Misc.*;

public class GUID {
	private static short[] clientID = null;
	private static Random rand = new Random();
	private static int GUID_BYTE_SIZE = 16;
	private short[] data;
	
	public GUID(){
        	data = new short[GUID_BYTE_SIZE];
		int arrayIndex = 15;
		int randInt = 0x00000000;

		for (int i = 0; i < 4; i++) {
			randInt = rand.nextInt();
			for (int j = 0; j < 4; j++) {
				int mask = 0x000000FF;

				mask = mask << (4 * j);
				int result = randInt & mask;

				result = result >> (4 * j);

				data[arrayIndex--] = (short)result;
			}
		}
		data[8]		= (short)0xFF;		// we are modern ^^
        	data[15]	= (short)0x00;		// preserved for future use.	        	
	}
	
	public GUID(short[] data) {
		this.data = data;
	}
	
	public short[] getData() {
		return data;
	}
	
	public boolean equals(Object obj) {
		if (!(obj instanceof GUID)) {
			return false;
		}

		// Check if the data is the same
		GUID rhs = (GUID)obj;
		short[] lhsData = getData();
		short[] rhsData = rhs.getData();

		return Arraysequals(lhsData, rhsData);
	}
	
	public String toRawString() {
		StringBuffer message = new StringBuffer();

		for (int i = 0; i < data.length; i++) {
			StringBuffer messageSection = new StringBuffer();
			messageSection.append(Integer.toHexString(data[i]));
			
			// Ensure every value is 2 chars long (i.e. 0F instead of F)
			if (messageSection.length() < 2) {
				message.append('0');
			}
			message.append(messageSection);
		}

		return message.toString();
	}
	
	/**
	 * Returns a GUID as a String
	 *
	 * @return text form of guid
	 */
	public String toString() {
		StringBuffer message = new StringBuffer();
		message.append("GUID: ");

		for (int i = 0; i < data.length; i++) {
			message.append("[" + Integer.toHexString(data[i]) + "]");
		}

		return message.toString();
	}
	
	private static boolean Arraysequals(short[] first, short[] second){
		if(first==null&&second==null)
			return true;
		if(first.length!=second.length)
			return false;
		for(int i=0;i<first.length;i++){
			if(first[i]!=second[i])
				return false;
		}
		return true;			
	}
	
	public static short[] getClientIdentifier() {
		if (null == clientID) {
			clientID = new short[16];
			short[] address = getHostAddress();

			int addressIndex = 0;
			for (int i = 0; i < clientID.length; i++) {
				if (addressIndex == address.length) {
					addressIndex = 0;
				}

				clientID[i] = address[addressIndex++];
			}

			StringBuffer message = new StringBuffer();
			message.append("Client GUID: ");

			for (int i = 0; i < clientID.length; i++) {
				message.append("[" + Integer.toHexString(clientID[i]) + "]");
			}

			System.out.println(message.toString());
		}

		return clientID;
	}

	/**
	 * Returns the client guid in the form of the wrapper GUID
	 *
	 */
	public static GUID getClientGUID() {
		return new GUID(getClientIdentifier());
	}
	
	static short[] getHostAddress() {
		short[] address = new short[4];
		try {
			String ipAddress = Constant.myipaddress;

			int beginIndex = 0;
			int endIndex = ipAddress.indexOf('.');

			address[0] =
				(short)Integer.parseInt(
					ipAddress.substring(beginIndex, endIndex));

			beginIndex = endIndex + 1;
			endIndex = ipAddress.indexOf('.', beginIndex);

			address[1] =
				(short)Integer.parseInt(
					ipAddress.substring(beginIndex, endIndex));

			beginIndex = endIndex + 1;
			endIndex = ipAddress.indexOf('.', beginIndex);

			address[2] =
				(short)Integer.parseInt(
					ipAddress.substring(beginIndex, endIndex));

			beginIndex = endIndex + 1;

			address[3] =
				(short)Integer.parseInt(
					ipAddress.substring(beginIndex, ipAddress.length()));
		}
		catch (Exception e) {
			System.out.println(e);
		}

		return address;
	}
} // public class GUID {}