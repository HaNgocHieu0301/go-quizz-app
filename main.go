package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/proxy"
)

func main() {
	pocketbaseURL := os.Getenv("POCKETBASE_URL")
	if pocketbaseURL == "" {
		log.Fatal("POCKETBASE_URL environment variable is not set")
	}

	app := fiber.New()
	app.Use(logger.New())
	app.Use("/api", proxy.Forward(pocketbaseURL))

	log.Println("Go proxy server is running on port 8081")
	log.Println("Request to /api/* will be forwarded to PocketBase server at", pocketbaseURL)

	log.Fatal(app.Listen(":8081"))

}
