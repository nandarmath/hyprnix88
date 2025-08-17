{ lib, ... }:
with lib;
let
  defaultApps = {
    browser = [ "zen-beta.desktop" ];
    text = [ "neovide.desktop" "nvim"];
    image = [ "imv-dir.desktop" ];
    audio = [ "mpv.desktop" ];
    video = [ "mpv.desktop" ];
    directory = [ "thunar.desktop" ];
    office = ["writer.desktop" "calc.desktop" "impress.desktop" "math.desktop" ];
    spreadsheet = [ "calc.desktop"];
    pdf = [
      # "org.gnome.Evince.desktop"
      "com.microsoft.Edge.desktop"
    ];
    terminal = [ "kitty.desktop" ];
    archive = [ "org.gnome.FileRoller.desktop" ];
    discord = [ "vesktop.desktop" ];
  };

  mimeMap = {
    text = [
      "text/plain"
      "txt"
      "text/nix"
      "text/txt"
      "text/sh"
      "text/py"
      "text/qmd"
      "text/R"
      "text/md"
    ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = [ "inode/directory" ];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
      "application/vnd.oasis.opendocument.text-template" 
      "application/vnd.oasis.opendocument.text-web"
      "application/vnd.oasis.opendocument.text-master"
      "application/vnd.sun.xml.writer" 
      "application/vnd.sun.xml.writer.template"
      "application/vnd.sun.xml.writer.global" 
      "application/msword" 
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" 
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template" 
      "application/rtf" 
      "text/rtf" 
      "application/x-doc" 
      "application/vnd.wordperfect" 
      
      
      # LibreOffice Impress - Presentation files
      "application/vnd.oasis.opendocument.presentation" 
      "application/vnd.oasis.opendocument.presentation-template" 
      "application/vnd.sun.xml.impress" 
      "application/vnd.sun.xml.impress.template" 
      "application/vnd.ms-powerpoint" 
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" 
      "application/vnd.openxmlformats-officedocument.presentationml.template"
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow" 
      
      # LibreOffice Draw - Drawing files
      "application/vnd.oasis.opendocument.graphics" 
      "application/vnd.oasis.opendocument.graphics-template" 
      "application/vnd.sun.xml.draw" 
      "application/vnd.sun.xml.draw.template" 
      
      # LibreOffice Math - Formula files
      "application/vnd.oasis.opendocument.formula" 
      "application/vnd.sun.xml.math" 
      
      # LibreOffice Base - Database files
      "application/vnd.oasis.opendocument.database" 
      "application/vnd.sun.xml.base" 

    ];
    spreadsheet =[
      # LibreOffice Calc - Spreadsheet files
      "application/vnd.oasis.opendocument.spreadsheet" 
      "application/vnd.oasis.opendocument.spreadsheet-template" 
      "application/vnd.sun.xml.calc" 
      "application/vnd.sun.xml.calc.template" 
      "application/vnd.ms-excel" 
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" 
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template" 
      "text/csv" 
      "application/csv" 
      "application/x-csv" 
    ];
    pdf = [ "application/pdf" ];
    terminal = [ "terminal" ];
    archive = [
      "application/zip"
      "application/rar"
      "application/7z"
      "application/*tar"
    ];
    discord = [ "x-scheme-handler/discord" ];
  };

  associations =
    with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );
in
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;

  home.sessionVariables = {
    # prevent wine from creating file associations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
