# Matrix Rain Effect

A terminal-based implementation of the iconic "Matrix Rain" effect in MoonBit.

## Overview

This project recreates the famous falling green code from "The Matrix" in your terminal using ANSI escape codes.

![Matrix Rain Effect](matrix_rain.gif)

**Note: Only supported by JS backend.**

## Usage

To run the Matrix Rain effect:

```
moon run src/main --target=js
```

Press `Ctrl+C` to exit.

## Implementation Details

### ANSI Control Characters

The implementation heavily relies on ANSI escape sequences to control terminal output:

- **Color Control**: `\u001b[<color_code>m` sequences set text colors
- **Cursor Positioning**: `\u001b[<row>;<col>H` moves cursor to specific positions
- **Screen Control**: Commands for clearing screen, hiding cursor, etc.

### Core Components

The codebase is organized into four main modules:

1. **ansi.mbt**: Defines constants and functions for ANSI terminal control
2. **colors.mbt**: Implements foreground/background color functions
3. **matrix.mbt**: Contains the main Matrix Rain animation logic
4. **main.mbt**: Entry point with the animation loop

### ANSI Control Implementation

The `ansi.mbt` module provides constants for terminal control:

```mbt
const CtlEsc = "\u001b["           // ANSI escape sequence prefix
const ClearScreen = "\u001b[2J"    // Clear entire screen
const CursorHome = "\u001b[H"      // Move cursor to home position
const CursorInvisible = "\u001b[?25l" // Hide cursor
```

Cursor positioning is implemented with:

```mbt
pub fn cursorPos(row: Int, col: Int) -> String {
  "\{CtlEsc}\{row};\{col}H"
}
```

### Color Management

The `colors.mbt` module handles text colors:

- Standard ANSI colors (Black, Red, Green, etc.)
- RGB color support with 24-bit color sequences

```mbt
pub fn fgRgb(r: Int, g: Int, b: Int) -> String {
  "\u001b[38;2;\{r};\{g};\{b}m"
}
```

### Matrix Rain Algorithm

The core algorithm in `matrix.mbt` follows these principles:

1. **Initialization**: Create a `MatrixRain` structure with configuration
2. **Character Generation**: Randomly generate characters from selected character sets (ASCII, Katakana, Emoji, etc.)
3. **Droplet Creation**: Create "droplets" that fall down the screen
4. **Frame Rendering**: Update and render each droplet in every animation frame

#### Droplet Structure

Each droplet contains:
- Position (`col`, `curRow`)
- Speed and lifespan (`speed`, `alive`)
- Visual properties (`height`, `chars`)

```mbt
struct Droplet {
  col: Int               // Column position
  mut alive: Int         // Tracks droplet lifetime
  mut curRow: Int        // Current row position
  height: Int            // Length of the droplet
  speed: Int             // Movement speed (frames per step)
  chars: String          // Characters displayed in the droplet
}
```

#### Rendering Process

The `render_frame` function creates the illusion of falling characters:

1. Iterate through all column droplets
2. For each droplet:
   - Draw the leading character in white
   - Draw trailing characters in the selected color
   - Erase characters at the tail end
   - Increment the droplet position
3. Reset droplets that have moved off-screen

### JavaScript FFI

The implementation uses JavaScript FFI to interact with the terminal:

```mbt
extern "js" fn print(str: String) -> Unit =
  #| (str) => process.stdout.write(str)

extern "js" fn process_rows() -> Int =
  #| () => process.stdout.rows

extern "js" fn process_cols() -> Int =
  #| () => process.stdout.columns
```

These functions allow:
- Direct output to stdout
- Detecting terminal dimensions for responsive animation

### Animation Control

The `MatrixRain` class provides run/stop methods:

```mbt
pub fn MatrixRain::run(self: MatrixRain) -> Unit {
  self.write(UseAltBuffer)     // Use alternate screen buffer
  self.write(CursorInvisible)  // Hide cursor
  self.write(BgBlack)          // Set background color
  self.write(ClearScreen)      // Clear the screen
  self.flush()
  self.resize(process_cols(), process_rows())
}

pub fn MatrixRain::stop(self: MatrixRain) -> Unit {
  self.write(CursorVisible)    // Show cursor
  self.write(ClearScreen)      // Clear screen
  self.write(CursorHome)       // Reset cursor position
  self.write(UseNormalBuffer)  // Return to normal screen buffer
  self.flush()
}
```

### Async Animation Loop

The main animation loop uses MoonBit's async features to control timing:

```mbt
fn main {
  let rain = MatrixRain::new()
  rain.run()
  run_async(fn() {
    try {
      while(true) {
        rain.render_frame()
        sleep!!(5)  // Wait 5ms between frames
      }
    } catch {
      _ => {
        rain.stop()
        panic()
      }
    }
  })
}
```

Key async components:
- `run_async`: Creates a new coroutine for the animation
- `sleep`: Suspends execution for a specified duration
- `suspend`: Controls coroutine execution

## Reference
[matrix-rain](https://github.com/nojvek/matrix-rain)