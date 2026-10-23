{ ... }:

{
  flake.nixosModules.sync = { pkgs, ... }:
    let
      git-sync-bin = pkgs.writeShellApplication {
        name = "git-sync-bin";
        runtimeInputs = with pkgs; [ git coreutils gum repomix bash ];
        text = ''
          r() { gum style --foreground 1 "$*"; }
          g() { gum style --foreground 2 "$*"; }
          y() { gum style --foreground 3 "$*"; }
          b() { gum style --foreground 4 "$*"; }
          m() { gum style --foreground 5 "$*"; }
          w() { gum style --foreground 7 "$*"; }

          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              gum join --horizontal "$(r "[!] ")" "Error: Not in a git repository."
              exit 1
          fi

          GIT_ROOT=$(git rev-parse --show-toplevel)
          cd "$GIT_ROOT"

          SKIP_XML=false
          NO_MSG_PROMPT=false
          MSG_ARG=""

          for arg in "$@"; do
            if [ "$arg" = "--no-xml" ]; then
              SKIP_XML=true
            elif [ "$arg" = "--nm" ]; then
              NO_MSG_PROMPT=true
            else
              if [ -z "$MSG_ARG" ]; then
                MSG_ARG="$arg"
              fi
            fi
          done

          if [ -f "$GIT_ROOT/.sync.sh" ]; then
              echo
              gum join --horizontal "$(m "[>] ")" "Custom sync script found: " "$(y ".sync.sh")"
              chmod +x "$GIT_ROOT/.sync.sh"
              bash "$GIT_ROOT/.sync.sh" "$@"
          fi

          if [ "$SKIP_XML" = false ]; then
              echo
              gum join --horizontal "$(m "[>] ")" "Running Repomix..."
              repomix --quiet || true
          fi

          BRANCH=$(git branch --show-current 2>/dev/null || echo "")
          if [ -z "$BRANCH" ]; then
              BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
          fi

          echo
          gum join --horizontal "$(m "[>] ")" "Syncing " "$(y "$GIT_ROOT") to " "$(b "origin/$BRANCH")"
          echo

          gum join --horizontal "$(m "[>] ")" "Staging changes..."
          git add .

          if ! git diff-index --quiet HEAD --; then
              GEN_MSG=$(date -u +'%Y-%m-%d at %H:%M UTC')
              if [ "$NO_MSG_PROMPT" = "true" ]; then
                  MSG="''${MSG_ARG:-$GEN_MSG}"
              else
                  DEFAULT_VAL="$MSG_ARG"
                  if [ -z "$DEFAULT_VAL" ]; then
                      DEFAULT_VAL="$GEN_MSG"
                  fi
                  PROMPT_MSG=$(gum input --width 60 --placeholder "Enter commit message (Press Enter for default: $DEFAULT_VAL)" --value "")
                  if [ -z "$PROMPT_MSG" ]; then
                      MSG="$DEFAULT_VAL"
                  else
                      MSG="$PROMPT_MSG"
                  fi
              fi

              echo
              gum join --horizontal "$(g "[+] ")" "Committing: " "$(w "$MSG")"
              git commit -m "$MSG"
          else
              echo
              gum join --horizontal "$(y "[~] ")" "No changes to commit."
          fi

          if ! git remote | grep -q "^origin$"; then
              echo
              gum join --horizontal "$(y "[!] ")" "No " "$(b "origin")" " remote found. Skipping push."
          else
              echo
              gum join --horizontal "$(m "[>] ")" "Pushing to " "$(b "origin/$BRANCH")" "..."
              if git push -u origin "$BRANCH"; then
                  gum join --horizontal "$(g "[+] ")" "Push successful."
              else
                  gum join --horizontal "$(r "[!] ")" "Push failed."
              fi
          fi

          echo
          gum join --horizontal "$(g "[+] ")" "Sync Complete."
        '';
      };
    in
    {
      environment.systemPackages = [ git-sync-bin ];
    };
}
