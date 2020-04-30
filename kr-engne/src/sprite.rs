use crate::Universum;

pub struct Sprite {
    pub x: u32,
    pub y: u32,
    pub z: u32,
    pub dx: u32,
    pub dy: u32,
    pub phase: u32,
    pub old_time: f64,
    pub ph_time: Vec<u32>,
    pub set_phase: fn(&mut Universum, &Sprite, u32),
    pub drawme: fn(&mut Universum, &Sprite, u32, u32, u32, u32),
    pub inme: Option<fn(&mut Universum, u32, u32) -> bool>,
    pub extend: Vec<u32>,
}
