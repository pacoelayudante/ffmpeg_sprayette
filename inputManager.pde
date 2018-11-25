import java.io.BufferedWriter;

class InputManager {
  BufferedWriter writer;
  
  InputManager(Process writer){
    this.writer = new BufferedWriter(new java.io.OutputStreamWriter( writer.getOutputStream() ) );
  }
  InputManager(OutputStream writer){
    this.writer = new BufferedWriter(new java.io.OutputStreamWriter( writer ) );
  }
  InputManager(java.io.OutputStreamWriter writer){
    this.writer = new BufferedWriter(writer);
  }
  InputManager(BufferedWriter writer){
    this.writer = writer;
  }
  
  void comando(String comando){
    try{
    writer.append(comando,0,comando.length());
    writer.newLine();
    writer.flush();
    }
    catch(Exception e){
      println(e);
    }
  }
}
