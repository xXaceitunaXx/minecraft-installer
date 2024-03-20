REQUIRED_PKGS=( "default-jre" "libasound2" "libatk-bridge2.0-0" "libatk1.0-0" "libatspi2.0-0" "libc6" "libcairo2" "libcups2" "libdbus-1-3" "libdrm2" "libexpat1" "libgbm1" "libfontconfig1" "libgdk-pixbuf2.0-0" "libglib2.0-0" "libgtk-3-0" "libnspr4" "libnss3" "libpangocairo-1.0-0" "libstdc++6" "libx11-6" "libxcomposite1" "libxcursor1" "libxdamage1" "libxext6" "libxfixes3" "libxi6" "libxrandr2" "libxrender1" "libxss1" "libxtst6" "libx11-xcb1" "libxcb-dri3-0" "libxcb1" "libbz2-1.0" "xdg-utils" "wget" "libuuid1" )
OPTIONAL_PKGS_LP=( "libpango1.0-0" "libpango-1.0-0")
OPTIONAL_PKGS_LB=( "libcurl3" "libcurl4" )
CHECK=0
LAUNCHER_ROUTE="/usr/bin/minecraft-launcher"
MINECRAFT_LAUNCHER="$HOME/Descargas/Minecraft.deb"
MINECRAFT_CHECKSUM="5f4e4ba13a9666625abef5afee50dbaa6c0efa608230b86d378962ca0d662aef"
re='^[0-9]+$'

if test -f "$LAUNCHER_ROUTE"; then
  echo "Minecraft already installed"
  exit 0
fi

if java --version | grep -q "java version"; then
  echo "please install java"
  exit 1
fi

for REQUIRED_PKG in ${REQUIRED_PKGS[@]}
do
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
  echo Checking for $REQUIRED_PKG: $PKG_OK
  if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    sudo apt-get --yes install $REQUIRED_PKG
  fi
done

for OPTIONAL_PKG in ${OPTIONAL_PKGS_LB[@]}
do
  
  echo "Checking if $OPTIONAL_PKG is installed"
  
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $OPTIONAL_PKG|grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    CHECK=$(($CHECK + 1))
  fi
done

if [ "2" -eq "$CHECK" ]; then
  echo "Problems found. Which package do you want to install [number]"
  echo ${OPTIONAL_PKG_LB[*]}
  read
  while [ "$REPLY" = $re ]
  do
    read
  done
  sudo apt-get --yes install ${OPTIONAL_PKGS_LB[$(($REPLY - 1))]}
fi

CHECK=0

for OPTIONAL_PKG in ${OPTIONAL_PKGS_LP[@]}
do
  
  echo "Checking if $OPTIONAL_PKG is installed"
  
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $OPTIONAL_PKG|grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    CHECK=$(($CHECK + 1))
  fi
done

if [ "2" -eq "$CHECK" ]; then
  echo "Problems found. Which package do you want to install [number]"
  echo ${OPTIONAL_PKGS_LP[*]}
  read
  while [ "$REPLY" = $re ]
  do
    read
  done
  sudo apt-get --yes install ${OPTIONAL_PKGS_LP[$(($REPLY - 1))]}
fi

if [ ! -f "$MINECRAFT_LAUNCHER" ]; then
  wget https://launcher.mojang.com/download/Minecraft.deb
  if [ "$MINECRAFT_CHECKSUM" = "$(sha256sum $MINECRAFT_LAUNCHER)" ]; then
    echo "Incorrect checksum, deleting files, please manualy install to go on the process" 
    rm $MINECRAFT_LAUCHER --yes
    exit 1
  fi
fi

sudo dpkg -i "$MINECRAFT_LAUNCHER"
echo "Minecraft launcher installed with exit code $?"

minecraft-launcher