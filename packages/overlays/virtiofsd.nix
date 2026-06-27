final: prev: {
  # virtiofs + kvmfr bug patch
  virtiofsd = let
    src = final.fetchFromGitLab {
      owner = "virtio-fs";
      repo = "virtiofsd";
      rev = "2424fed9673f4a013e44b6f59a95427c71757c84";
      hash = "sha256-2mrydMqjduG0yGDekZbE0VGIun+3/UVe0OxBOgyCLK8=";
    };
  in
    prev.virtiofsd.overrideAttrs (_: {
      inherit src;
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-MOEozjN8EbHNyMSSSOP2/GFhlsY5RYOKWOkuGfHewP4=";
      };
    });
}
