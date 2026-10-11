{
  pkgs,
  username,
  profile,
  lib,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "video"];
    shell = pkgs.bash;

    # Enable lingering on the server so user services keep running after the login session ends.
    linger = lib.mkIf (profile == "server") true;
  };
}
