# TFG UCM 2020
## Estudio de la seguridad del protocolo TPMS / Vulnerabilities in the TPMS protocol

En este repositorio se encuentra el codigo utilizado para generar la señal adecuada para los dispositivos TPMS Citröen y Toyota. Para generar dicha señal se utilza Matlab para la codificación y Gnu-Radio para la modulación. Para comprobar la vibilidad de transmision de nuestra señal se utiliza Inspectrum y el protocolo RTL_433.

# Instalacion de los entornos
**rtl_433**

El repositorio oficial de rtl_433 se encuentra en https://github.com/merbanan/rtl_433.git, este software de codigo abierto mediante el uso de un dispositivo SDR permite demodular y decodificar señales en un amplio rango de frecuencias. En este proyecto se utiliza con el fin de comprobar la validez de la señal que se generará con Gnu_Radio y para poder ver los datos transmitidos por los sistemas TPMS.
````
    git clone https://github.com/merbanan/rtl_433.git
    cd rtl_433/
    mkdir build
    cd build
    cmake ..
    make
    make install
````
**Inspectrum**
````
    sudo apt-get update -y
    sudo apt-get install qt5-default libfftw3-dev cmake pkg-config libliquid-dev 
    sudo apt-get install build-essential git
    git clone https://github.com/miek/inspectrum.git
    cd inspectrum/
    mkdir build
    cd build/
    cmake ..
    make
    sudo make install
````
**Gnu-Radio**
````
    sudo apt install gnuradio
````
**Python 3**
````
sudo apt install python3.8
````
**SoX**
````
sudo apt get install sox
````


# Obtenición de señales 
