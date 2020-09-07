# TFG UCM 2020
## Estudio de la seguridad del protocolo TPMS / Vulnerabilities in the TPMS protocol

En este repositorio se encuentra el código utilizado para generar la señal adecuada para los dispositivos TPMS Citroën y Toyota. Para generar dicha señal se utiliza Matlab para la codificación y Gnu-Radio para la modulación. Para comprobar la viabilidad de transmisión de nuestra señal se utiliza Inspectrum y el software[**rtl_433**](https://github.com/merbanan/rtl_433).

# Instalación de los diferentes entornos
**rtl_sdr**
Rtl_sdr permite el uso de software junto a un receptor SDR. Se utilizará para el uso de herramientas como GQRX con el objetivo de inspeccionar el aspecto de las señales transmitidas por los sistemas TPMS.

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

El repositorio oficial de rtl_433 se encuentra en https://github.com/merbanan/rtl_433.git, este software de código abierto y mediante el uso de un dispositivo SDR permite demodular y decodificar señales en un amplio rango de frecuencias. En este proyecto se utiliza con el fin de comprobar la validez de la señal que se generará con Gnu-Radio y para poder ver los datos transmitidos por los sistemas TPMS.

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

El repositorio oficial de Inspectrum se encuentra en https://github.com/miek/inspectrum. Inspectrum facilita herramientas para poder obtener símbolos de una señal grabada, este se utilizará para comprobar la modulación de las señales transmitidas por los sistemas TPMS.

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

Gnu-Radio proporciona un amplio kit de herramientas para generar señales, este se utilizará para modular digitalmente los datos provenientes de un archivo binario.

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
GQRX permite la escucha de señales en un amplio rango de frecuencias. En el proyecto se utilizará para inspeccionar visualmente las señales TPMS y escuchar el sonido característico de los dispositivos que transmiten a 433MHz.
*Instalación*
````
sudo apt update -y
sudo apt install -y gqrx-sdr
````

# Análisis de señales 

Mediante GQRX, un dongle SDR y Inspectrum se puede inspeccionar el aspecto y el sonido de la señal y por último obtener el flujo de bits que transmite.

El dongle SDR que se ha utilizado para poder realizar el proyecto es como el representado en la siguiente imagen:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/dongle.jpg" height="200" width="200">

    
La configuración que necesita el GQRX para poder capturar señales mediante el dongle SDR será la que se muestra en la siguiente imagen:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/GQRX_CONFIG.png" height="358" width="211">


De esta forma si presionamos el botón play de la interfaz de GQRX, el dispositivo SDR comenzará a capturar las señales. El siguiente paso será sintonizar las bandas de frecuencia de 433MHz, después de esto, si captamos una señal de tipo TPMS en la interfaz veremos un espectro frecuencia como el siguiente:  

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/GQRX.png" height="550" width="750">

Para grabar la señal se puede utilizar GQRX, pero es más recomendable el uso del protocolo Rtl_433. Por último, con la señal grabada se puede realizar ingeniería inversa y poder obtener la codificación y la modulación del dispositivo. La demodulación se puede hacer mediante Inspectrum, obteniendo como resultado un flujo de bits. Seleccionando el tipo de modulación y fijando el ancho de símbolo se puede obtener un flujo de bits de la siguiente forma:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Inspectrum.png" height="550" width="750">


# Cómo generar señales 

En este proyecto se va a llevar a cabo la construcción de la trama y la generación de la señal para los dispositivos TPMS pertenecientes a los fabricantes Toyota y Citroën.

- Construcción de la trama de datos:

Los aspectos como el formato de trama de estos dispositivos y la modulación utilizada han sido obtenidos del software [**rtl_433**](https://github.com/merbanan/rtl_433).

**Citroën**
<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Citroen-Frame.png">
**Toyota**
<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Toyota-Frame.png">

- Codificación de los datos:

Mediante la interfaz de Matlab se pasarán los datos de la trama que se desee formar y codificar, obteniendo como resultado un archivo binario con la información que se debe pasar a Gnu-Radio para ser modulada.

**Citroën**

El dispositivo Citroën utiliza una codificación Manchester, el código de esta codificación la podemos encontrar en el archivo *ManchesterEncoder.m*. El formato de la trama lo podemos introducir mediante la interfaz de Matlab con la ejecución del archivo *CitroenTPMS.m*.

**Toyota**

El dispositivo Toyota utiliza una codificación Manchester diferencial, el código de esta codificación la podemos encontrar en el archivo *Differential_ManchesterEncoder.m*. El formato de la trama lo podemos introducir mediante la ejecución del archivo *ToyotaTPMS.m*. Además, el CRC-8 utilizado para calcular el checksum lo podemos encontrar en el archivo *crc8.m*.

- Modulación de la señal:

Tras generar la trama codificada con la interfaz de Matlab se debe pasar a modular la señal, siendo la modulación utilizada para los dos dispositivos FSK. La modulación se realiza con Gnu-Radio y como resultado se obtiene un archivo binario con la información de la señal en su interior. El diagrama de bloques que se ha utilizado para generar la señal modulada en FSK se encuentra en *./Gnu-Radio-Block-Diagram/fsk_modulation.grc*.

**Diagrama de bloques Gnu-Radio**

El diagrama de bloques de Gnu-Radio para la modulación de la señal en FSK está inspirado en [**TXTPMS**](https://github.com/cdeletre/txtpms)

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/gnu-radio.png" height="550" width="750">

Se pueden observar tres fases diferenciadas: lectura del archivo binario que almacena la trama codificada, modulación digital de los datos y escritura de la señal modulada.
Para la lectura del archivo deberemos editar en el módulo ``File Source`` el parámetro correspondiente al nombre de archivo. De la misma forma debemos editar el módulo ``File Sink`` introduciendo el nombre del fichero de salida.

-Comprobar la señal con [**rtl_433**](https://github.com/merbanan/rtl_433):

Para comprobar la señal se usará el software rtl_433. Este software proporciona la capacidad de demodular señales mostrando la información que transmiten por consola. La señal que se ha generado mediante Gnu-Radio todavía no es apta para poder ser demodulada por rtl_433, la señal es muy rápida y se necesita cierta información previa sobre el muestro para poder demodular/descodificar la señal, por este motivo es necesario añadir silencio al principio y al final de la señal con una frecuencia de muestreo de 250k . Para llevar a cabo este proceso se hará uso de SoX. En este repositorio se encuentra un pequeño script llamado *./Sox-silence-script/Sox-Silence.sh* que se encargará de realizar esta función, como parámetros recibe dos nombres de archivo, el primero será el archivo con la señal modulada y el segundo será el archivo destino que contendrá la señal con el silencio que se busca añadir.

Despues de añadir silencio, si inspeccionamos la señal con Inspectrum, la señal debería tener un aspecto como el siguiente:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/Inspectrum_Silence.png" height="550" width="750">

Si pasamos a analizar la señal con rtl_433, en el caso de Toyota la información que mostrará dependerá de los datos introducidos, pero el formato debería tener un aspecto como el siguiente:

<img src="https://github.com/alberc01/VULNERABILITIES-IN-THE-TPMS-PROTOCOL/blob/master/Images/citroen_normal.png">

Para finalizar este estudio, se podría llevar a cabo la emisión vía radioeléctrica de la señal que acabamos de generar, para esto se puede utilizar el dispositivo HackRf One. Para saber cómo realizar este proceso, se puede obtener información del repositorio de Ciryl [**TXTPMS**](https://github.com/cdeletre/txtpms), donde se explica cómo añadir el módulo correspondiente a HackRf One en Gnu-Radio y como se debe aumentar la frecuencia de muestro para poder transmitir la señal. 

El envío de la señal se puede realizar mediante el uso de *hackrf_transfer* especificando la frecuencia de muestreo a la especificada al generar la señal y la frecuencia portadora a 433920000MHz. La sintaxis de dicho comando sería la siguiente:
````
    hackrf_transfer -R -t simu_tpms_2500k.cs8 -f 433920000 -s 2500000 -x 0
````









