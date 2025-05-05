
#!/bin/bash

echo "----------------------------------------------------------------------------------------"                                                                    
echo "            >> Transferencia de archivos a Clientes Windows mediante SSH <<             "
echo "----------------------------------------------------------------------------------------"
                     
usuario_actual=$(whoami)
LOG_FILE="/home/$usuario_actual/transferencias.log"

# Validar archivo
read -p "Ruta al archivo local (Linux)(ej. /home/archivo.txt): " ARCHIVO_LOCAL
if [ ! -f "$ARCHIVO_LOCAL" ]; then
    echo "❌ El archivo '$ARCHIVO_LOCAL' no existe."
    exit 1
fi

# Pedir ruta remota
read -p "Ruta remota de destino en Windows (ej: C:/Users/Usuario/Desktop): " RUTA_WINDOWS
RUTA_WINDOWS_UNIX=$(echo "$RUTA_WINDOWS" | sed 's#\\#/#g')  # Reemplaza backslashes por slashes

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
    echo "Ejemplo: 192.168.0.201,Administracion,Password"
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

# Contadores
exitos=0
fallos=0

# Iterar sobre servidores
for entry in "${SERVIDORES[@]}"; do
    IFS=',' read -r IP USUARIO PASS <<< "$entry"

    echo "--------------------------------------------------------"
    echo "⏳ Conectando a $USUARIO@$IP..."

    # Verificar conexión SSH
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USUARIO@$IP" "exit" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "⚠️ ❌ No se pudo establecer conexión con $IP"
        estado="⚠️ ❌ Error de conexión"
        fallos=$((fallos + 1))
    else
        echo "📤 🔐 Conexión establecida. Enviando archivo..."

        if [ -n "$PASS" ]; then
            sshpass -p "$PASS" scp -o StrictHostKeyChecking=no "$ARCHIVO_LOCAL" "$USUARIO@$IP:$RUTA_WINDOWS_UNIX"
        else
            scp -o StrictHostKeyChecking=no "$ARCHIVO_LOCAL" "$USUARIO@$IP:$RUTA_WINDOWS_UNIX"
        fi

        if [ $? -eq 0 ]; then
            echo "📥 ✅ Archivo enviado correctamente a $IP"
            estado="📥 ✅ Enviado"
            exitos=$((exitos + 1))
        else
            echo "⚠️ ❌ Error al enviar a $IP"
            estado="⚠️ ❌ Fallo en envío"
            fallos=$((fallos + 1))
        fi
    fi

    # Registrar en log
    echo "$(date '+%Y-%m-%d %H:%M:%S') | IP: $IP | Usuario: $USUARIO | Archivo: $(basename "$ARCHIVO_LOCAL") | Estado: $estado" >> "$LOG_FILE"
done

# Resumen final
echo "--------------------------------------------------------"
echo "📋 Resumen:"
echo "✅ Exitosos: $exitos"
echo "❌ Fallidos: $fallos"
echo "📁 Log guardado en: $LOG_FILE"
