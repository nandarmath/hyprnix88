#!/bin/bash

# Pasopati by Rania Amina (me@raniaamina)
# VERSION=1.9.7
{ pkgs }:

pkgs.writeShellScriptBin "pasopati" ''


set -e

DIALOGSET="--center --no-escape --window-icon=/opt/pasopati/pasopati.png --width=450 --height=550"
KEY=`echo $RANDOM`

if [ "$1" = "--version" ] ; then
  echo -e "\n  Pasopati v$VERSION"
  echo -e "  by Devlovers ID\n"
  exit 0
fi

if [ "$1" = "--donate" ] ; then
  echo 'Membuka halaman donasi ...'
  xdg-open https://support.dev-is.my.id/
  exit 0
fi


if [ "$1" = "--docs" ] ; then
  echo 'Membuka halaman repositori ...'
  xdg-open https://github.com/raniaamina/pasopati
  exit 0
fi


if [ "$1" = "--help" ] ; then
  echo
  echo "Penggunaan Umum:"
  echo "pasopati [NAMA-FOLDER]"
  echo "  Contoh: pasopati folder-saya"
  echo ""
  echo "Parameter Khusus"
  echo "  --version             Menampilkan versi Inkporter"
  echo "  --docs                Membuka halaman dokumentasi"
  echo "  --donate              Membuka halaman donasi"
  echo "  --help                Menampilkan halaman bantuan"
  echo 
  echo "Pasopati v$VERSION"
  echo "https://github.com/raniaamina/pasopati"
  echo
  exit 0
fi

MAINDIR=$PWD
SCDIR=$1
CONFIG_DIR="$HOME/.config/pasopati.cfg"

# Read Last Setting
if [[ -f $CONFIG_DIR ]] ; then
echo "[*] Found Config file: $CONFIG_DIR"
WidthConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "1q;d")
HeightConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "2q;d")
QualityConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "3q;d")
ColospaceConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "4q;d")
FormatConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "5q;d")
CoreConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "6q;d")
CropConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "7q;d")
OptimizeConf=$(cat ~/.config/pasopati.cfg | egrep -v "^\s*(#|$)" | sed "8q;d")

else
echo "[X] Found Config Not Found, it we'll creat it later."
WidthConf="0\!0..10000\!1\!0"
HeightConf="0\!0..10000\!1\!0"
QualityConf="90\!1..100\!1\!0"
ColospaceConf="RGB!CMYK"
FormatConf="Default!PNG!JPG"
CoreConf="4\!1..12\!1\!0"
CropConf="FALSE"
OptimizeConf="FALSE"
fi


yad --plug=$KEY --tabnum=1 --form --title="Pasopati" $DIALOGSET --scroll --focus-field=1 \
--field=" Folder Sumber":DIR \
--field=" Folder Ekspor":DIR \
--field=" Lebar (px)":NUM \
--field=" Tinggi (px)":NUM \
--field=" Kualitas":SCL \
--field=" Colorspace":CB \
--field=" Export Format":CB \
--field=" Core to Use":NUM \
--field=" Crop Result":CHK \
--field=" Optimize PNG":CHK \
--separator=$'\n' \
-- "$SCDIR" "$MAINDIR" "$WidthConf" "$HeightConf" "$QualityConf" "$ColospaceConf" "$FormatConf" "$CoreConf" "$CropConf" "$OptimizeConf"\
> /tmp/pasoresizer-tmp &

# yad --plug=$KEY --tabnum=2 --form --title="Pasopati" $DIALOGSET  \
# --title="Pasopati" \
# --text="\nPasopati merupakan perkakas pengubah ukuran gambar secara masal yang dikembangkan oleh Devlovers ID.\n\nCara penggunaan:\nKlik kanan berkas yang memuat gambar Anda, lalu buka dengan Pasopati. Isi paramter dan klik Ok/Apply!" \
# > /tmp/pasoabout-tmp &

# Main tab Setting
yad $DIALOGSET --center --notebook --key=$KEY  --tab="Bulk Resize"  \
--image-on-top \
--title="Pasopati" \
--image=/opt/pasopati/pasopati.png \
--text="\nPasopati merupakan perkakas pengubah ukuran gambar secara masal yang dikembangkan oleh Devlovers ID.\n\nhttps://dev-is.my.id/"

