{
  writeShellApplication,
  curl,
  git,
  gum,
  openssh,
}:
writeShellApplication {
  name = "fleet-deploy";
  runtimeInputs = [curl git gum openssh];
  excludeShellChecks = ["SC1087" "SC2029" "SC2329"];
  text = builtins.readFile ./script.sh;
}
