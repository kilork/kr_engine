mod graph;
mod obj_lib;
mod sprite;
mod utils;
mod vga;

use graph::{BLUE, GREEN, LIGHT_GRAY, WHITE, YELLOW};
use rand::{prelude::*, rngs::OsRng};
use sprite::Sprite;
use std::{convert::TryInto, mem};
use vga::PALETTE;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::{CanvasRenderingContext2d, ImageData};

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

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
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
    context: CanvasRenderingContext2d,
    rng: OsRng,
    scene: Vec<Sprite>,
    sun: usize,
    sun_x0: i32,
    sun_y0: i32,
    pub num_of_covered_clouds: usize,
    light_on: bool,
    ovca_l: usize,
    ovca_r: usize,
    ovca_dance_l: usize,
    ovca_dance_r: usize,
    images: Vec<Vec<u8>>,
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
            num_of_covered_clouds: 0,
            light_on: false,
            sun: 0,
            sun_x0: 0,
            sun_y0: 0,
            width,
            height,
            context,
            rng: OsRng::default(),
            scene: vec![],
            images: vec![],
            ovca_dance_l: 0,
            ovca_dance_r: 0,
            ovca_l: 0,
            ovca_r: 0,
        }
    }

    pub(crate) fn now() -> f64 {
        web_sys::window()
            .expect("should have a Window")
            .performance()
            .expect("should have a Performance")
            .now()
    }

    fn random(&mut self, high: i32) -> i32 {
        self.rng.gen_range(0, high)
    }

    /// Add default objects to scene
    pub fn init_defaults(&mut self) {
        // ground
        self.create_plane(0, 100, 639, 399, WHITE, GREEN, 32764, 1);
        // sky
        self.create_plane(0, 0, 639, 99, BLUE, BLUE, 32767, 1);
        // sun
        let nscene = self.create_circle(-20, 40, 20, 20, BLUE, YELLOW, 32766);
        self.scene[nscene].x = 50;

        // clouds
        for _ in 0..10 {
            let i = self.rng.gen_range(15, 40);
            let cloud_color = self.random(256) as u8;
            let z = self.random(5);
            let nscene = self.create_cloud(-(i << 3), 30, i, i, LIGHT_GRAY, cloud_color, 32766 - z);
            self.scene[nscene].x = self.random(640);
        }

        // logo

        self.create_tpt(2, 335, 0, 0, 0, 0, 0);

        // ovca

        self.ovca_l = self.add_tpt(include_bytes!("../img/OVCA.TPT"));
        self.ovca_r = self.add_tpt_mirror(self.ovca_l);
        self.ovca_dance_l = self.add_tpt(include_bytes!("../img/OVCA_DAN.TPT"));
        self.ovca_dance_r = self.add_tpt_mirror(self.ovca_dance_l);

        for i in 0..8 {
            let ovca_x = 10 + self.random(240);
            self.create_ovca(ovca_x, 100 + ((i + 1) << 4), 32700 + 30 - i);
        }

        self.render_scene();
    }

    pub fn tick(&mut self) {
        let new_time = Self::now();

        let mut need_to_redraw = false;

        for nscene in 0..self.scene.len() {
            let sprite = &self.scene[nscene];
            let mut t = sprite.phase;
            if sprite.ph_time[t] < new_time - sprite.old_time {
                t += 1;
                if t == sprite.ph_time.len() || sprite.ph_time[t] == 0.0 {
                    t = 0;
                }

                (sprite.set_phase)(self, nscene, t);

                let sprite = &mut self.scene[nscene];
                sprite.phase = t;
                sprite.old_time = new_time;
                need_to_redraw = true;
            }
        }

        if need_to_redraw {
            self.context
                .clear_rect(0.0, 0.0, self.width.into(), self.height.into());

            self.render_scene();
        }
    }

    fn render_scene(&mut self) {
        let mut zbuffer: Vec<_> = self
            .scene
            .iter()
            .enumerate()
            .map(|(i, s)| (i, s.z))
            .collect();
        zbuffer.sort_by(|a, b| a.1.cmp(&b.1).reverse());

        for sprite in zbuffer.iter().map(|&(i, _)| &self.scene[i]) {
            (sprite.drawme)(self, sprite);
        }
    }

    pub(crate) fn add_tpt(&mut self, image_buffer: &[u8]) -> usize {
        let mut data = vec![0; 64 * 64 * 4];
        for (i, &pixel) in image_buffer.iter().enumerate() {
            let image_index = i * 4;
            if pixel == 0 {
                data[image_index] = 0;
                data[image_index + 1] = 0;
                data[image_index + 2] = 0;
                data[image_index + 3] = 0;
                continue;
            }
            let palette_index = (pixel as usize) * 3;
            data[image_index] = PALETTE[palette_index];
            data[image_index + 1] = PALETTE[palette_index + 1];
            data[image_index + 2] = PALETTE[palette_index + 2];
            data[image_index + 3] = 255;
        }
        let ntpt = self.images.len();

        self.images.push(data);
        ntpt
    }

    pub(crate) fn add_tpt_mirror(&mut self, original: usize) -> usize {
        let original = &self.images[original];
        let mut data = vec![0; 64 * 64 * 4];
        for j in 0..64 {
            for i in 0..64 {
                let index: usize = (j * 64 + i) << 2;
                let original_index = (j * 64 + 63 - i) << 2;
                data[index] = original[original_index];
                data[index + 1] = original[original_index + 1];
                data[index + 2] = original[original_index + 2];
                data[index + 3] = original[original_index + 3];
            }
        }
        let ntpt = self.images.len();

        self.images.push(data);
        ntpt
    }
}
