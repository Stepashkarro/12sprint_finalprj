# сборка приложения
FROM golang:1.22-alpine AS builder

WORKDIR /app

# копируем файлы зависимостей
COPY go.mod go.sum ./
# скачиваем зависимости
RUN go mod download

# копируем весь исходный код
COPY . .

# собираем бинарный файл
# CGO_ENABLED=0 нужен, чтобы файл был статическим и работал в пустом алпин
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/tracker .

# делаем финальный образ для запуска 
FROM alpine:latest

WORKDIR /app

# копируем скомпилированный бинарник из самого начала
COPY --from=builder /app/tracker .

# копируем базу данных, а то приложение упадет
COPY tracker.db .

# запускаем
CMD ["./tracker"]