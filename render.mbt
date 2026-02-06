// Canvas 2D rendering via JavaScript FFI

// External type for Canvas 2D context
type CanvasContext

// Get canvas context from DOM
pub extern "js" fn get_context(canvas_id : String) -> CanvasContext =
  #| (id) => document.getElementById(id).getContext('2d')

// Clear canvas
pub extern "js" fn clear_canvas(
  ctx : CanvasContext,
  width : Double,
  height : Double
) -> Unit =
  #| (ctx, w, h) => ctx.clearRect(0, 0, w, h)

// Set fill color
pub extern "js" fn set_fill_color(ctx : CanvasContext, color : String) -> Unit =
  #| (ctx, c) => { ctx.fillStyle = c; }

// Set stroke color
pub extern "js" fn set_stroke_color(ctx : CanvasContext, color : String) -> Unit =
  #| (ctx, c) => { ctx.strokeStyle = c; }

// Set line width
pub extern "js" fn set_line_width(ctx : CanvasContext, width : Double) -> Unit =
  #| (ctx, w) => { ctx.lineWidth = w; }

// Fill a circle
pub extern "js" fn fill_circle(
  ctx : CanvasContext,
  x : Double,
  y : Double,
  radius : Double
) -> Unit =
  #| (ctx, x, y, r) => { ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI * 2); ctx.fill(); }

// Stroke a circle (outline only)
pub extern "js" fn stroke_circle(
  ctx : CanvasContext,
  x : Double,
  y : Double,
  radius : Double
) -> Unit =
  #| (ctx, x, y, r) => { ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI * 2); ctx.stroke(); }

// Fill a rectangle
pub extern "js" fn fill_rect(
  ctx : CanvasContext,
  x : Double,
  y : Double,
  width : Double,
  height : Double
) -> Unit =
  #| (ctx, x, y, w, h) => ctx.fillRect(x, y, w, h)

// Set font
pub extern "js" fn set_font(ctx : CanvasContext, font : String) -> Unit =
  #| (ctx, f) => { ctx.font = f; }

// Set text alignment
pub extern "js" fn set_text_align(ctx : CanvasContext, align : String) -> Unit =
  #| (ctx, a) => { ctx.textAlign = a; }

// Fill text
pub extern "js" fn fill_text(
  ctx : CanvasContext,
  text : String,
  x : Double,
  y : Double
) -> Unit =
  #| (ctx, t, x, y) => ctx.fillText(t, x, y)

// Draw a health bar
pub fn draw_health_bar(
  ctx : CanvasContext,
  x : Double,
  y : Double,
  width : Double,
  health : Int,
  max_health : Int
) -> Unit {
  let health_pct = health.to_double() / max_health.to_double()
  let bar_height = 6.0

  // Background (red)
  set_fill_color(ctx, "#FF0000")
  fill_rect(ctx, x - width / 2.0, y - 30.0, width, bar_height)

  // Foreground (green)
  set_fill_color(ctx, "#00FF00")
  fill_rect(ctx, x - width / 2.0, y - 30.0, width * health_pct, bar_height)
}
