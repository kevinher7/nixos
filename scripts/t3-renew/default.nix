{
  writeShellApplication,
  coreutils,
  gnugrep,
  openssh,
  qrencode,
}:
writeShellApplication {
  name = "t3-renew";
  runtimeInputs = [coreutils gnugrep openssh qrencode];
  text = builtins.readFile ./script.sh;
}
