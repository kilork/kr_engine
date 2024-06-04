use crate::{
    graph::{BLACK, BLUE, BROWN, LIGHT_BLUE, LIGHT_GRAY, RED},
    sprite::Sprite,
    Universum,
};

use rand::Rng;
use wasm_bindgen::prelude::*;

const GROUND_LEVEL: i32 = 340;

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
        _dx0: i32,
        _dy0: i32,
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
            ph_time: vec![self.rng.gen_range(250.0..500.0)],
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

    pub fn create_house(&mut self, x0: i32, y0: i32, z0: i32) -> usize {
        self.create_top(
            x0,
            y0,
            0,
            0,
            LIGHT_GRAY,
            BROWN,
            z0,
            x0 + 150,
            y0 - 150,
            x0 + 300,
            y0,
        );
        self.create_plane(x0 + 40, y0 - 70, x0 + 60, y0, RED, RED, z0 + 1, 1);
        self.create_plane(x0 + 30, y0 - 80, x0 + 70, y0 - 70, RED, RED, z0 + 1, 1);
        self.create_plane(x0 + 30, y0 + 1, x0 + 270, y0 + 150, BROWN, BROWN, z0 + 1, 1);
        self.create_plane(x0 + 20, y0 + 150, x0 + 280, y0 + 160, RED, RED, z0 + 1, 1);

        for _i in 0..50 {
            let nscene = self.create_fog(x0 + 55, y0 - 70, 0, 0, BLACK, LIGHT_GRAY, z0 + 2);
            self.scene[nscene].phase = self.random(255) as usize;
        }

        self.create_plane(
            x0 + 180,
            y0 + 40,
            x0 + 250,
            y0 + 140,
            RED,
            LIGHT_GRAY,
            z0 + 1,
            4,
        );

        self.create_plane(x0 + 50, y0 + 50, x0 + 150, y0 + 100, RED, 0, z0 + 1, 1);
        self.create_plane(
            x0 + 52,
            y0 + 52,
            x0 + 108,
            y0 + 98,
            RED,
            LIGHT_BLUE,
            z0 + 1,
            1,
        );
        self.create_plane(
            x0 + 110,
            y0 + 52,
            x0 + 148,
            y0 + 74,
            RED,
            LIGHT_BLUE,
            z0 + 1,
            1,
        );
        self.create_plane(x0 + 110, y0 + 76, x0 + 148, y0 + 98, RED, BLUE, z0 + 1, 1);
        self.scene.len() - 1
    }

    pub fn create_top(
        &mut self,
        x0: i32,
        y0: i32,
        dx0: i32,
        dy0: i32,
        color: u8,
        color2: u8,
        z0: i32,
        x1: i32,
        y1: i32,
        x2: i32,
        y2: i32,
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
            set_phase: Self::set_phase_top,
            drawme: Self::drawme_top,
            inme: None,
            extend: vec![color2 as i32, color as i32, x0, y0, x1, y1, x2, y2, 4],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_top(&mut self, _nscene: usize, _phase: usize) {}

    fn drawme_top(&self, sprite: &Sprite) {
        let Sprite { ref extend, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        let context = &self.context;

        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());

        context.begin_path();
        context.move_to(extend[2].into(), extend[3].into());
        context.line_to(extend[4].into(), extend[5].into());
        context.line_to(extend[6].into(), extend[7].into());
        context.fill();
        context.stroke();
    }

    pub fn create_fog(
        &mut self,
        x0: i32,
        y0: i32,
        dx0: i32,
        dy0: i32,
        color: u8,
        color2: u8,
        z0: i32,
    ) -> usize {
        let mut sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: dx0,
            dy: dy0,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![75.0; 256],
            set_phase: Self::set_phase_fog,
            drawme: Self::drawme_fog,
            inme: None,
            extend: vec![color2 as i32, color as i32, x0, y0],
        };
        sprite.ph_time[255] = 0.0;
        self.add_to_scene(sprite)
    }

    fn set_phase_fog(&mut self, nscene: usize, _phase: usize) {
        let r_3 = self.random(3);
        let r_2 = self.random(2);
        let r_10 = self.random(10);
        let r_8 = self.random(8);

        let mut sprite = &mut self.scene[nscene];
        let Sprite {
            x,
            y,
            dx,
            dy,
            ref mut extend,
            ..
        } = &mut sprite;
        *dx += r_3;
        *dy += r_2;
        if *dx > 20 {
            *dx = 15;
        }
        if *dy > 10 {
            *dy = 8;
        }
        *y -= r_10;
        *x += r_8 - 5;
        if *y + *dx < 0 {
            *dx = 1;
            *dy = 1;
            *x = extend[2];
            *y = extend[3];
        }
    }

    fn drawme_fog(&self, sprite: &Sprite) {
        let &Sprite { x, y, dx, dy, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        let context = &self.context;

        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());

        self.fill_ellipse(x, y, dx, dy);
    }

    pub fn create_light(&mut self, x0: i32, y0: i32, z0: i32) -> usize {
        let tpt = self.add_tpt(include_bytes!("../img/LIGHT2.TPT"));
        let sprite = Sprite {
            x: x0,
            y: y0,
            z: z0,
            dx: 64,
            dy: 64,
            phase: 0,
            old_time: Self::now(),
            ph_time: vec![50.0, 0.0],
            set_phase: Self::set_phase_light,
            drawme: Self::drawme_light,
            inme: None,
            extend: vec![self.random(2), tpt as i32],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_light(&mut self, _nscene: usize, _phase: usize) {}

    fn drawme_light(&self, sprite: &Sprite) {
        if !self.light_on {
            return;
        }

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

    pub fn create_sosulka(
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
            ph_time: vec![50.0, 50.0, 50.0, 0.0, 150.0, 150.0, 150.0, 0.0],
            set_phase: Self::set_phase_sosulka,
            drawme: Self::drawme_sosulka,
            inme: None,
            extend: vec![
                color2 as i32,
                color as i32,
                x0,
                y0,
                x0 + 5,
                y0 + 15,
                x0 + 10,
                y0,
                1,
            ],
        };
        self.sosulka = self.add_to_scene(sprite);
        self.kaplja = self.create_kaplja(x0 + 5, y0 + 15, 3, 3, BLUE, LIGHT_BLUE, z0);
        self.sosulka
    }

    fn set_phase_sosulka(&mut self, nscene: usize, _phase: usize) {
        let mut sprite = &mut self.scene[nscene];
        let Sprite {
            y, ref mut extend, ..
        } = &mut sprite;
        if self.kaplja_drop && self.is_sosulka {
            extend[5] -= 1;
            self.kaplja_drop = false;
            if extend[5] < *y {
                extend[5] = *y;
                self.is_sosulka = false;
            }
        } else if !self.is_sosulka {
            extend[5] += 1;
            if extend[5] > *y + 15 {
                extend[5] = *y + 15;
                self.is_sosulka = true;
                self.scene[self.kaplja].y = extend[5];
            }
        }
    }

    fn drawme_sosulka(&self, sprite: &Sprite) {
        Self::drawme_top(self, sprite);
        let &Sprite { y, ref extend, .. } = sprite;
        let fill_color = sprite.extend[0];
        let stroke_color = sprite.extend[1];
        let fill_color_rgb = self.rgb(fill_color);
        let stroke_color_rgb = self.rgb(stroke_color);

        let context = &self.context;

        context.set_fill_style(&fill_color_rgb.into());
        context.set_stroke_style(&stroke_color_rgb.into());

        self.fill_ellipse(170, 340, 150 - extend[5] + y, 20);
    }

    pub fn create_kaplja(
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
            ph_time: vec![25.0, 0.0],
            set_phase: Self::set_phase_kaplja,
            drawme: Self::drawme_kaplja,
            inme: None,
            extend: vec![color2 as i32, color as i32, 1, 3],
        };
        self.add_to_scene(sprite)
    }

    fn set_phase_kaplja(&mut self, nscene: usize, _phase: usize) {
        let sosulka_extend5 = self.scene[self.sosulka].extend[5];
        let mut sprite = &mut self.scene[nscene];
        let Sprite { y, .. } = &mut sprite;

        if self.is_sosulka || !self.kaplja_drop {
            *y += 5;
            if *y > GROUND_LEVEL {
                *y = sosulka_extend5;
                self.kaplja_drop = true;
            }
        }
    }

    fn drawme_kaplja(&self, sprite: &Sprite) {
        if !self.is_sosulka && self.kaplja_drop {
            return;
        }

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
}