# Variableset
SCDIR=`sed "1q;d" /tmp/pasoresizer-tmp`
OUTPUTDIR=`sed "2q;d" /tmp/pasoresizer-tmp`
WIDTH="`sed "3q;d" /tmp/pasoresizer-tmp`"
HEIGHT=`sed "4q;d" /tmp/pasoresizer-tmp`
QUALITY=`sed "5q;d" /tmp/pasoresizer-tmp`
COLORSPACE=`sed "6q;d" /tmp/pasoresizer-tmp`
EXFORMAT=`sed "7q;d" /tmp/pasoresizer-tmp`
CORES=`sed "8q;d" /tmp/pasoresizer-tmp`
CROPSTAT=`sed "9q;d" /tmp/pasoresizer-tmp`
PNGOPT=`sed "10q;d" /tmp/pasoresizer-tmp`

# cat /tmp/pasoresizer-tmp


GEOMETRY="$WIDTH"x"$HEIGHT"
if [[ $HEIGHT == 0 ]]; then
    GEOMETRY=`echo "$WIDTH"x`
    # echo $GEOMETRY 
fi

if [[ $WIDTH == 0 ]]; then
    GEOMETRY=`echo "x$HEIGHT"`
    # echo $GEOMETRY 
fi

if [[ $CROPSTAT == TRUE ]]; then
    CROPIMG="`echo -gravity center -crop "$WIDTH"x"$HEIGHT"+0+0`"
    # echo $CROPIMG 
else
    CROPIMG=" "
    # echo $CROPIMG
fi


# Variabel Check
echo -e "\nRingkasan Proses: \n Memproses berkas dari folder: \n  $SCDIR \n ke folder: \n  $OUTPUTDIR \n dengan ukuran: $GEOMETRY (px) \n di kualitas: $QUALITY \n dengan palet: $COLORSPACE \n ke format: $EXFORMAT \n"

# export 
[[ ! -d $OUTPUTDIR ]] && mkdir -p $OUTPUTDIR
cd "$SCDIR"
echo -e "\nfolder Saat ini:\n $PWD\n"
# echo "target folder $OUTPUTDIR"


