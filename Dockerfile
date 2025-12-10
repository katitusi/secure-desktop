# Легкий Alpine образ с рабочим столом в браузере
FROM linuxserver/webtop:latest

LABEL maintainer="Vladimir Sadikov"
LABEL description="Lightweight secure desktop with VPN, Telegram and WhatsApp"

# Устанавливаем необходимые пакеты
# wireguard-tools - VPN
# telegram-desktop - официальный клиент Telegram
# chromium - для WhatsApp Web
# font-noto* - шрифты с поддержкой эмодзи и кириллицы
RUN apk add --no-cache \
    wireguard-tools \
    telegram-desktop \
    chromium \
    font-noto \
    font-noto-emoji \
    font-noto-cjk

# Создаём ярлык WhatsApp на рабочем столе
RUN mkdir -p /config/Desktop && \
    echo '[Desktop Entry]' > /config/Desktop/WhatsApp.desktop && \
    echo 'Version=1.0' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Type=Application' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Name=WhatsApp' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Comment=WhatsApp Web' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Exec=chromium --app=https://web.whatsapp.com --no-sandbox' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Icon=chromium' >> /config/Desktop/WhatsApp.desktop && \
    echo 'Terminal=false' >> /config/Desktop/WhatsApp.desktop && \
    echo 'StartupNotify=false' >> /config/Desktop/WhatsApp.desktop && \
    chmod +x /config/Desktop/WhatsApp.desktop

# Создаём ярлык Telegram на рабочем столе
RUN echo '[Desktop Entry]' > /config/Desktop/Telegram.desktop && \
    echo 'Version=1.0' >> /config/Desktop/Telegram.desktop && \
    echo 'Type=Application' >> /config/Desktop/Telegram.desktop && \
    echo 'Name=Telegram' >> /config/Desktop/Telegram.desktop && \
    echo 'Comment=Telegram Desktop' >> /config/Desktop/Telegram.desktop && \
    echo 'Exec=telegram-desktop' >> /config/Desktop/Telegram.desktop && \
    echo 'Icon=telegram' >> /config/Desktop/Telegram.desktop && \
    echo 'Terminal=false' >> /config/Desktop/Telegram.desktop && \
    echo 'StartupNotify=false' >> /config/Desktop/Telegram.desktop && \
    chmod +x /config/Desktop/Telegram.desktop

# Скрипт для автозапуска VPN (если конфиг есть)
RUN mkdir -p /custom-cont-init.d && \
    echo '#!/bin/sh' > /custom-cont-init.d/99-start-vpn && \
    echo 'if [ -f /etc/wireguard/wg0.conf ]; then' >> /custom-cont-init.d/99-start-vpn && \
    echo '    echo "Starting WireGuard VPN..."' >> /custom-cont-init.d/99-start-vpn && \
    echo '    wg-quick up wg0' >> /custom-cont-init.d/99-start-vpn && \
    echo 'fi' >> /custom-cont-init.d/99-start-vpn && \
    chmod +x /custom-cont-init.d/99-start-vpn

EXPOSE 3000 3001
