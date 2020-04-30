mod graph;
mod obj_lib;
mod sprite;
mod utils;
mod vga;

use graph::{BLUE, GREEN, WHITE, YELLOW};
use rand::{prelude::*, rngs::OsRng};
use sprite::Sprite;
use std::convert::TryInto;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::CanvasRenderingContext2d;

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

struct ZSprite {
    i: usize,
    z: u16,
}

#[wasm_bindgen]
pub struct Universum {
    width: u32,
    height: u32,
    buffer: Vec<u8>,
    context: CanvasRenderingContext2d,
    rng: OsRng,
    scene: Vec<Sprite>,
    zscene: Vec<ZSprite>,
    nscene: usize,
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
    pub fn new(width: u32, height: u32) -> Self {
        utils::set_panic_hook();
        let buffer = vec![0; ((width * height) as usize) << 2];
        let document = web_sys::window().unwrap().document().unwrap();
        let canvas = document.get_element_by_id("canvas").unwrap();
        let canvas: web_sys::HtmlCanvasElement = canvas
            .dyn_into::<web_sys::HtmlCanvasElement>()
            .map_err(|_| ())
            .unwrap();

        let context = canvas
            .get_context("2d")
            .unwrap()
            .unwrap()
            .dyn_into::<web_sys::CanvasRenderingContext2d>()
            .unwrap();

        Self {
            width,
            height,
            buffer,
            context,
            rng: OsRng::default(),
            scene: vec![],
            zscene: vec![],
            nscene: 0,
        }
    }

    pub(crate) fn now() -> f64 {
        web_sys::window()
            .expect("should have a Window")
            .performance()
            .expect("should have a Performance")
            .now()
    }

    /// Add default objects to scene
    pub fn init_defaults(&mut self) {
        self.create_plane(0, 100, 639, 399, WHITE, GREEN, 32764, 1);
        self.create_plane(0, 0, 639, 99, BLUE, BLUE, 32767, 1);
        // self.create_circle(-20, 40, 20, 20, BLUE, YELLOW, 32766);
    }

    pub fn tick(&mut self) {
        for i in 0..200 {
            self.pixel(i, i, Color::new(0, 0, 0, 255));
        }
        let mut rng = OsRng::default();
        for _ in 0..10000 {
            let x: u32 = rng.gen_range(0, 640);
            let y: u32 = rng.gen_range(0, 480);
            self.pixel(x, y, Color::new(0, 0, 0, 255));
        }
        let side = 10;
        for k in 0..256 {
            let x = k % 16;
            let y = k / 16;
            for j in y * side..(y + 1) * side {
                for i in x * side..(x + 1) * side {
                    let c = k * 3 as usize;
                    self.pixel(
                        i as u32,
                        j as u32,
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

    fn pixel(&mut self, x: u32, y: u32, color: Color) {
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