CONVERT_JPG () {
    COUNTJPG=(`find "$SCDIR" -maxdepth 1 -name "*.jpg"`)
    if [ ${#COUNTJPG[@]} -gt 0 ]; then 
    for i in *.jpg
    do 
    persen=$(($index*100/$ITEMS))
    echo "# Memproses (JPG) $i \n" 
	convert -geometry $GEOMETRY $CROPIMG -strip -interlace Plane -quality $QUALITY -colorspace $COLORSPACE "$i" "$OUTPUTDIR/${i%.*}.jpg"; let index++ ; echo $persen ; done 
    else 
    echo "No JPG Found, nothing todo"
    fi
}

CONVERT_PNG () {
    COUNTPNG=(`find "$SCDIR" -maxdepth 1 -name "*.png"`)
    if [ ${#COUNTPNG[@]} -gt 0 ]; then 
    for i in *.png
    do
    persen=$(($index*100/$ITEMS));
    echo "# Memproses (PNG) '$i' \n" 
    convert -geometry $GEOMETRY $CROPIMG "$i" "$OUTPUTDIR/${i%.*}.png"; let index++; echo $persen; done
    else 
    echo "No PNG Found, nothing todo"
    fi
}

CONVERT_TO_JPG () {
    for i in *.*
    do 
    persen=$(($index*100/$ITEMS))
    echo "# Memproses (JPG) '$i' \n" 
	convert -geometry $GEOMETRY^ $CROPIMG -strip -interlace Plane -quality $QUALITY -colorspace $COLORSPACE "$i" "$OUTPUTDIR/${i%.*}.jpg"; let index++ ; echo $persen ; done 
}

CONVERT_TO_PNG () {
    for i in *.*
    do
    persen=$(($index*100/$ITEMS));
    echo "# Memproses (PNG) $i \n" 
    convert -geometry $GEOMETRY^ $CROPIMG "$i" "$OUTPUTDIR/${i%.*}.png"; let index++; echo $persen; done 
}

OPTIMIZE_PNG () {
    cd "$OUTPUTDIR"
    persen=$(($index*100/$ITEMS))
    find "$OUTPUTDIR" -maxdepth 1 -type f -name '*.png'
    echo "# Mengoptimasi Berkas PNG" 
    # ls
    find "$OUTPUTDIR" -maxdepth 1 -type f -name '*.png' | while read line; 
    do
    parallel -j$CORES pngquant -f {} -o {}
    let index++
    echo $persen; 
    done

    # find $OUTPUTDIR -maxdepth 1 -type f -name '*.png'  -exec echo {} \; | parallel -j $CORES pngquant -f {} -o {} ; let index++; 
    # for i in *.png; do pngquant -f -o "${i%.*}.png" "$i"; done
}

# check folder
FOLDERCOUNT=$(ls -w 1 "$SCDIR" | wc -l)
if [[ $FOLDERCOUNT == 0 ]]; then
yad --width=300 --info --text="\nHmm, Sepertinya folder yang Anda pilih kosong. Silakan coba lagi." --image dialog-error $DIALOGSET --button="gtk-close:0"
exit
fi

start=`date +%s`
if [[ $EXFORMAT == Default ]]; then
    ITEMS=$(find "$SCDIR" -maxdepth 1 -not -type d |  wc -l)
    index=2
    { CONVERT_JPG & CONVERT_PNG; } | yad --progress --percentage=0 --center --width=350 --auto-close --title="Memproses Berkas"
fi


if [[ $EXFORMAT == JPG ]]; then
    ITEMS=$(find "$SCDIR" -maxdepth 1 -not -type d |  wc -l)
    index=2
    CONVERT_TO_JPG | yad --progress --percentage=0 --center --width=350 --auto-close --title="Memproses Berkas"
fi

if [[ $EXFORMAT == PNG ]]; then
    ITEMS=$(find "$SCDIR" -maxdepth 1 -not -type d |  wc -l)
    index=2
    CONVERT_TO_PNG | yad --progress --percentage=0 --center --width=350 --auto-close --title="Memproses Berkas"
fi

if [[ $PNGOPT == TRUE ]]; then
    LISTPNG=$(find "$OUTPUTDIR" -maxdepth 1 -type f -name '*.png' | wc -l)
    if [[ $LISTPNG == 0 ]]; then
    echo "[X] Tidak ada berkas PNG untuk dioptimasi!"
    else
    ITEMS=$(find "$OUTPUTDIR" -maxdepth 1 -type f -name '*.png' | wc -l)
    echo "Menemukan $ITEMS PNG untuk diotimasi."
    index=2
    echo "[*] Optimizing PNG"
    OPTIMIZE_PNG | yad --progress --percentage=0 --center --width=350 --auto-close --title="Mengoptimasi berkas PNG"
    fi
fi

cd "$MAINDIR"
end=`date +%s`
runtime=$((end-start))

# Dialog Info
TOTAL=`find "$OUTPUTDIR" -maxdepth 1 -not -type d |  wc -l`
echo -e "Berhasil memproses $TOTAL gambar ke folder $OUTPUTDIR dalam waktu $runtime detik! \n\nPasopati by Devlovers ID \nhttps://dev-is.my.id/" | yad --center --title="Status" --width=500 --height=320 --button="gtk-ok:0" --image=/opt/pasopati/pasopati.png  --text-info --wrap --fixed --show-uri --uri-color=#ad8305

echo -e "Berhasil memproses $TOTAL gambar ke folder $OUTPUTDIR dalam waktu $runtime detik!"


# Create Config

if [[ $COLORSPACE == RGB ]] ; then
CLSPACE="RGB!CMYK"
else
CLSPACE="CMYK!RGB"
fi

if [[ $EXFORMAT == Default ]] ; then
XFORMAT="Default!PNG!JPG"
fi

if [[ $EXFORMAT == JPG ]] ; then
XFORMAT="JPG!PNG!Default"
fi

if [[ $EXFORMAT == PNG ]] ; then
XFORMAT="PNG!JPG!Default"
fi

# Create User Config

if [[ -f $CONFIG_DIR ]] ; then
echo -e "[*] Menyimpan pengaturan ... \ndone"
else
echo -e "[*] Membuat berkas konfigurasi ... \ndone"
fi

echo -e "# Pasopati $VERSION configuration files" > $CONFIG_DIR
echo -e "# Default Width \n$WIDTH\!0..10000\!1\!0" >> $CONFIG_DIR
echo -e "\n# Default Hight \n$HEIGHT\!0..10000\!1\!0" >> $CONFIG_DIR
echo -e "\n# Default Quality for JPG \n$QUALITY\!1..100\!1\!0" >> $CONFIG_DIR
echo -e "\n# Default Colorspace \n$CLSPACE" >> $CONFIG_DIR
echo -e "\n# Default Export Format \n$XFORMAT" >> $CONFIG_DIR
echo -e "\n# Core to Use \n$CORES\!1..12\!1\!0" >> $CONFIG_DIR
echo -e "\n# Crop Result \n$CROPSTAT" >> $CONFIG_DIR
echo -e "\n# Optimize PNG \n$PNGOPT" >> $CONFIG_DIR

# cat $CONFIG_DIR

echo -e "\nTerima kasih telah menggunakan:\nPasopati dari Devlovers ID \nhttps://dev-is.my.id/"
echo -e "\nHave a nice day!\n"

rm /tmp/pasoresizer-tmp
''
