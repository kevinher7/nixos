{ pkgs, username, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
