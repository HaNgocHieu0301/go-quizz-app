package main

import (
	"log"
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/proxy"
)

func main() {
	pocketbaseURL := os.Getenv("POCKETBASE_URL")
	if pocketbaseURL == "" {
		pocketbaseURL = "http://127.0.0.1:8090"
	}

	app := fiber.New()
	app.Use(logger.New())

	// Default proxy for all API routes with auto-expand cards
	app.Use("/api/*", func(c *fiber.Ctx) error {
		// Check if expand parameter already exists
		expand := c.Query("expand")
		if expand == "" {
			expand = "cards(collection)"
		} else if !strings.Contains(expand, "cards(collection)") {
			expand += ",cards(collection)"
		}

		// Build the URL with the expand parameter
		targetURL := pocketbaseURL + c.OriginalURL()
		if strings.Contains(targetURL, "?") {
			if c.Query("expand") == "" {
				targetURL += "&expand=" + expand
			} else {
				// Replace the existing expand parameter
				targetURL = strings.Replace(targetURL, "expand="+c.Query("expand"), "expand="+expand, 1)
			}
		} else {
			targetURL += "?expand=" + expand
		}

		log.Println("Forwarding request to:", targetURL)
		return proxy.Do(c, targetURL)
	})

	log.Println("Go proxy server is running on port 8081")
	log.Println("Request to /api/* will be forwarded to PocketBase server at", pocketbaseURL)

	log.Fatal(app.Listen(":8081"))

}
