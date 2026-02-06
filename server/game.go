package main

import (
	"math"
	"math/rand"
	"sync/atomic"
)

const (
	canvasWidth  = 800.0
	canvasHeight = 600.0
	playerRadius = 20.0
	playerSpeed  = 200.0
	bulletRadius = 5.0
	bulletSpeed  = 400.0
	bulletDamage = 25
	maxHealth    = 100
)

// Direction represents facing direction
type Direction string

const (
	Up    Direction = "Up"
	Down  Direction = "Down"
	Left  Direction = "Left"
	Right Direction = "Right"
)

// Player represents a player in the game
type Player struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	X         float64   `json:"x"`
	Y         float64   `json:"y"`
	VX        float64   `json:"vx"`
	VY        float64   `json:"vy"`
	Radius    float64   `json:"radius"`
	Speed     float64   `json:"speed"`
	Health    int       `json:"health"`
	MaxHealth int       `json:"maxHealth"`
	Facing    Direction `json:"facing"`
	Color     string    `json:"color"`
}

// Bullet represents a bullet in the game
type Bullet struct {
	ID      string  `json:"id"`
	OwnerID string  `json:"ownerId"`
	X       float64 `json:"x"`
	Y       float64 `json:"y"`
	VX      float64 `json:"vx"`
	VY      float64 `json:"vy"`
	Radius  float64 `json:"radius"`
	Damage  int     `json:"damage"`
	Alive   bool    `json:"alive"`
}

// GameState holds all game state
type GameState struct {
	Players       map[string]*Player `json:"players"`
	Bullets       []*Bullet          `json:"bullets"`
	bulletCounter atomic.Int64
}

// NewGameState creates a new game state
func NewGameState() *GameState {
	return &GameState{
		Players: make(map[string]*Player),
		Bullets: make([]*Bullet, 0),
	}
}

// AddPlayer adds a new player to the game
func (g *GameState) AddPlayer(id, username string) *Player {
	colors := []string{"#3498db", "#e74c3c", "#2ecc71", "#9b59b6", "#f39c12", "#1abc9c"}
	color := colors[rand.Intn(len(colors))]

	player := &Player{
		ID:        id,
		Username:  username,
		X:         rand.Float64()*(canvasWidth-100) + 50,
		Y:         rand.Float64()*(canvasHeight-100) + 50,
		VX:        0,
		VY:        0,
		Radius:    playerRadius,
		Speed:     playerSpeed,
		Health:    maxHealth,
		MaxHealth: maxHealth,
		Facing:    Right,
		Color:     color,
	}
	g.Players[id] = player
	return player
}

// RemovePlayer removes a player from the game
func (g *GameState) RemovePlayer(id string) {
	delete(g.Players, id)
}

// HandleInput handles player input
func (g *GameState) HandleInput(playerID string, data map[string]any) {
	player, ok := g.Players[playerID]
	if !ok {
		return
	}

	moveLeft, _ := data["left"].(bool)
	moveRight, _ := data["right"].(bool)
	moveUp, _ := data["up"].(bool)
	moveDown, _ := data["down"].(bool)

	player.VX = 0
	player.VY = 0

	if moveLeft {
		player.VX = -player.Speed
		player.Facing = Left
	}
	if moveRight {
		player.VX = player.Speed
		player.Facing = Right
	}
	if moveUp {
		player.VY = -player.Speed
		player.Facing = Up
	}
	if moveDown {
		player.VY = player.Speed
		player.Facing = Down
	}
}

// PlayerShoot creates a new bullet from the player
func (g *GameState) PlayerShoot(playerID string) {
	player, ok := g.Players[playerID]
	if !ok || player.Health <= 0 {
		return
	}

	var vx, vy float64
	switch player.Facing {
	case Up:
		vy = -bulletSpeed
	case Down:
		vy = bulletSpeed
	case Left:
		vx = -bulletSpeed
	case Right:
		vx = bulletSpeed
	}

	bulletID := player.ID + "_" + string(rune(g.bulletCounter.Add(1)))
	bullet := &Bullet{
		ID:      bulletID,
		OwnerID: player.ID,
		X:       player.X,
		Y:       player.Y,
		VX:      vx,
		VY:      vy,
		Radius:  bulletRadius,
		Damage:  bulletDamage,
		Alive:   true,
	}
	g.Bullets = append(g.Bullets, bullet)
}

// Update updates the game state
func (g *GameState) Update(delta float64) {
	// Update player positions
	for _, player := range g.Players {
		if player.Health <= 0 {
			continue
		}
		player.X += player.VX * delta
		player.Y += player.VY * delta

		// Clamp to bounds
		if player.X < player.Radius {
			player.X = player.Radius
		}
		if player.X > canvasWidth-player.Radius {
			player.X = canvasWidth - player.Radius
		}
		if player.Y < player.Radius {
			player.Y = player.Radius
		}
		if player.Y > canvasHeight-player.Radius {
			player.Y = canvasHeight - player.Radius
		}
	}

	// Update bullets
	for _, bullet := range g.Bullets {
		if !bullet.Alive {
			continue
		}
		bullet.X += bullet.VX * delta
		bullet.Y += bullet.VY * delta

		// Check bounds
		if bullet.X < -bullet.Radius || bullet.X > canvasWidth+bullet.Radius ||
			bullet.Y < -bullet.Radius || bullet.Y > canvasHeight+bullet.Radius {
			bullet.Alive = false
		}
	}

	// Check bullet-player collisions
	for _, bullet := range g.Bullets {
		if !bullet.Alive {
			continue
		}
		for _, player := range g.Players {
			if player.ID == bullet.OwnerID || player.Health <= 0 {
				continue
			}
			if circlesCollide(bullet.X, bullet.Y, bullet.Radius, player.X, player.Y, player.Radius) {
				bullet.Alive = false
				player.Health -= bullet.Damage
				if player.Health < 0 {
					player.Health = 0
				}
			}
		}
	}

	// Remove dead bullets
	aliveBullets := make([]*Bullet, 0, len(g.Bullets))
	for _, bullet := range g.Bullets {
		if bullet.Alive {
			aliveBullets = append(aliveBullets, bullet)
		}
	}
	g.Bullets = aliveBullets
}

// GetState returns the current game state for broadcasting
func (g *GameState) GetState() map[string]any {
	return map[string]any{
		"players": g.Players,
		"bullets": g.Bullets,
	}
}

// circlesCollide checks if two circles are colliding
func circlesCollide(x1, y1, r1, x2, y2, r2 float64) bool {
	dx := x2 - x1
	dy := y2 - y1
	distSq := dx*dx + dy*dy
	radiusSum := r1 + r2
	return distSq < radiusSum*radiusSum
}

// distance calculates distance between two points
func distance(x1, y1, x2, y2 float64) float64 {
	dx := x2 - x1
	dy := y2 - y1
	return math.Sqrt(dx*dx + dy*dy)
}
