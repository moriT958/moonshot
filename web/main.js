
// ゲームモジュールの読み込み確認
const validateGameModule = () => {
  if (typeof game_init !== 'function') {
    throw new Error('Game module not loaded');
  }
};

// ステータス表示の更新
const updateStatus = (message) => {
  document.getElementById('status').textContent = message;
};

// キーボードイベントの設定
const setupKeyboardControls = () => {
  document.addEventListener('keydown', (e) => {
    if (['h', 'j', 'k', 'l', ' '].includes(e.key)) {
      e.preventDefault();
    }
    on_key_press(e.key);
  });
  document.addEventListener('keyup', (e) => {
    on_key_release(e.key);
  });
};

// ゲームループの作成・開始
const createGameLoop = () => {
  let lastTime = performance.now();
  const gameLoop = (currentTime) => {
    const delta = (currentTime - lastTime) / 1000.0;
    lastTime = currentTime;
    update(delta);
    requestAnimationFrame(gameLoop);
  };
  requestAnimationFrame(gameLoop);
};

// ゲーム開始
const startGame = () => {
  try {
    validateGameModule();
    game_init();
    setupKeyboardControls();
    updateStatus('Game running! Use h/j/k/l to move.');
    createGameLoop();
  } catch (error) {
    console.error('Failed to start game:', error);
    updateStatus('Error starting game: ' + error.message);
  }
};

window.addEventListener('load', startGame);
