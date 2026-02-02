{
  lib,
  buildNpmPackage,
  python3,
  paperless-ai-src,
  makeWrapper,
  ...
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      fastapi
      uvicorn
      python-dotenv
      requests
      numpy
      torch
      sentence-transformers
      chromadb
      rank-bm25
      nltk
      tqdm
      pydantic
    ]
  );
in
buildNpmPackage {
  pname = "paperless-ai";
  version = "unstable";

  src = paperless-ai-src;

  npmDepsHash = "sha256-nAcI3L0fvVI/CdUxWYg8ZiPRDjF7dW+dcIKC3KlHjNQ=";

  nativeBuildInputs = [ makeWrapper ];

  # build phase for better-sqlite3 and other native modules
  # we might need to skip some npm build steps if they are problematic
  dontNpmBuild = true;

  postInstall = ''
    # Create the RAG service bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/paperless-ai-rag \
      --add-flags "$out/lib/node_modules/paperless-ai/main.py"

    # Wrap the main node service to ensure it can find its assets if run from anywhere
    # buildNpmPackage usually creates a bin that calls node on the server.js
  '';

  meta = with lib; {
    description = "An automated document analyzer for Paperless-ngx";
    homepage = "https://github.com/clusterzx/paperless-ai";
    license = licenses.mit;
    maintainers = [ ];
  };
}
