{ ... }:

{
  flake.nixosModules.ns = { pkgs, id, ... }:
    let
      ns = pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [ git coreutils gum rsync openssh ];
        text = ''
          rb() { gum style --foreground 1 --bold "$*"; }
          gb() { gum style --foreground 2 --bold "$*"; }
          yb() { gum style --foreground 3 --bold "$*"; }
          bb() { gum style --foreground 4 --bold "$*"; }
          mb() { gum style --foreground 5 --bold "$*"; }
          wb() { gum style --foreground 7 --bold "$*"; }
          r() { gum style --foreground 1 "$*"; }
          g() { gum style --foreground 2 "$*"; }
          y() { gum style --foreground 3 "$*"; }
          b() { gum style --foreground 4 "$*"; }
          m() { gum style --foreground 5 "$*"; }
          w() { gum style --foreground 7 "$*"; }

          SKIP_GIT=false
          MSG_ARG=""

          for arg in "$@"; do
            if [ "$arg" = "--ng" ]; then
              SKIP_GIT=true
            else
              if [ -z "$MSG_ARG" ]; then
                MSG_ARG="$arg"
              fi
            fi
          done

          MSG="''${MSG_ARG:-$(date -u +'%Y-%m-%d %H:%M UTC')}"
          cd "${id.repoPath}"

          if [ "$SKIP_GIT" = "false" ]; then
              echo
              gum join --horizontal "$(m "[>] ")" "Committing local changes..."
              git add .
              if ! git diff-index --quiet HEAD --; then
                  git commit -m "$MSG"
              else
                  gum join --horizontal "$(y "[~] ")" "No changes to commit locally."
              fi
          fi

          LAB_HOST="''${LAB_HOST:-lab}"
          LAB_REPO_PATH="''${LAB_REPO_PATH:-${id.repoPath}}"

          echo
          gum join --horizontal "$(m "[>] ")" "Mirroring to Lab: " "$(y "$LAB_HOST:$LAB_REPO_PATH")" "..."

          if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$LAB_HOST" "mkdir -p '$LAB_REPO_PATH'"; then
              gum join --horizontal "$(r "[!] ")" "Cannot reach Lab over SSH."
              exit 1
          fi

          if rsync -aHAX --delete --no-owner --no-group --protect-args \
            "${id.repoPath}/" "$LAB_HOST:$LAB_REPO_PATH/";
          then
              gum join --horizontal "$(g "[+] ")" "Lab is now a perfect mirror."
          else
              gum join --horizontal "$(r "[!] ")" "Mirroring to Lab failed."
              exit 1
          fi

          if [ "$SKIP_GIT" = "false" ]; then
              if git remote | grep -q "^origin$"; then
                  RAW_ADDR=$(git remote get-url origin)
                  TARGET_ADDR=''${RAW_ADDR%.git}
                  TARGET_ADDR=''${TARGET_ADDR%/}
                  BRANCH=$(git branch --show-current)
                  BRANCH="''${BRANCH:-main}"

                  echo
                  gum join --horizontal "$(m "[>] ")" "Pushing to Origin: " "$(y "$TARGET_ADDR")" "..."

                  if git push -u origin "$BRANCH"
                  then
                      gum join --horizontal "$(g "[+] ")" "Pushed to Origin."
                  else
                      gum join --horizontal "$(r "[!] ")" "Push failed."
                  fi
              fi
          fi
        '';
      };
    in
    {
      environment.systemPackages = [ ns ];
    };
}
