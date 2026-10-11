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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXMjORUiyuc1f1Jvrd6PFpXRkepYAM43Kt0s8Tmwdyw kevinhernem@gmail.com"
    ];

    # Enable lingering on the server so user services keep running after the login session ends.
    linger = lib.mkIf (profile == "server") true;
  };
}
