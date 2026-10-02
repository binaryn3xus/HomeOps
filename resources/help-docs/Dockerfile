# Build MkDocs static site
FROM squidfunk/mkdocs-material:latest AS build
WORKDIR /app
COPY mkdocs.yml .
COPY docs/ docs/
RUN mkdocs build --clean --site-dir site

# Serve with lightweight unprivileged Nginx
FROM nginxinc/nginx-unprivileged:alpine
COPY --from=build /app/site /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
