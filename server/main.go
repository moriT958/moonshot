package main

import (
	"log"
	"net/http"
)

func main() {
	room := NewRoom()
	go room.Run()

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		ServeWs(room, w, r)
	})

	log.Println("Server starting on :8080")
	log.Println("Open http://localhost:8080 in your browser")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
