# VetTrack Frontend Web Hosting (Nginx)
FROM plugger/flutter:3.24.5 AS build
WORKDIR /app

# Flutter's String.fromEnvironment values are compile-time constants. Pass the
# public web configuration explicitly when building the image; do not copy the
# local .env file into Docker layers.
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG API_BASE_URL
ARG GOOGLE_WEB_CLIENT_ID

COPY . .
RUN flutter pub get
RUN test -n "$SUPABASE_URL" && test -n "$SUPABASE_ANON_KEY" && test -n "$API_BASE_URL"
RUN flutter build web --release \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    --dart-define=API_BASE_URL="$API_BASE_URL" \
    --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID"

FROM nginx:1.27-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
