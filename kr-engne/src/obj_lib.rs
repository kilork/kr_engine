use crate::{log, sprite::Sprite, vga::PALETTE, Universum};

use rand::Rng;
use std::f64;
use wasm_bindgen::prelude::*;
use wasm_bindgen::{Clamped, JsCast};
use web_sys::ImageData;

#[wasm_bindgen]
impl Universum {
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

    fn set_phase_plane(&mut self, _nscene: usize, _phase: usize) {}

    fn drawme_plane(&self, sprite: &Sprite) {
        let &Sprite { x, y, dx, dy, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        self.context.set_fill_style(&fill_color_rgb.into());
        self.context.set_stroke_style(&stroke_color_rgb.into());

        self.fill_rect(x, y, dx - x, dy - y);
        self.stroke_rect(x, y, dx - x, dy - y);
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
            ph_time: vec![33.3, 0.0],
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
            let Sprite {
                ref mut x,
                y,
                extend,
                ..
            } = &mut sprite;
            *x += 1;
            if *x > extend[3] {
                *x = extend[2];
            }
            self.sun_x0 = *x;
            self.sun_y0 = *y;
        }
    }

    fn drawme_circle(&self, sprite: &Sprite) {
        let &Sprite { x, y, dx, dy, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        let context = &self.context;
        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());

        self.fill_ellipse(x, y, dx, dy);
        context.stroke();
    }

    pub fn create_cloud(
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
            ph_time: vec![(1 + dx0 + self.random(10)).into(), 0.0],
            set_phase: Self::set_phase_cloud,
            drawme: Self::drawme_cloud,
            inme: None,
            extend: vec![color2 as i32, color as i32, x0, y0, 639 + dx0, 0],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_cloud(&mut self, nscene: usize, _phase: usize) {
        let sun_x = self.scene[self.sun].x;
        let sun_dx = self.scene[self.sun].dx;
        let mut sprite = &mut self.scene[nscene];
        let Sprite { x, dx, extend, .. } = &mut sprite;
        *x += 2;
        if *x > extend[4] {
            *x = extend[2];
        }
        if (*x + *dx - sun_x).abs() < (*dx * 3 / 2 + sun_dx) {
            if extend[5] == 0 {
                extend[5] = 1;
                self.num_of_covered_clouds += 1;
                self.light_on = true;
            }
        } else if extend[5] == 1 {
            self.num_of_covered_clouds -= 1;
            if self.num_of_covered_clouds == 0 {
                self.light_on = false;
            }
            extend[5] = 0;
        }
    }

    fn drawme_cloud(&self, sprite: &Sprite) {
        let &Sprite { x, y, dx, dy, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        let context = &self.context;
        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());

        self.fill_rect(x, y, dx << 1, dy);
        self.stroke_rect(x, y, dx << 1, dy);

        self.fill_ellipse(x + dx, y, dx, dy >> 1);
        self.fill_ellipse(x, y + (dy >> 1), dx >> 1, dy >> 1);
        self.fill_ellipse(x + (dx << 1), y + (dy >> 1), dx >> 1, dy >> 1);

        self.stroke_arc(x + dx, y, 180.0, 360.0, dx, dy >> 1);
        self.stroke_arc(x, y + (dy >> 1), 90.0, 300.0, dx >> 1, dy >> 1);
        self.stroke_arc(x + (dx << 1), y + (dy >> 1), 240.0, 90.0, dx >> 1, dy >> 1);
    }

    pub fn create_tpt(
        &mut self,
        x0: i32,
        y0: i32,
        dx0: i32,
        dy0: i32,
        color: u8,
        color2: u8,
        z0: i32,
    ) -> usize {
        let ntpt = self.add_tpt(include_bytes!("../img/LOGO2.TPT"));

        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: 64,
            dy: 64,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![1000.0, 0.0],
            set_phase: Self::set_phase_tpt,
            drawme: Self::drawme_tpt,
            inme: None,
            extend: vec![color2 as i32, color as i32, 0, ntpt as i32],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_tpt(&mut self, nscene: usize, _phase: usize) {
        let mut sprite = &mut self.scene[nscene];
        let Sprite { x, .. } = &mut sprite;
        *x += 1;
        if *x > 640 {
            *x = -64;
        }
    }

    fn drawme_tpt(&self, sprite: &Sprite) {
        let &Sprite {
            x,
            y,
            dx,
            dy,
            ref extend,
            ..
        } = sprite;

        self.draw_tpt(x, y, dx, dy, extend[3] as usize);
    }

    pub fn create_ovca(&mut self, x0: i32, y0: i32, z0: i32) -> usize {
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: 64,
            dy: 64,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![self.rng.gen_range(250.0, 500.0)],
            set_phase: Self::set_phase_ovca,
            drawme: Self::drawme_ovca,
            inme: None,
            extend: vec![self.random(2)],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_ovca(&mut self, nscene: usize, _phase: usize) {
        let shift = self.random(3);
        let mut sprite = &mut self.scene[nscene];
        let Sprite {
            x, ref mut extend, ..
        } = &mut sprite;
        match (self.light_on, extend[0]) {
            (false, 0) => {
                *x -= shift;
                if *x < 10 {
                    extend[0] = 1;
                }
            }
            (false, _) => {
                *x += shift;
                if *x > 400 {
                    extend[0] = 0;
                }
            }
            (true, 0) => {
                extend[0] = 1;
            }
            (true, _) => {
                extend[0] = 0;
            }
        }
    }

    fn drawme_ovca(&self, sprite: &Sprite) {
        let &Sprite {
            x,
            y,
            dx,
            dy,
            ref extend,
            ..
        } = sprite;

        let tpt = match (self.light_on, extend[0]) {
            (false, 0) => self.ovca_l,
            (false, _) => self.ovca_r,
            (true, 0) => self.ovca_dance_l,
            (true, _) => self.ovca_dance_r,
        };
        self.draw_tpt(x, y, dx, dy, tpt);
    }

    pub fn create_oblakov(&mut self, x0: i32, y0: i32, z0: i32) -> usize {
        let tpt = self.add_tpt(include_bytes!("../img/OBLAKOV.TPT"));
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: 64,
            dy: 64,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![50.0, 0.0],
            set_phase: Self::set_phase_oblakov,
            drawme: Self::drawme_oblakov,
            inme: None,
            extend: vec![self.random(2), tpt as i32],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_oblakov(&mut self, nscene: usize, _phase: usize) {
        let mut sprite = &mut self.scene[nscene];
        let Sprite {
            x, ref mut extend, ..
        } = &mut sprite;
        if extend[0] == 0 {
            *x -= 1;
            if *x < 50 {
                extend[0] = 1;
            }
        } else {
            *x += 1;
            if *x > 200 {
                extend[0] = 0;
            }
        }
    }

    fn drawme_oblakov(&self, sprite: &Sprite) {
        let &Sprite {
            x,
            y,
            dx,
            dy,
            ref extend,
            ..
        } = sprite;

        self.draw_tpt(x, y, dx, dy, extend[1] as usize);
    }
}
