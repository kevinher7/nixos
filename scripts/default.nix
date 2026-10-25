{pkgs}: {
  fleet-deploy = pkgs.callPackage ./fleet-deploy {};
  rotate-secrets = pkgs.callPackage ./rotate-secrets {};
  update-inputs = pkgs.callPackage ./update-inputs {};
  t3-renew = pkgs.callPackage ./t3-renew {};
}
