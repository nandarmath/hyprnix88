{
  imports = [./tlp.nix];
  powerManagement.enable = true;
  services = {
    auto-cpufreq.enable = false;
    thermald = {
      enable = true;
      configFile = "/etc/thermald.xml";
    };
  };
  environment.etc = {
    "auto-cpufreq.conf" = {
      enable = true;
      source = ./auto-cpufreq.conf;
    };
    "thermal-conf.xml" = {
      enable = true;
      source = ./thermal-conf.xml;
      target = "thermald.xml";
    };
  };
}
