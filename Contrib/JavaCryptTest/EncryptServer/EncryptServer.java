import java.net.*;
import java.io.*;

public class EncryptServer {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = null;
        Socket socket = null;
        boolean listening = true;

        try {
            serverSocket = new ServerSocket(2222);
        } catch (IOException e) {
            System.err.println("Could not listen on port: 2222");
            System.exit(-1);
        }

        while (listening){
          socket = serverSocket.accept();
          //System.out.println(socket.getInetAddress());
          //System.out.println(serverSocket.getInetAddress());
          if(socket.getInetAddress().toString().endsWith("127.0.0.1")){
	        new EncryptServerThread(socket).start();
	      }else{
	      	socket.close();
	      }	
	    }

        serverSocket.close();
    }
}