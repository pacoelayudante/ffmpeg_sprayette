class Terminal extends PApplet {
  Process proceso;
  String actual;
  String nombre = "";
  ArrayList<String> consola;
  int initWidth, initHeight;
  color colorFondo, colorTexto;
  char ultimoChar;
  boolean notificarComandoTerminado;

  BufferedReader reader;
  Terminal(InputStream reader, int initWidth, int initHeight, Process proceso) {
    this.reader = new BufferedReader( new java.io.InputStreamReader( reader ) );
    init(initWidth, initHeight, proceso);
  }
  Terminal(java.io.InputStreamReader reader, int initWidth, int initHeight, Process proceso) {
    this.reader = new BufferedReader(reader);
    init(initWidth, initHeight, proceso);
  }
  Terminal(BufferedReader reader, int initWidth, int initHeight, Process proceso) {
    this.reader = reader;
    init(initWidth, initHeight, proceso);
  }

  void init(int initWidth, int initHeight, Process proceso) {
    this.proceso = proceso;
    this.initWidth = initWidth;
    this.initHeight = initHeight;
    colorFondo = color(#3B167C);
    colorTexto = color(#F0D3A7, 255);
    consola = new ArrayList<String>();
    actual = "";
  }

  void setup() {
    consola.add("terminal familiar iniciada");
    consola.add("-------------"+nombre+"-------------");
  }

  void settings() {
    size(initWidth, initHeight);
  }

  void draw() {
    try {
      while (reader.ready()) {
        char ch = (char)reader.read();
        if (ch=='\n' || ch=='\r') {
          if ((ultimoChar=='\n'||ultimoChar=='\r')&&(ultimoChar!=ch))continue;
          consola.add(actual);
          actual = "";
          if (notificarComandoTerminado)comandoTerminado();
        } else {
          actual += ch;
        }
        ultimoChar = ch;
      }
    }
    catch(Exception e) {
      println(e);
    }

    background(colorFondo);
    fill(255);
    String funcandoText = "funcando "+(new char[]{'\\', '|', '/', '-'})[(frameCount/24)%4];
    if (proceso!=null) {
      funcandoText += "    "+proceso.toString()+" = "+(proceso.isAlive()?"?":proceso.exitValue());
    }
    fill(colorTexto);
    text(funcandoText, 5, height-7);

    noStroke();
    pushMatrix();
    translate(30, height-g.textSize*3-textAscent()-textDescent());
    translate(0, -g.textSize-textAscent()-textDescent());
    text(actual, 0, 0);
    for ( int i=consola.size()-1; i>=0; i-- ) {
      translate(0, -g.textSize);
      text(consola.get(i), 0, 0);
    }
    popMatrix();
  }
}
