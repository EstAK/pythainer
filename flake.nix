{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
  };

  outputs = { self, nixpkgs, pyproject-nix, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      python = pkgs.python312;
      project = pyproject-nix.lib.project.loadRequirementsTxt {
        projectRoot = ./.;
      };

      pythonEnv =
        assert project.validators.validateVersionConstraints { inherit python; } == { };
        python.withPackages (ps:
          (project.renderers.withPackages { inherit python; } ps)
          ++ [ ps.pip ps.hatchling ]
        );

      pypkgs = pkgs.python312Packages;

    in
      {


        packages.${system}.pythainer = pypkgs.buildPythonPackage {
          format = "pyproject";
          pname = "pythainer"; 
          version= "0.1";

          src = ./.;

          propagatedBuildInputs = [
            pythonEnv
          ];

          build-system = [ pypkgs.hatchling ];
        };

        devShells.${system}.default = pkgs.mkShell {
          packages = [ pythonEnv ];
        };
      };
}
