#!/bin/bash

echo "----------------------------------------------------------------------------------------"                                                                    
echo "            >> Transferencia de archivos a Clientes Windows mediante SSH <<             "
echo "----------------------------------------------------------------------------------------"
                     
usuario_actual=$(whoami)


# Validar archivo
read -p "Ruta al archivo local (Linux)(ej. /home/archivo.txt): " ARCHIVO_LOCAL
if [ ! -f "$ARCHIVO_LOCAL" ]; then
    echo "El archivo '$ARCHIVO_LOCAL' no existe."
    exit 1
fi

# Pedir ruta remota
read -p "Ruta remota de destino en Windows (ej: C:/Users/Usuario/Desktop): " RUTA_WINDOWS
RUTA_WINDOWS_UNIX=$(echo "$RUTA_WINDOWS" | sed 's#\\#/#g')  # solo reemplaza backslashes por slashes


# Pedir archivo de configuración o ingresar servidores a mano
read -p "¿Quieres leer los servidores desde un archivo? (s/n): " USAR_ARCHIVO

if [[ "$USAR_ARCHIVO" == "s" || "$USAR_ARCHIVO" == "S" ]]; then
    read -p "Ruta del archivo (Suele estar en /home/$usuario_actual/formacion/inventory.txt): " ARCHIVO_SERVIDORES
    if [ ! -f "$ARCHIVO_SERVIDORES" ]; then
        echo "❌ El archivo '$ARCHIVO_SERVIDORES' no existe."
        exit 1
    fi
    SERVIDORES=($(cat "$ARCHIVO_SERVIDORES"))
else
    echo "Introduce los servidores manualmente. Formato: ip, usuario, contraseña"
    echo "Ejemplo: 192.168.0.201,Administracion,Password, donde el formato sería ip, usuario, contraseña"
    echo "Cuando termines, deja la línea vacía y presiona Enter."
    SERVIDORES=()
    while true; do
        read -p "> " entrada
        [[ -z "$entrada" ]] && break
        SERVIDORES+=("$entrada")
    done
fi

# Comprobar sshpass
if ! command -v sshpass &> /dev/null; then
    echo "Instalando sshpass..."
    sudo apt install sshpass -y
fi

# Iterar sobre servidores
# La iteración envia el archivo a múltiples servidores Windows, uno por uno.
for entry in "${SERVIDORES[@]}"; do
    IFS=',' read -r IP USUARIO PASS <<< "$entry"

    echo "Enviando a $USUARIO@$IP..."

if [ -n "$PASS" ]; then
    sshpass -p "$PASS" scp "$ARCHIVO_LOCAL" "$USUARIO@$IP:$RUTA_WINDOWS_UNIX"
else
    scp "$ARCHIVO_LOCAL" "$USUARIO@$IP:$RUTA_WINDOWS_UNIX"
fi


    if [ $? -eq 0 ]; then
        echo "$(date) Archivo enviado a $IP"  
    else
        echo "$(date) Error al enviar a $IP"
    fi
done


# Menú de administración post-envío
    while true; do
        echo ""
        echo "¿Acción adicional para $IP?"
        echo "1) Reiniciar equipo remoto"
        echo "2) Ejecutar script remoto"
        echo "3) Ninguna (continuar)"
        read -p "Opción [1-3]: " OPC

        case "$OPC" in
            1)
                echo "Reiniciando $IP..."
                sshpass -p "$PASS" ssh "$USUARIO@$IP" "shutdown /r /t 0"
                echo "$(date) -> $IP | Reinicio solicitado" >> "$LOG_FILE"
                break
                ;;
            2)
                read -p "Ruta local del script a ejecutar (ej: /home/script.bat): " SCRIPT_LOCAL
                read -p "Ruta destino en Windows (ej: C:/Users/Usuario/Desktop/script.bat): " SCRIPT_REMOTO
                SCRIPT_REMOTO_UNIX=$(echo "$SCRIPT_REMOTO" | sed 's#\\#/#g')

                sshpass -p "$PASS" scp "$SCRIPT_LOCAL" "$USUARIO@$IP:$SCRIPT_REMOTO_UNIX"
                sshpass -p "$PASS" ssh "$USUARIO@$IP" "$SCRIPT_REMOTO_UNIX"
                echo "$(date) -> $IP | Script ejecutado: $SCRIPT_REMOTO" >> "$LOG_FILE"
                break
                ;;
            3)
                break
                ;;
            *)
                echo "Opción inválida. Intenta de nuevo."
                ;;
        esac
    done
done

echo ""
echo "✔️  Tarea completada. Revisa el log en: $LOG_FILE"
