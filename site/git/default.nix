{
  lib,
  pkgs,
  site ? "https://git.maydayv7.cc",
  repos ? import ./repos.nix,
}:
let
  theme = import ./theme.nix pkgs;
  buildCommands = lib.concatMapStrings (repo: ''
    build_repo "${repo.name}" "${repo.description}" "${repo.owner}" "${repo.url}" "${repo.logo or ""}"
  '') repos;
in
pkgs.writeShellApplication {
  name = "build-stagit";
  runtimeInputs = with pkgs; [
    coreutils
    git
    stagit-fork
    xhtml1
  ];

  text = ''
    set -e
    echo "Building Site..."

    BASE_URL=${site}
    OUTPUT_DIR="./public"
    FONTS_SRC="./site/static/fonts"
    FAVICON_SRC="./site/static/desktop.ico"

    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/fonts"

    # 1. Global Assets
    echo "Copying Global Assets..."

    # Fonts
    if [ -d "$FONTS_SRC" ]
    then
      cp "$FONTS_SRC"/* "$OUTPUT_DIR/fonts/"
    else
      echo "Warning: Fonts directory $FONTS_SRC not found."
    fi

    # Theme
    ls $OUTPUT_DIR
    cp "${theme.red}" "$OUTPUT_DIR/style.css"
    cp "${theme.red}" "$OUTPUT_DIR/style-red.css"
    cp "${theme.blue}" "$OUTPUT_DIR/style-blue.css"
    cp "${theme.black}" "$OUTPUT_DIR/style-black.css"

    # Favicon
    if [ -f "$FAVICON_SRC" ]
    then
       cp "$FAVICON_SRC" "$OUTPUT_DIR/favicon.png"
    else
       echo "Warning: Global favicon not found at $FAVICON_SRC"
    fi

    # 2. Build Setup
    BUILD_ROOT=$(mktemp -d)
    trap 'rm -rf "$BUILD_ROOT"' EXIT
    build_repo() {
        NAME=$1
        DESC=$2
        OWNER=$3
        URL=$4
        LOGO=$5

        echo "---------------------------------------"
        echo "Processing $NAME..."
        REPO_DIR="$BUILD_ROOT/$NAME.git"
        git clone --bare "$URL" "$REPO_DIR"

        # Metadata
        echo "$DESC" > "$REPO_DIR/description"
        echo "$OWNER" > "$REPO_DIR/owner"
        echo "$URL" > "$REPO_DIR/url"

        mkdir -p "$OUTPUT_DIR/$NAME"
        if [ -n "$LOGO" ] && [ -f "$LOGO" ]
        then
          cp "$LOGO" "$OUTPUT_DIR/$NAME/logo.png"
        fi

        # Run Stagit
        (cd "$OUTPUT_DIR/$NAME" && stagit -l 50 -u "$BASE_URL/$NAME" "$REPO_DIR")

        # Link Global Assets
        ln -sf ../style.css "$OUTPUT_DIR/$NAME/style.css"
        ln -sf ../favicon.png "$OUTPUT_DIR/$NAME/favicon.png"
        echo "---------------------------------------"
    }

    # 3. Execute Builds
    ${buildCommands}

    # 4. Generate Index
    echo "Generating Index..."
    stagit-index "$BUILD_ROOT"/*.git > "$OUTPUT_DIR/index.html"

    echo "Successfully built to $OUTPUT_DIR!"
  '';
}
