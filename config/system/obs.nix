{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
       # obs-backgroundremoval
        obs-pipewire-audio-capture
      #  obs-vkcapture
      #  obs-vaapi
        obs-livesplit-one
        obs-gstreamer
        droidcam-obs
        obs-backgroundremoval
        # obs-vertical-canvas
        obs-3d-effect
        obs-move-transition

      ];
    })
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback 
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    options v4l2loopback devices=2 video_nr=1 card_label="droi cam" exclusive_caps=1
  '';
  security.polkit.enable = true;
}
