{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/sway
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/input
    ../../modules/audio
    ../../modules/bluetooth
    ../../modules/t3code
  ];

  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  myModules = {
    power.profile = "laptop";

    theming.wallpaper = ../../assets/wallpapers/orion-nebula.jpg;

    input.waylandFrontend = true;

    networking = {
      enable = true;
      tailscale = {
        enable = true;
        ssh = false;
        operatorUser = "kevin";
      };
    };

    t3code = {
      enable = true;
      tailscaleServe.enable = true;
    };
  };

  # AMD Radeon integrated graphics.
  hardware.enableRedistributableFirmware = true;

  # amd-pstate exposes EPP through the `powersave` governor; unlike
  # intel_pstate, pinning `performance` here would ignore the EPP hint
  # entirely and keep the cores boosting on battery.
  services.auto-cpufreq.settings.battery.governor = "powersave";
}
