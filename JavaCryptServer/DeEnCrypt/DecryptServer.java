import java.net.*;
import java.io.*;

public class DecryptServer {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = null;
        Socket socket = null;
        boolean listening = true;

        try {
            serverSocket = new ServerSocket(1111);
        } catch (IOException e) {
            System.err.println("Could not listen on port: 1111");
            System.exit(-1);
        }

        while (listening){
          socket = serverSocket.accept();
          //System.out.println(socket.getInetAddress());
          //System.out.println(serverSocket.getInetAddress());
          if(socket.getInetAddress().toString().endsWith("127.0.0.1")){
	        new DecryptServerThread(socket).start();
	      }else{
	      	socket.close();
	      }	
	    }

        serverSocket.close();
    }
}
