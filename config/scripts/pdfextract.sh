#!/bin/bash

set -e
VERSION=$(echo v2.15)

# color
RED='\033[0;31m'
GR='\033[0;32m'
NC='\033[0m'

if [ "$1" = "--help" ] ; then
  echo
  echo "Usage: pdf-extractor [FILE-NAME...] then choose your action
  i.e: pdf-extractor my-files.pdf"
  echo 
  echo "--help             show this help page"
  echo "--install-dep      install depencenies (for debian base only)"
  echo  
  exit 0
fi

if [ "$1" = "--version" ] ; then
  echo -e "\nPDF-Extractor ${GR}$VERSION${NC}\n"
  exit 0
fi

if [ "$1" = "--install-dep" ] ; then
  sudo apt install pdftk inkscape ghostscript
  exit 0
fi


SOURCE=$1
DIRECTORY=$3

# files checking
## if no files
if [ "$1" == "" ] ; then
  echo
  pdf-extractor --help
  echo
  exit 0
fi

if [ "${SOURCE: -4}" == ".pdf" ]; then
  echo ""
else
  if [ "${SOURCE: -3}" == ".ai" ]; then
    if [ ! -f $SOURCE ]; then
    echo -e "\n${RED}File $1 not found!${NC}"
    echo -e "Please recheck the file name.\n"
    exit
    fi
    echo -e "\nIllustrator file detected!"
    sleep 1
    cp -f $SOURCE $SOURCE.pdf
    SOURCE=$(echo "$SOURCE.pdf")
  else
  echo -e ${RED}"\nOnly accept PDF/AI File!${NC}\n"
  exit
  fi
fi

if [ ! -f $SOURCE ]; then
  echo -e "${RED}File $1 not found!${NC}"
  echo Please recheck the file name.
  echo
  exit
else
  echo -e "Welcome to Simple PDF Extractor $VERSION\n"
fi

# Starting Program
# echo -e "Welcome to Simple PDF Extractor $VERSION\n"

