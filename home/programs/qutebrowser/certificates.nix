{
  config,
  lib,
  pkgs,
  osFamily,
  ...
}: let
  compromisedIntermediates = pkgs.fetchurl {
    url = "https://emudhra.we-have-a-problem.com/impacted-intermediates.json";
    hash = "sha256-9ns6vptIefTpGHTtBBvszXElfx20HFiMckzPEqqQxZ4=";
  };
  distrustedCertificates =
    pkgs.runCommand "qutebrowser-distrusted-certificates" {
      nativeBuildInputs = [pkgs.jq];
    } ''
      mkdir -p "$out"
      jq -r '.[].sha256 | ascii_downcase' ${compromisedIntermediates} | while read -r sha; do
        jq -r --arg sha "$sha" \
          '.[] | select((.sha256 | ascii_downcase) == $sha) | .pem' \
          ${compromisedIntermediates} > "$out/$sha.pem"
      done
    '';
in {
  config = lib.mkIf (config.myPrograms.qutebrowser.enable && osFamily == "linux") {
    home.activation.distrustCompromisedCertificates = lib.hm.dag.entryAfter ["writeBoundary"] ''
      nssDb="${config.home.homeDirectory}/.pki/nssdb"
      run mkdir -p -m 700 "$nssDb"
      if [[ ! -e "$nssDb/cert9.db" ]]; then
        run ${pkgs.nssTools}/bin/certutil -N -d "sql:$nssDb" --empty-password
      fi
      for certificate in ${distrustedCertificates}/*.pem; do
        run ${pkgs.nssTools}/bin/certutil -A -a -d "sql:$nssDb" \
          -t p,p,p -n "eMudhra $(basename "$certificate" .pem)" -i "$certificate"
      done
    '';
  };
}
