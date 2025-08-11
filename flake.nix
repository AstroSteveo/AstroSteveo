{
  description = "UltrawideWindows KWin script packaged as a Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ultrawidewindows = {
      url = "github:lucmos/UltrawideWindows";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ultrawidewindows }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          version = ultrawidewindows.shortRev or ultrawidewindows.rev or "unstable";
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "ultrawidewindows";
            inherit version src;
            dontBuild = true;
            nativeBuildInputs = [ pkgs.zip ];
            installPhase = ''
              outDir=$out/share/kwin/scripts/$pname
              mkdir -p $outDir
              cp -r contents metadata.json "$outDir/"
              mkdir -p $out/share/doc/$pname
              cp LICENSE "$out/share/doc/$pname/"
              zip -r "$out/$pname.kwinscript" contents LICENSE metadata.json
            '';
            meta = with pkgs.lib; {
              description = "Expose useful shortcuts to manage windows on ultrawide monitors";
              homepage = "https://github.com/lucmos/UltrawideWindows";
              license = licenses.gpl2;
              platforms = platforms.linux;
            };
          };
        });
    };
}
