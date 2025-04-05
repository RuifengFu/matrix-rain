///|
pub fn fgRgb(r : Int, g : Int, b : Int) -> String {
  "\u001b[38;2;\{r};\{g};\{b}m"
}

///|
pub fn bgRgb(r : Int, g : Int, b : Int) -> String {
  "\u001b[48;2;\{r};\{g};\{b}m"
}

///|
const FgBlack = "\u001b[30;1m"

///|
const FgRed = "\u001b[31;1m"

///|
const FgGreen = "\u001b[32;1m"

///|
const FgYellow = "\u001b[33;1m"

///|
const FgBlue = "\u001b[34;1m"

///|
const FgMagenta = "\u001b[35;1m"

///|
const FgCyan = "\u001b[36;1m"

///|
const FgWhite = "\u001b[37;1m"

///|
const BgBlack = "\u001b[40;1m"

///|
const BgRed = "\u001b[41;1m"

///|
const BgGreen = "\u001b[42;1m"

///|
const BgYellow = "\u001b[43;1m"

///|
const BgBlue = "\u001b[44;1m"

///|
const BgMagenta = "\u001b[45;1m"

///|
const BgCyan = "\u001b[46;1m"

///|
const BgWhite = "\u001b[47;1m"
