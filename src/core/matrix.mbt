///|
typealias @random.Rand

///|
extern "js" fn print(str : String) -> Unit =
  #| (str) => process.stdout.write(str)

///|
extern "js" fn process_rows() -> Int =
  #| () => process.stdout.rows

///|
extern "js" fn process_cols() -> Int =
  #| () => process.stdout.columns

///|
pub(all) enum Direction {
  Horizontal
  Vertical
}

///|
pub(all) enum Color {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  RGB(Int, Int, Int)
}

///|
pub(all) enum CharSet {
  Ascii
  Braille
  Katakana
  Emoji
  File(String)
}

///|
pub(all) struct MatrixRain {
  direction : Direction
  color : Color
  mut charRange : CharSet
  maxSpeed : Int
  mut columns : Int
  mut rows : Int
  rand : Rand
  colDroplets : Array[Array[Droplet]]
  buffer : Array[String]
}

///|
struct Droplet {
  col : Int
  mut alive : Int
  mut curRow : Int
  height : Int
  speed : Int
  chars : Array[String]
}

///|
pub fn MatrixRain::new() -> MatrixRain {
  {
    direction: Vertical,
    color: Green,
    charRange: Ascii,
    maxSpeed: 10,
    columns: process_cols(),
    rows: process_rows(),
    rand: @random.new(),
    colDroplets: [],
    buffer: [],
  }
}

///|
pub fn MatrixRain::generateChars(self : MatrixRain, len : Int) -> Array[String] {
  let (start, end) = match self.charRange {
    Ascii => (33, 126)
    Braille => (0x2840, 0x28FF)
    Katakana => (0x30A0, 0x30FF)
    Emoji => (0x1F600, 0x1F64F)
    _ => (0, 0)
  }
  let chars = []
  for i in 0..<len {
    let char = self.rand.int(limit=end - start) + start
    if char < 0x10000 {
      chars.push(Char::from_int(char).to_string())
    } else {
      // let adjusted = char - 0x10000
      // let high = 0xD800 + (adjusted >> 10)
      // let low = 0xDC00 + (adjusted & 0x3FF)
      // chars.push(Char::from_int(high))
      // chars.push(Char::from_int(low))
      chars.push(Char::from_int(char).to_string())
    }
  }
  chars
}

///|
test "generateChars" {
  let rain = MatrixRain::new()
  rain.charRange = Emoji
  let str = rain.generateChars(10)
  println(str)
}

///|
pub fn MatrixRain::make_droplet(self : MatrixRain, col : Int) -> Droplet {
  {
    col,
    alive: 0,
    curRow: self.rand.int(limit=self.rows),
    height: self.rand.int(limit=self.rows / 2),
    speed: 1 + self.rand.int(limit=self.maxSpeed - 1),
    chars: self.generateChars(self.rows),
  }
}

///|
pub fn MatrixRain::resize(self : MatrixRain, col : Int, row : Int) -> Unit {
  self.columns = col
  self.rows = row
  match self.direction {
    Horizontal => {
      self.columns = row
      self.rows = col
    }
    _ => ()
  }
  if self.columns > self.colDroplets.length() {
    for i in self.colDroplets.length()..<self.columns {
      self.colDroplets.push([self.make_droplet(i), self.make_droplet(i)])
    }
  } else {
    let _ = self.colDroplets.drain(self.columns, self.colDroplets.length())

  }
}

///|
pub fn MatrixRain::write_at(
  self : MatrixRain,
  row : Int,
  col : Int,
  str : String,
  color : String
) -> Unit {
  // println("\{row} \{self.rows} \{col} \{self.columns}")
  if row >= 0 && row < self.rows && col >= 0 && col < self.columns {
    let pos = match self.direction {
      Horizontal => cursorPos(col, row)
      Vertical => cursorPos(row, col)
    }
    self.write("\{pos}\{color}\{str}")
  }
}

///|
test {
  let pos = cursorPos(30, 50)
  let color = FgRed
  let str = "Hello, World!"
  println("\{pos}\{color}\{str}")
}

///|
pub fn Color::to_int(self : Color) -> Int {
  match self {
    Black => 30
    Red => 31
    Green => 32
    Yellow => 33
    Blue => 34
    Magenta => 35
    Cyan => 36
    White => 37
    _ => abort("Invalid color")
  }
}

///|
pub fn MatrixRain::render_frame(self : MatrixRain) -> Unit {
  let color = match self.color {
    Black => FgBlack
    Red => FgRed
    Green => FgGreen
    Yellow => FgYellow
    Blue => FgBlue
    Magenta => FgMagenta
    Cyan => FgCyan
    White => FgWhite
    RGB(r, g, b) => fgRgb(r, g, b)
  }
  let last_color = match self.color {
    RGB(r, g, b) => FgWhite
    c => output_color(c.to_int() + 60)
  }
  for i in 0..<self.colDroplets.length() {
    let droplets = self.colDroplets[i]
    for j in 0..<droplets.length() {
      let droplet = droplets[j]
      droplet.alive += 1
      let curRow = droplet.curRow
      let curCol = droplet.col
      let height = droplet.height
      let charsLen = droplet.chars.length()
      if droplet.alive % droplet.speed == 0 {
        // 避免在最后一行绘制，防止终端滚动
        if curRow - 1 >= 0 &&
          curRow - 1 < self.rows - 1 &&
          curRow - 1 < charsLen {
          self.write_at(
            curRow - 1,
            curCol,
            droplet.chars[curRow - 1].to_string(),
            color,
          )
        }

        // 避免在最后一行绘制
        if curRow >= 0 && curRow < self.rows - 1 && curRow < charsLen {
          self.write_at(
            curRow,
            curCol,
            droplet.chars[curRow].to_string(),
            FgWhite,
          )
        }
        if curRow - height >= 0 && curRow - height < self.rows {
          self.write_at(curRow - height, curCol, " ", "")
        }
        droplet.curRow += 1
      }

      // 当雨滴头部离开屏幕时重置
      if droplet.curRow - droplet.height > self.rows {
        let new_droplet = self.make_droplet(droplet.col)
        new_droplet.curRow = 0
        self.colDroplets[i][j] = new_droplet
      }
    }
  }
  self.flush()
}

///|
fn MatrixRain::write(self : MatrixRain, str : String) -> Unit {
  self.buffer.push(str)
}

///|
fn MatrixRain::flush(self : MatrixRain) -> Unit {
  if self.buffer.length() > 0 {
    let str = self.buffer.join("")
    print(str)
    self.buffer.clear()
  }
}

///|
test "flush" {
  let rain = MatrixRain::new()
  rain.resize(process_cols(), process_rows())
  rain.run()
  for i in 0..<100 {
    rain.render_frame()
  }
  rain.stop()
}

///|
pub fn MatrixRain::run(self : MatrixRain) -> Unit {
  // println(process_cols())
  // println(process_rows())
  self.write(UseAltBuffer) // 使用备用缓冲区
  self.write(CursorInvisible) // 隐藏光标
  self.write(BgBlack) // 设置背景颜色为黑色
  self.write(FgBlack) // 设置前景颜色为黑色
  self.write(ClearScreen) // 清空屏幕
  self.flush()
  self.resize(process_cols(), process_rows())
}

///|
pub fn MatrixRain::stop(self : MatrixRain) -> Unit {
  self.write(CursorVisible)
  self.write(ClearScreen)
  self.write(CursorHome)
  self.write(UseNormalBuffer)
  self.flush()
}
