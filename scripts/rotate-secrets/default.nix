{
  writeShellApplication,
  age,
  coreutils,
  gh,
  git,
  gnugrep,
  gnused,
  gum,
  jq,
  nix,
  openssl,
  sops,
}:
writeShellApplication {
  name = "rotate-secrets";
  runtimeInputs = [age coreutils gh git gnugrep gnused gum jq nix openssl sops];
  text = builtins.readFile ./script.sh;
}
