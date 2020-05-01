use crate::{log, sprite::Sprite, vga::PALETTE, Universum};

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
            ph_time: vec![(1 + self.random(5)).into(), 0.0],
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
        let mut data = vec![0; 64 * 64 * 4];
        let image_buffer = include_bytes!("../img/LOGO2.TPT");
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

        let context = &self.context;

        let image_data = context
            .get_image_data(x.into(), y.into(), dx.into(), dy.into())
            .unwrap();
        let data = image_data.data();
        let sprite_data = &self.images[extend[3] as usize];
        let mut new_data = sprite_data.to_vec();
        for (i, w) in new_data.chunks_mut(4).enumerate() {
            if w[3] != 0 {
                continue;
            }
            let index = i * 4;
            w[0] = data[index];
            w[1] = data[index + 1];
            w[2] = data[index + 2];
            w[3] = data[index + 3];
        }
        context
            .put_image_data(
                &ImageData::new_with_u8_clamped_array_and_sh(
                    Clamped(&mut new_data),
                    dx as u32,
                    dy as u32,
                )
                .unwrap(),
                sprite.x.into(),
                sprite.y.into(),
            )
            .unwrap();
    }
}
