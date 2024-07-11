{ pkgs, config, lib, ... }:

let inherit (import ../../options.nix) gpuType; in
lib.mkIf ("${gpuType}" == "intel") { 
  nixpkgs.config.packageOverrides =
    pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };

  # OpenGL
  hardware.opengl = {
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      #vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };
  environment.sessionVariables ={ LIBVA_DRIVER_NAME = "iHD";};
}
