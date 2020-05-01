use crate::Universum;

pub struct Sprite {
    pub x: i32,
    pub y: i32,
    pub z: i32,
    pub dx: i32,
    pub dy: i32,
    pub phase: usize,
    pub old_time: f64,
    pub ph_time: Vec<f64>,
    pub set_phase: fn(&mut Universum, usize, usize),
    pub drawme: fn(&Universum, &Sprite),
    pub inme: Option<fn(&mut Universum, i32, i32) -> bool>,
    pub extend: Vec<i32>,
}
