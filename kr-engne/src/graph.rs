use crate::{vga::PALETTE, Universum};

pub(crate) const BLUE: u8 = 1;
pub(crate) const GREEN: u8 = 2;
pub(crate) const LIGHT_GRAY: u8 = 7;
pub(crate) const WHITE: u8 = 15;
pub(crate) const YELLOW: u8 = 14;

impl Universum {
    pub(crate) fn rgb(&self, color_index: i32) -> String {
        let color = (color_index * 3) as usize;
        format!(
            "rgb({},{},{})",
            PALETTE[color],
            PALETTE[color + 1],
            PALETTE[color + 2]
        )
    }

    pub(crate) fn ellipse(&self, x: i32, y: i32, dx: i32, dy: i32) {
        let context = &self.context;
        context.begin_path();
        context
            .ellipse(
                x.into(),
                y.into(),
                dx.into(),
                dy.into(),
                0.0,
                0.0,
                std::f64::consts::PI * 2.0,
            )
            .unwrap();
    }

    pub(crate) fn arc(&self, x: i32, y: i32, start: f64, end: f64, dx: i32, dy: i32) {
        let context = &self.context;
        context.begin_path();
        context
            .ellipse(
                x.into(),
                y.into(),
                dx.into(),
                dy.into(),
                0.0,
                start * std::f64::consts::PI / 180.0,
                end * std::f64::consts::PI / 180.0,
            )
            .unwrap();
    }

    pub(crate) fn stroke_arc(&self, x: i32, y: i32, start: f64, end: f64, dx: i32, dy: i32) {
        self.arc(x, y, start, end, dx, dy);
        self.context.stroke();
    }

    pub(crate) fn fill_ellipse(&self, x: i32, y: i32, dx: i32, dy: i32) {
        self.ellipse(x, y, dx, dy);
        self.context.fill();
    }

    pub(crate) fn fill_rect(&self, x: i32, y: i32, dx: i32, dy: i32) {
        self.context
            .fill_rect(x.into(), y.into(), dx.into(), dy.into());
    }

    pub(crate) fn stroke_rect(&self, x: i32, y: i32, dx: i32, dy: i32) {
        self.context
            .stroke_rect(x.into(), y.into(), dx.into(), dy.into());
    }
}
