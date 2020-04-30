use crate::{sprite::Sprite, Universum};

use std::f64;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;

impl Universum {
    pub fn create_plane(
        &mut self,
        x0: u32,
        y0: u32,
        dx0: u32,
        dy0: u32,
        color: u8,
        color2: u8,
        z0: u32,
        fill: u32,
    ) {
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: dx0,
            dy: dy0,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![18000, 0],
            set_phase: Self::set_phase_plane,
            drawme: Self::drawme_plane,
            inme: None,
            extend: vec![color2 as u32, color as u32, fill],
        };
    }

    fn set_phase_plane(&mut self, sprite: &Sprite, phase: u32) {}

    fn drawme_plane(&mut self, sprite: &Sprite, x0: u32, y0: u32, dx0: u32, dy0: u32) {
        unimplemented!()
    }
}
