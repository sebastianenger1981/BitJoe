import java.net.*;
import java.io.*;

import org.bouncycastle.util.encoders.Hex;
import org.bouncycastle.crypto.BufferedBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.CryptoException;

public class EncryptServerThread extends Thread {
    private Socket socket = null;
    private byte[] cipherText  = null;

    public EncryptServerThread(Socket socket) {
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
	    
	    
	    outputLine = performEncrypt(Hex.decode(cryptText[0].getBytes()), cryptText[1]);
	    
	    out.println(outputLine);

	    out.close();
	    in.close();
	    socket.close();

	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
 private final String performEncrypt(byte[] key, String plainText){

        byte[] ptBytes = plainText.getBytes();
        /*for(int i = 0; i < key.length; i++){
			System.out.print(key[i]);
	    }
        System.out.println("");*/
   BufferedBlockCipher cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(new AESEngine()));
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ISO7816d4Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ISO10126d2Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new TBCPadding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new X923Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ZeroBytePadding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), null);
      
        

        String name = cipher.getUnderlyingCipher().getAlgorithmName();

        cipher.init(true, new KeyParameter(key));

        byte[] rv = new byte[cipher.getOutputSize(ptBytes.length)];

        int oLen = cipher.processBytes(ptBytes, 0, ptBytes.length, rv, 0);
        try
        {
            cipher.doFinal(rv, oLen);
        }
        catch (CryptoException ce)
        {
            System.out.println(ce.toString());
        }
        return new String(Hex.encode(rv));
        //return new String(rv).trim();
    }
}       