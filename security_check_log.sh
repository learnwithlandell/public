#!/bin/bash
# Linux Härdningsrapport med logg till CSV
# Kräver Lynis (apt install lynis)

CSV_FILE="security_log.csv"

# Skapa CSV-fil med rubriker om den inte finns
if [ ! -f "$CSV_FILE" ]; then
    echo "Datum,Lynis Score,Öppna portar,Antal uppdateringar,Sudo-användare,Aktiva tjänster" > "$CSV_FILE"
fi

# Hämta datum och tid
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# 1. Lynis Security Score med one-liner
SCORE=$(sudo lynis audit system --quick | awk '/Hardening index/{print $3}')
if [ -z "$SCORE" ]; then
    SCORE=0
fi

# 2. Antal öppna portar (LISTEN)
LISTEN_PORTS=$(ss -tuln | grep LISTEN | wc -l)

# 3. Tillgängliga säkerhetsuppdateringar
if command -v apt >/dev/null; then
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
else
    UPDATES=0
fi

# 4. Antal sudo-användare
SUDO_USERS=$(getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -v '^$' | wc -l)

# 5. Antal aktiva tjänster
ACTIVE_SERVICES=$(systemctl list-units --type=service --state=running | grep ".service" | wc -l)

# Skriv till CSV
echo "$DATE,$SCORE,$LISTEN_PORTS,$UPDATES,$SUDO_USERS,$ACTIVE_SERVICES" >> "$CSV_FILE"

# Visa rapport på skärmen
echo "==============================="
echo "  Linux Härdningsrapport"
echo "==============================="
echo "Datum: $DATE"
echo "Lynis Security Score: $SCORE"
echo "Öppna portar (LISTEN): $LISTEN_PORTS"
echo "Tillgängliga uppdateringar: $UPDATES"
echo "Sudo-användare: $SUDO_USERS"
echo "Aktiva tjänster: $ACTIVE_SERVICES"
echo "==============================="
echo "Rapport sparad i: $CSV_FILE"
