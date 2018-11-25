static class PaletaDeComandos {
  
  static String escalarVideo(String entrada, int w, int h, String salida){
    return "ffmpeg -y -i \""+entrada+"\" -vf scale="+w+":"+h+" \""+salida+"\"";
  }
  
}
