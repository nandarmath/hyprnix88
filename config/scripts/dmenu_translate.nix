#!/bin/bash
# File              : dmenu_translate
# License           : MIT License
# Author            : M. Nabil Adani <nblid48@gmail.com>
# Date              : Kamis, 30/07/2020 22:25 WIB
# Last Modified Date: Minggu, 02/08/2020 16:31 WIB
# Last Modified By  : M. Nabil Adani <nblid48@gmail.com>
{pkgs}:

pkgs.writeShellScriptBin "dmenu_translate" ''
DMENU="rofi -dmenu -i"
ICON="$HOME/Dotfiles/icons/linebit/keyboard.png"
COUNTRY=''''
[
  { "code": "af", "name": "Afrikaans" },
  { "code": "am", "name": "Amharic" },
  { "code": "ar", "name": "Arabic" },
  { "code": "az", "name": "Azerbaijani" },
  { "code": "ba", "name": "Bashkir" },
  { "code": "be", "name": "Belarusian" },
  { "code": "bg", "name": "Bulgarian" },
  { "code": "bn", "name": "Bengali" },
  { "code": "bs", "name": "Bosnian" },
  { "code": "ca", "name": "Catalan" },
  { "code": "ceb", "name": "Cebuano" },
  { "code": "co", "name": "Corsican" },
  { "code": "cs", "name": "Czech" },
  { "code": "cy", "name": "Welsh" },
  { "code": "da", "name": "Danish" },
  { "code": "de", "name": "German" },
  { "code": "el", "name": "Greek" },
  { "code": "en", "name": "English" },
  { "code": "eo", "name": "Esperanto" },
  { "code": "es", "name": "Spanish" },
  { "code": "et", "name": "Estonian" },
  { "code": "eu", "name": "Basque" },
  { "code": "fa", "name": "Persian" },
  { "code": "fi", "name": "Finnish" },
  { "code": "fj", "name": "Fijian" },
  { "code": "fr", "name": "French" },
  { "code": "fy", "name": "Frisian" },
  { "code": "ga", "name": "Irish" },
  { "code": "gd", "name": "Scots" },
  { "code": "gl", "name": "Galician" },
  { "code": "gu", "name": "Gujarati" },
  { "code": "ha", "name": "Hausa" },
  { "code": "haw", "name": "Hawaiian" },
  { "code": "he", "name": "Hebrew" },
  { "code": "hi", "name": "Hindi" },
  { "code": "hmn", "name": "Hmong" },
  { "code": "hr", "name": "Croatian" },
  { "code": "ht", "name": "Haitian" },
  { "code": "hu", "name": "Hungarian" },
  { "code": "hy", "name": "Armenian" },
  { "code": "id", "name": "Indonesian" },
  { "code": "ig", "name": "Igbo" },
  { "code": "is", "name": "Icelandic" },
  { "code": "it", "name": "Italian" },
  { "code": "ja", "name": "Japanese" },
  { "code": "jv", "name": "Javanese" },
  { "code": "ka", "name": "Georgian" },
  { "code": "kk", "name": "Kazakh" },
  { "code": "km", "name": "Khmer" },
  { "code": "kn", "name": "Kannada" },
  { "code": "ko", "name": "Korean" },
  { "code": "ku", "name": "Kurdish" },
  { "code": "ky", "name": "Kyrgyz" },
  { "code": "la", "name": "Latin" },
  { "code": "lb", "name": "Luxembourgish" },
  { "code": "lo", "name": "Lao" },
  { "code": "lt", "name": "Lithuanian" },
  { "code": "lv", "name": "Latvian" },
  { "code": "mg", "name": "Malagasy" },
  { "code": "mhr", "name": "Eastern" },
  { "code": "mi", "name": "Maori" },
  { "code": "mk", "name": "Macedonian" },
  { "code": "ml", "name": "Malayalam" },
  { "code": "mn", "name": "Mongolian" },
  { "code": "mr", "name": "Marathi" },
  { "code": "mrj", "name": "Hill" },
  { "code": "ms", "name": "Malay" },
  { "code": "mt", "name": "Maltese" },
  { "code": "mww", "name": "Hmong" },
  { "code": "my", "name": "Myanmar" },
  { "code": "ne", "name": "Nepali" },
  { "code": "nl", "name": "Dutch" },
  { "code": "no", "name": "Norwegian" },
  { "code": "ny", "name": "Chichewa" },
  { "code": "or", "name": "Oriya" },
  { "code": "otq", "name": "Querétaro" },
  { "code": "pa", "name": "Punjabi" },
  { "code": "pap", "name": "Papiamento" },
  { "code": "pl", "name": "Polish" },
  { "code": "ps", "name": "Pashto" },
  { "code": "pt", "name": "Portuguese" },
  { "code": "ro", "name": "Romanian" },
  { "code": "ru", "name": "Russian" },
  { "code": "rw", "name": "Kinyarwanda" },
  { "code": "sd", "name": "Sindhi" },
  { "code": "si", "name": "Sinhala" },
  { "code": "sk", "name": "Slovak" },
  { "code": "sl", "name": "Slovenian" },
  { "code": "sm", "name": "Samoan" },
  { "code": "sn", "name": "Shona" },
  { "code": "so", "name": "Somali" },
  { "code": "sq", "name": "Albanian" },
  { "code": "sr-Cyrl", "name": "Serbian" },
  { "code": "sr-Latn", "name": "Serbian" },
  { "code": "st", "name": "Sesotho" },
  { "code": "su", "name": "Sundanese" },
  { "code": "sv", "name": "Swedish" },
  { "code": "sw", "name": "Swahili" },
  { "code": "ta", "name": "Tamil" },
  { "code": "te", "name": "Telugu" },
  { "code": "tg", "name": "Tajik" },
  { "code": "th", "name": "Thai" },
  { "code": "tk", "name": "Turkmen" },
  { "code": "tl", "name": "Filipino" },
  { "code": "tlh", "name": "Klingon" },
  { "code": "tlh-Qaak", "name": "Klingon" },
  { "code": "to", "name": "Tongan" },
  { "code": "tr", "name": "Turkish" },
  { "code": "tt", "name": "Tatar" },
  { "code": "ty", "name": "Tahitian" },
  { "code": "udm", "name": "Udmurt" },
  { "code": "ug", "name": "Uyghur" },
  { "code": "uk", "name": "Ukrainian" },
  { "code": "ur", "name": "Urdu" },
  { "code": "uz", "name": "Uzbek" },
  { "code": "vi", "name": "Vietnamese" },
  { "code": "xh", "name": "Xhosa" },
  { "code": "yi", "name": "Yiddish" },
  { "code": "yo", "name": "Yoruba" },
  { "code": "yua", "name": "Yucatec" },
  { "code": "yue", "name": "Cantonese" },
  { "code": "zh-CN", "name": "Chinese" },
  { "code": "zh-TW", "name": "Chinese" },
  { "code": "zu", "name": "Zulu" }
]
''''

