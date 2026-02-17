# https://devblogs.microsoft.com/azure-sql/getting-started-with-ai-in-sql-server-2025-on-windows/


# Install OLLAMA
winget install Ollama.Ollama

# NGINX installieren
..\..\certs\createCert.ps1
## DNS = localhost
## Password: ppedv2026!
## Filepath: c:\certs\cert.pfx

# Open SSL installation
winget install ShiningLight.OpenSSL.Light
## In Umgebungsvariablem mitaufnehmen
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $oldPath + ";C:\Program Files\OpenSSL-Win64\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")
## KOntrolle e der Systemvariablen
rundll32 sysdm.cpl,EditEnvironmentVariables

## Powershellkonsole

## Zertifikat für nginx
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
## CMD Konsole
cd \certs
openssl pkcs12 -in cert.pfx -nocerts -out cert.key -nodes

## Eingabe Kennwort...
openssl pkcs12 -in cert.pfx -clcerts -nokeys -out cert.crt

## nginx conf anpassen ########
cd C:\nginx-1.29.4\conf
notepad nginx.conf

## Alles mit folgendem ersetzen
worker_processes auto;

events {
worker_connections 1024;
}

http {

upstream ollama {
server localhost:11434;
}

server {
listen 11435 ssl;
server_name localhost;

ssl_certificate C:\certs\cert.crt;
ssl_certificate_key C:\certs\cert.key;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers HIGH:!aNULL:!MD5;

location / {
proxy_pass http://localhost:11434;
proxy_http_version 1.1;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header Origin '';
proxy_set_header Referer '';
}
}
}
####################################


## hosts datei anpassen
cd C:\Windows\System32\drivers\etc
notepad hosts
## Eintrag:  127.0.0.1 localhost

## OLLAMA
Set-Location -Path "C:\"
ollama pull nomic-embed-text
ollama serve

##  NGINX starten
C:\nginx-1.29.4
start nginx

##TEST
Invoke-WebRequest -Uri "https://localhost:11435/api/embed" -ContentType "application/json" -Method POST -Body '{ "model":"nomic-embed-text", "prompt":"test text"}'
## hier muss StatusCode 200 kommen


##############################

## JETZT SQL 2025 mit ollama verbinden
AI_Setup.sql













## Falls Fehler

$env:OLLAMA_HOST="127.0.0.1:11434"
ollama pull nomic-embed-text


## Nginx starten
cd C:\nginx-1.29.4
start nginx

Invoke-WebRequest -Uri "https://localhost:11435/api/embed" -ContentType "application/json" -Method POST -Body '{ "model":"nomic-embed-text", "prompt":"test text"}'

$env:OLLAMA_HOST="127.0.0.1"
ollama serve

# Beendet die App und den Server-Dienst
Stop-Process -Name "ollama*" -Force -ErrorAction SilentlyContinue

Get-NetTCPConnection -LocalPort 11435 -ErrorAction SilentlyContinue
$env:OLLAMA_HOST="localhost:11435"
ollama pull nomic-embed-text

Invoke-RestMethod -Uri "https://127.0.0.1:11435/api/tags"
Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags"

$env:OLLAMA_HOST="127.0.0.1:11434"
ollama pull nomic-embed-text