{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "video"];
    shell = pkgs.bash;
  };
}
