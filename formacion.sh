#!/bin/bash

# Preguntar al usuario si no se pasan argumentos
read -p "IP del servidor Windows: " WINDOWS_IP
read -p "Usuario de Windows: " WINDOWS_USER
read -s -p "Contraseña de Windows (opcional, se usará SSH key si no se ingresa): " WINDOWS_PASS
echo
read -p "Ruta al archivo local (Linux): " ARCHIVO_LOCAL
read -p "Ruta de destino en Windows (ej: C:/Users/Usuario/Escritorio): " RUTA_WINDOWS

# Convertir ruta de Windows a ruta SSH válida
RUTA_WINDOWS_UNIX=$(echo "$RUTA_WINDOWS" | sed 's#\\#/#g' | sed 's#C:/#/c/gi')

# Enviar el archivo usando sshpass + scp si se proporciona contraseña
if [ -n "$WINDOWS_PASS" ]; then
    # Verifica que sshpass esté instalado
    if ! command -v sshpass &> /dev/null; then
        echo "sshpass no está instalado. Instalando..."
        sudo apt install sshpass -y
    fi

    sshpass -p "$WINDOWS_PASS" scp "$ARCHIVO_LOCAL" "${WINDOWS_USER}@${WINDOWS_IP}:/$(echo $RUTA_WINDOWS_UNIX)"
else
    # Usar SSH Key por defecto
    scp "$ARCHIVO_LOCAL" "${WINDOWS_USER}@${WINDOWS_IP}:/$(echo $RUTA_WINDOWS_UNIX)"
fi

echo "✅ Archivo enviado."
