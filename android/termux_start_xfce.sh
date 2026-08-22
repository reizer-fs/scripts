#!/bin/bash

#pkg install xfce xfce4-goodies pulseaudio pavucontrol virglrenderer-android termux-x11

#export MESA_LOADER_DRIVER_OVERRIDE=zink
#export GALLIUM_DRIVER=zink 
#export ZINK_DESCRIPTORS=lazy

export DISPLAY=:0

#virgl_test_server --use-egl-surfaceless &
virgl_test_server_android &

pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

termux-x11 :0 -xstartup "dbus-launch --exit-with-session xfce4-session" &