function translateText() {
    text="$1"
    if [ -z "$text" ]; then
        exit
    fi
    name=$(echo $COUNTRY | jq -r ".[].name" | $DMENU -p "Translate ")
    if [ ! -z "$name" ]; then
        code=$(echo $COUNTRY | jq -r ".[] | select(.name == \"$name\") | .code")
        result=$(trans -b --download-audio-as /tmp/trans.ts :$code "$text")
        again=true

        notify-send -i $ICON "Translate" "Result saved to clipboard"
        echo -n "$result" | wl-copy 

        while $again; do
            speak=$(echo -e "Yes\nNo" | $DMENU -theme-str "listview {lines:2;}" -p "Play Audio" -mesg "Result: $result")
            if [[ $speak == "Yes" ]]; then
                notify-send -i $ICON "Translate" "Listen to the translation."
                mpv /tmp/trans.ts
            else
                again=false
            fi
        done
    fi
}

function fromClip() {
    text=$(wl-paste)
    translateText "$text"
}

function fromInput() {
    text=$($DMENU -p "Translate" -l 0)
    translateText "$text"
}

case "$1" in
"-c" | "--clipboard")
    fromClip
    ;;
"-i" | "--input")
    fromInput
    ;;
*)
    echo "Usage dmenu_translate [options]"
    echo ""
    echo "Available Options:"
    echo "-c   --clipboard   read text from clipboard"
    echo "-i   --input       read text from user input"
    echo ""
    ;;
esac

''
