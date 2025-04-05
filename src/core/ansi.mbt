///|
const CtlEsc = "\u001b["

// ansi
///|
const Reset = "\u001b[c"

///|
const ClearScreen = "\u001b[2J"

///|
const CursorHome = "\u001b[H"

///|
pub fn cursorPos(row : Int, col : Int) -> String {
  "\{CtlEsc}\{row};\{col}H"
}

///|
const CursorVisible = "\u001b[?25h"

///|
const CursorInvisible = "\u001b[?25l"

///|
const UseAltBuffer = "\u001b[?47h"

///|
const UseNormalBuffer = "\u001b[?47l"

///|
const Underline = "\u001b[4m"

///|
const Off = "\u001b[0m"

///|
const Bold = "\u001b[1m"

///|
pub fn output_color(c : Int) -> String {
  "\{CtlEsc}\{c};1m"
}
