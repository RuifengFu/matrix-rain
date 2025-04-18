///|
typealias @core.MatrixRain

///|
typealias @core.CharSet

typealias @core.Color

typealias @core.Direction

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

fn main {
  let args = get_opts(@sys.get_cli_args())
  println("args : \{args}")
  let usage = get_usage()
  let help_flag = @ref.new(false)
  let transpose_flag = @ref.new(false)
  let color_ref = @ref.new("green")
  let char_flag = @ref.new(false)
  @ArgParser.parse(
    [
      ("-h", "--help", Set(help_flag), "Show this help message"),
      ("-t", "--transpose", Set(transpose_flag), "Transpose the matrix"),
      ("-C", "--color", Set_string(color_ref), "Set the color of the rain"),
    ],
    fn { anything => println("warning: ignoring unknown option: " + anything) },
    usage,
    args,
  )
  if args.contains("-h") || args.contains("--help") {
    return
  }
  println("flags \{help_flag.val} \{transpose_flag.val} \{color_ref.val} \{char_flag.val}")
  let rain = MatrixRain::{
    direction: if transpose_flag.val { Direction::Horizontal } else { Direction::Vertical },
    color:  match color_ref.val {
              "green" => Color::Green
              "red" => Color::Red
              "blue" => Color::Blue
              "yellow" => Color::Yellow
              "magenta" => Color::Magenta
              "cyan" => Color::Cyan
              "white" => Color::White
              _ => {
                println("warning: ignoring unknown color: " + color_ref.val)
                Color::Green
              }
            },
    charRange: CharSet::Ascii,
    maxSpeed: 10,
    columns: 24,
    rows: 80,
    rand: @random.new(),
    colDroplets: [],
    buffer: [],    
  }
  rain.run()
  run_async(fn() {
    try {
      while true {
        rain.render_frame()
        sleep!!(16)
      }
    } catch {
      _ => {
        rain.stop()
        panic()
      }
    }
  })
  return 
}

fn get_usage() -> String {
  #| matrix-rain - Print a matrix rain effect
  #| usage: matrix-rain [options]
  #| options:
  #|   -h, --help       Show this help message
  #|   -t, --transpose  Transpose the matrix
  #|   -s, --speed      Set the speed of the rain 
  #|   -C, --color      Set the color of the rain 
  #|                    (green, red, blue, yellow, magenta, cyan, white)
}

fn get_opts(args: Array[String]) -> Array[String] {
  let list = @queue.new()
  for arg in args[2:] {
    if arg.starts_with("-") && arg.length() > 2 && not(arg.starts_with("--")) {
      for i = 1; i < arg.length(); i = i + 1 {
        list.push("-" + arg[i].to_string())
      }
    } else {
      list.push(arg)
    }
  }

  return list.iter().collect()
}

