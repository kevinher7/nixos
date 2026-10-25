{
  writeShellApplication,
  git,
  gh,
  gum,
  nodejs,
}:
writeShellApplication {
  name = "update-inputs";
  runtimeInputs = [git gh gum nodejs];
  text = builtins.readFile ./script.sh;
}
