mod utils;
mod vga;

use std::convert::TryInto;
use wasm_bindgen::prelude::*;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet() {
    alert("Hello, kr-engne!");
}

#[wasm_bindgen(js_namespace = console)]
extern "C" {
    pub fn log(s: &str);
}

#[wasm_bindgen]
pub struct Universum {
    width: u16,
    height: u16,
    buffer: Vec<u8>,
}

#[derive(Clone, Copy, Default)]
struct Color {
    red: u8,
    green: u8,
    blue: u8,
    alpha: u8,
}

impl Color {
    fn new(red: u8, green: u8, blue: u8, alpha: u8) -> Self {
        Self {
            red,
            green,
            blue,
            alpha,
        }
    }
}

#[wasm_bindgen]
impl Universum {
    pub fn new(width: u16, height: u16) -> Self {
        utils::set_panic_hook();
        let buffer = vec![0; ((width * height) as usize) << 2];
        Self {
            width,
            height,
            buffer,
        }
    }

    pub fn tick(&mut self) {
        for i in 0..200 {
            self.pixel(i, i, Color::new(0, 0, 0, 255));
        }
        let side = 10;
        for k in 0..256 {
            let x = k % 16;
            let y = k / 16;
            for j in y * side..(y + 1) * side {
                for i in x * side..(x + 1) * side {
                    let c = k * 3 as usize;
                    self.pixel(
                        i as u16,
                        j as u16,
                        Color::new(
                            vga::PALETTE[c],
                            vga::PALETTE[c + 1],
                            vga::PALETTE[c + 2],
                            255,
                        ),
                    );
                }
            }
        }
    }

    fn pixel(&mut self, x: u16, y: u16, color: Color) {
        let index = ((y * self.width + x) as usize) << 2;
        self.buffer[index] = color.red;
        self.buffer[index + 1] = color.green;
        self.buffer[index + 2] = color.blue;
        self.buffer[index + 3] = color.alpha;
    }

    pub fn buffer(&self) -> *const u8 {
        self.buffer.as_ptr()
    }
}
