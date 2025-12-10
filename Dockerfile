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

# Скрипт для создания ярлыков при запуске (volume перезаписывает /config)
RUN mkdir -p /custom-cont-init.d && \
    echo '#!/bin/bash' > /custom-cont-init.d/10-create-shortcuts && \
    echo 'mkdir -p /config/Desktop' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '# WhatsApp shortcut' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'cat > /config/Desktop/WhatsApp.desktop << EOF' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '[Desktop Entry]' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Version=1.0' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Type=Application' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Name=WhatsApp' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Comment=WhatsApp Web' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Exec=chromium --app=https://web.whatsapp.com --no-sandbox' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Icon=chromium' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Terminal=false' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'StartupNotify=false' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'EOF' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '# Telegram shortcut' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'cat > /config/Desktop/Telegram.desktop << EOF' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '[Desktop Entry]' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Version=1.0' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Type=Application' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Name=Telegram' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Comment=Telegram Desktop' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Exec=telegram-desktop' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Icon=telegram' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'Terminal=false' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'StartupNotify=false' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'EOF' >> /custom-cont-init.d/10-create-shortcuts && \
    echo '' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'chmod +x /config/Desktop/*.desktop' >> /custom-cont-init.d/10-create-shortcuts && \
    echo 'chown -R abc:abc /config/Desktop/' >> /custom-cont-init.d/10-create-shortcuts && \
    chmod +x /custom-cont-init.d/10-create-shortcuts

# Скрипт для автозапуска VPN (если конфиг есть)
RUN echo '#!/bin/bash' > /custom-cont-init.d/99-start-vpn && \
    echo 'if [ -f /etc/wireguard/wg0.conf ]; then' >> /custom-cont-init.d/99-start-vpn && \
    echo '    echo "Starting WireGuard VPN..."' >> /custom-cont-init.d/99-start-vpn && \
    echo '    wg-quick up wg0' >> /custom-cont-init.d/99-start-vpn && \
    echo 'fi' >> /custom-cont-init.d/99-start-vpn && \
    chmod +x /custom-cont-init.d/99-start-vpn

EXPOSE 3000 3001
