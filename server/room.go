package main

import (
	"encoding/json"
	"log"
	"math/rand"
	"sync"
	"time"
)

// Room manages all connected clients and game state
type Room struct {
	clients    map[*Client]bool
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
	game       *GameState
	mu         sync.RWMutex
}

// NewRoom creates a new room
func NewRoom() *Room {
	return &Room{
		clients:    make(map[*Client]bool),
		broadcast:  make(chan []byte, 256),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		game:       NewGameState(),
	}
}

// Run starts the room's main loop
func (r *Room) Run() {
	// Start the game loop
	go r.gameLoop()

	for {
		select {
		case client := <-r.register:
			r.mu.Lock()
			r.clients[client] = true
			// Add player to game
			r.game.AddPlayer(client.id, client.username)
			r.mu.Unlock()

			// Send init message to the new client
			initMsg := Message{
				Type: "init",
				Data: map[string]any{
					"playerId": client.id,
					"username": client.username,
				},
			}
			data, _ := json.Marshal(initMsg)
			client.send <- data

			log.Printf("Player %s (%s) joined", client.username, client.id)

		case client := <-r.unregister:
			if _, ok := r.clients[client]; ok {
				r.mu.Lock()
				delete(r.clients, client)
				r.game.RemovePlayer(client.id)
				r.mu.Unlock()
				close(client.send)
				log.Printf("Player %s (%s) left", client.username, client.id)
			}

		case message := <-r.broadcast:
			r.mu.RLock()
			for client := range r.clients {
				select {
				case client.send <- message:
				default:
					close(client.send)
					delete(r.clients, client)
				}
			}
			r.mu.RUnlock()
		}
	}
}

// gameLoop runs the server-side game simulation
func (r *Room) gameLoop() {
	ticker := time.NewTicker(time.Millisecond * 16)          // ~60 FPS
	broadcastTicker := time.NewTicker(time.Millisecond * 50) // 20 Hz state broadcast
	defer ticker.Stop()
	defer broadcastTicker.Stop()

	lastTime := time.Now()

	for {
		select {
		case <-ticker.C:
			now := time.Now()
			delta := now.Sub(lastTime).Seconds()
			lastTime = now

			r.mu.Lock()
			r.game.Update(delta)
			r.mu.Unlock()

		case <-broadcastTicker.C:
			r.mu.RLock()
			state := r.game.GetState()
			r.mu.RUnlock()

			msg := Message{
				Type: "state",
				Data: state,
			}
			data, _ := json.Marshal(msg)
			r.broadcast <- data
		}
	}
}

// HandleMessage processes a message from a client
func (r *Room) HandleMessage(client *Client, msg Message) {
	switch msg.Type {
	case "input":
		if data, ok := msg.Data.(map[string]any); ok {
			r.mu.Lock()
			r.game.HandleInput(client.id, data)
			r.mu.Unlock()
		}
	case "shoot":
		r.mu.Lock()
		r.game.PlayerShoot(client.id)
		r.mu.Unlock()
	}
}

// generateUsername creates a random username
func generateUsername() string {
	adjectives := []string{"Swift", "Brave", "Silent", "Cosmic", "Shadow", "Thunder", "Frost", "Fire", "Storm", "Night"}
	nouns := []string{"Wolf", "Eagle", "Tiger", "Dragon", "Phoenix", "Hawk", "Bear", "Lion", "Viper", "Raven"}
	return adjectives[rand.Intn(len(adjectives))] + nouns[rand.Intn(len(nouns))]
}
