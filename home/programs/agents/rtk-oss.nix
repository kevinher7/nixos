{
  lib,
  rtk,
}:
rtk.overrideAttrs (oldAttrs: {
  pname = "rtk-oss";
  cargoBuildNoDefaultFeatures = true;
  cargoCheckNoDefaultFeatures = true;
  checkFlags =
    (oldAttrs.checkFlags or [])
    ++ [
      "--test-threads=1"
      "--skip=curl_forwards_piped_stdin_body"
    ];
  meta = oldAttrs.meta // {license = lib.licenses.asl20;};
})
