import * as wasm from "kr-engne";
import {
    memory
} from "kr-engne/kr_engne_bg";

const canvas = document.getElementById("canvas");

const ctx = canvas.getContext('2d');
/*
let rect = canvas.getBoundingClientRect();

const canvas_width = rect.width - 2;
const canvas_height = rect.height - 2;
// increase the actual size of our canvas
canvas.width = canvas_width * devicePixelRatio;
canvas.height = canvas_height * devicePixelRatio;

// ensure all drawing operations are scaled
ctx.scale(devicePixelRatio, devicePixelRatio);

// scale everything down using CSS
canvas.style.width = canvas_width + 'px';
canvas.style.height = canvas_height + 'px';

const width = canvas.width;
const height = canvas.height;
console.log(`canvas: ${width}:${height}`);
*/
const universum = wasm.Universum.new(640, 400);


// const memoryPtr = universum.buffer();
// const buffer = new Uint8ClampedArray(memory.buffer, memoryPtr, width * height * 4);
// const imageData = new ImageData(buffer, width, height);

universum.init_defaults();

const renderLoop = () => {
    universum.tick();
    ctx.fillStyle = 'white';
    ctx.fillText(universum.num_of_covered_clouds, 100, 100);
    requestAnimationFrame(renderLoop);
};

requestAnimationFrame(renderLoop);
