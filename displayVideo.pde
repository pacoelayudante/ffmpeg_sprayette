public class DisplayVideo extends PApplet {
  Movie video;
  String urlVideo;
  int initWidth, initHeight;
  boolean cargandoVideo = true, escalar = false;

  DisplayVideo(String urlVideo, int w, int h) {
    this.urlVideo = urlVideo;
    this.initWidth = w;
    this.initHeight = h;
  }
  DisplayVideo(Movie video, int w, int h) {
    this.video = video;
    this.initWidth = w;
    this.initHeight = h;
  }

  void setup() {  
    noStroke();
    background(0);
    fill(255);
    text("CARGANDO VIDEO...", 0, height-textDescent());
    if (video==null) {
      video = new Movie(this, urlVideo);
        video.volume(0);
      video.loop();
    }
  }
  
  void settings() {
    size(initWidth, initHeight);
  }

  void draw() {
    if (video.width > 0) {
      if (cargandoVideo) {println(displayWidth+"/"+displayHeight+" -> "+video.width+"/"+video.height);
      float escalaDisplay = min((displayWidth*.75)/(float)video.width, (displayHeight*.75)/(float)video.height) ;
        //escalaDisplay *= .6;
        if (escalaDisplay > 1f) surface.setSize(video.width,video.height);
        else surface.setSize(round(video.width*escalaDisplay),round(video.height*escalaDisplay));
        cargandoVideo=false;
      }
      float escala = min(width/(float)video.width, height/(float)video.height) ;
      pushMatrix();
      if(escala<1f)scale(escala);
      image(video, 0, 0);
      popMatrix();
      fill(0);
      String fpsText = " fps: "+floor(frameRate);
      rect( 0, 0, textWidth(" fps: 1000"), g.textSize);
      fill(0, 255, 0);
      textAlign(LEFT, TOP);
      text(fpsText, 0, 0);
    }
  }

  void movieEvent(Movie m) {
    m.read();
  }
}