RANGE=$(pdftk $1 dump_data | grep NumberOfPages | cut -c 16-)
PS3='Enter the number options: '
options=("Extract PDF" "Extract to SVG" "Extract to PNG" "Extract Custom Range" "Cancel")
select opt in "${options[@]}"
do
    case $opt in
        "Extract PDF")
            echo -e "\nThis action will extract your selected PDF to separated pages\n"
            read -e -p "Create Directory to save extracted filed: " DIRECTORY
            echo ""
            if [[ -d $DIRECTORY ]]; then
                echo -e "${RED}Directory exist! Skipping create directory${NC}"; else
                echo -e "${GR}Creating Directory${NC}"
                mkdir $DIRECTORY
            fi
            cd $DIRECTORY
            echo "Extracting ..."
            echo "Starting extract PDF to $DIRECTORY at $(date)" &>> /tmp/pdf-extractor.log
            pdftk ../"$SOURCE" burst &>> /tmp/pdf-extractor.log
            echo -e "Extracted to:${GR} $DIRECTORY ${NC}"
            rm doc_data.txt
            echo "Finishing extract PDF at $(date)" &>> /tmp/pdf-extractor.log
            echo " " &>> /tmp/pdf-extractor.log
            break
            ;;
        "Extract to SVG")
            echo -e "\nThis action will extract your selected PDF to separted SVG files\n"
            read -e -p "Create Directory to save extracted filed: " DIRECTORY
            echo ""
            if [[ -d $DIRECTORY/.tmp ]]; then
                echo -e "${RED}Directory exist! Skipping create directory${NC}"; else
                echo -e "${GR}Creating Directory${NC}"
                mkdir -p $DIRECTORY/.tmp
            fi
            cd $DIRECTORY/.tmp
            echo "Extracting ..."
            echo "Starting extract SVG to $DIRECTORY at $(date)" &>> /tmp/pdf-extractor.log
            pdftk ../../"$SOURCE" burst &>> /tmp/pdf-extractor.log
            for i in *.pdf; do inkscape -l -o "../${i%.*}.svg" $i &>> /tmp/pdf-extractor.log 
            echo 'Extracting' "${i%.*}.svg"
            done 
            rm -f *.pdf *.txt
            cd .. && rm -r .tmp
            echo "Finishing extract SVG at $(date)" &>> /tmp/pdf-extractor.log
            echo " " &>> /tmp/pdf-extractor.log
            echo -e "Extracted to:${GR} $DIRECTORY ${NC}"
            break
            ;;
        "Extract to PNG")
            echo "\nThis action will extract your selected PDF to separted PNG files\n"
            read -e -p "Create Directory to save extracted filed: " DIRECTORY
            echo ""
            if [[ -d $DIRECTORY/.tmp ]]; then
                echo -e "${RED}Directory exist! Skipping create directory${NC}"; else
                echo -e "${GR}Creating Directory${NC}"
                mkdir -p $DIRECTORY/.tmp
            fi
            cd $DIRECTORY/.tmp
            echo "Extracting ..."
            echo "Starting extract PNG to $DIRECTORY at $(date)" &>> /tmp/pdf-extractor.log
            pdftk ../../"$SOURCE" burst &>> /tmp/pdf-extractor.log
            for i in *.pdf; do inkscape --export-type=png --export-dpi=600  -o "../${i%.*}.png" $i &>> /tmp/pdf-extractor.log
            echo 'Extracting' "${i%.*}.png"
            done
            rm -f *.pdf *.txt *.svg
            cd .. 
            rm  -r .tmp
            echo "Finishing extract PNG at $(date)" &>> /tmp/pdf-extractor.log
            echo " " &>> /tmp/pdf-extractor.log
            echo -e "Extracted to:${GR} $DIRECTORY ${NC}"
            break
            ;;
        "Extract Custom Range")
            echo -e "\nThis action will extract selected range from your selected PDF to separted pages"
            echo -e "Available range is 1 until $RANGE\n"
            read -e -p "Start Page Range: " START
            read -e -p "End Page Range: " END 
            read -e -p "Export as SVG? Default PDF (y/n): " FORMAT
            read -e -p "Create Directory to save extracted filed: " DIRECTORY
            if [[ -d $DIRECTORY ]]; then
                echo -e "${RED}Directory exist! Skipping create directory${NC}"; else
                echo -e "Creating Directory"
                mkdir $DIRECTORY
            fi
            cd $DIRECTORY
            echo "Extracting ..."
            echo "Starting extract custom range to $DIRECTORY at $(date)" &>> /tmp/pdf-extractor.log
            gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dFirstPage=$START -dLastPage=$END -sOutputFile=".temp-file.pdf" ../"$SOURCE" &>> /tmp/pdf-extractor.log
            pdftk ".temp-file.pdf" burst &>> /tmp/pdf-extractor.log
            rm -f .temp-file.pdf
            rm -f *.txt
            if [[ $FORMAT =~ ^[Yy]$ ]]; then
              if [[ ! -d SVG ]]; 
                then mkdir SVG; 
              fi
              for i in *.pdf; do inkscape -l -o "SVG/${i%.*}.svg" $i &>> /tmp/pdf-extractor.log 
              echo "Converting to ${i%.*}.svg"
              done
              rm -f *.pdf
              mv SVG/* .
              rm -rf SVG
            fi
            echo "Finishing extract custom range at $(date)" &>> /tmp/pdf-extractor.log
            echo -e "Extracted to:${GR} $DIRECTORY ${NC}"
            break
            ;;
        "Cancel")
            echo -e "\nCatch you later!\n"
            exit
            ;;
        *) echo -e ${RED}"Hmm, wrong option! There's no option: $REPLY" ${NC};;
    esac
done;
echo " "
