use crate::{log, sprite::Sprite, vga::PALETTE, Universum};

use std::f64;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;

#[wasm_bindgen]
impl Universum {
    fn rgb(&self, color_index: i32) -> String {
        let color = (color_index * 3) as usize;
        format!(
            "rgb({},{},{})",
            PALETTE[color],
            PALETTE[color + 1],
            PALETTE[color + 2]
        )
    }

    fn add_to_scene(&mut self, sprite: Sprite) -> usize {
        self.scene.push(sprite);
        self.scene.len() - 1
    }

    pub fn create_plane(
        &mut self,
        x0: i32,
        y0: i32,
        dx0: i32,
        dy0: i32,
        color: u8,
        color2: u8,
        z0: i32,
        fill: i32,
    ) -> usize {
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: dx0,
            dy: dy0,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![1000.0, 0.0],
            set_phase: Self::set_phase_plane,
            drawme: Self::drawme_plane,
            inme: None,
            extend: vec![color2 as i32, color as i32, fill],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_plane(&mut self, nscene: usize, phase: usize) {}

    fn drawme_plane(&self, sprite: &Sprite) {
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        self.context.set_fill_style(&fill_color_rgb.into());
        self.context.fill_rect(
            sprite.x.into(),
            sprite.y.into(),
            (sprite.dx - sprite.x).into(),
            (sprite.dy - sprite.y).into(),
        );
        let stroke_color_rgb = self.rgb(stroke_color);
        self.context.set_stroke_style(&stroke_color_rgb.into());
        self.context.stroke_rect(
            sprite.x.into(),
            sprite.y.into(),
            (sprite.dx - sprite.x).into(),
            (sprite.dy - sprite.y).into(),
        );
    }

    pub fn create_circle(
        &mut self,
        x0: i32,
        y0: i32,
        dx0: i32,
        dy0: i32,
        color: u8,
        color2: u8,
        z0: i32,
    ) -> usize {
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: dx0,
            dy: dy0,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![3.3, 0.0],
            set_phase: Self::set_phase_circle,
            drawme: Self::drawme_circle,
            inme: None,
            extend: vec![color2 as i32, color as i32, x0, 639 + dx0],
        };
        let circle_index = self.add_to_scene(sprite);

        self.sun = circle_index;
        self.sun_x0 = x0;
        self.sun_y0 = y0;

        circle_index
    }

    fn set_phase_circle(&mut self, nscene: usize, phase: usize) {
        if phase == 0 {
            let mut sprite = &mut self.scene[nscene];
            sprite.x += 1;
            if sprite.x > sprite.extend[3] {
                sprite.x = sprite.extend[2];
            }
            self.sun_x0 = sprite.x;
            self.sun_y0 = sprite.y;
        }
    }

    fn drawme_circle(&self, sprite: &Sprite) {
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);
        let context = &self.context;
        context.begin_path();
        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());
        context
            .ellipse(
                sprite.x.into(),
                sprite.y.into(),
                sprite.dx.into(),
                sprite.dy.into(),
                0.0,
                0.0,
                f64::consts::PI * 2.0,
            )
            .unwrap();
        context.fill();
        context.stroke();
    }
}
