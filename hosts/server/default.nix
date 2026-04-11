{ pkgs, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/docker.nix
    ../../modules/desktop/qtile
    ../../modules/networking
    ../../modules/login
  ];

  myModules.networking = {
    enable = true;
    hostname = hostname;
    tailscale = {
      enable = true;
      openFirewall = true;
      ssh = true;
    };
  };

  time.timeZone = "Asia/Tokyo";

  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  users.users.uribo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ]; # Enable 'sudo' for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alacritty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}

