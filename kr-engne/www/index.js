import * as wasm from "kr-engne";

const canvas = document.getElementById("canvas");

const ctx = canvas.getContext('2d');
ctx.webkitImageSmoothingEnabled = false;
ctx.mozImageSmoothingEnabled = false;
ctx.imageSmoothingEnabled = false;
const universum = wasm.Universum.new(640, 400);

universum.init_defaults();

const renderLoop = () => {
    universum.tick();
    requestAnimationFrame(renderLoop);
};

requestAnimationFrame(renderLoop);
