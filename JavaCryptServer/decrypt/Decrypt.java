import org.bouncycastle.util.encoders.Hex;
import org.bouncycastle.crypto.BufferedBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.CryptoException;


public class Decrypt{

 private BufferedBlockCipher cipher      = null;
 private byte[]              cipherText  = null;
	
	public Decrypt(String kryptKey, String s){
		//System.out.println(s);
		//cipherText = performEncrypt(Hex.decode(kryptKey.getBytes()), s);
		String cs = performDecrypt(Hex.decode(kryptKey.getBytes()), s);
		System.out.println(cs);
	}
    
    private final String performDecrypt(byte[] key, String st)
    {
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
            System.out.println("Ooops, decrypt exception");
            System.out.println(ce.toString());
        }
        return new String(rv).trim();
    }
    public static void main(String args[]){
    	//System.out.println("In Main");
    	String s = "";
    	for(int i = 1; i < args.length; i++){
    		if(i == 1){
    		  s = s +args[i];	
    		}else{	
    		  s = s +" "+args[i];
    	    }
    	}	
    	 new Decrypt(args[0], s);
    	 
    }			
}	