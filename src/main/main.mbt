///|
typealias @core.MatrixRain

///|
typealias @core.CharSet

// `run_async` 会创建一个新的协程，并在其中运行一个异步函数
///|
fn run_async(f : async () -> Unit) -> Unit = "%async.run"

// `suspend` 会中断当前协程的运行。
// `suspend` 会接受一个回调函数，并让这个回调函数来操作中断的协程
///|
async fn suspend[T, E : Error](
  // `f` 是负责操作中断的协程的回调函数
  // `f` 的第一个参数用于继续运行被中断的协程
  // `f` 的第二个参数用于取消被中断的协程。
  // 取消会被表示为在中断处抛出错误
  f : ((T) -> Unit, (E) -> Unit) -> Unit
) -> T!E = "%async.suspend"

///|
extern type JSTimer

///|
extern "js" fn js_set_timeout(f : () -> Unit, duration : Int) -> JSTimer =
  #| (f, duration) => setTimeout(f, duration)

///|
async fn sleep(duration : Int) -> Unit! {
  suspend!!(fn(resume_ok, _resume_err) {
    let _ = js_set_timeout(fn() { resume_ok(()) }, duration)

  })
}

///|
fn main {
  let rain = MatrixRain::new()
  rain.charRange = Emoji
  rain.run()
  run_async(fn() {
    try {
      while true {
        rain.render_frame()
        sleep!!(33)
      }
    } catch {
      _ => {
        rain.stop()
        panic()
      }
    }
  })
}
