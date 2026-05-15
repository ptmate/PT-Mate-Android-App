import 'package:ptmate_client/_data/variables.dart';


class HelperTheme {
  

  static String getEmailColor() {
    var color = "";
    var themes = ["default", "blue", "darkblue", "green", "yellow", "orange", "red", "purple", "vividblue", "vividgreen", "darkgreen", "pink", "brown", "red2", "pink2", "lightblue", "purple2", "emeraldgreen"];
    var colors = ["#1CB6C7", "#1DC5C9", "#0C82AC", "#81DB24", "#FAB54A", "#FB631F", "#DE1053", "#8A15E9", "#4695ED", "#6CD69D", "#53A238", "#EB0BD1", "#8F5D46", "#F20E0E", "#FFA6F5", "#03C3FF", "#AF6CD6", "#00A86B"];
    if(GlobalData.space.enterprise) {
      for(var i=0; i<themes.length; i++) {
        if(GlobalData.space.theme == themes[i]) {
          color = colors[i];
        }
      }
    }
    return color;
  }


  static String getEmailImage() {
    var image = "";
    if(GlobalData.space.enterprise) {
      for(var item in GlobalUI.emailImages) {
        if(item.contains(GlobalData.space.id)) {
          var ar = item.split("||");
          image = ar[1];
        }
      }
    }
    return image;
  }


}
