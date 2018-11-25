//ffmpeg -progress tcp://
//processing Server

import processing.video.*;

final int ESTADO_ESPERANDO_VIDEO = 0, ESTADO_CARGANDO_VIDEO = 1, ESTADO_ACHICANDO_VIDEO = 2, ESTADO_EDITANDO_VIDEO = 3;

Movie video;
Process procesoFFMPEG;
InputManager inputManager;
//PaletaDeComandos ffmpegManager;
DisplayVideo displayVideo;

int estado = 0;
boolean dialogoAbierto = false;
boolean muteado = true;
File archivoCargado = null;

void settings() {
  size(640, 120);
}

void overThread(String th){
  thread(th);
}

void setup() {  
  background(0);
  iniciarCmd();

  buscarArchivo();
}

void iniciarCmd() {
  //procesoFFMPEG = exec("cmd", "/k", "cd", "/d", "\""+sketchPath()+"\"");
  //Terminal errores = new Terminal(procesoFFMPEG.getErrorStream(), 650, 450, procesoFFMPEG);
  //errores.colorTexto = color(#FA772B);
  //errores.nombre = "ERRORES";
  //runSketch(new String[]{"Terminal"}, errores);
  //Terminal salida = new Terminal(procesoFFMPEG.getInputStream(), 650, 450, procesoFFMPEG);
  //salida.notificarComandoTerminado = true;
  //runSketch(new String[]{"Terminal"}, salida);
  //inputManager = new InputManager(procesoFFMPEG.getOutputStream());
  //ffmpegManager = new PaletaDeComandos();
}

void mutear(boolean mutear) {
  this.muteado = mutear;
  if (video!=null) video.volume(mutear?0:1);
}

void buscarArchivo() {
  if (!dialogoAbierto) {
    dialogoAbierto = true;
    selectInput("Video para abrir", "archivoDeVideoElegido");
  }
}

void achicarVideo() {
  float duracion = video.duration();
  video.stop();
  //println(sketchPath("ffmpeg.exe").replace('\\','/'));
  //procesoFFMPEG = launch( "\""+sketchPath("ffplay.exe").replace('\\','/')+"\"" );
  //outputProceso = new BufferedReader(new java.io.InputStreamReader( procesoFFMPEG.getInputStream() ) );
  //float escala = min((float)width/video.width, (float)height/video.height) ;
  float escala = min(1024./video.width, 768./video.height) ;
  if (escala < 1) {
    int w = round(video.width*escala);
    int h = round( video.height*escala);
    if (w%2==1)w++;
    if (h%2==1)h++;
    //inputManager.comando( PaletaDeComandos.escalarVideo(archivoCargado.toString(), w, h, "tempscaled.mp4") );
    TareaFFMPEG tarea = new TareaFFMPEG(1000, 600);
    tarea.comando(PaletaDeComandos.escalarVideo(archivoCargado.toString(), w, h, sketchPath("tempscaled.mp4")));
    tarea.referenciaProgresoMillis = floor( duracion*1000000);
    tarea.alTerminar = "achicadoTerminado";
  }
  estado = ESTADO_ACHICANDO_VIDEO;
  //video.loop();
}

void comandoTerminado() {
  println("comandoTerminado");
}

void archivoDeVideoElegido(File archivo) {
  archivoCargado = archivo;
  dialogoAbierto = false;
  video = null;
  if (archivoCargado != null) {
    //video = new Movie(this,archivoCargado.toString());
    //video.loop();
    //displayVideo = new DisplayVideo(video,1024,768);
    displayVideo = new DisplayVideo(archivoCargado.toString(), 320, 120);
    runSketch(new String[]{"DisplayVideo"}, displayVideo);
    //if(video==null)video = displayVideo.video;
    /*if (video == null) archivoCargado = null;
     else {
     video.play();
     if (muteado) {
     video.volume(0);
     }
     estado = ESTADO_CARGANDO_VIDEO;
     }*/
    estado = ESTADO_CARGANDO_VIDEO;
  }
}

void mousePressed() {
  if (archivoCargado==null) buscarArchivo();
}

void estadoEsperandoVideo() {
  int tamfila = 7;
  noStroke();
  fill(noise(frameCount*millis()*0.00001)*255);
  rect(0, (tamfila*frameCount)%height, width, tamfila);
}
void estadoCargandoVideo() {
  noStroke();
  int tamcelda = 50;
  int x = floor(random(width/tamcelda))*tamcelda;
  int y = floor(random(height/tamcelda))*tamcelda;
  fill(0, 75);
  rect(x, y, tamcelda, tamcelda);
  if (video == null) {
    video = displayVideo.video;
  } else {
    if (video.width>0) {
      //estado = ESTADO_ACHICANDO_VIDEO;
      achicarVideo();//thread( "achicarVideo" );
    } else if (video.width == -1) {
      video = null;
      estado = ESTADO_ESPERANDO_VIDEO;
    }
  }
}
void estadoAchicandoVideo() {
  copy(1, 1, width-2, height-2, 0, 0, width, height);
}

void achicadoTerminado() {
  displayVideo = new DisplayVideo(sketchPath("tempscaled.mp4"), 1000, 1000);
  runSketch(new String[]{"DisplayVideo achicado"}, displayVideo);
}

void estadoEditandoVideo() {
}

void draw() {  
  if (displayVideo == null) estado = ESTADO_ESPERANDO_VIDEO;
  switch (estado) {
  case ESTADO_ESPERANDO_VIDEO:
    estadoEsperandoVideo();
    break;
  case ESTADO_CARGANDO_VIDEO:
    estadoCargandoVideo();
    break;
  case ESTADO_ACHICANDO_VIDEO:
    estadoAchicandoVideo();
    break;
  case ESTADO_EDITANDO_VIDEO:
    estadoEditandoVideo();
    break;
  }

  fill(0);
  noStroke();
  String fpsText = "fps: "+floor(frameRate);
  rect( 0, 0, textWidth("fps: 1000"), textDescent()+textAscent());
  fill(0, 255, 0);
  textAlign(LEFT, TOP);
  text(fpsText, 0, 0);
}

void movieEvent(Movie m) {
  m.read();
}
