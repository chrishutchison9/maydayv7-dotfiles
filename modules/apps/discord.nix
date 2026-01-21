{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  enable = builtins.elem "discord" config.apps.list;
  package = pkgs.vesktop;
in
{
  ## Discord Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = [ package ];
    user.homeConfig = {
      imports = [ inputs.nixcord.homeModules.nixcord ];
      home.persist.directories = [ ".config/vesktop" ];
      programs.nixcord = {
        enable = true;
        discord.enable = false;
        vesktop = {
          enable = true;
          inherit package;
        };

        config = {
          # Theming
          useQuickCss = true;
          frameless = false;
          transparent = false;

          # Vencord Plugins
          plugins = {
            betterFolders = {
              enable = true;
              showFolderIcon = 2;
              closeAllHomeButton = true;
            };
            betterGifAltText.enable = true;
            betterGifPicker.enable = true;
            betterRoleContext.enable = true;
            betterSessions.enable = true;
            betterSettings.enable = true;
            biggerStreamPreview.enable = true;
            BlurNSFW.enable = true;
            copyEmojiMarkdown.enable = true;
            copyFileContents.enable = true;
            CopyUserURLs.enable = true;
            crashHandler.enable = true;
            decor.enable = true;
            expressionCloner.enable = true;
            favoriteEmojiFirst.enable = true;
            favoriteGifSearch.enable = true;
            fixImagesQuality.enable = true;
            fixSpotifyEmbeds.enable = true;
            friendsSince.enable = true;
            fullSearchContext.enable = true;
            imageZoom.enable = true;
            memberCount.enable = true;
            mentionAvatars.enable = true;
            messageClickActions.enable = true;
            messageLinkEmbeds.enable = true;
            PinDMs.enable = true;
            platformIndicators.enable = true;
            previewMessage.enable = true;
            quickMention.enable = true;
            readAllNotificationsButton.enable = true;
            relationshipNotifier.enable = true;
            replyTimestamp.enable = true;
            serverInfo.enable = true;
            serverListIndicators.enable = true;
            showHiddenChannels.enable = true;
            showHiddenThings.enable = true;
            showMeYourName.enable = true;
            showTimeoutDuration.enable = true;
            typingTweaks.enable = true;
            validUser.enable = true;
            voiceChatDoubleClick.enable = true;
            voiceDownload.enable = true;
            voiceMessages.enable = true;
            volumeBooster.enable = true;
            webKeybinds.enable = true;
            webScreenShareFixes.enable = true;
          };
        };
      };
    };
  };
}
