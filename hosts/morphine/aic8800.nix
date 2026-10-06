{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

let
  firmware = fetchFromGitHub {
    owner = "gtxaspec";
    repo = "aic8800-wifi";
    rev = "master";
    hash = "sha256-I1oNykTLgdJMb3wbf0OYX5jHMN8SLanYGW8WD7fUg4A=";
  };
in
stdenv.mkDerivation {
  pname = "aic8800";
  version = "6.4.3.0-8";

  src = fetchFromGitHub {
    owner = "ronnyf";
    repo = "AIC8800-Linux-Driver";
    tag = "v6.4.3.0-8";
    hash = "sha256-WWrl6sU4IEhMyo9p9yEHXFdyrehKuwMnQ5i9jDvPGIE=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    runHook preBuild

    make -C drivers/aic8800 \
      KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 \
      drivers/aic8800/aic_load_fw/aic_load_fw.ko \
      "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/aic8800/aic_load_fw.ko"

    install -Dm644 \
      drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko \
      "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/aic8800/aic8800_fdrv.ko"

    mkdir -p "$out/lib/firmware/aic8800"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fmacfw.bin \
      "$out/lib/firmware/aic8800/fmacfw.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_adid_u03.bin \
      "$out/lib/firmware/aic8800/fw_adid_u03.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_patch_u03.bin \
      "$out/lib/firmware/aic8800/fw_patch_u03.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_patch_table_u03.bin \
      "$out/lib/firmware/aic8800/fw_patch_table_u03.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/aic_userconfig.txt \
      "$out/lib/firmware/aic8800/aic_userconfig.txt"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_adid.bin \
      "$out/lib/firmware/aic8800/fw_adid.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_patch.bin \
      "$out/lib/firmware/aic8800/fw_patch.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_patch_table.bin \
      "$out/lib/firmware/aic8800/fw_patch_table.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fmacfw_rf.bin \
      "$out/lib/firmware/aic8800/fmacfw_rf.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_adid_rf.bin \
      "$out/lib/firmware/aic8800/fw_adid_rf.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/fw_ble_scan.bin \
      "$out/lib/firmware/aic8800/fw_ble_scan.bin"

    install -Dm644 \
      ${firmware}/USB/driver_fw/fw/aic8800/m2d_ota.bin \
      "$out/lib/firmware/aic8800/m2d_ota.bin"

    runHook postInstall
  '';
}
