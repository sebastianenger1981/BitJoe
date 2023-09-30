import java.net.*;
import java.io.*;

import org.bouncycastle.util.encoders.Hex;
import org.bouncycastle.crypto.BufferedBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.CryptoException;

public class DecryptServerThread extends Thread {
    private Socket socket = null;
    private byte[] cipherText  = null;

    public DecryptServerThread(Socket socket) {
	super("DecryptServerThread");
	this.socket = socket;
    }

    public void run() {

	try {
	    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
	    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

	    String inputLine, outputLine;
	    
	    inputLine = in.readLine();
	    
	    String[] cryptText= inputLine.split(":");
	    
	    
	    outputLine = performDecrypt(Hex.decode(cryptText[0].getBytes()), cryptText[1]);
	    
	    out.println(outputLine);

	    out.close();
	    in.close();
	    socket.close();

	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
    private final String performDecrypt(byte[] key, String st){
    	cipherText = Hex.decode(st);
    	BufferedBlockCipher cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(new AESEngine()));
        cipher.init(false, new KeyParameter(key));

        byte[] rv = new byte[cipher.getOutputSize(cipherText.length)];

        int oLen = cipher.processBytes(cipherText, 0, cipherText.length, rv, 0);
        try
        {
            cipher.doFinal(rv, oLen);
        }
        catch (CryptoException ce)
        {
            System.out.println(ce.toString());
        }
        return new String(rv).trim();
    }
}
