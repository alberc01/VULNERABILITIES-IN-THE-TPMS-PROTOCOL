# TFG UCM 2020
## Estudio de la seguridad del protocolo TPMS / Vulnerabilities in the TPMS protocol

En este repositorio se encuentra el código utilizado para generar la señal adecuada para los dispositivos TPMS Citroën y Toyota. Para generar dicha señal se utiliza Matlab para la codificación y Gnu-Radio para la modulación. Para comprobar la viabilidad de transmisión de nuestra señal se utiliza Inspectrum y el protocolo RTL_433.

# Instalación de los diferentes entornos
**rtl_sdr**
Rtl_sdr permite el uso de software junto a un receptor SDR. Se utilizara para el uso de herramientas como GQRX con el objetivo de inspeccionar el aspecto de las señales transmitidas por los sistemas TPMS.

*Instalación*
````
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/ && mkdir build && cd build/
cmake ../ -DINSTALL_UDEV_RULES=ON
sudo make
sudo make install
sudo ldconfig
````
**rtl_433**

El repositorio oficial de rtl_433 se encuentra en https://github.com/merbanan/rtl_433.git, este software de código abierto mediante el uso de un dispositivo SDR permite demodular y decodificar señales en un amplio rango de frecuencias. En este proyecto se utiliza con el fin de comprobar la validez de la señal que se generará con Gnu-Radio y para poder ver los datos transmitidos por los sistemas TPMS.

*Instalación*
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

El repositorio oficial de Inspectrum se encuentra en https://github.com/miek/inspectrum. Inspectrum facilita herramientas para poder obtener símbolos de una señal grabada. Se utilizará para comprobar la modulación de las señales transmitidas por los sistemas TPMS.

*Instalación*
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

Gnu-Radio proporciona un amplio kit de herramientas para generar señales. Se utilizará para modular digitalmente los datos provenientes de un archivo binario.

*Instalación*
````
    sudo apt install gnuradio
````
**SoX**

SoX facilita herramientas para la escritura y lectura de señales de audio. Se utilizará para aumentar la duración de la señal que se generará mediante Gnu-Radio.

*Instalación*
````
sudo apt install sox
````
**GQRX**
GQRX permite la escucha de señales en un amplio rango de frecuencias. En el proyecto se utilizará para inspeccionar visualmente las señales TPMS y escuchar el sonido caracteristico de los dispsitivos que transmiten a 433 MHz.
*Instalación*
````
sudo apt update -y
sudo apt install -y gqrx-sdr
````

# Analisis de señales 

Mediante GQRX, un dongle SDR y Inspectrum se puede inspeccionar el aspecto y el sonido de la señal y por último obtener el flujo de bits que transmite.

El dongle SDR que se ha utilizado para poder realizar el proyecto es como el representado en la siguiente imagen:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/dongle.jpg" height="200" width="200">

    
La configuración que necesita el GQRX para poder captar señales mediante el dongle SDR será la que se muestra en la siguiente imagen:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/GQRX_CONFIG.png" height="358" width="211">


De esta forma si presionamos el botón play de la interfaz de GQRX, el dispositivo SDR comenzará a captar las señales. El siguiente paso será sintonizar la frecuencia 433 MHz, después de esto, si captamos una señal de tipo TPMS en la interfaz veremos un espectro frecuencia como el siguiente:  

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/GQRX.png" height="550" width="750">

Para grabar la señal se puede utilizar GQRX, pero es más recomendable el uso del protocolo Rtl_433. Por último, con la señal grabada se puede realizar ingeniería inversa y poder obtener la codificación y la modulación del dispositivo. La demodulación se puede hacer mediante Inspectrum, obteniendo como resultado un flujo de bits. Seleccionando el tipo de modulación y seleccionando el ancho de símbolo se puede obtener un flujo de bits de la siguiente forma:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Inspectrum.png" height="550" width="750">


# Como generar señales 

En este proyecto se va a llevar a cabo la construccion de la trama y la generacion de la señal para los dispositivos TPMS pertenecientes a los fabricantes Toyota y Citroën.

- Construcción de la trama de datos:

Los aspectos como el formato de trama de estos dispositivos y la modulación utilizada han sido obtenidos del protocolo [**rtl_433**](https://github.com/merbanan/rtl_433).

**Citroën**
<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Citroen-Frame.png">
**Toyota**
<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Toyota-Frame.png">

- Codificación de los datos:

Mediante la interfaz de Matlab se pasarán los datos de la trama que se desee formar y codificar, obteniendo como resultado un archivo binario con la informacion que se debe pasar a Gnu-Radio para ser modulada.

**Citroën**

El dispositivo Citroën utiliza una codificacion Manchester, el codigo de dicha codificacion la podemos encontrar en  el archivo *ManchesterEncoder.m*. El formato de la trama lo podemos introducir mediante la ejecucion del archivo *CitroenTPMS.m*.

**Toyota**

El dispositivo Toyota utiliza una codificacion Manchester diferencial, el codigo de dicha codificacion la podemos encontrar en  el archivo *Differential_ManchesterEncoder.m*. El formato de la trama lo podemos introducir mediante la ejecucion del archivo *ToyotaTPMS.m*. Ademas el CRC-8 utilizado para calcular el checksum lo podemos encontrar en el archivo *crc8.m*.

- Modulación de la señal:

Tras generar la trama codificada con la interfaz de Matlab se debe pasar a modular la señal, siendo la modulacion utilizada para los dos dispositivos FSK. La modulacion se realiza con Gnu-Radio y como resultado se obtiene un archivo binario con la informacion de la señal en su interior. El diagrama de bloques que se ha utilizado para generar la señal modulada en FSK se encuentra en *./Gnu-Radio-Block-Diagram/tpms_fsk.gr*.

**Diagrama de bloques Gnu-Radio**

El diagrama de bloques de Gnu-Radio para la modulación de la señal en FSK esta inspirado en [**TXTPMS**](https://github.com/cdeletre/txtpms)

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/gnu-radio.png" height="550" width="750">

-Comprobar la señal con [**rtl_433**](https://github.com/merbanan/rtl_433):

Para comprobar la señal se usara el software rtl_433. Este software propociona la capacidad de demodular señales mostrando la informacion que transmiten por consola. La señal que se ha generado mediante Gnu-Radio todavia no es apta para poder ser demodulada por rtl_433, la señal es demasiado rapida por lo que hay que añadir silencio al principio y al final de la señal para que rtl_433 pueda demodularla. Para llevar a cabo este proceso se hará uso de SoX. En este repositorio se encuentra un pequeño script llamado  *Sox-Silence.sh* que se encargara de realizar esta funcion, como parametros recibe dos nombres de archivo, el primero sera el archivo con la señal modulada y el segundo será el archivo destino que contendra la señal con el silencio que se busca añadir.

Despues de añadir silencio, si inspeccionamos la señal con Inspectrum, la señal debería tener un aspecto como el siguiente:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Inspectrum_Silence.png" height="550" width="750">

Si pasamos a analizar la señal con rtl_433, en el caso de toyota la informacion que mostrará dependerá de los datos introducidos, pero el formato debería tener un aspecto como el siguiente:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/citroen_normal.png" height="550" width="750">









