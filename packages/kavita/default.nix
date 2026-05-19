{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildDotnetModule,
  buildNpmPackage,
  dotnetCorePackages,
  ...
}:
let
  version = "0.9.0.2";
  src = fetchFromGitHub {
    owner = "kareadita";
    repo = "kavita";
    rev = "v${version}";
    hash = "sha256-Wfb/Lc+BvkiJLopH1NQx1YQWzm2Sdmvg1Xmn+8YwWus=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kavita";
  inherit version src;

  backend = buildDotnetModule {
    pname = "kavita-backend";
    inherit (finalAttrs) version src;

    patches = [ ];

    postPatch = ''
      rm global.json

      # Fix directory paths to point to the nix store
      substituteInPlace Kavita.Services/DirectoryService.cs \
        --replace-fail 'FileSystem.Path.Join(FileSystem.Directory.GetCurrentDirectory(), "Assets")' 'FileSystem.Path.Join("@out@/lib/kavita-backend", "Assets")' \
        --replace-fail 'FileSystem.Path.Join(FileSystem.Directory.GetCurrentDirectory(), "I18N")' 'FileSystem.Path.Join("@out@/lib/kavita-backend", "I18N")' \
        --replace-fail 'FileSystem.Path.Join(FileSystem.Directory.GetCurrentDirectory(), "EmailTemplates")' 'FileSystem.Path.Join("@out@/lib/kavita-backend", "EmailTemplates")'
      
      # Remove ExistOrCreate calls for read-only store paths
      sed -i '/AssetsDirectory = FileSystem.Path.Join/n; /ExistOrCreate(AssetsDirectory);/d' Kavita.Services/DirectoryService.cs
      sed -i '/TemplateDirectory = FileSystem.Path.Join/n; /ExistOrCreate(TemplateDirectory);/d' Kavita.Services/DirectoryService.cs
      
      substituteInPlace Kavita.Services/DirectoryService.cs --subst-var out

      # Define webroot placeholder
      webroot="${finalAttrs.frontend}/lib/node_modules/kavita-webui/dist/browser"

      substituteInPlace Kavita.Server/Controllers/FallbackController.cs \
        --replace-fail 'Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "index.html")' "Path.Combine(\"$webroot\", \"index.html\")"

      # Fix LocalizationService.cs
      substituteInPlace Kavita.Services/LocalizationService.cs \
        --replace-fail 'directoryService.FileSystem.Directory.GetCurrentDirectory()' "\"$webroot\"" \
        --replace-fail '"wwwroot", ' ""

      # Fix Startup.cs
      substituteInPlace Kavita.Server/Startup.cs \
        --replace-fail 'UpdateBaseUrlInIndex(basePath);' '// UpdateBaseUrlInIndex(basePath);' \
        --replace-fail 'Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "index.html")' "Path.Combine(\"$webroot\", \"index.html\")" \
        --replace-fail 'ContentTypeProvider = new FileExtensionContentTypeProvider' "FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(\"$webroot\"), ContentTypeProvider = new FileExtensionContentTypeProvider"
    '';

    executables = [ "Kavita.Server" ];

    projectFile = "Kavita.Server/Kavita.Server.csproj";
    nugetDeps = ./deps.json;
    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  };

  frontend = buildNpmPackage {
    pname = "kavita-frontend";
    inherit (finalAttrs) version src;

    sourceRoot = "${finalAttrs.src.name}/UI/Web";

    npmBuildScript = "prod";
    npmFlags = [ "--legacy-peer-deps" ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    npmDepsHash = "sha256-Qa/lf0hH2KMDdRcBj8GW9cJGE3YZsP32z2kfTk6YNYc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/kavita
    ln -s $backend/lib/kavita-backend $out/lib/kavita/backend
    ln -s $frontend/lib/node_modules/kavita-webui/dist $out/lib/kavita/frontend
    ln -s $backend/bin/Kavita.Server $out/bin/kavita

    runHook postInstall
  '';

  meta = {
    description = "Fast, feature rich, cross platform reading server";
    homepage = "https://kavitareader.com";
    changelog = "https://github.com/kareadita/kavita/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "kavita";
  };
})
