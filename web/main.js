// Moonshot - Game loop (Moonbit code is loaded separately)

function startGame() {
  const statusEl = document.getElementById('status');

  try {
    // Check if game functions are available (loaded from moonbit.js)
    if (typeof game_init !== 'function') {
      throw new Error('Game module not loaded');
    }

    // Initialize the game
    game_init();

    // Set up keyboard event listeners
    document.addEventListener('keydown', (e) => {
      // Prevent default for game keys
      if (['h', 'j', 'k', 'l', ' '].includes(e.key)) {
        e.preventDefault();
      }
      on_key_down(e.keyCode);
    });

    document.addEventListener('keyup', (e) => {
      on_key_up(e.keyCode);
    });

    statusEl.textContent = 'Game running! Use h/j/k/l to move.';

    // Start the game loop
    let lastTime = performance.now();

    function gameLoop(currentTime) {
      const delta = (currentTime - lastTime) / 1000.0; // Convert to seconds
      lastTime = currentTime;

      update(delta);

      requestAnimationFrame(gameLoop);
    }

    requestAnimationFrame(gameLoop);

  } catch (error) {
    console.error('Failed to start game:', error);
    statusEl.textContent = 'Error starting game: ' + error.message;
  }
}

// Start the game when the page loads
window.addEventListener('load', startGame);
