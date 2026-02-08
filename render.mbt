///|
/// ゲーム全体の描画

///|
// 2*PI
let two_pi : Double = 6.283185307179586

///|
fn get_context(canvas_id : String) -> @canvas.CanvasRenderingContext2D {
  let element = @dom.document().getElementById(canvas_id)
  match element {
    Some(el) => {
      let canvas : @dom.HTMLCanvasElement = @core.identity(el)
      let ctx_any = canvas.getContext("2d")
      @core.identity(ctx_any)
    }
    None => abort("Canvas element not found: " + canvas_id)
  }
}

///|
fn set_fill_color(
  ctx : @canvas.CanvasRenderingContext2D,
  color : String,
) -> Unit {
  ctx.fillStyle = color
}

///|
fn set_stroke_color(
  ctx : @canvas.CanvasRenderingContext2D,
  color : String,
) -> Unit {
  ctx.strokeStyle = color
}

///|
fn set_line_width(
  ctx : @canvas.CanvasRenderingContext2D,
  width : Double,
) -> Unit {
  ctx.lineWidth = width
}

///|
fn fill_circle(
  ctx : @canvas.CanvasRenderingContext2D,
  x : Double,
  y : Double,
  radius : Double,
) -> Unit {
  ctx.beginPath()
  ctx.arc(x, y, radius, 0.0, two_pi)
  ctx.fill()
}

///|
fn stroke_circle(
  ctx : @canvas.CanvasRenderingContext2D,
  x : Double,
  y : Double,
  radius : Double,
) -> Unit {
  ctx.beginPath()
  ctx.arc(x, y, radius, 0.0, two_pi)
  ctx.stroke()
}

///|
fn fill_rect(
  ctx : @canvas.CanvasRenderingContext2D,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  ctx.fillRect(x, y, width, height)
}

///|
fn set_font(ctx : @canvas.CanvasRenderingContext2D, font : String) -> Unit {
  ctx.font = font
}

///|
fn set_text_align(
  ctx : @canvas.CanvasRenderingContext2D,
  align : String,
) -> Unit {
  ctx.textAlign = align
}

///|
fn fill_text(
  ctx : @canvas.CanvasRenderingContext2D,
  text : String,
  x : Double,
  y : Double,
) -> Unit {
  ctx.fillText(text, x, y)
}

///|
fn draw_health_bar(
  ctx : @canvas.CanvasRenderingContext2D,
  x : Double,
  y : Double,
  width : Double,
  health : Int,
  max_health : Int,
) -> Unit {
  let health_pct = health.to_double() / max_health.to_double()
  let bar_height = 6.0

  // 背景を赤に
  set_fill_color(ctx, "#FF0000")
  fill_rect(ctx, x - width / 2.0, y - 30.0, width, bar_height)

  // 緑で上塗り
  set_fill_color(ctx, "#00FF00")
  fill_rect(ctx, x - width / 2.0, y - 30.0, width * health_pct, bar_height)
}

///|
/// ゲーム画面を描画
fn render_game(ctx : @canvas.CanvasRenderingContext2D) -> Unit {
  // 黒背景で初期化
  set_fill_color(ctx, "#1a1a2e")
  fill_rect(ctx, 0.0, 0.0, game.canvas_width, game.canvas_height)

  // 遠隔プレーヤーを描画
  for player in game.remote_players {
    if player.is_alive() {
      player.render(ctx)
    }
  }

  // ローカルプレーヤー(自分) を描画
  match game.local_player {
    Some(player) =>
      if player.is_alive() {
        // 自分は白のラインで囲んで表示
        set_stroke_color(ctx, "#FFFFFF")
        set_line_width(ctx, 3.0)
        stroke_circle(ctx, player.x, player.y, player.radius + 5.0)
        player.render(ctx)
      }
    None => ()
  }

  // 弾丸を描画
  for bullet in game.bullets {
    if bullet.alive {
      bullet.render(ctx)
    }
  }

  // ゲームのステータスを描画
  render_status(ctx)
}

///|
/// ゲームのステータス (接続状況、プレーヤー数など)
fn render_status(ctx : @canvas.CanvasRenderingContext2D) -> Unit {
  set_fill_color(ctx, "#888888")
  set_font(ctx, "14px Arial")
  set_text_align(ctx, "left")
  fill_text(ctx, "Controls: h/j/k/l to move, space to shoot", 10.0, 20.0)

  // Connection status
  let status = if game.connected {
    "Online: " + game.local_username
  } else {
    "Connecting..."
  }
  fill_text(ctx, status, 10.0, 40.0)

  // 生存プレイヤー数の表示
  let mut player_count = 0
  for player in game.remote_players {
    if player.is_alive() {
      player_count = player_count + 1
    }
  }
  match game.local_player {
    Some(p) => if p.is_alive() { player_count = player_count + 1 }
    None => ()
  }
  fill_text(ctx, "Players: " + player_count.to_string(), 10.0, 60.0)
}
