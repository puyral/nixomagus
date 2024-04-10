{...} :{
  service.picom = {
    enable = true;
    backend = "glx";
settings= {
vsync = true;
#use-damage = true;
### Shadow
shadow = true;
#no-dnd-shadow = true;
#no-dock-shadow = true;
clear-shadow = true;
shadow-radius = 20;
shadow-offset-x = -20;
shadow-offset-y = -20;
shadow-opacity = 1;
# shadow-red = 0.0;
# shadow-green = 0.0;
# shadow-blue = 0.0;
shadow-exclude = [
  # From the Ubuntu forums link ('screaminj3sus')
  "! name~=''"
  "n:e:Notification"
  "n:e:Plank"
  "n:e:Docky"
  "g:e:Synapse"
  "g:e:Kupfer"
  "g:e:Conky"
  "n:w:*Firefox*"
  "n:w:*Chrome*"
  "n:w:*Chromium*"
  "class_g ?= 'Notify-osd'"
  "class_g ?= 'Cairo-dock'"
  "class_g ?= 'Xfce4-notifyd'"
  "class_g ?= 'Xfce4-power-manager'"
  "class_g = 'zoom'"
  "n:e:cpt_frame_xcb_window"
];
  };};

}