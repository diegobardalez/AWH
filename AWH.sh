#!/bin/bash

# Variable global para almacenar el PID del proceso actual
current_pid=""

# Función para manejar la señal SIGINT (Ctrl+C)
function handle_sigint() {
    echo "¡Se recibió la señal SIGINT! Deteniendo la tarea actual..."
    # Si hay un PID de tarea actual, matarlo
    if [[ ! -z "$current_pid" ]]; then
        echo "Deteniendo el proceso con PID $current_pid..."
        kill -SIGINT "$current_pid"
    fi
}

# Asignar la función handle_sigint para manejar la señal SIGINT
trap handle_sigint SIGINT

# Función para mostrar el banner en ASCII
function mostrar_banner() {
    # Usamos tput para los colores
    tput setaf 3 # Amarillo
    cat << "EOF"
    
    
  /$$$$$$  /$$      /$$ /$$   /$$
 /$$__  $$| $$  /$ | $$| $$  | $$
| $$  \ $$| $$ /$$$| $$| $$  | $$
| $$$$$$$$| $$/$$ $$ $$| $$$$$$$$
| $$__  $$| $$$$_  $$$$| $$__  $$
| $$  | $$| $$$/ \  $$$| $$  | $$
| $$  | $$| $$/   \  $$| $$  | $$
|__/  |__/|__/     \__/|__/  |__/

            By D13G0

EOF
    tput sgr0 # Reset de colores
}

# Función para limpiar la URL y obtener la IP
function limpiar_y_obtener_ip() {
    read -p "Por favor, introduce la URL: " url
    
    # Limpiar la URL removiendo http://, https:// y www.
    url_limpia=$(echo $url | sed -e 's/^https\?:\/\///' -e 's/^www\.//')
    
    # Obtener la IP usando dig
    ip=$(dig +short "$url_limpia" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    if [[ -z "$ip" ]]; then
        echo "No se pudo obtener la IP de $url"
        exit 1
    else
        echo "La dirección IP de $url es: $ip"
    fi

    # Ejecutar nmap en segundo plano y mostrar resultados
    tput setaf 2 # Verde
    echo "Ejecutando nmap..."
    tput sgr0 # Reset de colores
    nmap_output="nmap_results.txt"
    nmap -sCV -open -vvv -Pn -T5 --min-rate 5000 -p- "$ip" > "$nmap_output" &
    current_pid=$!
    wait $current_pid
    tput setaf 2 # Verde
    echo "Escaneo de nmap completado. Los resultados están en $nmap_output"
    tput sgr0 # Reset de colores
    
    # Ejecutar nuclei en la URL
    tput setaf 2 # Verde
    echo "Ejecutando nuclei en $url..."
    tput sgr0 # Reset de colores
    nuclei_output="nuclei_results.txt"
    nuclei -u "$url" -o "$nuclei_output" &
    current_pid=$!
    wait $current_pid
    tput setaf 2 # Verde
    echo "Escaneo de nuclei completado. Los resultados están en $nuclei_output"
    tput sgr0 # Reset de colores
    
     # Ejecutar gobuster en la URL
    tput setaf 2 # Verde
    echo "Ejecutando gobuster en $url..."
    tput sgr0 # Reset de colores
    gobuster_output="gobuster_results.txt"
    gobuster dir -u "$url" -w /usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt -x "php, txt, asp, aspx, bak, inc, rar, zip, sql" -o "$gobuster_output" &
    current_pid=$!
    wait $current_pid
    tput setaf 2 # Verde
    echo "Escaneo de gobuster completado. Los resultados están en $gobuster_output"
    tput sgr0 # Reset de colores
    
     # Ejecutar sublist3r en la URL
    tput setaf 2 # Verde
    echo "Ejecutando sublist3r en $url..."
    tput sgr0 # Reset de colores
    sublist3r_output="sublist3r_results.txt"
    sublist3r -d "$url" -o "$sublist3r_output" &
    current_pid=$!
    wait $current_pid
    tput setaf 2 # Verde
    echo "Escaneo de sublist3r completado. Los resultados están en $sublist3r_output"
    tput sgr0 # Reset de colores
}

# Ejecutar las funciones
mostrar_banner
limpiar_y_obtener_ip
