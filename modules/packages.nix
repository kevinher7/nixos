{ pkgs, ... }:
{
  users.users.kevin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    packages = with pkgs; [ tree ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
    ghostty
    pavucontrol
    pasystray
    btop
    xwallpaper
    pfetch
    pcmanfm
    rofi
    xsecurelock
    papirus-icon-theme
    statix
  ];

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
