# formacion

Script creado para un proyecto de trabajo, en el cual, tenemos que enviar un archivo desde un servidor linux a varios clientes windows.

<h1>Cosas a tener en cuenta:</h1>

- La ruta en Windows debe convertirse a estilo UNIX si estás usando WSL o OpenSSH en Windows (C:/Users/... → /c/Users/...).

- Si no deseas pedir contraseña cada vez, puedes:

- Configurar autenticación con clave SSH.

- O También, puedes introducir la clave


## 🚀 Características

- Envío de archivos a uno o varios equipos Windows
- Interfaz interactiva para ingresar datos
- Soporte para lista de equipos desde archivo o entrada manual
- Compatibilidad con contraseña o clave SSH
- Si hay contraseña ($PASS): usa sshpass para pasarla automáticamente al comando scp, lo que permite autenticación sin intervención del usuario.
- Si no hay contraseña: simplemente llama a scp esperando que se use una clave SSH o que el usuario introduzca la contraseña manualmente.
- Verificación automática del archivo y dependencias

---

## 📋 Requisitos

### En el servidor Linux:
- `ssh` instalado (`sudo apt install ssh`)
- Conectividad SSH hacia los equipos Windows

### En los equipos Windows:
- Tener habilitado el servicio **OpenSSH Server**
- Puedes instalarlo desde “Características opcionales” en Windows
- El usuario debe tener permisos de escritura en la carpeta de destino
- Asegúrate de que el puerto **22** esté abierto (firewall)

---

## 🛠 Uso

Ejecuta el script:

El script pedirá:
Ruta del archivo local en Linux (ej. /home/archivo.txt)

Ruta de destino en Windows (ej. C:/Users/Usuario/Desktop)

Si deseas ingresar los servidores manualmente o desde un archivo

📁 Formato del archivo de servidores (opcional)
Puedes crear un archivo de texto con los servidores, uno por línea:


192.168.10.100,formacion01,12345678.formacion

192.168.10.101,formacion02,12345678.formacion

192.168.10.102,formacion03,1234

**El script, se creo como medida experimental, si crees que necesita mejoras, abre un pull request.**
