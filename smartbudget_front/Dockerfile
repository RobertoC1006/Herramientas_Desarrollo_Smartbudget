# Etapa 1: Compilación de Flutter Web
FROM debian:bullseye-slim AS build-env

# Instalar dependencias para Flutter
RUN apt-get update && apt-get install -y curl git wget unzip xz-utils libglu1-mesa

# Descargar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Cambiar a canal stable y descargar herramientas
RUN flutter doctor
RUN flutter channel stable
RUN flutter upgrade

# Copiar el proyecto frontend
WORKDIR /app
COPY . .

# Obtener dependencias y compilar para Web
RUN flutter pub get
RUN flutter build web

# Etapa 2: Servir con Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
