import processing.net.*;

public class TareaFFMPEG extends PApplet {
  final String KEY_OUT_TIME_MS = "out_time_ms", KEY_PROGRESS = "progress";
  final String VALUE_END = "end";
  int referenciaProgresoMillis = 0, progresoMillis = 0;
  int puerto=-1;
  Server servidorProgress;
  Process proceso;
  InputManager inputManager;
  BufferedReader outReader, errReader;
  java.io.InputStreamReader outStreamReader, errStreamReader;
  InputStream outStream, errStream;
  int initWidth, initHeight;
  String outActual = "", errActual = "";
  ArrayList<String> outLog = new ArrayList<String>(), errLog = new ArrayList<String>();
  color colorFondo, colorOut, colorErr;
  HashMap<String, String> dataProgreso = new HashMap<String, String>();
  String alTerminar=null;

  ArrayList<String> colaDeComandos = new ArrayList<String>();
  String comandoActual = null;

  TareaFFMPEG(int w, int h) {
    this.initWidth = w;
    this.initHeight = h;

    runSketch(new String[]{"TareaFFMPEG"}, this);
  }
  TareaFFMPEG(String comando, int w, int h) {
    colaDeComandos.add(comando);
    this.initWidth = w;
    this.initHeight = h;

    runSketch(new String[]{"TareaFFMPEG"}, this);
  }
  TareaFFMPEG(String[] comandos, int w, int h) {
    for (String s : comandos) colaDeComandos.add(s);
    this.initWidth = w;
    this.initHeight = h;

    runSketch(new String[]{"TareaFFMPEG"}, this);
  }

  void settings() {
    size(initWidth, initHeight);
  }

  void stop() {
    proceso.destroy();
    servidorProgress.stop();
    super.stop();
  }

  boolean esperandoComandos() {
    return comandoActual == null && colaDeComandos.size()==0;
  }

  void setup() {
    colorFondo = color(#3B167C);
    colorOut = color(#F0D3A7, 255);
    colorErr = color(#FA772B, 255);

    proceso = exec("cmd", "/k", "cd", "/d", "\""+sketchPath()+"\"");
    errStream = proceso.getErrorStream();
    outStream = proceso.getInputStream();
    errStreamReader = new java.io.InputStreamReader( errStream );
    outStreamReader = new java.io.InputStreamReader( outStream );
    errReader = new BufferedReader(errStreamReader);
    outReader = new BufferedReader(outStreamReader);
    inputManager = new InputManager(proceso);

    puerto = TareaFFMPEGServerGetter.puerto();
    servidorProgress = new Server(this, puerto);
  }

  private String leerStream( BufferedReader reader, String actual, ArrayList<String> consola ) {
    try {
      while (reader.ready()) {
        char ultimoChar = 0;
        if (actual.length()>0)ultimoChar = actual.charAt(actual.length()-1);
        char ch = (char)reader.read();
        if (ch=='\n' || ch=='\r') {
          if ((ultimoChar=='\n'||ultimoChar=='\r')&&(ultimoChar!=ch)||actual.length()==0)continue;
          consola.add(actual);
          actual = "";
        } else {
          actual += ch;
        }
      }
    }
    catch(Exception e) {
      println(e);
    }
    return actual;
  }

  void draw() {
    outActual = leerStream(outReader, outActual, outLog);
    errActual = leerStream(errReader, errActual, errLog);

    background(colorFondo);
    if (referenciaProgresoMillis > 0) {
      pushStyle();
      fill(255, 150);
      rect(0, 0, width*(float)progresoMillis/referenciaProgresoMillis, 20);
      popStyle();
    }

    translate(30, height-g.textSize*3-textAscent()-textDescent());
    fill(colorOut);
    escribirTexto(outActual, outLog);
    noStroke();
    translate(0, -g.textSize*9);
    //fill(colorFondo);
    //rect(-30, 0, width, g.textSize*9);
    fill(colorErr);
    escribirTexto(errActual, errLog);

    procesarMensajeProgress();

    if (comandoActual==null && colaDeComandos.size()>0) {
      iniciarComando( colaDeComandos.get(0) );
      colaDeComandos.remove(0);
    }
  }

  void procesarMensajeProgress() {
    // Get the next available client
    Client thisClient = servidorProgress.available();
    // If the client is not null, and says something, display what it said
    if (thisClient !=null) {
      String whatClientSaid = thisClient.readString();
      if (whatClientSaid != null) {
        //println(thisClient.ip() + "\n\t" + whatClientSaid);
        whatClientSaid = whatClientSaid.replace("\r", "");
        String[] texto = whatClientSaid.split("\n");
        for (String s : texto) {
          String[] sep = s.split("=");
          //println("\""+sep[0]+"\" ----> "+sep[1]);
          dataProgreso.put(sep[0], sep[1]);
        }

        if (dataProgreso.containsKey(KEY_OUT_TIME_MS)) {
          progresoMillis = int(dataProgreso.get(KEY_OUT_TIME_MS));
        }
        if (dataProgreso.containsKey(KEY_PROGRESS)) {
          if (dataProgreso.get(KEY_PROGRESS).equals(VALUE_END)) finComando();
        }
      }
    }
  }
  /*void serverEvent(Server someServer, Client someClient) {
   println("We have a new client: " + someClient.ip());
   }
   void disconnectEvent(Client someClient) {
   print("Disconnected Says:  ");
   println(someClient.ip());
   }*/

  void escribirTexto(String actual, ArrayList<String> consola) {
    pushMatrix();
    translate(0, -g.textSize-textAscent()-textDescent());
    text(actual, 0, 0);
    for ( int i=consola.size()-1; i>=0; i-- ) {
      translate(0, -g.textSize);
      text(consola.get(i), 0, 0);
    }
    popMatrix();
  }

  void finComando() {
    comandoActual = null;
    if (colaDeComandos.size()==0 && alTerminar!=null) {
      overThread(alTerminar);
      alTerminar=null;
    }
  }

  boolean comando(String comando) {
    if (comandoActual == null && inputManager != null) {
      iniciarComando(comando);
      return true;
    } else {
      colaDeComandos.add(comando);
      return false;
    }
  }

  private void iniciarComando(String comando) {
    comando += " -progress tcp://localhost:"+puerto;
    comandoActual = comando;
    inputManager.comando(comando);
  }
}

static class TareaFFMPEGServerGetter {
  static final int puertoBase = 30000;
  static final int limiteDePuertos = 10000;
  static int ultimoPuertoDado = -1;
  static int puerto() {
    ultimoPuertoDado += 1;
    ultimoPuertoDado %= limiteDePuertos;
    return puertoBase + ultimoPuertoDado;
  }
  static Server serverLocal(PApplet parent) {
    return server(parent, "127.0.0.1");
  }
  static Server serverLocal(PApplet parent, int puerto) {
    return server(parent, puerto, "127.0.0.1");
  }
  static Server server(PApplet parent, String ip) {
    return server(parent, puerto(), ip);
  }
  static Server server(PApplet parent, int puerto, String ip) {
    return new Server(parent, puerto);
  }
}
