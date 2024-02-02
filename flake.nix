{
  description = "A flake to build itemdb";

  inputs = {
    # pulls in the flake.nix file from this github repo    
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

  };

  outputs = inputs@{ self, nixpkgs }: rec {

    # I'm not sure why I need to import nixpkgs in order for python3Packages to appear. 
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    
    speech_recognition = pkgs.python3Packages.buildPythonPackage {
      pname = "speech_recognition";
      version = "v3.10.0";
      src = pkgs.fetchFromGitHub {
        owner = "Adam-D-Lewis";
        repo = "speech_recognition";
        rev = "8b07762";
        sha256 = "sha256-w+BXfzsEtikPLnHDCI48aXTVLRxfDg43IAOzuAShngY=";
      };
      propagatedBuildInputs = with pkgs.python3Packages; [
        requests 
        pyaudio
      ];
      checkPhase = ''
        runHook preCheck    
        # skip tests                
        runHook postCheck    
      '';
      pythonImportsCheck = [ 
        "speech_recognition" 
        ];
    };

    legacyPackages.x86_64-linux = { inherit speech_recognition; };
    defaultPackage.x86_64-linux = legacyPackages.x86_64-linux.speech_recognition;
    
    # develop
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs =
        [ (pkgs.python3.withPackages (pypkgs: with pkgs.python3Packages; [ speech_recognition ])) ];
    };
  };
}
